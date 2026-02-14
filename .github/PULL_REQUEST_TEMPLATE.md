# Pull Request

## Summary

<!-- What changed and why? Link related issue/plan/artifact if applicable. -->

## Scope of changes

- [ ] Agents
- [ ] Prompts
- [ ] Instructions
- [ ] Scripts
- [ ] Documentation
- [ ] Tests

## Validation (PowerShell 5.1)

Mark the commands you ran and include notable output in the PR description.

- [ ] `powershell -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .`
- [ ] `powershell -File scripts/add-prompt-metadata.ps1 -RepositoryRoot . -CheckOnly` (when prompt files changed)
- [ ] `powershell -File scripts/run-lint.ps1 -RepositoryRoot .`
- [ ] `powershell -File scripts/run-smoke-tests.ps1 -RepositoryRoot .`
- [ ] `powershell -File scripts/token-report.ps1 -Path .` (when large docs/prompts changed)

## Documentation updates

- [ ] `docs/CHANGELOG.md` updated (if notable repository change)
- [ ] `INSTRUCTION_CHANGELOG.md` updated (if instruction files changed)
- [ ] `docs/operations.md` updated for deferred follow-up work (if needed)

## Risk and rollout notes

<!-- Mention breaking changes, migration steps, or reviewer focus areas. -->

## Checklist

- [ ] I kept changes scoped and reviewed my own diff.
- [ ] I did not include secrets or sensitive data.
- [ ] I linked any related issues/plans.
