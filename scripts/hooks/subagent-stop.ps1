# SubagentStop hook — records subagent completion + duration for budget analytics.
[CmdletBinding()]
param(
    [string]$Parent = $env:COPILOT_PARENT_AGENT,
    [string]$Child = $env:COPILOT_CHILD_AGENT,
    [int]$Depth = [int]($env:COPILOT_SUBAGENT_DEPTH),
    [string]$Status = $env:COPILOT_SUBAGENT_STATUS,
    [int]$DurationMs = [int]($env:COPILOT_SUBAGENT_DURATION_MS)
)
. (Join-Path $PSScriptRoot "_common.ps1")
Write-HookEvent -Event 'subagent-stop' -Payload @{
    parent = $Parent; child = $Child; depth = $Depth; status = $Status; duration_ms = $DurationMs
}
