# Validation Scripts — Workflow Patterns

Use these workflow patterns to decide which validation scripts to run, in what order, and how to interpret the results before proceeding.

## Common Workflows

### After Phase Implementation

Run the fast structural checks first, then pause if they fail.

```powershell
powershell -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .
powershell -File scripts/run-lint.ps1 -RepositoryRoot .
```

- If asset validation fails, stop and fix structure/frontmatter issues first.
- If lint reports only warnings, document them and continue if they are pre-existing or non-blocking.

### Before Plan Completion

Run the full validation stack before declaring the workflow complete.

```powershell
powershell -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .
powershell -File scripts/run-lint.ps1 -RepositoryRoot .
powershell -File scripts/run-smoke-tests.ps1 -RepositoryRoot .
powershell -File scripts/token-report.ps1 -Path . -ConfigPath token-thresholds.json
```

- Use this sequence for final readiness checks.
- If smoke tests fail, do not proceed to completion artifacts until fixed.

### After Adding New Prompt

Check metadata, then re-validate the repository and token budget.

```powershell
powershell -File scripts/add-prompt-metadata.ps1 -RepositoryRoot . -CheckOnly
powershell -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .
powershell -File scripts/token-report.ps1 -Path . -ConfigPath token-thresholds.json
```

- If metadata is missing, rerun `add-prompt-metadata.ps1` without `-CheckOnly` after approval.
- Re-run asset validation after any metadata write.

## Interpreting Results

### Exit Codes

- `0` — Success; proceed to the next workflow step.
- `1` — Failure; stop and fix blocking issues before proceeding.

### Validation Priorities

1. **Blockers:** Asset validation failures and smoke-test failures
2. **Errors:** New lint errors introduced by the current change
3. **Warnings:** Non-blocking lint or token warnings that still require documentation
4. **Info:** Guidance or optimization suggestions only

### When to Pause

- Pause immediately if `validate-copilot-assets.ps1` fails.
- Pause immediately if `run-smoke-tests.ps1` fails.
- Pause for newly introduced lint errors; fix them before handing off.
- Proceed with caution for warnings only, but document them clearly in the handoff summary.
- Treat token warnings as a review item unless a hard threshold or policy says otherwise.