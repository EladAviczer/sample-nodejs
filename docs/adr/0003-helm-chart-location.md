# ADR-0003: Helm chart location: application repository

## Context
- CI/CD for the Node.js app uses GitHub Actions and Argo CD (GitOps).
- The Helm chart needs a home: the application repo or the GitOps repo (`platform`).
- Environment values and the deployed image tag live in the GitOps repo either way.

## Decision
Keep the Helm chart in the application repository, and keep environment values, the deployed image tag, and the Argo CD Application in the GitOps repository, because:
- Clear sources of truth: the app repo defines how the app runs; the GitOps repo defines what version and configuration is deployed.
- Atomic changes: code and the chart changes it needs (probes, ports, env vars) are reviewed in one PR.
- CI validation: the chart is linted and rendered in the same pipeline as the code, before merge.
- Maintainability: the chart evolves with the code it deploys and doesn't drift.

## Alternatives considered
- Helm chart in the GitOps repository: centralizes all Kubernetes config and uses a single-source Argo CD Application, but rejected because app-related changes would need coordinated PRs across two repos.

## Consequences
- Good: one PR per feature, chart tested with the code, no CI loop since CI commits only the image tag to the GitOps repo.
- Bad: Argo CD needs a multi-source Application (v2.6+) or a published chart (e.g. OCI in ECR).
- Bad: chart and image versions must be kept compatible, because the GitOps repo pins the image tag while the chart comes from the app repo.
