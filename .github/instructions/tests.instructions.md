---
description: "Pester v5 test standards — structure, coverage expectations, sandboxing, and assertion patterns."
applyTo: "tests/**"
version: "1.0.0"
lastUpdated: "2026-04-23"
---

# Test Standards (Pester v5)

## File Naming

Test files match `*.Tests.ps1` and live under `tests/powershell/`. One test file per script under test. Name matches the script: `subagent-start.ps1` → `Test-Hooks.Tests.ps1` (grouped by domain) or `SubagentStart.Tests.ps1` (one-to-one).

## Structure

Use Pester v5 syntax only. No Pester v4 patterns.

```powershell
BeforeAll {
    # Setup: copy scripts to temp sandbox, create stub artifacts dirs
    $script:sandbox = Join-Path $env:TEMP ("test-" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path (Join-Path $script:sandbox "artifacts/sessions/hooks") -Force | Out-Null
    # Copy hook scripts so tests don't write to the real artifacts/
    Copy-Item (Join-Path $PSScriptRoot "../../scripts/hooks/*.ps1") -Destination (Join-Path $script:sandbox "scripts/hooks") -Force
}

AfterAll {
    Remove-Item -LiteralPath $script:sandbox -Recurse -Force -ErrorAction SilentlyContinue
}

Describe "script-name.ps1" {
    It "exits 0 on success" { ... }
    It "exits 1 on <specific failure condition>" { ... }
    It "writes JSONL record with expected schema" { ... }
}
```

## Coverage Expectations

Every hook script test must cover:
1. **Exit 0** on the happy path
2. **Exit 1** on each enforced failure condition (allowlist violation, depth cap)
3. **JSONL record schema** — verify `event`, `ts`, and at least 2 payload fields

Every validator test must cover:
1. **Passes** on a known-good input
2. **Error** on a known-bad input
3. Exit code (0 = all clear, non-zero = error found)

## Sandboxing

Never write to the real `artifacts/` directory from tests. Always use `$env:TEMP` sandboxes. Copy the scripts under test into the sandbox so `$PSScriptRoot`-relative paths resolve correctly.

## Stdin-Based Hook Testing

Hook scripts now read VS Code context from stdin JSON. Pipe JSON directly in tests:

```powershell
It "exits 0 on allowed edge" {
    $p = Join-Path $script:sandboxHooks "subagent-start.ps1"
    '{"agent_type":"test","parent_agent_type":"implementer","nesting_depth":1}' |
        & powershell -NoProfile -File $p
    $LASTEXITCODE | Should -Be 0
}
```

Do not pass `-Parent`, `-Child`, `-Depth` as CLI parameters — hook scripts no longer accept them.

## Assertions

- Use `Should -Be` for exact equality, `Should -Match` for regex, `Should -BeTrue` / `Should -BeFalse` for booleans.
- `Should -Not -BeNullOrEmpty` for required fields.
- For JSONL records: `ConvertFrom-Json` the last line of the log file and assert individual properties.
- Timestamp fields: `Should -Match '^\d{4}-\d{2}-\d{2}T'` (ISO 8601 prefix).

## Running Tests

```powershell
# All tests
Invoke-Pester -Path tests -Output Detailed

# Single describe block
Invoke-Pester -Path tests/powershell/Test-Hooks.Tests.ps1 -Output Detailed
```

Tests must pass before any PR. Skipped tests must have a documented reason in a `Pending` block.
