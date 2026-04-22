# Common hook logging helpers.
# Errors -> artifacts/sessions/hooks-errors.jsonl (legacy, kept for back-compat).
# Events -> artifacts/sessions/hooks/{event}.jsonl (structured per-hook stream).

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
        agent       = $Agent
        trigger     = $Trigger
        timestamp   = (Get-Date).ToString("o")
        exit_code   = $ExitCode
        stderr_tail = $StderrTail
    } | ConvertTo-Json -Compress
    Add-Content -LiteralPath (Join-Path $dir "hooks-errors.jsonl") -Value $entry -Encoding UTF8
}

function Write-HookEvent {
    param(
        [Parameter(Mandatory)][string]$Event,
        [Parameter(Mandatory)][hashtable]$Payload
    )
    $dir = Join-Path $PSScriptRoot "../../artifacts/sessions/hooks"
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $record = [ordered]@{ event = $Event; ts = (Get-Date).ToString("o") }
    foreach ($k in $Payload.Keys) { $record[$k] = $Payload[$k] }
    $json = ($record | ConvertTo-Json -Compress -Depth 6)
    Add-Content -LiteralPath (Join-Path $dir "$Event.jsonl") -Value $json -Encoding UTF8
}