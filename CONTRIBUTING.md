# Contributing

Thanks for contributing to `copilot_orchestrator`.

## Before you start

1. Read `AGENTS.md` for workflow and guardrails.
2. Check `docs/quick-reference.md` for commands and operational notes.
3. Keep changes scoped and include documentation updates when behavior changes.

## Development workflow

1. Create a branch for your work.
2. Make small, focused changes.
3. Run validation locally (PowerShell 5.1 examples below).
4. Open a pull request using `.github/PULL_REQUEST_TEMPLATE.md`.

## Validation commands (PowerShell 5.1)

```powershell
powershell -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .
powershell -File scripts/add-prompt-metadata.ps1 -RepositoryRoot . -CheckOnly
powershell -File scripts/run-lint.ps1 -RepositoryRoot .
powershell -File scripts/run-smoke-tests.ps1 -RepositoryRoot .
```

If your change affects token budgets, also run:

```powershell
powershell -File scripts/token-report.ps1 -Path .
```

## Documentation and changelog

When applicable:

- Update `docs/CHANGELOG.md` for notable repository changes.
- Update `INSTRUCTION_CHANGELOG.md` if instructions changed.
- Add follow-up tasks to `docs/operations.md` if work is deferred.

## Pull request expectations

- Link related issues/plans.
- Summarize what changed and why.
- Include validation results.
- Call out risks or follow-up work.

## Need help?

Open a question in Issues or Discussions (if enabled), and include context such as file paths, expected behavior, and current results.
