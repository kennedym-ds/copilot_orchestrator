[CmdletBinding()]
param()

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot "_common.ps1")

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

function Get-ToolPath {
    param([object]$InputObject)
    if (-not $InputObject) { return $null }
    foreach ($key in @('path', 'file_path', 'filePath', 'filepath', 'target_path')) {
        $value = Get-PropertyValue -InputObject $InputObject -Name $key
        if ($value) { return [string]$value }
    }
    return $null
}

$h = Read-HookInput
$toolExitCode = Get-PropertyValue -InputObject $h -Name 'tool_exit_code'
if ($null -eq $toolExitCode) { $toolExitCode = 0 }
if ([int]$toolExitCode -ne 0) { return }

$toolName = Get-PropertyValue -InputObject $h -Name 'tool_name'
if (-not $toolName) { $toolName = '' }
if ($toolName -ne 'edit' -and $toolName -ne 'apply_patch') { return }

$skip = $env:COPILOT_SKIP_TOKEN_REPORT
if ($skip -and $skip -ne '0') {
    Write-HookEvent -Event 'PostToolUseTokenReport' -Payload @{
        skipped = $true
        reason = 'COPILOT_SKIP_TOKEN_REPORT set'
    }
    return
}

$path = Get-ToolPath -InputObject (Get-PropertyValue -InputObject $h -Name 'tool_input')
if (-not $path) { return }

$lowerPath = $path.ToLowerInvariant()
$isMarkdown = $lowerPath.EndsWith('.md')
$isDocs = ($lowerPath -match '(^|[\\/])docs[\\/]') -or ($lowerPath -match '(readme|changelog)\.md$')
if (-not ($isMarkdown -and $isDocs)) { return }

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$scriptPath = Join-Path $repoRoot "scripts/token-report.ps1"
if (-not (Test-Path -LiteralPath $scriptPath)) {
    Write-HookEvent -Event 'PostToolUseTokenReport' -Payload @{
        path = $path
        skipped = $true
        reason = 'token-report.ps1 missing'
    }
    return
}

try {
    $runner = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($runner) {
        & pwsh -File $scriptPath -Path $repoRoot | Out-Null
    } else {
        & powershell -NoProfile -File $scriptPath -Path $repoRoot | Out-Null
    }
    $exitCode = $LASTEXITCODE
} catch {
    Write-HookError -Agent "implementer" -Trigger "PostToolUseTokenReport" -ExitCode 1 -StderrTail $_.Exception.Message
    $exitCode = 1
}

Write-HookEvent -Event 'PostToolUseTokenReport' -Payload @{
    path = $path
    exit_code = $exitCode
}
