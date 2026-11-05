# ADR-0005: SAST tool: Semgrep

## Context
- The pipeline must run SAST and fail on critical findings in the code.
- The assignment suggests tools from the OWASP Source Code Analysis Tools list.
- The app is a small Node.js/Express service.

## Decision
Use Semgrep (open source CLI) because:
- Listed on the OWASP Source Code Analysis Tools page as open source/free.
- Fails the pipeline with built-in flags: `--severity ERROR` limits findings to the highest-severity rules, `--error` exits non-zero on any finding.
- No account or token needed; uses public rule packs (`p/javascript`, `p/nodejsscan`).
- Runs as a plain CLI, so the same command works locally and in CI.
- Runs from the official image, pinned by digest.
- Results are also exported as SARIF and uploaded to the GitHub Security tab, giving the same alert view as CodeQL.

## Alternatives considered
- CodeQL: GitHub-native with results in the Security tab, but rejected because blocking the pipeline on severity needs extra setup.
- SonarCloud: rejected because it needs an external account, a token, and a quality gate configured outside the repo.

## Consequences
- Good: simple to run and explain, fails fast before the image build, no secrets required.
- Good: findings visible both in the job log and as alerts in the Security tab.
- Bad: public rule packs only (no Semgrep Pro cross-file analysis).
- Bad: the `sast` job needs `security-events: write` to upload results; this permission is scoped to that job only.
