<#
.SYNOPSIS
  Lint agent files for user-choice prompts without corresponding clickable handoff buttons.

.DESCRIPTION
  Scans `.github/agents/*.agent.md` files for common question/choice phrases
  (e.g. "Would you like", "Which track", "Do you want", "Select") and verifies
  that the agent frontmatter contains at least one `handoffs:` entry with `send: true`.

  This enforces the clickable-action requirement in `instructions/workflows/conductor.instructions.md`.

.EXIT
  0 — no violations
  1 — violations found
#>

param(
    [string]$AgentsDir = ".github/agents",
    [switch]$Verbose
)

Set-StrictMode -Version Latest

function Get-FrontMatter {
    param([string]$text)
    if ($text -match '(?s)^---\r?\n(.*?)\r?\n---') { return $matches[1] } else { return $null }
}

function Has-SendTrueInHandoffs {
    param([string]$front)
    if (-not $front) { return $false }
    # find handoffs block
    if ($front -notmatch "handoffs:\s*") { return $false }
    # crude parse: check for any 'send: true' under handoffs
    if ($front -match "send:\s*true") { return $true }
    return $false
}

$repoRoot = Get-Location
$agentFiles = Get-ChildItem -Path $AgentsDir -Filter "*.agent.md" -Recurse -ErrorAction SilentlyContinue

if (-not $agentFiles) {
    Write-Output "No agent files found under $AgentsDir"
    exit 0
}

$questionPatterns = @(
    'Would you like',
    'Would you like me',
    'Do you want',
    'Which track',
    'Which option',
    'Select',
    'Choose',
    'Click',
    'Would you prefer',
    'Which do you prefer'
)

$violations = @()

foreach ($f in $agentFiles) {
    $text = Get-Content -Raw -Path $f.FullName -ErrorAction SilentlyContinue
    if (-not $text) { continue }

    $hasQuestion = $false
    foreach ($p in $questionPatterns) {
        if ($text -match [regex]::Escape($p)) { $hasQuestion = $true; break }
    }

    if (-not $hasQuestion) { continue }

    $front = Get-FrontMatter -text $text
    $hasSendTrue = $false
    if ($front) { $hasSendTrue = Has-SendTrueInHandoffs -front $front }

    if (-not $hasSendTrue) {
        $snippet = ($text -split "\r?\n") | Where-Object { $_ -match ($questionPatterns -join '|') } | Select-Object -First 3
        $violations += [PSCustomObject]@{
            File = $f.FullName
            Questions = ($snippet -join ' | ')
            FrontMatterPresent = ($front -ne $null)
            SendTrueFound = $hasSendTrue
        }
    }
}

if ($violations.Count -gt 0) {
    Write-Output "Found $($violations.Count) agent files that ask for user choices but lack clickable handoff buttons (send: true) in their frontmatter handoffs."
    foreach ($v in $violations) {
        Write-Output "- $($v.File)"
        Write-Output "  Questions: $($v.Questions)"
        Write-Output "  FrontMatterPresent: $($v.FrontMatterPresent) | SendTrueFound: $($v.SendTrueFound)";
    }
    exit 1
} else {
    Write-Output "No violations found. All agent choice prompts have handoff buttons with send: true."
    exit 0
}
