# SessionStart hook — emits project context as additionalContext so the agent
# has key conventions and session state without reading AGENTS.md.
# VS Code stdin: {sessionId, hookEventName, cwd, transcript_path}
[CmdletBinding()]
param()
. (Join-Path $PSScriptRoot "_common.ps1")
$h         = Read-HookInput
$SessionId = if ($h.sessionId) { $h.sessionId } else { $env:COPILOT_SESSION_ID }
$Cwd       = if ($h.cwd)       { $h.cwd }       else { $env:COPILOT_CWD }

$ctx  = "Project: Copilot Orchestrator (16-agent orchestration system)`n"
$ctx += "Shell: Windows PowerShell 5.1 (scripts use `"powershell`"; cross-platform uses `"pwsh`")`n"
$ctx += "Validate: pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .`n"
$ctx += "Test: Invoke-Pester -Path tests -Output Detailed`n"
$ctx += "Pre-PR: pwsh -File scripts/run-lint.ps1; pwsh -File scripts/run-smoke-tests.ps1"

$activeCtxPath = Join-Path $PSScriptRoot "../../artifacts/memory/activeContext.md"
if (Test-Path -LiteralPath $activeCtxPath) {
    $body = (Get-Content -LiteralPath $activeCtxPath -Raw).Trim()
    if ($body.Length -gt 50) {
        $ctx += "`n`n--- Active Session Context ---`n$body"
    }
}

Write-AdditionalContext $ctx
Write-HookEvent -Event 'SessionStart' -Payload @{ session_id = $SessionId; cwd = $Cwd }
