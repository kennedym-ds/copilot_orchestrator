# TaskCompleted hook — logs task completion + updates team-state.json when present.
[CmdletBinding()]
param(
    [string]$TaskId = $env:COPILOT_TASK_ID,
    [string]$Assignee = $env:COPILOT_TASK_ASSIGNEE,
    [string]$Status = $env:COPILOT_TASK_STATUS
)
. (Join-Path $PSScriptRoot "_common.ps1")
Write-HookEvent -Event 'task-completed' -Payload @{
    task_id = $TaskId; assignee = $Assignee; status = $Status
}
$state = Join-Path $PSScriptRoot "../../artifacts/sessions/team-state.json"
if (Test-Path -LiteralPath $state) {
    try {
        $json = Get-Content -LiteralPath $state -Raw | ConvertFrom-Json
        if ($json.tasks) {
            $task = $json.tasks | Where-Object { $_.id -eq $TaskId } | Select-Object -First 1
            if ($task) { $task.status = $Status; $json | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $state -Encoding UTF8 }
        }
    } catch {
        Write-HookError -Agent 'conductor' -Trigger 'task-completed' -ExitCode 1 -StderrTail $_.Exception.Message
    }
}
