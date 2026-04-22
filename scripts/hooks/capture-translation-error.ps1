# Translation-validator error hook: captures the error context into a dated log.
[CmdletBinding()]
param()

$ErrorActionPreference = "Continue"
. (Join-Path $PSScriptRoot "_common.ps1")

try {
    $dir = Join-Path $PSScriptRoot "../../artifacts/sessions/translation-errors"
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $ts = Get-Date -Format "yyyyMMdd-HHmmss"
    $ctx = $env:COPILOT_ERROR_CONTEXT
    if ([string]::IsNullOrWhiteSpace($ctx)) { $ctx = "(no COPILOT_ERROR_CONTEXT provided)" }
    $ctx | Out-File -FilePath (Join-Path $dir "$ts.log") -Encoding UTF8
} catch {
    Write-HookError -Agent "translation-validator" -Trigger "error" -ExitCode 1 -StderrTail $_.Exception.Message
}