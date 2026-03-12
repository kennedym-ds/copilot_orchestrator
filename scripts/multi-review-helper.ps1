# SYNOPSIS
#   Parse an HS-QUALITY consolidated JSON artifact and emit a Conductor -> Implementer `#runSubagent` command
#
# DESCRIPTION
#   Reads a JSON file produced by `multi-reviewer` (HS-QUALITY contract). Finds
#   all findings with `severity` == 'BLOCKER' and formats a runSubagent command
#   for the Conductor to hand off to the Implementer with a prioritized list.
#
# PARAMETER JsonPath
#   Path to the consolidated HS-QUALITY JSON file. If omitted, reads from stdin.
#
# EXAMPLE
#   pwsh -File scripts/multi-review-helper.ps1 -JsonPath artifacts/reviews/2026-03-11-feature-multi.json
#
#   Outputs a single line: the `#runSubagent implementer "..."` command.

param(
    [string]$JsonPath
)

try {
    if (-not $JsonPath) {
        $raw = [Console]::In.ReadToEnd()
        if (-not $raw) { throw "No input: provide -JsonPath or pipe JSON to stdin." }
        $data = $raw | ConvertFrom-Json
    } else {
        if (-not (Test-Path $JsonPath)) { throw "File not found: $JsonPath" }
        $data = Get-Content -Raw -Path $JsonPath | ConvertFrom-Json
    }
} catch {
    Write-Error "Failed to read JSON: $_"
    exit 2
}

# Validate shape minimally
if (-not $data.findings) {
    Write-Error "Invalid HS-QUALITY payload: missing 'findings' array"
    exit 3
}

$blockers = $data.findings | Where-Object { $_.severity -eq 'BLOCKER' }

if (-not $blockers -or $blockers.Count -eq 0) {
    Write-Output "No BLOCKER findings; no implementer handoff needed."
    exit 0
}

$pairs = $blockers | ForEach-Object {
    $file = $_.file -replace '"',''
    $line = if ($_.line) { $_.line } else { '1' }
    "$file`:$line"
}

$list = $pairs -join ','

$cmd = "#runSubagent implementer \"Fix BLOCKER findings: [$list]; Priority: BLOCKER first. Re-run multi-reviewer after fixes. Acceptance criteria: all BLOCKER findings cleared and multi-reviewer consensus shows no BLOCKERs.\""

Write-Output $cmd
exit 0
