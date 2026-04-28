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

$path = Get-ToolPath -InputObject (Get-PropertyValue -InputObject $h -Name 'tool_input')
if (-not $path) { return }

$lowerPath = $path.ToLowerInvariant()
if (-not $lowerPath.EndsWith('.md')) { return }

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$fullPath = if ([IO.Path]::IsPathRooted($path)) { $path } else { Join-Path $repoRoot $path }
if (-not (Test-Path -LiteralPath $fullPath)) { return }

$changed = $false
try {
    $lines = Get-Content -LiteralPath $fullPath
    $trimmed = $lines | ForEach-Object { $_.TrimEnd() }
    if (($lines -join "`n") -ne ($trimmed -join "`n")) {
        Set-Content -LiteralPath $fullPath -Value $trimmed -Encoding UTF8
        $changed = $true
    }
} catch {
    Write-HookError -Agent "implementer" -Trigger "PostToolUseMarkdownFormat" -ExitCode 1 -StderrTail $_.Exception.Message
}

Write-HookEvent -Event 'PostToolUseMarkdownFormat' -Payload @{
    path = $path
    changed = $changed
}
