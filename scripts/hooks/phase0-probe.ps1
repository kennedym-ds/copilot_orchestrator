param([string]$EventName = "unknown")
$ErrorActionPreference = "Continue"
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$logDir = Join-Path $repoRoot "artifacts/sessions/hooks"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$logFile = Join-Path $logDir "phase0-probe.jsonl"

# Capture every env var that looks hook-related + all args + timestamp
$envDump = @{}
Get-ChildItem env: | Where-Object {
    $_.Name -match "^(COPILOT|VSCODE|TOOL|HOOK|AGENT|TASK|SUBAGENT|CHAT|CLAUDE)"
} | ForEach-Object { $envDump[$_.Name] = $_.Value }

$record = [ordered]@{
    ts         = (Get-Date).ToString("o")
    event      = $EventName
    argv       = $args
    envKeys    = ($envDump.Keys | Sort-Object)
    env        = $envDump
    cwd        = (Get-Location).Path
    stdin_hint = "read separately if present"
}

# Try to read stdin non-blocking (hooks may pass JSON payload via stdin)
try {
    if ([Console]::IsInputRedirected) {
        $stdin = [Console]::In.ReadToEnd()
        if ($stdin) { $record["stdin"] = $stdin }
    }
} catch { }

$json = $record | ConvertTo-Json -Depth 6 -Compress
Add-Content -Path $logFile -Value $json -Encoding utf8

# For additionalContext experiments (Q1), also echo a structured response on stdout
$response = @{
    hookSpecificOutput = @{
        hookEventName     = $EventName
        additionalContext = "phase0-probe fired at $((Get-Date).ToString('o')) for $EventName"
    }
} | ConvertTo-Json -Depth 4 -Compress
Write-Output $response
exit 0
