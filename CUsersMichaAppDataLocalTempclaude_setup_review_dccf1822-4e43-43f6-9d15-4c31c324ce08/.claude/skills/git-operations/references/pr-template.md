# Pull Request Template

Standard PR template for the copilot orchestrator repository.

---

## Description

<!-- What does this PR do? Link to plan artifact or issue if applicable. -->

**Related:** <!-- artifacts/plans/{feature}/plan.md | Closes #NNN -->

## Changes

<!-- Bullet-list the key changes. Group by category if many files changed. -->

### Agents
-

### Instructions
-

### Scripts
-

### Documentation
-

## Type of Change

- [ ] `feat` — New feature or capability
- [ ] `fix` — Bug fix
- [ ] `docs` — Documentation only
- [ ] `refactor` — Code restructuring (no behavior change)
- [ ] `test` — Test additions or updates
- [ ] `chore` — Maintenance, tooling, config
- [ ] `ci` — CI/CD pipeline changes

## Validation Checklist

- [ ] `powershell -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .` — 0 errors
- [ ] `powershell -File scripts/run-lint.ps1 -RepositoryRoot .` — Clean
- [ ] `powershell -File scripts/add-prompt-metadata.ps1 -RepositoryRoot . -CheckOnly` — All metadata present
- [ ] `powershell -File scripts/run-smoke-tests.ps1 -RepositoryRoot .` — All pass
- [ ] `powershell -File scripts/token-report.ps1 -Path .` — No files over budget

## Review Focus Areas

<!-- Guide reviewers to the most important changes. -->

1.
2.
3.

## Breaking Changes

<!-- List any breaking changes and migration steps. Remove section if none. -->

None.

## Screenshots / Examples

<!-- If applicable, add before/after screenshots or example outputs. -->

## Post-Merge Tasks

- [ ] Update `docs/CHANGELOG.md`
- [ ] Update `INSTRUCTION_CHANGELOG.md` (if instructions changed)
- [ ] Run `powershell -File scripts/analyze-sessions.ps1` (if workflow changed)
