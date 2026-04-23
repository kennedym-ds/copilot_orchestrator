# Validation script tests — suppress Write-Host (stream 6) and Warning
# (stream 3) output to prevent flooding VS Code's integrated terminal.
#
# Fast tests (no tag): run in-process — safe for interactive use.
# Slow tests ([Tag('Slow')]): spawned out-of-process with a 120-second kill
# timeout so they cannot block the VS Code extension host.
#
# Interactive:  Invoke-Pester -Path tests -ExcludeTag Slow -Output Detailed
# Full (CI):    Invoke-Pester -Path tests -Output Detailed

function Invoke-ScriptWithTimeout {
    [CmdletBinding()]
    param(
        [string]$ScriptPath,
        [string[]]$Arguments,
        [int]$TimeoutSeconds = 120
    )
    $proc = Start-Process -FilePath 'powershell.exe' `
        -ArgumentList (@('-NonInteractive', '-NoProfile', '-File', "`"$ScriptPath`"") + $Arguments) `
        -PassThru -NoNewWindow
    $exited = $proc.WaitForExit($TimeoutSeconds * 1000)
    if (-not $exited) {
        $proc.Kill()
        throw "Script '$(Split-Path $ScriptPath -Leaf)' timed out after ${TimeoutSeconds}s and was killed."
    }
    return $proc.ExitCode
}

Describe 'Copilot validation scripts' {
    BeforeAll {
        $script:repoRoot = (Get-Item $PSScriptRoot).Parent.Parent.FullName
        $script:scriptRoot = Join-Path $script:repoRoot 'scripts'
    }

    # ── Fast (in-process, safe for interactive Pester runs) ──────────────

    It 'validate-copilot-assets.ps1 completes successfully' {
        $scriptPath = Join-Path $script:scriptRoot 'validate-copilot-assets.ps1'
        $err = $null
        try { & $scriptPath -RepositoryRoot $script:repoRoot -ErrorAction Stop 6>$null 3>$null | Out-Null } catch { $err = $_ }
        $err | Should -BeNullOrEmpty
        $LASTEXITCODE | Should -Be 0
    }

    It 'add-prompt-metadata.ps1 passes in check-only mode' {
        $scriptPath = Join-Path $script:scriptRoot 'add-prompt-metadata.ps1'
        $err = $null
        try { & $scriptPath -RepositoryRoot $script:repoRoot -CheckOnly -ErrorAction Stop 6>$null 3>$null | Out-Null } catch { $err = $_ }
        $err | Should -BeNullOrEmpty
        $LASTEXITCODE | Should -Be 0
    }

    # ── Slow (out-of-process, 120s timeout) — excluded from interactive run ──
    # Run with: Invoke-Pester -Path tests -Output Detailed
    # Skip with: Invoke-Pester -Path tests -ExcludeTag Slow -Output Detailed

    It 'run-lint.ps1 completes without errors' -Tag 'Slow' {
        $scriptPath = Join-Path $script:scriptRoot 'run-lint.ps1'
        $exitCode = Invoke-ScriptWithTimeout -ScriptPath $scriptPath `
            -Arguments @('-RepositoryRoot', "`"$script:repoRoot`"")
        $exitCode | Should -Be 0
    }

    It 'run-smoke-tests.ps1 validates repository health' -Tag 'Slow' {
        $scriptPath = Join-Path $script:scriptRoot 'run-smoke-tests.ps1'
        $exitCode = Invoke-ScriptWithTimeout -ScriptPath $scriptPath `
            -Arguments @('-RepositoryRoot', "`"$script:repoRoot`"")
        $exitCode | Should -Be 0
    }

    It 'token-report.ps1 emits JSON output' -Tag 'Slow' {
        $outputDirectory = Join-Path $TestDrive 'artifacts'
        $null = New-Item -ItemType Directory -Path $outputDirectory -Force
        $outputPath = Join-Path $outputDirectory 'token-report.json'
        $scriptPath = Join-Path $script:scriptRoot 'token-report.ps1'

        $exitCode = Invoke-ScriptWithTimeout -ScriptPath $scriptPath `
            -Arguments @('-Path', "`"$script:repoRoot`"", '-OutputPath', "`"$outputPath`"")
        $exitCode | Should -Be 0

        Test-Path -LiteralPath $outputPath | Should -BeTrue
        $json = Get-Content -LiteralPath $outputPath -Raw | ConvertFrom-Json
        $json.totalTokens | Should -BeGreaterThan 0
        ($json.summary | Measure-Object).Count | Should -BeGreaterThan 0
    }
}
