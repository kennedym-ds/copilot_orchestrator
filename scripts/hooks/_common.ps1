# Common hook logging helper.
# Logs hook failures to artifacts/sessions/hooks-errors.jsonl per phase-2-hooks-spec.md.
function Write-HookError {
    param(
        [string]$Agent,
        [string]$Trigger,
        [int]$ExitCode,
        [string]$StderrTail
    )
    $dir = Join-Path $PSScriptRoot "../../artifacts/sessions"
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $entry = [ordered]@{
        agent      = $Agent
        trigger    = $Trigger
        timestamp  = (Get-Date).ToString("o")
        exit_code  = $ExitCode
        stderr_tail = $StderrTail
    } | ConvertTo-Json -Compress
    Add-Content -LiteralPath (Join-Path $dir "hooks-errors.jsonl") -Value $entry -Encoding UTF8
}