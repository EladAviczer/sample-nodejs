# Architecture Decision Records

## ADR Index

| ID | Sub-System | Decision | Status | Date | Decision Makers | File |
|----|------------|----------|--------|------|------------------|------|
| ADR-001 | System | Node.js Express Stateless Monolith | accepted | 2026-11-19 | Legacy/Inferred | [ADR-001.md](ADR-001.md) |
| ADR-002 | System | Prometheus Metrics Embedded In-Process | accepted | 2026-11-19 | Legacy/Inferred | [ADR-002.md](ADR-002.md) |
| ADR-003 | CI/CD | GitHub Actions as CI/CD Engine | accepted | 2026-11-19 | Assignment/Planned | [ADR-003.md](ADR-003.md) |
| ADR-004 | Deployment | AWS ECR as Container Registry | accepted | 2026-11-19 | Assignment/Planned | [ADR-004.md](ADR-004.md) |
| ADR-005 | Deployment | Same-Repo GitOps with ArgoCD | accepted | 2026-11-19 | Assignment/Planned | [ADR-005.md](ADR-005.md) |
| ADR-006 | CI/CD | SAST: nodejsscan + npm audit | accepted | 2026-11-19 | Oren Sultan | [ADR-006.md](ADR-006.md) |
| ADR-007 | CI/CD | Trivy Image Scan Gate: HIGH+ignore-unfixed | accepted | 2026-11-19 | Oren Sultan | [ADR-007.md](ADR-007.md) |
| ADR-008 | CI/CD | ArgoCD Image Tag Update: CI Opens PR | accepted | 2026-11-19 | Oren Sultan | [ADR-008.md](ADR-008.md) |
| ADR-009 | Deployment | Kubernetes: EKS (prod) + k3d (local dev) | accepted | 2026-11-19 | Oren Sultan | [ADR-009.md](ADR-009.md) |
| ADR-010 | CI/CD | Semantic Versioning + Git Tags | accepted | 2026-11-19 | Oren Sultan | [ADR-010.md](ADR-010.md) |
| ADR-011 | Deployment | Terraform for AWS Infrastructure Provisioning | accepted | 2026-11-19 | Oren Sultan | [ADR-011.md](ADR-011.md) |
| ADR-012 | CI/CD | Bonus: Hadolint + Helm Lint in CI | accepted | 2026-11-19 | Oren Sultan | [ADR-012.md](ADR-012.md) |
| ADR-013 | Development | Local Dev Task Runner: Taskfile (go-task) | accepted | 2026-11-19 | Oren Sultan | [ADR-013.md](ADR-013.md) |
| ADR-014 | CI/CD | CI Routing by Changed Paths and Branch | accepted | 2026-11-19 | Oren Sultan | [ADR-014.md](ADR-014.md) |
| ADR-015 | CI/CD | Terraform Plan in the PR Gate via OIDC Read Policy | accepted | 2026-11-19 | Oren Sultan | [ADR-015.md](ADR-015.md) |


---

## Quick Links

- [ADR-001: Node.js Express Stateless Monolith](ADR-001.md)
- [ADR-002: Prometheus Metrics Embedded In-Process](ADR-002.md)
- [ADR-003: GitHub Actions as CI/CD Engine](ADR-003.md)
- [ADR-004: AWS ECR as Container Registry](ADR-004.md)
- [ADR-005: Same-Repo GitOps with ArgoCD](ADR-005.md)
- [ADR-006: SAST: nodejsscan + npm audit](ADR-006.md)
- [ADR-007: Trivy Image Scan Gate: HIGH+ignore-unfixed](ADR-007.md)
- [ADR-008: ArgoCD Image Tag Update: CI Opens PR](ADR-008.md)
- [ADR-009: Kubernetes: EKS (prod) + k3d (local dev)](ADR-009.md)
- [ADR-010: Semantic Versioning + Git Tags](ADR-010.md)
- [ADR-011: Terraform for AWS Infrastructure Provisioning](ADR-011.md)
- [ADR-012: Bonus: Hadolint + Helm Lint in CI](ADR-012.md)
- [ADR-013: Local Dev Task Runner: Taskfile (go-task)](ADR-013.md)
- [ADR-014: CI Routing by Changed Paths and Branch](ADR-014.md)
- [ADR-015: Terraform Plan in the PR Gate via OIDC Read Policy](ADR-015.md)

