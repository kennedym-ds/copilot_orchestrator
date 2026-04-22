# PreCompact hook — snapshots active context before strategic compaction.
[CmdletBinding()]
param(
    [string]$Agent = $env:COPILOT_ACTIVE_AGENT,
    [int]$Tokens = [int]($env:COPILOT_CONTEXT_TOKENS)
)
. (Join-Path $PSScriptRoot "_common.ps1")
$dir = Join-Path $PSScriptRoot "../../artifacts/sessions/snapshots"
if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
$snapshot = Join-Path $dir ("pre-compact-{0:yyyyMMdd-HHmmss}.txt" -f (Get-Date))
$ctx = $env:COPILOT_ACTIVE_CONTEXT
if (-not [string]::IsNullOrWhiteSpace($ctx)) { $ctx | Out-File -FilePath $snapshot -Encoding UTF8 }
Write-HookEvent -Event 'pre-compact' -Payload @{
    agent = $Agent; tokens = $Tokens; snapshot = $snapshot
}
