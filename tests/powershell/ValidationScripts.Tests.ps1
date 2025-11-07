$repoRoot = (Get-Item $PSScriptRoot).Parent.Parent.FullName
$scriptRoot = Join-Path $repoRoot 'scripts'

function Invoke-RepositoryScript {
    param(
        [Parameter(Mandatory)]
        [string]$ScriptName,
        [string[]]$ArgumentList = @()
    )

    $scriptPath = Resolve-Path -LiteralPath (Join-Path $scriptRoot $ScriptName)
    $arguments = @('-NoLogo', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $scriptPath.Path) + $ArgumentList
    $process = Start-Process -FilePath 'powershell.exe' -ArgumentList $arguments -NoNewWindow -PassThru -Wait
    return $process.ExitCode
}

Describe 'Copilot validation scripts' {
    It 'validate-copilot-assets.ps1 completes successfully' {
        $exitCode = Invoke-RepositoryScript -ScriptName 'validate-copilot-assets.ps1' -ArgumentList @('-RepositoryRoot', $repoRoot)
        $exitCode | Should Be 0
    }

    It 'add-prompt-metadata.ps1 passes in check-only mode' {
        $exitCode = Invoke-RepositoryScript -ScriptName 'add-prompt-metadata.ps1' -ArgumentList @('-RepositoryRoot', $repoRoot, '-CheckOnly')
        $exitCode | Should Be 0
    }

    It 'run-lint.ps1 completes without errors' {
        $exitCode = Invoke-RepositoryScript -ScriptName 'run-lint.ps1' -ArgumentList @('-RepositoryRoot', $repoRoot)
        $exitCode | Should Be 0
    }

    It 'run-smoke-tests.ps1 validates repository health' {
        $exitCode = Invoke-RepositoryScript -ScriptName 'run-smoke-tests.ps1' -ArgumentList @('-RepositoryRoot', $repoRoot)
        $exitCode | Should Be 0
    }

    It 'token-report.ps1 emits JSON output' {
        $outputDirectory = Join-Path $TestDrive 'artifacts'
        $null = New-Item -ItemType Directory -Path $outputDirectory -Force
        $outputPath = Join-Path $outputDirectory 'token-report.json'

        $exitCode = Invoke-RepositoryScript -ScriptName 'token-report.ps1' -ArgumentList @('-Path', $repoRoot, '-OutputPath', $outputPath)
        $exitCode | Should Be 0
        Test-Path -LiteralPath $outputPath | Should Be $true

        $json = Get-Content -LiteralPath $outputPath -Raw | ConvertFrom-Json
        $json.totalTokens | Should BeGreaterThan 0
        ($json.summary | Measure-Object).Count | Should BeGreaterThan 0
    }
}
