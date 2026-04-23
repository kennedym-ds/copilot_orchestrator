# PostToolUse hook — captures failed tool invocations for budget + reliability metrics.
# VS Code stdin: {sessionId, hookEventName, tool_name, tool_input, tool_exit_code, cwd}
# Only logs when tool_exit_code is non-zero (error guard — fires on every tool use).
[CmdletBinding()]
param()
. (Join-Path $PSScriptRoot "_common.ps1")
$h        = Read-HookInput
$ExitCode = if ($null -ne $h.tool_exit_code) { [int]$h.tool_exit_code } else { [int]($env:COPILOT_TOOL_EXIT_CODE) }
if ($ExitCode -eq 0) { return }
$Tool  = if ($h.tool_name)          { $h.tool_name }          else { $env:COPILOT_TOOL_NAME }
$Agent = if ($h.hookEventName)      { $h.hookEventName }       else { $env:COPILOT_ACTIVE_AGENT }
Write-HookEvent -Event 'PostToolUse' -Payload @{
    agent = $Agent; tool = $Tool; exit_code = $ExitCode
}
