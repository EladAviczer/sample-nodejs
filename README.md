# sample-nodejs — Production-Grade CI/CD on Kubernetes

> DevOps home assignment: a lightweight Node.js app wired into a production-grade pipeline — SAST, image scanning, ECR, ArgoCD GitOps, and EKS — built the way I'd actually do it on a real engagement.

---

## TL;DR

Fork a sample Node.js/Express app. Ship it with a fully automated CI/CD pipeline: parallel GitHub Actions jobs (SAST, lint, Trivy scan), keyless ECR push via OIDC, and GitOps delivery to EKS via ArgoCD. Every architectural decision is documented in an ADR. Every change goes through a PR. Every release is a semver git tag.

---

## What's Running

```
GET /my-app       → Hello, World!  (increments Prometheus counter)
GET /ready        → 200 OK         (readiness probe)
GET /live         → 200 OK         (liveness probe)
GET /metrics      → Prometheus scrape endpoint
```

Port: `8080` (override with `PORT` env var)

---

## Repo Map

```
refael/
├── app.js                      # Express app — single file, stateless
├── Dockerfile                  # Multi-stage: deps → hardened runtime (npm removed)
├── package.json
│
├── .github/workflows/
│   └── ci.yml                  # Full CI/CD pipeline (see Pipeline section)
│
├── helm/                       # Helm chart — Deployment, Service, Ingress, HPA, PDB
│   ├── Chart.yaml
│   ├── values.yaml             # Defaults; CI patches image.tag on release
│   └── templates/
│
├── argocd/
│   └── application.yaml        # ArgoCD Application CR — watches helm/, auto-syncs on merge
│
├── terraform/                  # AWS infra: ECR, GitHub OIDC provider, IAM role, EKS + node group
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── versions.tf
│
├── Taskfile.yml                # Local task runner (go-task) — mirrors CI steps exactly
│
└── .adlc/drafts/adr/           # Architecture Decision Records (ADR-001 → ADR-013)
```

---

## Pipeline

Three triggers, three behaviours:

| Trigger | Jobs | What it does |
|---|---|---|
| Pull Request | `sast` + `lint` + `build-and-scan` (parallel) | Gate: fail fast before merge |
| Push to `main` | Same 3 parallel jobs | Verify merged state |
| Push `v*` tag | `build-scan-push` → `update-image-tag` | Build, scan, push ECR, open deploy PR |

### PR Gate (3 parallel jobs, no `needs` between them)

```
sast ──────────────────────────────────────────┐
lint ──────────────────────────────────────────┤─── all must pass to merge
build-and-scan (build → trivy scan, no push) ──┘
```

**SAST** (`sast` job):
- `npm audit --audit-level=high` — SCA, blocks on any HIGH+
- `njsscan` — Node.js-specific SAST, blocks on any finding

**Lint** (`lint` job):
- `hadolint` — Dockerfile best-practice linter
- `helm lint --strict` — Helm chart validation

**Build & Scan** (`build-and-scan` job):
- `docker build --load` — build image into local daemon
- Trivy scan: `severity: HIGH,CRITICAL`, `ignore-unfixed: true`, SARIF output to GitHub Security tab

### Release Chain (sequential, tag-triggered)

```
build-scan-push
  └─ docker build → trivy (gate) → ECR push (OIDC, no long-lived keys)
       └─ update-image-tag
            └─ yq patch helm/values.yaml → open PR → ArgoCD auto-syncs on merge
```

No deploy reaches the cluster without a merged PR. That's intentional — human oversight on every release.

---

## GitOps Flow

```
git tag v1.2.0 && git push origin v1.2.0
        │
        ▼
GitHub Actions (build-scan-push)
  build image → trivy scan → push to ECR as :v1.2.0
        │
        ▼
GitHub Actions (update-image-tag)
  yq: helm/values.yaml image.tag = "v1.2.0"
  git commit → open PR "chore: deploy image v1.2.0"
        │
        ▼
Merge PR → ArgoCD detects helm/ change → auto-sync → EKS
```

