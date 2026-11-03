# ADR-0001: Git workflow: GitHub Flow

## Context
- Single developer, one environment.
- Every merge to `main` builds an image, pushes it to ECR, and updates the GitOps repo, so `main` must always be deployable.
- Work comes in task-sized pieces (Dockerfile, CI pipeline, manifests).
- Environment promotion lives in the GitOps repo, not in app branches.

## Decision
Use GitHub Flow because:
- CI runs on the PR before the merge, keeping broken code out of `main` and the cluster.
- Each task fits one branch (`feat/`, `fix/`, `ci/`, `chore/`, `docs/`) and one PR.
- `main` is protected: no direct pushes, CI required.

## Alternatives considered
- Trunk-Based Development (commit to `main`, or to branches that live less than a day): rejected because avoiding merge conflicts across many developers doesn't matter for a single developer, and unfinished work would need feature flags.
- GitFlow: rejected because it is built for versioned releases across several environments.

## Consequences
- Good: each task is one PR with its diff and CI results in one place, `main` stays deployable.
- Bad: deploys happen per finished task, branches can drift from `main`, CI is the only merge gate (no approvals).
