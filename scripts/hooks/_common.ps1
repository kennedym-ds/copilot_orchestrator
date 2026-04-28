# Common hook logging helpers.
# Errors -> artifacts/sessions/hooks-errors.jsonl (legacy, kept for back-compat).
# Events -> artifacts/sessions/hooks/{event}.jsonl (structured per-hook stream).
#
# VS Code delivers hook context via stdin JSON (not env vars).
# Standard fields: timestamp, cwd, sessionId, hookEventName, transcript_path
# PostToolUse adds: tool_name, tool_input, tool_exit_code
# SubagentStart adds: agent_id, agent_type

$script:HookInput = $null

function Read-HookInput {
    # Reads VS Code hook payload from stdin JSON. Returns empty object on no input.
    try {
        $raw = $null
        if ([Console]::IsInputRedirected) {
            $raw = [Console]::In.ReadToEnd()
        }
        if ([string]::IsNullOrWhiteSpace($raw)) {
            for ($scope = 1; $scope -le 6 -and [string]::IsNullOrWhiteSpace($raw); $scope++) {
                $callerInput = Get-Variable -Name input -Scope $scope -ErrorAction SilentlyContinue
                if ($callerInput -and $callerInput.Value) {
                    $raw = ($callerInput.Value | Out-String)
                    break
                }
            }
        }
        if (-not [string]::IsNullOrWhiteSpace($raw)) {
            $script:HookInput = ($raw | ConvertFrom-Json -Depth 6)
            return $script:HookInput
        }
    } catch {}
    $script:HookInput = [PSCustomObject]@{}
    return $script:HookInput
}

function Get-HookSessionId {
    if ($script:HookInput -and $script:HookInput.sessionId) {
        return [string]$script:HookInput.sessionId
    }
    if ($env:COPILOT_SESSION_ID) {
        return [string]$env:COPILOT_SESSION_ID
    }
    return ''
}

function Write-AdditionalContext {
    # Emits additionalContext JSON to stdout — VS Code injects this into the assistant context.
    param([string]$Context)
    [Console]::Out.WriteLine(($([ordered]@{ additionalContext = $Context } | ConvertTo-Json -Compress)))
}

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
    if (-not $Payload.ContainsKey('session_id')) {
        $sessionId = Get-HookSessionId
        if (-not [string]::IsNullOrWhiteSpace($sessionId)) {
            $Payload['session_id'] = $sessionId
        }
    }
    $record = [ordered]@{ event = $Event; ts = (Get-Date).ToString("o") }
    foreach ($k in $Payload.Keys) { $record[$k] = $Payload[$k] }
    $json = ($record | ConvertTo-Json -Compress -Depth 6)
    Add-Content -LiteralPath (Join-Path $dir "$Event.jsonl") -Value $json -Encoding UTF8
}
