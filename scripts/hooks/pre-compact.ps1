# PreCompact hook — snapshots active context before strategic compaction.
# VS Code stdin: {sessionId, hookEventName, cwd, transcript_path}
[CmdletBinding()]
param()
. (Join-Path $PSScriptRoot "_common.ps1")
$h         = Read-HookInput
$SessionId = if ($h.sessionId)        { $h.sessionId }         else { $env:COPILOT_SESSION_ID }
$Tokens    = if ($null -ne $h.tokens) { [int]$h.tokens }        else { [int]($env:COPILOT_CONTEXT_TOKENS) }
$dir = Join-Path $PSScriptRoot "../../artifacts/sessions/snapshots"
if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
$snapshot = Join-Path $dir ("pre-compact-{0:yyyyMMdd-HHmmss}.txt" -f (Get-Date))
# transcript_path from stdin provides the full conversation transcript
if ($h.transcript_path -and (Test-Path -LiteralPath $h.transcript_path)) {
    Copy-Item -LiteralPath $h.transcript_path -Destination $snapshot -Force
}
Write-HookEvent -Event 'PreCompact' -Payload @{
    session_id = $SessionId; tokens = $Tokens; snapshot = $snapshot
}
