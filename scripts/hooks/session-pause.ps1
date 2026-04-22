# Conductor session-pause hook.
# 1. Appends ISO-8601 timestamp to artifacts/sessions/pause-log.txt
# 2. Writes active context to Copilot Memory (per ADR-memory-layers) when copilot CLI is on PATH.
[CmdletBinding()]
param()

$ErrorActionPreference = "Continue"
. (Join-Path $PSScriptRoot "_common.ps1")

try {
    $dir = Join-Path $PSScriptRoot "../../artifacts/sessions"
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    (Get-Date).ToString("o") | Out-File -FilePath (Join-Path $dir "pause-log.txt") -Append -Encoding UTF8
} catch {
    Write-HookError -Agent "conductor" -Trigger "session-pause" -ExitCode 1 -StderrTail $_.Exception.Message
}

# Copilot Memory write (best-effort). Skip silently when the CLI is absent.
$copilot = Get-Command copilot -ErrorAction SilentlyContinue
if ($copilot) {
    $ctx = $env:COPILOT_ACTIVE_CONTEXT
    if ([string]::IsNullOrWhiteSpace($ctx)) { $ctx = "session paused at $(Get-Date -Format o)" }
    try {
        $ctx | & copilot memory write --scope session --subject active-context --stdin 2>$null
    } catch {
        Write-HookError -Agent "conductor" -Trigger "session-pause" -ExitCode 2 -StderrTail $_.Exception.Message
    }
}