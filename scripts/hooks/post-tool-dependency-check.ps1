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
$depType = $null
$installCommand = $null

if ($lowerPath.EndsWith('requirements.txt')) {
    $depType = 'python-requirements'
    $installCommand = 'pip install -r requirements.txt'
} elseif ($lowerPath.EndsWith('pyproject.toml')) {
    $depType = 'python-pyproject'
    $installCommand = 'pip install -e .'
} elseif ($lowerPath.EndsWith('package.json') -or
    $lowerPath.EndsWith('package-lock.json') -or
    $lowerPath.EndsWith('pnpm-lock.yaml') -or
    $lowerPath.EndsWith('yarn.lock')) {
    $depType = 'node'
    $installCommand = 'npm install'
}

if (-not $depType) { return }

$autoInstall = $env:COPILOT_AUTO_INSTALL
if (-not $autoInstall -or $autoInstall -eq '0') {
    Write-AdditionalContext -Context ("Dependency change detected ({0}: {1}). Recommended: {2}" -f $depType, $path, $installCommand)
    Write-HookEvent -Event 'PostToolUseDependencyCheck' -Payload @{
        path = $path
        dependency_type = $depType
        ran_install = $false
        recommended = $installCommand
    }
    return
}

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$exitCode = 0
try {
    Push-Location $repoRoot
    if ($depType -eq 'node') {
        & npm install | Out-Null
    } else {
        if ($lowerPath.EndsWith('requirements.txt')) {
            & pip install -r requirements.txt | Out-Null
        } else {
            & pip install -e . | Out-Null
        }
    }
    $exitCode = $LASTEXITCODE
} catch {
    Write-HookError -Agent "implementer" -Trigger "PostToolUseDependencyCheck" -ExitCode 1 -StderrTail $_.Exception.Message
    $exitCode = 1
} finally {
    Pop-Location
}

Write-HookEvent -Event 'PostToolUseDependencyCheck' -Payload @{
    path = $path
    dependency_type = $depType
    ran_install = $true
    exit_code = $exitCode
}
