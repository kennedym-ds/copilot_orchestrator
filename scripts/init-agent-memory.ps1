<#
.SYNOPSIS
  Initialize .agent-memory templates and ensure .gitignore entry exists.

.DESCRIPTION
  Creates the `.agent-memory` folder with starter templates and optionally
  appends a .gitignore entry to avoid accidental commits of non-template files.
#>

param()

$root = Split-Path -Parent $MyInvocation.MyCommand.Definition
$agentDir = Join-Path $root "..\.agent-memory" | Resolve-Path -Relative

if (-not (Test-Path $agentDir)) {
    New-Item -ItemType Directory -Path $agentDir | Out-Null
    Write-Output "Created $agentDir"
} else {
    Write-Output ".agent-memory already exists at $agentDir"
}

# ensure templates exist (the repo already includes README and templates but keep idempotent)
$templates = @('project_decisions.md','error_patterns.md','README.md')
foreach ($t in $templates) {
    $p = Join-Path $agentDir $t
    if (-not (Test-Path $p)) { New-Item -Path $p -ItemType File -Force | Out-Null ; Write-Output "Created template $p" }
}

# ensure .gitignore contains a line suggesting templates only (do not auto-ignore the folder entirely)
$gitignore = Join-Path $root "..\.gitignore" | Resolve-Path -ErrorAction SilentlyContinue
if ($gitignore) {
    $gi = Get-Content $gitignore -Raw
    if ($gi -notmatch "^# agent-memory" ) {
        Add-Content -Path $gitignore -Value "`n# agent-memory: durable templates only - keep entries small and review before committing`n.agent-memory/*.md"
        Write-Output "Updated .gitignore with .agent-memory guidance"
    }
}

Write-Output "Initialization complete. Use scripts/add-agent-decision.ps1 to add durable facts."
