# SubagentStop hook — records subagent completion + duration for budget analytics.
# VS Code stdin: {sessionId, hookEventName, agent_id, agent_type, cwd, transcript_path}
[CmdletBinding()]
param()
. (Join-Path $PSScriptRoot "_common.ps1")
$h = Read-HookInput
$Child      = if ($h.agent_type)            { $h.agent_type }         else { $env:COPILOT_CHILD_AGENT }
$Parent     = if ($h.parent_agent_type)     { $h.parent_agent_type }  else { $env:COPILOT_PARENT_AGENT }
$Depth      = if ($null -ne $h.nesting_depth) { [int]$h.nesting_depth } else { [int]($env:COPILOT_SUBAGENT_DEPTH) }
$Status     = if ($h.status)                { $h.status }             else { $env:COPILOT_SUBAGENT_STATUS }
$DurationMs = if ($null -ne $h.duration_ms) { [int]$h.duration_ms }   else { [int]($env:COPILOT_SUBAGENT_DURATION_MS) }
Write-HookEvent -Event 'SubagentStop' -Payload @{
    parent = $Parent; child = $Child; depth = $Depth; status = $Status; duration_ms = $DurationMs
}
