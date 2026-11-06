# Sample Node.js App: CI/CD and DevSecOps

[![CI](https://github.com/asaf-refaeli/sample-nodejs/actions/workflows/ci.yml/badge.svg)](https://github.com/asaf-refaeli/sample-nodejs/actions/workflows/ci.yml)

A small Express app used as a deployment target. The focus is the infrastructure around it: a GitHub Actions pipeline with security gates, a Helm chart, and GitOps deployment with Argo CD.

## Pipeline

```
 test ─┐
       ├─► build ─► integration test ─► Trivy scan ─► push to ECR* ─┐
 sast ─┘                                                            ├─► update GitOps repo*
 helm ──────────────────────────────────────────────────────────────┘
```
`*` planned: runs only on merge to `main`.

| Job | Tool | Fails when |
|---|---|---|
| `test` | Jest + Supertest | Any unit test fails |
| `sast` | Semgrep | Any finding with severity `ERROR` in the code |
| `helm` | chart-testing (`ct lint`), kubeconform | Chart lint error, chart changed without a version bump, or a rendered resource doesn't match the Kubernetes schema |
| `build` | Docker | Image doesn't build |
| `build` → integration test | `scripts/integration-test.sh` | Image doesn't start read-only as a non-root user, or any endpoint fails |
| `build` → Trivy | Trivy | Any `HIGH` or `CRITICAL` vulnerability in the image (fixed or not) |

- Runs on every pull request to `main` and on every push to `main`.
- Semgrep and Trivy findings are also uploaded to the GitHub Security tab.
- Third-party actions are pinned by commit SHA and tool images by digest; Dependabot keeps the actions up to date.

## Repository layout

```
.
├── app.js                      # The app
├── app.test.js                 # Unit tests
├── Dockerfile                  # Multi-stage build
├── scripts/
│   └── integration-test.sh     # Container integration test
├── chart/                      # Helm chart
│   └── ci/                     # Values files for the chart checks
├── .github/
│   ├── workflows/ci.yml        # The pipeline
│   └── dependabot.yml          # Keeps pinned actions up to date
└── docs/adr/                   # Architecture decision records
```

## Decisions

| ADR | Decision |
|---|---|
| [0001](docs/adr/0001-git-workflow.md) | Git workflow: GitHub Flow |
| [0002](docs/adr/0002-ci-platform.md) | CI platform: GitHub Actions |
| [0003](docs/adr/0003-helm-chart-location.md) | Helm chart lives in this repo; environment values and deployed versions live in the GitOps repo |
| [0004](docs/adr/0004-workload-type.md) | Workload type: Deployment (stateless app) |
| [0005](docs/adr/0005-sast-tool.md) | SAST tool: Semgrep |

## Run locally

Requires Docker. Node.js 22 is only needed to run the tests outside a container.

```bash
# Unit tests
npm ci && npm test

# Build and run the image
docker build -t sample-app:local .
docker run --rm -p 8080:8080 sample-app:local

# Integration test (needs port 8080 free)
scripts/integration-test.sh sample-app:local
```

The other checks (SAST, chart lint and schema validation, image scan) run in CI on every pull request; see [Pipeline](#pipeline).

## Endpoints

| Path | Purpose | Exposed by the Ingress |
|---|---|---|
| `/my-app` | Hello world; increments `root_access_total` | Yes |
| `/about` | App description | Yes |
| `/live` | Liveness probe | No |
| `/ready` | Readiness probe | No |
| `/metrics` | Prometheus metrics | No (scraped in-cluster via ServiceMonitor) |
| `/classified` | Internal endpoint | No |

The app listens on `PORT` (default `8080`).

## Deployment (planned)

On merge to `main`, CI updates the [GitOps repo](https://github.com/asaf-refaeli/platform), pinning both the image tag and the chart revision. Argo CD syncs the cluster from that repo. A rollback is a commit there that restores the previous pin.

## Node.js version

Runs on Node.js 22 LTS; the exact version is pinned in the `Dockerfile`. The original README listed 22.1.0. The image uses the latest 22.x patch for security fixes, verified by the unit and integration tests.
