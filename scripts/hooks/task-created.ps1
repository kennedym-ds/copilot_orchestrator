# TaskCreated hook — logs new task entries for team-state.json reconciliation.
[CmdletBinding()]
param(
    [string]$TaskId = $env:COPILOT_TASK_ID,
    [string]$Assignee = $env:COPILOT_TASK_ASSIGNEE,
    [string]$Title = $env:COPILOT_TASK_TITLE
)
. (Join-Path $PSScriptRoot "_common.ps1")
Write-HookEvent -Event 'task-created' -Payload @{
    task_id = $TaskId; assignee = $Assignee; title = $Title
}
