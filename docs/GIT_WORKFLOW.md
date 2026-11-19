# Git Workflow & Version Bumping

Submission reference for how a change travels from a branch to `main`, how a release version is chosen, and how a `v*` tag becomes a running deployment. Source of truth for the pipeline is [`.github/workflows/ci.yml`](../.github/workflows/ci.yml); the deploy gate is [`argocd/application.yaml`](../argocd/application.yaml).

---

## 1. Branching and PR flow

`main` is the only integration branch. Every change — app code, CI config, Helm, Terraform, docs — goes through its own PR. Nobody pushes directly to `main`, and CI never commits to `main` (the only write-enabled job creates a deploy branch and opens a PR).

| Branch prefix | Meaning | Expected version bump |
|---|---|---|
| `feat/` | new behaviour / endpoint | minor |
| `fix/` | bug fix | patch |
| `chore/`, `refactor/` | maintenance, dependency bump, cleanup | patch |
| `docs/` | documentation only | none |
| `feat/terraform-*`, `fix/ci-*`, Helm/Terraform/ArgoCD-only | infra or CI config | none |

Standard sequence:

1. `git checkout main && git pull`
2. `git checkout -b <prefix>/<slug>`
3. Commit with conventional-commit messages (`feat:`, `fix:`, `chore:`, `docs:`, ...).
4. `gh pr create --base main --title "<type>: <short description>" ...`
5. Let the `detect`-routed checks run, review, then merge the PR into `main`.
6. Only if that merged work changed app code, cut a tag (§2).

"App code" means `app.js`, `Dockerfile`, `package.json`, `package-lock.json` — exactly the paths the `detect` job classifies as `app` (`ci.yml:85`). Docs, Helm, Terraform, ArgoCD and CI-only changes do not produce a release.

**Protected-branch expectations:** branch protection is *not* configured in this repository (`GET /repos/OrenOren1/refael/branches/main/protection` returns 404). The PR-only rule and required reviews/checks are a documented convention, not an enforced server-side setting; enable them in **Settings → Branches** if enforcement is wanted. What *is* enforced in code: workflow permissions default to `contents: read`, and only the deploy-PR job elevates to `contents: write` + `pull-requests: write` (`ci.yml:16-18`, `ci.yml:302-304`).

---

## 2. SemVer policy and tag procedure

Tags follow `vMAJOR.MINOR.PATCH` (for example `v1.0.0`), annotated tags preferred. No pre-release suffix is in use.

| Change merged since the previous tag | Bump | Example |
|---|---|---|
| Breaking behaviour / API change | major | `v1.0.0` → `v2.0.0` |
| New feature (`feat/`) | minor | `v1.0.0` → `v1.1.0` |
| Bug fix, dependency bump, refactor (`fix/`, `chore/`, `refactor/`) | patch | `v1.0.0` → `v1.0.1` |
| Docs, Helm, Terraform, CI/ArgoCD config only | none | no tag |

Rules:

- Cut a tag **after** the app-code PR is merged to `main`, tagging the commit on `main`. One tag per release; the tag covers every commit since the previous `v*` tag, which is the range CI inspects (`ci.yml:54`).
- Never tag from a feature branch, never move or re-use an existing tag, and never tag docs/infra-only work — release jobs are gated on `app == true` and would be skipped.
- Tags are created and pushed manually by a human maintainer with push access. There is no bump script, no release bot, and no automatic bump on merge. The existing `v1.0.0` tag is annotated and was created by Oren Sultan on 2026-11-19.

```bash
git checkout main && git pull
git tag -a v1.1.0 -m "release: v1.1.0"   # or a lightweight tag: git tag v1.1.0
git push origin v1.1.0
```

Manual bookkeeping: nothing bumps `package.json` `version` or `helm/Chart.yaml` `appVersion` automatically — keep them aligned when you cut a tag. `helm/values.yaml` `image.tag` is the one version field CI rewrites (inside the deploy PR); after the `v1.0.0` release and deploy PR #34 merge it points at `<ecr>/sample-nodejs:v1.0.0`. Note that ADR-010 describes `git describe --tags --abbrev=0` and an `appVersion` update; the current pipeline derives the tag from `GITHUB_REF` (`ci.yml:253-255`) and does not touch `Chart.yaml`.

---

## 3. From `v*` tag to cluster

```
PR → main ──(app code changed)── git tag vX.Y.Z + git push origin vX.Y.Z
                                          │
  push v* → detect → build-scan-push → update-image-tag → deploy PR → merge → ArgoCD sync
```

| Stage | Job / config | Behaviour |
|---|---|---|
| Trigger | `ci.yml:5-9` | `push` of a `v*` tag starts a release run. PRs and pushes to `main` run verify jobs instead. |
| Route | `detect` (`ci.yml:25-88`) | Sets `release=true`, `verify=false`, finds the previous semver tag, diffs `previous..HEAD` into `app/helm/terraform/argocd` flags. |
| Build, scan, push | `build-scan-push` (`ci.yml:238-294`, `if release && app`) | `TAG=${GITHUB_REF#refs/tags/}` → e.g. `v1.1.0` (leading `v` included). Builds `sample-nodejs:$TAG`, gates on Trivy HIGH/CRITICAL with `ignore-unfixed`, then keyless OIDC (`AWS_ROLE_TO_ASSUME`) pushes `<registry>/sample-nodejs:$TAG` to ECR. A failed scan stops here — no push, no deploy PR. |
| Propose deploy | `update-image-tag` (`ci.yml:296-340`) | Patches `helm/values.yaml` `image.repository` and `image.tag`, commits as `github-actions[bot]` on `deploy/image-$TAG`, opens PR `chore: deploy image $TAG` → `main`. No auto-merge, no branch/PR reuse. |
| Deploy | `argocd/application.yaml` | Watches `helm/` on `main`; automated sync with `prune`, `selfHeal`, 3 retries, namespace `sample-nodejs`. No Argo CD Image Updater — merging the deploy PR is the human gate. |

The image tag pushed to ECR, written into `values.yaml`, and shown in the deploy PR title is always the exact tag string, including the leading `v`.

---

## 4. Reviewer quick checks

```bash
git tag -l                                              # currently: v1.0.0
git show v1.0.0                                          # tagger, date, target commit
gh run list --workflow CI --event push                   # tag-triggered release runs
gh pr list --search "chore: deploy image" --state all    # generated deploy PRs
```

Related reading: [ADR-003](https://github.com/OrenOren1/refael/issues/3), [ADR-005](https://github.com/OrenOren1/refael/issues/6), [ADR-008](https://github.com/OrenOren1/refael/issues/10), [ADR-010](https://github.com/OrenOren1/refael/issues/8), and the README's Pipeline / GitOps Flow sections.