ArgoCD Application (`argocd/application.yaml`) watches `helm/` on `main`, prunes removed resources, self-heals on drift, retries up to 3×.

---

## Infrastructure

Provisioned by Terraform (`terraform/`), applied once before first pipeline run:

| Resource | Details |
|---|---|
| ECR repository | `sample-nodejs`, scan-on-push, lifecycle: keep last 10 |
| GitHub OIDC provider | Keyless auth — no `AWS_SECRET_ACCESS_KEY` in secrets |
| IAM role | `github-actions-refael` — ECR push only, scoped to this repo |
| EKS cluster | `refael`, Kubernetes 1.31, `us-east-1` (AZs: a/b/c/d/f) |
| EKS node group | 2× t3.medium, ECR read-only via node IAM role |

```bash
# One-time setup
task tf:init
task tf:apply              # ~12 min — EKS cluster takes the longest
task aws:kubeconfig        # configure kubectl

# Register app with ArgoCD
task argocd:install        # install ArgoCD to cluster
task argocd:apply          # apply argocd/application.yaml
```

After `tf:apply`, grab the ECR URI and IAM role ARN:
```bash
terraform -chdir=terraform output ecr_repository_url
terraform -chdir=terraform output github_actions_role_arn
```

Set as GitHub Actions secrets:
- `AWS_ROLE_TO_ASSUME` → the IAM role ARN
- `ECR_REGISTRY` → the ECR registry URL (account.dkr.ecr.us-east-1.amazonaws.com)

---

## Helm Chart

Kubernetes objects deployed:

| Object | Notes |
|---|---|
| `Deployment` | 2 replicas, stateless, rolling update |
| `Service` | ClusterIP, port 80 → container 8080 |
| `Ingress` | nginx ingress class, host configurable |
| `ConfigMap` | `PORT` env var injected |
| `HorizontalPodAutoscaler` | optional, CPU-based |
| `PodDisruptionBudget` | `minAvailable: 1` |

Probes configured on `/ready` (readiness) and `/live` (liveness).

```bash
# Local dev with k3d
task k3d:up
task deploy:local          # builds + imports image into k3d, deploys via helm
```

---

## Local Dev

Install `go-task` once: `brew install go-task`

```bash
task lint          # hadolint + helm lint
task security      # npm audit + nodejsscan
task build         # docker build local
task scan          # trivy scan local image (gate: HIGH+)
task ci            # full chain: lint → security → build → scan → deploy:local
```

---

## Architecture Decision Records

Every non-obvious choice is documented. Here's the full set:

| ADR | Decision | Why |
|---|---|---|
| [ADR-001](/.adlc/drafts/adr/ADR-001.md) | Stateless Express monolith → `Deployment` | No shared state, no DB, no domain boundaries — `StatefulSet` would be wrong |
| [ADR-002](/.adlc/drafts/adr/ADR-002.md) | In-process `prom-client` for metrics | Simplest path to Prometheus scraping, matches existing code |
| [ADR-003](/.adlc/drafts/adr/ADR-003.md) | GitHub Actions as CI/CD engine | No external CI infra, AWS OIDC support, first-class Trivy/Semgrep actions |
| [ADR-004](/.adlc/drafts/adr/ADR-004.md) | AWS ECR as container registry | Keyless OIDC auth from GHA, IAM-native access control, same AWS account |
| [ADR-005](/.adlc/drafts/adr/ADR-005.md) | Same-repo GitOps (ArgoCD watches `helm/`) | Single-app solo project — separate gitops repo adds ops overhead for zero gain |
| [ADR-006](/.adlc/drafts/adr/ADR-006.md) | SAST: `njsscan` + `npm audit` | njsscan is Node.js-specific OWASP-listed; npm audit covers dependency CVEs separately |
| [ADR-007](/.adlc/drafts/adr/ADR-007.md) | Trivy: HIGH+, ignore-unfixed | Pragmatic gate — block what can actually be fixed today |
| [ADR-008](/.adlc/drafts/adr/ADR-008.md) | CI opens deploy PR (not direct push) | Every deploy is a reviewable git event; bad image = no PR, cluster stays on last good |
| [ADR-009](/.adlc/drafts/adr/ADR-009.md) | EKS (prod) + k3d (local) | nginx-ingress works identically on both — zero environment divergence |
| [ADR-010](/.adlc/drafts/adr/ADR-010.md) | Semver git tags trigger release pipeline | Human-readable, sortable; decouples release from every commit push |
| [ADR-011](/.adlc/drafts/adr/ADR-011.md) | Terraform for AWS infra | Reproducible, reviewable, idempotent — no click-ops |
| [ADR-012](/.adlc/drafts/adr/ADR-012.md) | Hadolint + helm lint in CI | Catch Dockerfile and chart issues before they reach image build |
| [ADR-013](/.adlc/drafts/adr/ADR-013.md) | Taskfile as local task runner | Single YAML, Go binary, mirrors CI step order exactly |

