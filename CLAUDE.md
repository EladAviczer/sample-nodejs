# CLAUDE.md — Refael Home Assignment

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
