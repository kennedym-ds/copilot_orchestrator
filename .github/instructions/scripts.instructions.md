---
description: "PowerShell scripting standards for scripts/ — compatibility, error handling, output, and hook patterns."
applyTo: "scripts/**"
version: "1.0.0"
lastUpdated: "2026-04-23"
---

# PowerShell Script Standards

## Compatibility

Target **Windows PowerShell 5.1** as the baseline. Use `pwsh` (PowerShell Core 7+) only when a cross-platform shebang is needed (e.g., hook scripts invoked with `command:` key on Linux/macOS). Never use PowerShell 7-only syntax (ternary `?:`, `&&`/`||` pipeline chains, `ForEach-Object -Parallel`) without a version guard.

## Script Structure

Every script starts with:

```powershell
[CmdletBinding()]
param(
    # named parameters only — no positional $args
)
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
```

- `[CmdletBinding()]` enables `-Verbose`, `-Debug`, `-WhatIf` on every script.
- `Set-StrictMode -Version 2.0` catches undefined variables and uninitialized properties.
- `$ErrorActionPreference = 'Stop'` converts non-terminating errors to terminating ones so `try/catch` works.

## Path Handling

- Always use `$PSScriptRoot` for paths relative to the script file. Never use `Get-Location` or `.`.
- Wrap all paths in `[IO.Path]::Combine(...)` or `Join-Path` — never string-concatenate paths.
- Use `-LiteralPath` on `Get-Content`, `Set-Content`, `Test-Path`, `New-Item`, `Remove-Item` to avoid glob expansion on path characters like `[` and `]`.

## Output

- Use `Write-Output` for structured data consumed by callers.
- Use `Write-Host` only for human-readable progress in interactive scripts.
- Use `Write-Error` for non-terminating errors.
- Use `exit 1` only at the outermost scope after all cleanup is done.
- Validation scripts emit a `[PASS] / [WARN] / [ERROR]` prefix on every finding line.

## Hook Scripts (`scripts/hooks/`)

All hook scripts must:

1. Dot-source `_common.ps1`: `. (Join-Path $PSScriptRoot "_common.ps1")`
2. Call `Read-HookInput` to get the VS Code stdin JSON payload (not env vars).
3. Emit JSONL via `Write-HookEvent -Event '<PascalCaseName>' -Payload @{...}`.
4. Use `Write-AdditionalContext` to inject context into the assistant (where applicable).
5. Exit 0 on success. Exit 1 on blocking errors only — observability hooks must not exit 1 on normal operation.

For PostToolUse hooks: guard on `tool_exit_code` from stdin — the hook fires on every tool use, not just failures.

## Error Handling

- Wrap all side-effecting operations in `try/catch`.
- In `catch`, log with `Write-HookError` (for hook scripts) or `Write-Error` (for utility scripts).
- Do not swallow errors silently — at minimum log the exception message.
- Use `$_.Exception.Message` in catch blocks, not `$_` directly.

## Testing

Every script that has branching logic or side effects must have a corresponding Pester v5 test in `tests/powershell/`. Run `Invoke-Pester -Path tests -Output Detailed` before marking work complete. The validator also runs as part of the pre-commit gate.
