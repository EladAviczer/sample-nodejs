# ADR-0002: CI platform: GitHub Actions

## Context
- CI must automate testing, Docker image builds, and publishing.
- It should be reliable, easy to maintain, and integrate with the existing GitHub repositories.

## Decision
Use GitHub Actions because:
- Native integration with pull requests and branch protection.
- YAML workflows stored alongside the application code.
- GitHub-hosted runners remove the need to manage CI infrastructure.
- Built-in support for secrets.

## Alternatives considered
- Jenkins: offers more flexibility, plugins, and control over execution environments, but rejected because it requires additional infrastructure, maintenance, and plugin management.

## Consequences
- Good: fast setup, minimal operational overhead, version-controlled pipelines.
- Bad: dependency on GitHub's platform, hosted-runner limitations, potentially higher costs at scale.
