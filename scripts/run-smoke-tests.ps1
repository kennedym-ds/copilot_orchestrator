[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RepositoryRoot = (Get-Location).Path
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $RepositoryRoot)) {
    throw "Repository root '$RepositoryRoot' was not found."
}

$resolvedRoot = (Resolve-Path -LiteralPath $RepositoryRoot).ProviderPath

function Resolve-RepositoryPath {
    param(
        [string]$Path
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    return Join-Path -Path $resolvedRoot -ChildPath $Path
}

class SmokeTestResult {
    [string]$Name
    [bool]$Passed
    [string]$Message
}

$results = New-Object System.Collections.Generic.List[SmokeTestResult]

function Invoke-SmokeTest {
    param(
        [string]$Name,
        [ScriptBlock]$Test
    )

    $result = [SmokeTestResult]::new()
    $result.Name = $Name
    $result.Passed = $false
    $result.Message = ''

    try {
        & $Test
        $result.Passed = $true
        $result.Message = 'Passed'
    } catch {
        $result.Passed = $false
        $result.Message = $_.Exception.Message
    }

    $results.Add($result) | Out-Null
}

Invoke-SmokeTest -Name 'Root instructions exist' -Test {
    $requiredInstructions = @(
        'instructions/global/00_behavior.instructions.md',
        'instructions/global/01_quality.instructions.md',
        'instructions/global/02_security.instructions.md',
        'AGENTS.md'
    )

    foreach ($path in $requiredInstructions) {
        $fullPath = Resolve-RepositoryPath -Path $path
        if (-not (Test-Path -LiteralPath $fullPath)) {
            throw "Missing required repository artifact: $path"
        }
    }
}

Invoke-SmokeTest -Name 'Validation scripts runnable' -Test {
    $scriptPath = Resolve-RepositoryPath -Path 'scripts/validate-copilot-assets.ps1'
    if (-not (Test-Path -LiteralPath $scriptPath)) {
        throw 'Validation script not found.'
    }

    $null = Get-Command -Name $scriptPath -ErrorAction Stop
}

Invoke-SmokeTest -Name 'plans directory populated' -Test {
    $plansPath = Resolve-RepositoryPath -Path 'plans'
    if (-not (Test-Path -LiteralPath $plansPath)) {
        throw 'plans directory missing.'
    }

    $items = @(Get-ChildItem -Path $plansPath)
    if ($items.Count -eq 0) {
        throw 'plans directory does not contain any items.'
    }
}

$failed = @($results | Where-Object { -not $_.Passed })

foreach ($result in $results) {
    if ($result.Passed) {
        Write-Host "[PASS] $($result.Name)" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] $($result.Name): $($result.Message)" -ForegroundColor Red
    }
}

if ($failed.Count -gt 0) {
    exit 1
}

exit 0
