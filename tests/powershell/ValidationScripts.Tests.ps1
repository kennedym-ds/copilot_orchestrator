Describe 'Copilot validation scripts' {
    BeforeAll {
        $script:repoRoot = (Get-Item $PSScriptRoot).Parent.Parent.FullName
        $script:scriptRoot = Join-Path $script:repoRoot 'scripts'

        function Invoke-RepositoryScript {
            param(
                [Parameter(Mandatory)]
                [string]$ScriptName,
                [string[]]$ArgumentList = @()
            )

            $scriptPath = Resolve-Path -LiteralPath (Join-Path $script:scriptRoot $ScriptName)
            $shellExecutable = 'pwsh'
            if (-not (Get-Command -Name $shellExecutable -ErrorAction SilentlyContinue)) {
                $shellExecutable = 'powershell'
            }

            $arguments = @('-NoLogo', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $scriptPath.Path) + $ArgumentList
            $process = Start-Process -FilePath $shellExecutable -ArgumentList $arguments -NoNewWindow -PassThru -Wait
            return $process.ExitCode
        }
    }

    It 'validate-copilot-assets.ps1 completes successfully' {
        $exitCode = Invoke-RepositoryScript -ScriptName 'validate-copilot-assets.ps1' -ArgumentList @('-RepositoryRoot', $script:repoRoot)
        $exitCode | Should Be 0
    }

    It 'add-prompt-metadata.ps1 passes in check-only mode' {
        $exitCode = Invoke-RepositoryScript -ScriptName 'add-prompt-metadata.ps1' -ArgumentList @('-RepositoryRoot', $script:repoRoot, '-CheckOnly')
        $exitCode | Should Be 0
    }

    It 'run-lint.ps1 completes without errors' {
        $exitCode = Invoke-RepositoryScript -ScriptName 'run-lint.ps1' -ArgumentList @('-RepositoryRoot', $script:repoRoot)
        $exitCode | Should Be 0
    }

    It 'run-smoke-tests.ps1 validates repository health' {
        $exitCode = Invoke-RepositoryScript -ScriptName 'run-smoke-tests.ps1' -ArgumentList @('-RepositoryRoot', $script:repoRoot)
        $exitCode | Should Be 0
    }

    It 'token-report.ps1 emits JSON output' {
        $outputDirectory = Join-Path $TestDrive 'artifacts'
        $null = New-Item -ItemType Directory -Path $outputDirectory -Force
        $outputPath = Join-Path $outputDirectory 'token-report.json'

        $exitCode = Invoke-RepositoryScript -ScriptName 'token-report.ps1' -ArgumentList @('-Path', $script:repoRoot, '-OutputPath', $outputPath)
        $exitCode | Should Be 0
        Test-Path -LiteralPath $outputPath | Should Be $true

        $json = Get-Content -LiteralPath $outputPath -Raw | ConvertFrom-Json
        $json.totalTokens | Should BeGreaterThan 0
        ($json.summary | Measure-Object).Count | Should BeGreaterThan 0
    }

    It 'analyze-sessions.ps1 captures DS-Star metrics in the dashboard' {
        $dsStarFixture = Join-Path $PSScriptRoot 'fixtures/ds-star-session'
        $dsStarRoot = Join-Path $TestDrive 'plans/data-analysis'
        $sessionDirectory = Join-Path $dsStarRoot '20251115_094200_dsstar'
        $null = New-Item -ItemType Directory -Path $dsStarRoot -Force
        Copy-Item -Path $dsStarFixture -Destination $sessionDirectory -Recurse -Force

        $sessionsPath = Join-Path $TestDrive 'plans/sessions'
        $null = New-Item -ItemType Directory -Path $sessionsPath -Force
        $sampleSession = @{
            status = 'complete'
            currentPhase = 'Complete'
            escalations = @()
            modelUsage = @(
                @{ tier = 'premium'; cost = 0.12 }
                @{ tier = 'efficient'; cost = 0.06 }
            )
            reviews = @(
                @{ verdict = 'APPROVED' }
            )
            phaseDurations = @(
                @{ phase = 'Planning'; durationMinutes = 10 }
                @{ phase = 'Implementation'; durationMinutes = 25 }
                @{ phase = 'Review'; durationMinutes = 8 }
            )
        } | ConvertTo-Json -Depth 5
        Set-Content -LiteralPath (Join-Path $sessionsPath 'sample-session.json') -Value $sampleSession -Encoding UTF8

        $outputPath = Join-Path $TestDrive 'docs/dashboards'
        $null = New-Item -ItemType Directory -Path $outputPath -Force

        $exitCode = Invoke-RepositoryScript -ScriptName 'analyze-sessions.ps1' -ArgumentList @(
            '-SessionsPath', $sessionsPath,
            '-OutputPath', $outputPath,
            '-DSStarPath', $dsStarRoot,
            '-StartDate', ((Get-Date).AddDays(-2)).ToString('s'),
            '-EndDate', (Get-Date).ToString('s')
        )

        $exitCode | Should Be 0

        $dashboardPath = Join-Path $outputPath 'workflow-metrics.md'
        Test-Path -LiteralPath $dashboardPath | Should Be $true
        $dashboardContent = Get-Content -LiteralPath $dashboardPath -Raw
        $dashboardContent | Should Match 'DS-Star Workflow Metrics'
        $dashboardContent | Should Match 'Resume-Ready In-Progress'
        $dashboardContent | Should Match 'SUFFICIENT'
    }
}
