[CmdletBinding()]
param(
    [int]$LineThreshold = 400
)

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

function Get-ToolContent {
    param([object]$InputObject)
    if (-not $InputObject) { return $null }
    foreach ($key in @('content', 'new_content', 'patch', 'text', 'input')) {
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

$content = Get-ToolContent -InputObject (Get-PropertyValue -InputObject $h -Name 'tool_input')
if (-not $content) { return }

$lineCount = ($content -split "`r?`n").Count
if ($lineCount -lt $LineThreshold) { return }

$path = Get-ToolPath -InputObject (Get-PropertyValue -InputObject $h -Name 'tool_input')
Write-AdditionalContext -Context ("Large edit detected ({0} lines). Consider splitting into smaller patches for review clarity." -f $lineCount)
Write-HookEvent -Event 'PostToolUseLargeEdit' -Payload @{
    path = $path
    tool = $toolName
    line_count = $lineCount
    threshold = $LineThreshold
}
