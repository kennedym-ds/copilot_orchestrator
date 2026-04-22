# PostToolUseFailure hook — captures failed tool invocations for budget + reliability metrics.
[CmdletBinding()]
param(
    [string]$Agent = $env:COPILOT_ACTIVE_AGENT,
    [string]$Tool = $env:COPILOT_TOOL_NAME,
    [int]$ExitCode = [int]($env:COPILOT_TOOL_EXIT_CODE),
    [string]$Error = $env:COPILOT_TOOL_ERROR_TAIL
)
. (Join-Path $PSScriptRoot "_common.ps1")
Write-HookEvent -Event 'post-tool-failure' -Payload @{
    agent = $Agent; tool = $Tool; exit_code = $ExitCode; error_tail = $Error
}
