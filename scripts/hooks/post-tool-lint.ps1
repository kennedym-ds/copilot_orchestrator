[CmdletBinding()]
param(
    [string]$Agent = $env:COPILOT_ACTIVE_AGENT
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot "_common.ps1")
$h = Read-HookInput

function Get-PropertyValue {
    param(
        [object]$InputObject,
        [string]$Name
    )
    if (-not $InputObject) { return $null }
    if ($InputObject -is [System.Collections.IDictionary]) {
        foreach ($key in $InputObject.Keys) {
            if ($key -ieq $Name) { return $InputObject[$key] }
        }
    }
    foreach ($prop in $InputObject.PSObject.Properties) {
        if ($prop.Name -ieq $Name) { return $prop.Value }
    }
    return $null
}

$toolName = Get-PropertyValue -InputObject $h -Name 'tool_name'
if (-not $toolName) { $toolName = $env:COPILOT_TOOL_NAME }
$path = ''
if (Get-PropertyValue -InputObject $h -Name 'tool_input') {
    $toolInput = Get-PropertyValue -InputObject $h -Name 'tool_input'
    $path = Get-PropertyValue -InputObject $toolInput -Name 'path'
    if (-not $path) {
        $path = Get-PropertyValue -InputObject $toolInput -Name 'file'
    }
    if ($path) { $path = [string]$path }
}

if ([string]::IsNullOrWhiteSpace($path)) { return }
if ($path -notmatch '\.md$') { return }

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$lintScript = Join-Path $repoRoot "scripts/run-lint.ps1"
$exitCode = 0

try {
    & powershell -NoProfile -File $lintScript -RepositoryRoot $repoRoot | Out-Null
    $exitCode = $LASTEXITCODE
} catch {
    $exitCode = 1
    Write-HookError -Agent $Agent -Trigger 'PostToolUseLint' -ExitCode 1 -StderrTail $_.Exception.Message
}

Write-HookEvent -Event 'PostToolUseLint' -Payload @{
    agent     = $Agent
    tool      = $toolName
    path      = $path
    exit_code = $exitCode
}

if ($exitCode -ne 0) {
    Write-HookError -Agent $Agent -Trigger 'PostToolUseLint' -ExitCode $exitCode -StderrTail "run-lint.ps1 failed with exit code $exitCode"
}
