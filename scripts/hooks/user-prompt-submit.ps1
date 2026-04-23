# UserPromptSubmit hook — pre-delegation budget cap check (runs before each user prompt).
[CmdletBinding()]
param()
. (Join-Path $PSScriptRoot "_common.ps1")
$h = Read-HookInput
$SessionId   = if ($h.sessionId)                             { $h.sessionId }   else { $env:COPILOT_SESSION_ID }
$TokensUsed  = if ($null -ne $h.tokens_used)                 { [int]$h.tokens_used }  else { [int]($env:COPILOT_SESSION_TOKENS) }
$TokenBudget = if ($null -ne $h.token_budget)                { [int]$h.token_budget } else { [int]($env:COPILOT_SESSION_BUDGET) }
$warn = $TokenBudget -gt 0 -and $TokensUsed -gt ($TokenBudget * 0.8)
Write-HookEvent -Event 'UserPromptSubmit' -Payload @{
    session_id = $SessionId; tokens_used = $TokensUsed; token_budget = $TokenBudget; budget_warn = $warn
}
