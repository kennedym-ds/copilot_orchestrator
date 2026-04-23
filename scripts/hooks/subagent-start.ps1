# SubagentStart hook — validates parent->child edge against allowlist (AGENTS.md §Nested Subagent Allow-List).
# VS Code stdin: {sessionId, hookEventName, agent_id, agent_type, cwd, transcript_path}
# agent_type is the child agent name. Parent is not provided by VS Code; tracked via env var fallback.
[CmdletBinding()]
param()
. (Join-Path $PSScriptRoot "_common.ps1")
$h = Read-HookInput
$Child  = if ($h.agent_type)                   { $h.agent_type }              else { $env:COPILOT_CHILD_AGENT }
$Parent = if ($h.parent_agent_type)             { $h.parent_agent_type }       else { $env:COPILOT_PARENT_AGENT }
$Depth  = if ($null -ne $h.nesting_depth)       { [int]$h.nesting_depth }      else { [int]($env:COPILOT_SUBAGENT_DEPTH) }

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

Write-HookEvent -Event 'SubagentStart' -Payload @{
    parent = $Parent; child = $Child; depth = $Depth; allowed = $ok
}

if (-not $ok) {
    Write-HookError -Agent $Parent -Trigger 'SubagentStart' -ExitCode 1 -StderrTail "Nested subagent edge '$edge' (depth=$Depth) not allowed. Route via conductor."
    exit 1
}

# Emit additionalContext so VS Code injects session state into the subagent's context.
$ctx = "Subagent: $Child (invoked by: $Parent, depth: $Depth)"
$activeCtxPath = Join-Path $PSScriptRoot "../../artifacts/memory/activeContext.md"
if (Test-Path -LiteralPath $activeCtxPath) {
    $body = (Get-Content -LiteralPath $activeCtxPath -Raw).Trim()
    if ($body.Length -gt 50) {
        $ctx += "`n`n--- Session Context ---`n$body"
    }
}
Write-AdditionalContext $ctx