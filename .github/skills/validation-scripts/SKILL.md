---
name: validation-scripts
description: "PowerShell 5.1 validation script operations for asset validation, lint checks, smoke tests, and pause-point verification."
version: "2.0.0"
user-invocable: true
argument-hint: "[path to validate — defaults to repo root]"
---

# Validation Scripts

## Description

This skill is the entry point for the repository's PowerShell 5.1 validation workflow. It tells agents which scripts to run, how to interpret the results, when approval is required, and where the detailed per-script reference material lives.

Use it when you need validation cadence guidance or quick script selection during implementation, review, or conductor pause points. Keep deeper syntax and troubleshooting details in the bundled references instead of re-expanding this file into a monolith.

## When to Use

- Use when validating asset structure after editing agents, prompts, instructions, or skills.
- Use when deciding which validation scripts to run before review or completion.
- Use when interpreting pass/fail status, warnings, and pause conditions from validation output.
- Use when checking whether a validation script is read-only or approval-gated.

### When NOT to Use

- Do not use for general PowerShell scripting questions unrelated to repository validation.
- Do not use when the task is purely about terminal formatting; use `instructions/global/terminal-formatting.instructions.md` instead.
- Do not use when you already need full per-script details; go straight to the bundled references.

## Entry Points

- **Trigger phrases:** "validate changes", "run lint check", "run smoke tests", "check frontmatter", "generate token report"
- **Implementation context:** after phase work, before review handoff, after adding prompts, after changing instructions or skills
- **Conductor context:** before pause points, before workflow completion, after structural repository changes
- **Expected outcome:** choose the right validation sequence, run it in PowerShell 5.1, and interpret whether to proceed or stop

## Core Knowledge

### Validation scripts overview

| Script | Purpose | Auto-Approved | Exit Code |
|--------|---------|---------------|-----------|
| `validate-copilot-assets.ps1` | Validate frontmatter, YAML, and asset structure | ✓ Yes | `0` pass, `1` fail |
| `run-lint.ps1` | Check markdown and repository formatting issues | ✓ Yes | `0` pass, `1` fail |
| `run-smoke-tests.ps1` | Confirm critical repository paths still work | ✓ Yes | `0` pass, `1` fail |
| `token-report.ps1` | Generate token budget totals and warnings | ✓ Yes | `0` success |
| `add-prompt-metadata.ps1` | Add or normalize prompt metadata | ✗ No | `0` success, `1` fail |
| `init-artifacts.ps1` | Create local workflow artifact folders | ✗ No | `0` success |

### Terminal auto-approve behavior

Read-only validation scripts are typically safe to run without modification approval:

```powershell
powershell -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .
powershell -File scripts/run-lint.ps1 -RepositoryRoot .
powershell -File scripts/run-smoke-tests.ps1 -RepositoryRoot .
powershell -File scripts/token-report.ps1 -Path . -ConfigPath token-thresholds.json
```

Scripts that write to disk require approval because they modify repository state:

```powershell
powershell -File scripts/add-prompt-metadata.ps1 -RepositoryRoot .
powershell -File scripts/init-artifacts.ps1
```

### Validation cadence guidance

- **After implementation:** run asset validation, then lint.
- **Before completion or release readiness:** run asset validation, lint, smoke tests, then token report.
- **After adding prompts:** check or add metadata, then re-run asset validation.
- **When any blocking script fails:** stop, fix the cause, and re-run before proceeding.

## Examples

### Example: Phase completion validation

```powershell
powershell -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .
powershell -File scripts/run-lint.ps1 -RepositoryRoot .
```

If asset validation passes and lint shows only non-blocking warnings, proceed to the next quality gate.

### Example: Handling validation failure

```powershell
powershell -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .
Write-Host "Exit code: $LASTEXITCODE"
```

If `$LASTEXITCODE` is `1`, fix the structural issue first. Do not continue to review or completion checks until the validation script returns `0`.

## References

- [references/script-catalog.md](references/script-catalog.md) — detailed per-script syntax, parameters, exit codes, and troubleshooting
- [references/workflow-patterns.md](references/workflow-patterns.md) — validation sequences, priorities, and pause guidance
- [references/example-outputs.md](references/example-outputs.md) — expected pass/fail output examples
- [../../../scripts/](../../../scripts/) — script sources
- [../../agents/conductor.agent.md](../../agents/conductor.agent.md) — conductor workflow context
- [../../../docs/templates/phase-complete.md](../../../docs/templates/phase-complete.md) — completion template referenced by validation workflows
