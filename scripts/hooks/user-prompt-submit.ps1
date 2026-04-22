# UserPromptSubmit hook — pre-delegation budget cap check (runs before each user prompt).
[CmdletBinding()]
param(
    [string]$SessionId = $env:COPILOT_SESSION_ID,
    [int]$TokensUsed = [int]($env:COPILOT_SESSION_TOKENS),
    [int]$TokenBudget = [int]($env:COPILOT_SESSION_BUDGET)
)
. (Join-Path $PSScriptRoot "_common.ps1")
$warn = $false
if ($TokenBudget -gt 0 -and $TokensUsed -gt ($TokenBudget * 0.8)) { $warn = $true }
Write-HookEvent -Event 'user-prompt-submit' -Payload @{
    session_id = $SessionId; tokens_used = $TokensUsed; token_budget = $TokenBudget; budget_warn = $warn
}
