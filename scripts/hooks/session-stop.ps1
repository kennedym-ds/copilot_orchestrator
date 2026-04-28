[CmdletBinding()]
param()

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot "_common.ps1")

$h = Read-HookInput
$SessionId = if ($h.sessionId) { [string]$h.sessionId } else { $env:COPILOT_SESSION_ID }
$Cwd = if ($h.cwd) { [string]$h.cwd } else { $env:COPILOT_CWD }
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

$modifiedFiles = @()
try {
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) {
        $status = & git -C $repoRoot status --porcelain 2>$null
        if ($status) {
            $modifiedFiles = $status | ForEach-Object {
                if ($_.Length -gt 3) { $_.Substring(3) } else { $_ }
            }
        }
    }
} catch {
    Write-HookError -Agent "conductor" -Trigger "SessionStop" -ExitCode 1 -StderrTail $_.Exception.Message
}

$modifiedCount = $modifiedFiles.Count
$recapLines = @(
    "## Session Recap (auto)",
    "- Session ID: $SessionId",
    "- Ended: $(Get-Date -Format o)",
    "- Repo: $repoRoot",
    "- Modified files: $modifiedCount"
)
if ($modifiedCount -gt 0) {
    foreach ($file in ($modifiedFiles | Select-Object -First 20)) {
        $recapLines += "  - $file"
    }
}
$recap = $recapLines -join "`n"

$activeCtxPath = Join-Path $PSScriptRoot "../../artifacts/memory/activeContext.md"
try {
    $ctxDir = Split-Path -Parent $activeCtxPath
    if (-not (Test-Path -LiteralPath $ctxDir)) {
        New-Item -ItemType Directory -Path $ctxDir -Force | Out-Null
    }
    if (Test-Path -LiteralPath $activeCtxPath) {
        Add-Content -LiteralPath $activeCtxPath -Value "`r`n$recap" -Encoding UTF8
    } else {
        Set-Content -LiteralPath $activeCtxPath -Value $recap -Encoding UTF8
    }
} catch {
    Write-HookError -Agent "conductor" -Trigger "SessionStop" -ExitCode 1 -StderrTail $_.Exception.Message
}

Write-HookEvent -Event 'SessionStop' -Payload @{
    session_id = $SessionId
    cwd = $Cwd
    modified_count = $modifiedCount
    modified_files = ($modifiedFiles | Select-Object -First 20)
}
