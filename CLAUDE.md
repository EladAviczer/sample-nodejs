# CLAUDE.md — Refael Home Assignment

## Session Start Protocol (ALWAYS RUN FIRST)

**Every session on this repo must start with these steps — no exceptions:**

### Step 1: Load mission context
```bash
gh issue view 14 --repo OrenOren1/refael --comments
```

### Step 2: Check actual file state
```bash
ls .github/workflows/ci.yml 2>/dev/null && echo "✅ ci.yml" || echo "❌ ci.yml missing"
ls terraform/main.tf 2>/dev/null && echo "✅ terraform" || echo "❌ terraform missing"
ls Taskfile.yml 2>/dev/null && echo "✅ Taskfile" || echo "❌ Taskfile missing"
ls argocd/application.yaml 2>/dev/null && echo "✅ argocd" || echo "❌ argocd missing"
```

### Step 3: Tell the user
After reading the logbook and checking files, present to the user:
- What is already done (confirmed by file check)
- What is the **single next recommended step** (first item from the logbook's pending list)
- Ask: "Want me to start on [next step]?"

### Step 4: End of session
Before ending any session where files were created or changed:
```bash
gh issue comment 14 --repo OrenOren1/refael --body "## Session $(date +%Y-%m-%d)

**Done this session:**
- [list what was written/changed]

**Current state:**
- [list what is now done]

**Next step:**
- [first pending item]"
```

---

## Home Assignment Context

This repo is a DevOps/DevSecOps home assignment. Full brief:

**Task**: Fork the sample Node.js app and build a production-grade CI/CD pipeline + Kubernetes deployment.

### Deliverables Required

1. **Helm Chart** — deploy to Kubernetes with:
   - `Deployment` (stateless app — not StatefulSet)
   - Readiness + liveness probes
   - Service + Ingress
   - Resource limits/requests
   - ConfigMap / Secrets where appropriate

2. **CI/CD Pipeline** (GitHub Actions):
   - Version bumping (semantic versioning via git tags)
   - SAST scanning — fail on critical findings
   - Docker image build + push to registry (AWS ECR, `assignment-tests` profile, `us-east-1`)
   - Trivy image scan — block on HIGH+ severity
   - Deploy to Kubernetes via ArgoCD (GitOps)

3. **ArgoCD / GitOps**:
   - Chosen approach: manifests in same repo (app + helm chart in one repo, ArgoCD watches `helm/` path)
   - Rationale: single repo for a small solo project — simpler ops, no cross-repo sync issues

4. **Completion**:
   - Git repo link
   - Helm chart, pipelines, manifests in repo
   - K8s cluster access or screenshots of running app via Ingress

### App Overview

- Node.js + Express.js, single file (`app.js`)
- Prometheus metrics via `prom-client`
- Health endpoints: `GET /ready`, `GET /live`
- Main endpoint: `GET /my-app`
- Port configurable via `PORT` env var (default 8080)

### Key Architecture Decisions

- Stateless Express app → `Deployment` (not `StatefulSet`)
- Registry: AWS ECR (`assignment-tests`, `us-east-1`)
- GitOps: same-repo approach (helm chart in `helm/` dir, ArgoCD Application points to it)
- CI: GitHub Actions
- SAST: Semgrep (open source, Node.js support)
- Image scanning: Trivy

### AWS / Infrastructure

- AWS_PROFILE: `assignment-tests`
- Region: `us-east-1`

## Mission Logbook

**Always read this first** to restore session context:

```bash
gh issue view 14 --repo OrenOren1/refael --comments
```

GitHub Issue #14 tracks: what's done, what's pending, next steps, and per-session progress notes.
After each session, append a comment to issue #14 summarizing changes made and the next step.
