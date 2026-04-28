# SessionStart hook — emits project context as additionalContext so the agent
# has key conventions and session state without reading AGENTS.md.
# VS Code stdin: {sessionId, hookEventName, cwd, transcript_path}
[CmdletBinding()]
param()
. (Join-Path $PSScriptRoot "_common.ps1")
$h         = Read-HookInput
$SessionId = if ($h.sessionId) { $h.sessionId } else { $env:COPILOT_SESSION_ID }
$Cwd       = if ($h.cwd)       { $h.cwd }       else { $env:COPILOT_CWD }
$repoRoot  = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

$pythonVersion = ''
try {
    $pythonVersion = (& python --version 2>&1)
} catch {
    $pythonVersion = ''
}
if ([string]::IsNullOrWhiteSpace($pythonVersion)) {
    $pythonVersion = "python not found"
}

$venv = if ($env:VIRTUAL_ENV) { $env:VIRTUAL_ENV } else { '' }
if ([string]::IsNullOrWhiteSpace($venv)) {
    $venvCandidates = @(
        Join-Path $repoRoot ".venv\Scripts\python.exe",
        Join-Path $repoRoot "venv\Scripts\python.exe",
        Join-Path $repoRoot "env\Scripts\python.exe"
    )
    foreach ($candidate in $venvCandidates) {
        if (Test-Path -LiteralPath $candidate) {
            $venv = (Split-Path -Parent (Split-Path -Parent $candidate))
            break
        }
    }
}
if ([string]::IsNullOrWhiteSpace($venv)) {
    $venv = "not detected"
}

$ctx  = "Project: Copilot Orchestrator (16-agent orchestration system)`n"
$ctx += "Shell: Windows PowerShell 5.1 (scripts use `"powershell`"; cross-platform uses `"pwsh`")`n"
$ctx += "Validate: pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .`n"
$ctx += "Test: Invoke-Pester -Path tests -Output Detailed`n"
$ctx += "Pre-PR: pwsh -File scripts/run-lint.ps1; pwsh -File scripts/run-smoke-tests.ps1`n"
$ctx += "Python: $pythonVersion`n"
$ctx += "Venv: $venv"

$activeCtxPath = Join-Path $PSScriptRoot "../../artifacts/memory/activeContext.md"
if (Test-Path -LiteralPath $activeCtxPath) {
    $body = (Get-Content -LiteralPath $activeCtxPath -Raw).Trim()
    if ($body.Length -gt 50) {
        $ctx += "`n`n--- Active Session Context ---`n$body"
    }
}

Write-AdditionalContext $ctx
Write-HookEvent -Event 'SessionStart' -Payload @{ session_id = $SessionId; cwd = $Cwd }
