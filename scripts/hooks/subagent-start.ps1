# SubagentStart hook — validates parent->child edge against allowlist (AGENTS.md §Nested Subagent Allow-List).
[CmdletBinding()]
param(
    [string]$Parent = $env:COPILOT_PARENT_AGENT,
    [string]$Child = $env:COPILOT_CHILD_AGENT,
    [int]$Depth = [int]($env:COPILOT_SUBAGENT_DEPTH)
)
. (Join-Path $PSScriptRoot "_common.ps1")

$allowed = @(
    @{ parent='implementer'; child='test' },
    @{ parent='implementer'; child='researcher' },
    @{ parent='reviewer';    child='researcher' },
    @{ parent='reviewer';    child='reviewer' },
    @{ parent='planner';     child='researcher' },
    @{ parent='translation-conductor'; child='translator' },
    @{ parent='translation-conductor'; child='translation-analyzer' }
)

$edge = "$Parent->$Child"
$match = $allowed | Where-Object { $_.parent -eq $Parent -and $_.child -eq $Child }
$ok = [bool]$match -and $Depth -le 2

Write-HookEvent -Event 'subagent-start' -Payload @{
    parent = $Parent; child = $Child; depth = $Depth; allowed = $ok
}

if (-not $ok) {
    Write-HookError -Agent $Parent -Trigger 'subagent-start' -ExitCode 1 -StderrTail "Nested subagent edge '$edge' (depth=$Depth) not allowed. Route via conductor."
    exit 1
}