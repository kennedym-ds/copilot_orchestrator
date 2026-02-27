<#
.SYNOPSIS
    Configure Copilot Orchestrator for Visual Studio 2022/2025 and GitHub Copilot CLI.

.DESCRIPTION
    Sets up Copilot Orchestrator for use in:
    - Visual Studio (2022 17.x+ / 2025): Shares .github/agents/ and .github/prompts/
    - GitHub Copilot CLI: Discovers agents from .github/agents/ in current workspace

    Unlike Claude Code, Visual Studio and Copilot CLI use the same agent format as
    VS Code (.github/agents/*.agent.md), so no file transformation is needed.
    This script verifies prerequisites, symlinks or copies assets to a target project,
    and validates the configuration.

    Cross-platform: Works on Windows (PowerShell 5.1+), macOS, and Linux (PowerShell Core).

.PARAMETER RepositoryRoot
    Path to the copilot_orchestrator repository. Defaults to parent of scripts folder.

.PARAMETER TargetPath
    Project directory where agents should be available. Defaults to current directory.

.PARAMETER Platform
    Target platform: VisualStudio, CopilotCLI, or Both. Default: Both.

.PARAMETER Strategy
    How to make agents available: Symlink, Copy, or Reference.
    - Symlink: Create symlinks to orchestrator repo (recommended for single-machine dev)
    - Copy: Copy agent/prompt files to target project
    - Reference: Print guidance for configuring tilde paths in IDE settings
    Default: Symlink.

.PARAMETER Force
    Overwrite existing files. Default: $false.

.PARAMETER ValidateOnly
    Only validate the current configuration without making changes.

.EXAMPLE
    powershell -File scripts/setup-vs-cli.ps1 -Platform Both -TargetPath C:\Projects\my-app

.EXAMPLE
    powershell -File scripts/setup-vs-cli.ps1 -Platform CopilotCLI -ValidateOnly

.EXAMPLE
    powershell -File scripts/setup-vs-cli.ps1 -Strategy Copy -TargetPath ~/projects/my-app
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$RepositoryRoot = "",

    [Parameter()]
    [string]$TargetPath = "",

    [Parameter()]
    [ValidateSet("VisualStudio", "CopilotCLI", "Both")]
    [string]$Platform = "Both",

    [Parameter()]
    [ValidateSet("Symlink", "Copy", "Reference")]
    [string]$Strategy = "Symlink",

    [Parameter()]
    [switch]$Force,

    [Parameter()]
    [switch]$ValidateOnly
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

# ============================================================
# Resolve paths
# ============================================================

if ($RepositoryRoot -eq "") {
    $RepositoryRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
}
$RepositoryRoot = (Resolve-Path $RepositoryRoot).Path

if ($TargetPath -eq "") {
    $TargetPath = (Get-Location).Path
}

# Source paths
$GithubDir = Join-Path $RepositoryRoot ".github"
$AgentsSource = Join-Path $GithubDir "agents"
$PromptsSource = Join-Path $GithubDir "prompts"
$SkillsSource = Join-Path $GithubDir "skills"
$InstructionsSource = Join-Path $RepositoryRoot "instructions"
$CopilotInstr = Join-Path $GithubDir "copilot-instructions.md"

# Target paths
$TargetGithub = Join-Path $TargetPath ".github"
$TargetAgents = Join-Path $TargetGithub "agents"
$TargetPrompts = Join-Path $TargetGithub "prompts"
$TargetSkills = Join-Path $TargetGithub "skills"
$TargetInstructions = Join-Path $TargetPath "instructions"
$TargetCopilotInstr = Join-Path $TargetGithub "copilot-instructions.md"

# ============================================================
# Helpers
# ============================================================

function Test-IsAdmin {
    if ($env:OS -match "Windows") {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($identity)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    return $true  # Admin not needed on macOS/Linux for symlinks
}

function New-SymlinkSafe {
    param([string]$Link, [string]$Target, [bool]$IsDirectory = $false)

    $linkDir = Split-Path -Parent $Link
    if (-not (Test-Path $linkDir)) {
        New-Item -ItemType Directory -Path $linkDir -Force | Out-Null
    }

    if (Test-Path $Link) {
        if ($Force) {
            Remove-Item -Path $Link -Recurse -Force
        } else {
            Write-Host "  [SKIP] Already exists: $Link" -ForegroundColor Yellow
            return $false
        }
    }

    try {
        $isWindows = $false
        if ($env:OS -match "Windows") {
            $isWindows = $true
        }

        if ($IsDirectory) {
            if ($isWindows) {
                New-Item -ItemType Junction -Path $Link -Value $Target -Force | Out-Null
            } else {
                New-Item -ItemType SymbolicLink -Path $Link -Value $Target -Force | Out-Null
            }
        } else {
            New-Item -ItemType SymbolicLink -Path $Link -Value $Target -Force | Out-Null
        }
        return $true
    } catch {
        Write-Host "  [WARN] Symlink failed (try running as admin or use -Strategy Copy): $_" -ForegroundColor Yellow
        return $false
    }
}

function Copy-DirectorySafe {
    param([string]$Source, [string]$Dest)

    if (-not (Test-Path $Source)) { return }

    if (Test-Path $Dest) {
        if ($Force) {
            Remove-Item -Path $Dest -Recurse -Force
        } else {
            Write-Host "  [SKIP] Already exists: $Dest" -ForegroundColor Yellow
            return
        }
    }

    Copy-Item -Path $Source -Destination $Dest -Recurse -Force
}

function Copy-FileSafe {
    param([string]$Source, [string]$Dest)

    if (-not (Test-Path $Source)) { return }

    $destDir = Split-Path -Parent $Dest
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    if ((Test-Path $Dest) -and -not $Force) {
        Write-Host "  [SKIP] Already exists: $Dest" -ForegroundColor Yellow
        return
    }

    Copy-Item -Path $Source -Destination $Dest -Force
}

# ============================================================
# Validation
# ============================================================

function Test-OrchestratorSetup {
    param([string]$ProjectPath)

    $results = @{
        agents = @()
        prompts = @()
        skills = @()
        instructions = $false
        copilotInstructions = $false
        issues = @()
    }

    # Check agents
    $agentsDir = Join-Path (Join-Path $ProjectPath ".github") "agents"
    if (Test-Path $agentsDir) {
        $agentFiles = Get-ChildItem -Path $agentsDir -Filter "*.agent.md" -File -ErrorAction SilentlyContinue
        $results.agents = @($agentFiles | ForEach-Object { $_.Name })
    } else {
        $results.issues += "No .github/agents/ directory found"
    }

    # Check prompts
    $promptsDir = Join-Path (Join-Path $ProjectPath ".github") "prompts"
    if (Test-Path $promptsDir) {
        $promptFiles = Get-ChildItem -Path $promptsDir -Filter "*.prompt.md" -File -Recurse -ErrorAction SilentlyContinue
        $results.prompts = @($promptFiles | ForEach-Object { $_.Name })
    }

    # Check skills
    $skillsDir = Join-Path (Join-Path $ProjectPath ".github") "skills"
    if (Test-Path $skillsDir) {
        $skillDirs = Get-ChildItem -Path $skillsDir -Directory -ErrorAction SilentlyContinue
        $results.skills = @($skillDirs | ForEach-Object { $_.Name })
    }

    # Check instructions
    $instrDir = Join-Path $ProjectPath "instructions"
    if (Test-Path $instrDir) {
        $results.instructions = $true
    }

    # Check copilot-instructions.md
    $ciPath = Join-Path (Join-Path $ProjectPath ".github") "copilot-instructions.md"
    if (Test-Path $ciPath) {
        $results.copilotInstructions = $true
    }

    return $results
}

function Show-ValidationReport {
    param($Results)

    Write-Host ""
    Write-Host "--- Validation Report ---" -ForegroundColor Cyan

    if ($Results.agents.Count -gt 0) {
        Write-Host "  [OK] Agents: $($Results.agents.Count) found" -ForegroundColor Green
    } else {
        Write-Host "  [!!] No agents found" -ForegroundColor Red
    }

    if ($Results.prompts.Count -gt 0) {
        Write-Host "  [OK] Prompts: $($Results.prompts.Count) found" -ForegroundColor Green
    } else {
        Write-Host "  [--] No prompts found (optional)" -ForegroundColor Yellow
    }

    if ($Results.skills.Count -gt 0) {
        Write-Host "  [OK] Skills: $($Results.skills.Count) found" -ForegroundColor Green
    } else {
        Write-Host "  [--] No skills found (optional)" -ForegroundColor Yellow
    }

    if ($Results.copilotInstructions) {
        Write-Host "  [OK] copilot-instructions.md present" -ForegroundColor Green
    } else {
        Write-Host "  [--] No copilot-instructions.md (optional but recommended)" -ForegroundColor Yellow
    }

    if ($Results.instructions) {
        Write-Host "  [OK] instructions/ directory present" -ForegroundColor Green
    } else {
        Write-Host "  [--] No instructions/ directory (optional)" -ForegroundColor Yellow
    }

    foreach ($issue in $Results.issues) {
        Write-Host "  [!!] $issue" -ForegroundColor Red
    }

    Write-Host ""
}

# ============================================================
# Copilot CLI prerequisites check
# ============================================================

function Test-CopilotCLI {
    Write-Host "--- Checking Copilot CLI ---" -ForegroundColor Cyan

    # Check for gh CLI
    $ghPath = Get-Command "gh" -ErrorAction SilentlyContinue
    if ($ghPath) {
        Write-Host "  [OK] gh CLI found: $($ghPath.Source)" -ForegroundColor Green
    } else {
        Write-Host "  [!!] gh CLI not found - install from https://cli.github.com" -ForegroundColor Red
        return $false
    }

    # Check for Copilot extension
    try {
        $extensions = & gh extension list 2>&1
        if ($extensions -match "copilot") {
            Write-Host "  [OK] gh copilot extension installed" -ForegroundColor Green
        } else {
            Write-Host "  [!!] gh copilot extension not found" -ForegroundColor Red
            Write-Host "       Install with: gh extension install github/gh-copilot" -ForegroundColor Yellow
            return $false
        }
    } catch {
        Write-Host "  [WARN] Could not check gh extensions: $_" -ForegroundColor Yellow
    }

    # Check auth status
    try {
        $authStatus = & gh auth status 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [OK] gh authenticated" -ForegroundColor Green
        } else {
            Write-Host "  [!!] gh not authenticated - run: gh auth login" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "  [WARN] Could not check auth status: $_" -ForegroundColor Yellow
    }

    return $true
}

# ============================================================
# Visual Studio check
# ============================================================

function Test-VisualStudio {
    Write-Host "--- Checking Visual Studio ---" -ForegroundColor Cyan

    if (-not ($env:OS -match "Windows")) {
        Write-Host "  [--] Visual Studio only available on Windows" -ForegroundColor Yellow
        Write-Host "       Use VS Code or Claude Code on macOS/Linux" -ForegroundColor Yellow
        return $false
    }

    # Check for VS installation
    $vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    if (Test-Path $vsWhere) {
        try {
            $vsInfo = & $vsWhere -latest -property displayName 2>&1
            if ($vsInfo) {
                Write-Host "  [OK] Visual Studio found: $vsInfo" -ForegroundColor Green
            }

            $vsVersion = & $vsWhere -latest -property installationVersion 2>&1
            if ($vsVersion) {
                $major = ($vsVersion -split "\.")[0]
                if ([int]$major -ge 17) {
                    Write-Host "  [OK] Version $vsVersion supports Copilot agents" -ForegroundColor Green
                } else {
                    Write-Host "  [!!] Version $vsVersion - need 17.x+ for agent support" -ForegroundColor Red
                    return $false
                }
            }
        } catch {
            Write-Host "  [WARN] Could not query Visual Studio: $_" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  [--] Visual Studio not detected (vswhere not found)" -ForegroundColor Yellow
        Write-Host "       Copilot agents can still be used if VS 2022+ is installed" -ForegroundColor Yellow
    }

    return $true
}

# ============================================================
# Main execution
# ============================================================

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host " Copilot Orchestrator -> VS / CLI Setup"          -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Platform:       $Platform" -ForegroundColor White
Write-Host "Strategy:       $Strategy" -ForegroundColor White
Write-Host "Source:         $RepositoryRoot" -ForegroundColor White
Write-Host "Target:         $TargetPath" -ForegroundColor White
Write-Host ""

# Validate source
if (-not (Test-Path $AgentsSource)) {
    Write-Host "[ERROR] Agents source not found: $AgentsSource" -ForegroundColor Red
    Write-Host "[HINT]  Use -RepositoryRoot to point to the copilot_orchestrator repo." -ForegroundColor Yellow
    exit 1
}

# ============================================================
# Validate-only mode
# ============================================================

if ($ValidateOnly) {
    Write-Host "--- Validation-Only Mode ---" -ForegroundColor Cyan
    Write-Host ""

    if ($Platform -eq "Both" -or $Platform -eq "VisualStudio") {
        Test-VisualStudio | Out-Null
    }
    if ($Platform -eq "Both" -or $Platform -eq "CopilotCLI") {
        Test-CopilotCLI | Out-Null
    }

    Write-Host ""
    $results = Test-OrchestratorSetup -ProjectPath $TargetPath
    Show-ValidationReport -Results $results

    if ($results.agents.Count -gt 0) {
        Write-Host "[PASS] Target project is configured for Copilot agents." -ForegroundColor Green
        exit 0
    } else {
        Write-Host "[FAIL] Target project needs agent configuration." -ForegroundColor Red
        Write-Host "       Run this script without -ValidateOnly to set up." -ForegroundColor Yellow
        exit 1
    }
}

# ============================================================
# Platform checks
# ============================================================

if ($Platform -eq "Both" -or $Platform -eq "VisualStudio") {
    Test-VisualStudio | Out-Null
    Write-Host ""
}

if ($Platform -eq "Both" -or $Platform -eq "CopilotCLI") {
    Test-CopilotCLI | Out-Null
    Write-Host ""
}

# ============================================================
# Apply strategy
# ============================================================

switch ($Strategy) {
    "Symlink" {
        Write-Host "--- Creating Symlinks ---" -ForegroundColor Cyan

        # Ensure .github exists
        if (-not (Test-Path $TargetGithub)) {
            New-Item -ItemType Directory -Path $TargetGithub -Force | Out-Null
        }

        # Agents (required)
        $ok = New-SymlinkSafe -Link $TargetAgents -Target $AgentsSource -IsDirectory $true
        if ($ok) { Write-Host "  [OK] Linked agents" -ForegroundColor Green }

        # Prompts
        if (Test-Path $PromptsSource) {
            $ok = New-SymlinkSafe -Link $TargetPrompts -Target $PromptsSource -IsDirectory $true
            if ($ok) { Write-Host "  [OK] Linked prompts" -ForegroundColor Green }
        }

        # Skills
        if (Test-Path $SkillsSource) {
            $ok = New-SymlinkSafe -Link $TargetSkills -Target $SkillsSource -IsDirectory $true
            if ($ok) { Write-Host "  [OK] Linked skills" -ForegroundColor Green }
        }

        # Instructions
        if (Test-Path $InstructionsSource) {
            $ok = New-SymlinkSafe -Link $TargetInstructions -Target $InstructionsSource -IsDirectory $true
            if ($ok) { Write-Host "  [OK] Linked instructions" -ForegroundColor Green }
        }

        # copilot-instructions.md
        if (Test-Path $CopilotInstr) {
            $ok = New-SymlinkSafe -Link $TargetCopilotInstr -Target $CopilotInstr
            if ($ok) { Write-Host "  [OK] Linked copilot-instructions.md" -ForegroundColor Green }
        }
    }

    "Copy" {
        Write-Host "--- Copying Files ---" -ForegroundColor Cyan

        # Agents (required)
        Copy-DirectorySafe -Source $AgentsSource -Dest $TargetAgents
        Write-Host "  [OK] Copied agents" -ForegroundColor Green

        # Prompts
        if (Test-Path $PromptsSource) {
            Copy-DirectorySafe -Source $PromptsSource -Dest $TargetPrompts
            Write-Host "  [OK] Copied prompts" -ForegroundColor Green
        }

        # Skills
        if (Test-Path $SkillsSource) {
            Copy-DirectorySafe -Source $SkillsSource -Dest $TargetSkills
            Write-Host "  [OK] Copied skills" -ForegroundColor Green
        }

        # Instructions
        if (Test-Path $InstructionsSource) {
            Copy-DirectorySafe -Source $InstructionsSource -Dest $TargetInstructions
            Write-Host "  [OK] Copied instructions" -ForegroundColor Green
        }

        # copilot-instructions.md
        if (Test-Path $CopilotInstr) {
            Copy-FileSafe -Source $CopilotInstr -Dest $TargetCopilotInstr
            Write-Host "  [OK] Copied copilot-instructions.md" -ForegroundColor Green
        }
    }

    "Reference" {
        Write-Host "--- Reference Configuration ---" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Add these settings to your IDE to reference the orchestrator directly:" -ForegroundColor White
        Write-Host ""

        # Normalize path for tilde notation
        $HomeDir = if ($env:HOME) { $env:HOME } elseif ($env:USERPROFILE) { $env:USERPROFILE } else { "~" }
        $repoRelative = $RepositoryRoot -replace [regex]::Escape($HomeDir), "~"

        Write-Host "  --- VS Code / Visual Studio settings.json ---" -ForegroundColor Yellow
        Write-Host @"

    "chat.agentFilesLocations": { "$repoRelative/.github/agents": true },
    "chat.agentSkillsLocations": { "$repoRelative/.github/skills": true },
    "chat.promptFilesLocations": ["$repoRelative/.github/prompts"],
    "chat.instructionsFilesLocations": ["$repoRelative/instructions"]

"@ -ForegroundColor Gray

        Write-Host "  --- Copilot CLI ---" -ForegroundColor Yellow
        Write-Host @"

    The CLI discovers agents from .github/agents/ in the current
    working directory. Either cd to the orchestrator repo or use
    symlinks (Strategy: Symlink) to make agents available.

    Usage:
      gh copilot                    # Interactive mode
      gh copilot suggest "query"    # Agent-powered suggestions

"@ -ForegroundColor Gray
    }
}

Write-Host ""

# ============================================================
# Post-setup validation
# ============================================================

Write-Host "--- Post-Setup Validation ---" -ForegroundColor Cyan
$results = Test-OrchestratorSetup -ProjectPath $TargetPath
Show-ValidationReport -Results $results

# ============================================================
# Summary
# ============================================================

Write-Host "================================================" -ForegroundColor Green
Write-Host " Setup Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""

$agentCount = $results.agents.Count
$skillCount = $results.skills.Count
$promptCount = $results.prompts.Count

Write-Host "  Agents:       $agentCount" -ForegroundColor White
Write-Host "  Skills:       $skillCount" -ForegroundColor White
Write-Host "  Prompts:      $promptCount" -ForegroundColor White
Write-Host "  Strategy:     $Strategy" -ForegroundColor White
Write-Host ""

if ($Platform -eq "Both" -or $Platform -eq "VisualStudio") {
    Write-Host "Visual Studio:" -ForegroundColor Cyan
    Write-Host "  1. Open $TargetPath in Visual Studio 2022+" -ForegroundColor White
    Write-Host "  2. Copilot Chat should auto-discover agents from .github/agents/" -ForegroundColor White
    Write-Host "  3. Use @conductor or other agents in Copilot Chat" -ForegroundColor White
    Write-Host ""
}

if ($Platform -eq "Both" -or $Platform -eq "CopilotCLI") {
    Write-Host "Copilot CLI:" -ForegroundColor Cyan
    Write-Host "  1. cd $TargetPath" -ForegroundColor White
    Write-Host "  2. gh copilot" -ForegroundColor White
    Write-Host "  3. Agents are available via @conductor etc." -ForegroundColor White
    Write-Host ""
}

Write-Host "Troubleshooting:" -ForegroundColor Yellow
Write-Host "  - Run with -ValidateOnly to check configuration" -ForegroundColor White
Write-Host "  - Ensure Copilot extension is enabled in VS" -ForegroundColor White
Write-Host "  - For CLI: gh extension install github/gh-copilot" -ForegroundColor White
Write-Host ""
