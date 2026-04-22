# Generic agent session-pause hook.
# Appends an ISO-8601 timestamp to artifacts/sessions/<agent>-pause-log.txt.
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Agent
)

$ErrorActionPreference = "Continue"
. (Join-Path $PSScriptRoot "_common.ps1")

try {
    $dir = Join-Path $PSScriptRoot "../../artifacts/sessions"
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    "$((Get-Date).ToString('o')) agent=$Agent" | Out-File -FilePath (Join-Path $dir "$Agent-pause-log.txt") -Append -Encoding UTF8
} catch {
    Write-HookError -Agent $Agent -Trigger "session-pause" -ExitCode 1 -StderrTail $_.Exception.Message
}

