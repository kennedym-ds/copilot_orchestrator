# Pester v5 tests for hook scripts.
# Covers the runtime-critical logic: exit-code on allowlist violations, JSONL schema, state mutation.

BeforeAll {
    $script:repoRoot = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
    $script:hooksDir = Join-Path $script:repoRoot "scripts/hooks"
    # Per-test sandbox for artifacts/sessions
    $script:sandbox = Join-Path $env:TEMP ("hooks-tests-" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path (Join-Path $script:sandbox "artifacts/sessions/hooks") -Force | Out-Null
    # Redirect hook output by running each hook with cwd = sandbox and PSScriptRoot redirected via copy
    # Simpler: copy hooks to sandbox to avoid polluting the real artifacts/ folder.
    $sandboxHooks = Join-Path $script:sandbox "scripts/hooks"
    New-Item -ItemType Directory -Path $sandboxHooks -Force | Out-Null
    Copy-Item (Join-Path $script:hooksDir "*.ps1") -Destination $sandboxHooks -Force
    $script:sandboxHooks = $sandboxHooks
}

AfterAll {
    if (Test-Path $script:sandbox) {
        Remove-Item -LiteralPath $script:sandbox -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Describe "subagent-start.ps1" {
    It "exits 0 on an allowed edge (implementer -> test, depth 1)" {
        $p = Join-Path $script:sandboxHooks "subagent-start.ps1"
        & powershell -NoProfile -File $p -Parent "implementer" -Child "test" -Depth 1
        $LASTEXITCODE | Should -Be 0
    }

    It "exits 1 on a disallowed edge (implementer -> reviewer)" {
        $p = Join-Path $script:sandboxHooks "subagent-start.ps1"
        & powershell -NoProfile -File $p -Parent "implementer" -Child "reviewer" -Depth 1
        $LASTEXITCODE | Should -Be 1
    }

    It "exits 1 when depth exceeds cap (2)" {
        $p = Join-Path $script:sandboxHooks "subagent-start.ps1"
        & powershell -NoProfile -File $p -Parent "implementer" -Child "test" -Depth 3
        $LASTEXITCODE | Should -Be 1
    }

    It "writes a structured JSONL record to hooks/subagent-start.jsonl" {
        $p = Join-Path $script:sandboxHooks "subagent-start.ps1"
        & powershell -NoProfile -File $p -Parent "planner" -Child "researcher" -Depth 1 | Out-Null
        $log = Join-Path $script:sandbox "artifacts/sessions/hooks/subagent-start.jsonl"
        Test-Path $log | Should -BeTrue
        $last = Get-Content $log | Select-Object -Last 1 | ConvertFrom-Json
        $last.event | Should -Be "subagent-start"
        $last.parent | Should -Be "planner"
        $last.child | Should -Be "researcher"
        $last.allowed | Should -BeTrue
        $last.ts | Should -Not -BeNullOrEmpty
    }
}

Describe "_common.ps1 Write-HookEvent" {
    It "emits a record with event + ts + payload fields" {
        $common = Join-Path $script:sandboxHooks "_common.ps1"
        $script = @"
. `"$common`"
Write-HookEvent -Event 'unit-test' -Payload @{ foo='bar'; count=5 }
"@
        $tmp = Join-Path $script:sandbox "run.ps1"
        Set-Content -Path $tmp -Value $script -Encoding UTF8
        & powershell -NoProfile -File $tmp | Out-Null
        $log = Join-Path $script:sandbox "artifacts/sessions/hooks/unit-test.jsonl"
        Test-Path $log | Should -BeTrue
        $rec = Get-Content $log | Select-Object -Last 1 | ConvertFrom-Json
        $rec.event | Should -Be "unit-test"
        $rec.foo | Should -Be "bar"
        $rec.count | Should -Be 5
        $rec.ts | Should -Match '^\d{4}-\d{2}-\d{2}T'
    }
}

Describe "task-completed.ps1 JSON round-trip" {
    BeforeEach {
        $stateDir = Join-Path $script:sandbox "artifacts/sessions"
        $script:statePath = Join-Path $stateDir "team-state.json"
        $seed = @{
            status = "active"
            tasks = @(
                @{ id="T1"; status="pending"; assignee="implementer" },
                @{ id="T2"; status="pending"; assignee="reviewer" }
            )
        }
        $seed | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $script:statePath -Encoding UTF8
    }

    It "mutates the matching task's status and preserves siblings" {
        $p = Join-Path $script:sandboxHooks "task-completed.ps1"
        & powershell -NoProfile -File $p -TaskId "T1" -Assignee "implementer" -Status "complete" | Out-Null
        $after = Get-Content $script:statePath -Raw | ConvertFrom-Json
        $t1 = $after.tasks | Where-Object { $_.id -eq "T1" }
        $t2 = $after.tasks | Where-Object { $_.id -eq "T2" }
        $t1.status | Should -Be "complete"
        $t2.status | Should -Be "pending"
    }

    It "no-ops silently when task id does not match any entry" {
        $p = Join-Path $script:sandboxHooks "task-completed.ps1"
        & powershell -NoProfile -File $p -TaskId "T-nonexistent" -Assignee "x" -Status "complete" | Out-Null
        $after = Get-Content $script:statePath -Raw | ConvertFrom-Json
        $after.tasks.Count | Should -Be 2
        ($after.tasks | Where-Object { $_.status -eq "complete" }).Count | Should -Be 0
    }
}
