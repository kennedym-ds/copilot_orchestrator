# Reviewer pre-prompt hook: loads three most recent security review findings into stdout.
[CmdletBinding()]
param()

$ErrorActionPreference = "Continue"
. (Join-Path $PSScriptRoot "_common.ps1")

try {
    $dir = Join-Path $PSScriptRoot "../../artifacts/reviews"
    if (-not (Test-Path -LiteralPath $dir)) { return }
    Get-ChildItem -LiteralPath $dir -Filter '*security*' -Recurse -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 3 |
        ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw }
} catch {
    Write-HookError -Agent "reviewer" -Trigger "pre-prompt" -ExitCode 1 -StderrTail $_.Exception.Message
}