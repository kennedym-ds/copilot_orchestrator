# Validation script tests — suppress Write-Host (stream 6) and Warning
# (stream 3) output to prevent flooding VS Code's integrated terminal.
# Scripts use exit 0/1; check $LASTEXITCODE after each call.

$script:repoRoot = (Get-Item $PSScriptRoot).Parent.Parent.FullName
$script:scriptRoot = Join-Path $script:repoRoot 'scripts'

Describe 'Copilot validation scripts' {

    It 'validate-copilot-assets.ps1 completes successfully' {
        $scriptPath = Join-Path $script:scriptRoot 'validate-copilot-assets.ps1'
        $err = $null
        try { & $scriptPath -RepositoryRoot $script:repoRoot -ErrorAction Stop 6>$null 3>$null | Out-Null } catch { $err = $_ }
        $err | Should BeNullOrEmpty
        $LASTEXITCODE | Should Be 0
    }

    It 'add-prompt-metadata.ps1 passes in check-only mode' {
        $scriptPath = Join-Path $script:scriptRoot 'add-prompt-metadata.ps1'
        $err = $null
        try { & $scriptPath -RepositoryRoot $script:repoRoot -CheckOnly -ErrorAction Stop 6>$null 3>$null | Out-Null } catch { $err = $_ }
        $err | Should BeNullOrEmpty
        $LASTEXITCODE | Should Be 0
    }

    It 'run-lint.ps1 completes without errors' {
        $scriptPath = Join-Path $script:scriptRoot 'run-lint.ps1'
        $err = $null
        try { & $scriptPath -RepositoryRoot $script:repoRoot -ErrorAction Stop 6>$null 3>$null | Out-Null } catch { $err = $_ }
        $err | Should BeNullOrEmpty
        $LASTEXITCODE | Should Be 0
    }

    It 'run-smoke-tests.ps1 validates repository health' {
        $scriptPath = Join-Path $script:scriptRoot 'run-smoke-tests.ps1'
        $err = $null
        try { & $scriptPath -RepositoryRoot $script:repoRoot -ErrorAction Stop 6>$null 3>$null | Out-Null } catch { $err = $_ }
        $err | Should BeNullOrEmpty
        $LASTEXITCODE | Should Be 0
    }

    It 'token-report.ps1 emits JSON output' {
        $outputDirectory = Join-Path $TestDrive 'artifacts'
        $null = New-Item -ItemType Directory -Path $outputDirectory -Force
        $outputPath = Join-Path $outputDirectory 'token-report.json'

        $scriptPath = Join-Path $script:scriptRoot 'token-report.ps1'
        $err = $null
        try { & $scriptPath -Path $script:repoRoot -OutputPath $outputPath -ErrorAction Stop 6>$null 3>$null | Out-Null } catch { $err = $_ }
        $err | Should BeNullOrEmpty
        Test-Path -LiteralPath $outputPath | Should Be $true

        $json = Get-Content -LiteralPath $outputPath -Raw | ConvertFrom-Json
        $json.totalTokens | Should BeGreaterThan 0
        ($json.summary | Measure-Object).Count | Should BeGreaterThan 0
    }
}
