# UserPromptSubmit hook (reviewer): loads most recent security findings as additionalContext.
# VS Code stdin: {sessionId, hookEventName, cwd, transcript_path}
# Emits additionalContext JSON to stdout so VS Code injects it into the assistant's context.
[CmdletBinding()]
param()

$ErrorActionPreference = "Continue"
. (Join-Path $PSScriptRoot "_common.ps1")
$null = Read-HookInput

try {
    $dir = Join-Path $PSScriptRoot "../../artifacts/reviews"
    if (-not (Test-Path -LiteralPath $dir)) { return }
    $snippets = Get-ChildItem -LiteralPath $dir -Filter '*security*' -Recurse -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 3 |
        ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw }
    if ($snippets) {
        Write-AdditionalContext ($snippets -join "`n---`n")
    }
} catch {
    Write-HookError -Agent "reviewer" -Trigger "UserPromptSubmit" -ExitCode 1 -StderrTail $_.Exception.Message
}