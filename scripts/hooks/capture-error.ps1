# PostToolUse error-capture hook (formerly: trigger: error).
# Reads VS Code stdin JSON; only logs when tool_exit_code is non-zero.
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Agent
)

$ErrorActionPreference = "Continue"
. (Join-Path $PSScriptRoot "_common.ps1")
$h        = Read-HookInput
$ExitCode = if ($null -ne $h.tool_exit_code) { [int]$h.tool_exit_code } else { [int]($env:COPILOT_TOOL_EXIT_CODE) }
if ($ExitCode -eq 0) { return }

try {
    $dir = Join-Path $PSScriptRoot "../../artifacts/sessions/$Agent-errors"
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $ts   = Get-Date -Format "yyyyMMdd-HHmmss"
    $tool = if ($h.tool_name) { $h.tool_name } else { $env:COPILOT_TOOL_NAME }
    $ctx  = "tool=$tool exit_code=$ExitCode"
    $ctx | Out-File -FilePath (Join-Path $dir "$ts.log") -Encoding UTF8
    Write-HookEvent -Event 'PostToolUse' -Payload @{ agent = $Agent; tool = $tool; exit_code = $ExitCode }
} catch {
    Write-HookError -Agent $Agent -Trigger "PostToolUse" -ExitCode 1 -StderrTail $_.Exception.Message
}