---

## Security Decisions

A few things I'd flag for a reviewer:

**No long-lived AWS credentials** — GitHub Actions authenticates via OIDC (`sts:AssumeRoleWithWebIdentity`). No `AWS_ACCESS_KEY_ID` or `AWS_SECRET_ACCESS_KEY` anywhere. The IAM role is scoped to this exact repo (`repo:OrenOren1/refael:*`).

**npm removed from runtime image** — `node:22-alpine` bundles npm, which bundles `glob@13` and `minimatch` with known CVEs. npm is not needed to run `node app.js`. Removing it entirely (`rm -rf /usr/local/lib/node_modules/npm`) eliminates the CVE surface without suppression. `apk upgrade --no-cache` patches OS-level packages at build time.

**Pipeline fails on fixable CVEs** — `ignore-unfixed: true` means Trivy only blocks on CVEs that have a fix available. We're not blocking on theoretical risk — we're blocking on "you can fix this today."

**Least-privilege CI permissions** — `permissions: contents: read` global default. Only `build-scan-push` elevates to `id-token: write` (for OIDC) and `contents: write` (for the deploy PR commit). PR jobs never get write access.

---

## For Reviewers

What to look at:

1. **[`Dockerfile`](./Dockerfile)** — multi-stage, hardened runtime. npm removed, not suppressed.
2. **[`.github/workflows/ci.yml`](./.github/workflows/ci.yml)** — DAG structure, concurrency groups, timeout-minutes, permission scoping.
3. **[`helm/`](./helm/)** — values.yaml has resource limits, PDB, probes. Chart is environment-agnostic.
4. **[`argocd/application.yaml`](./argocd/application.yaml)** — auto-sync, prune, self-heal, retry policy.
5. **[`terraform/main.tf`](./terraform/main.tf)** — ECR + OIDC + EKS in one file. Subnets filtered for EKS-compatible AZs.
6. **[`Taskfile.yml`](./Taskfile.yml)** — local CI parity. `task ci` runs the same chain as the pipeline.

Things intentionally left out:
- **No `.trivyignore`** — CVEs are fixed at the root, not suppressed
- **No direct push to `main` from CI** — every deploy is a PR
- **No `--no-verify` anywhere** — hooks run, always

---

## Quick Start

```bash
# 1. Clone and install
git clone https://github.com/OrenOren1/refael && cd refael
npm install

# 2. Run locally
node app.js
curl http://localhost:8080/my-app

# 3. Local K8s (needs go-task + docker + k3d)
task k3d:up
task deploy:local
curl http://localhost:8080/my-app

# 4. Trigger a release
git tag v1.0.0 && git push origin v1.0.0
# → pipeline builds, scans, pushes to ECR, opens deploy PR
```

---

## Tech Stack

`Node.js 22` · `Express` · `prom-client` · `Docker (Alpine)` · `Helm 3` · `ArgoCD` · `GitHub Actions` · `AWS ECR` · `AWS EKS` · `Terraform` · `Trivy` · `njsscan` · `Hadolint` · `go-task`
