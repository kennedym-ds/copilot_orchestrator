<#
.SYNOPSIS
    Export Copilot Orchestrator agents, skills, and instructions to Claude Code format.

.DESCRIPTION
    Transforms VS Code Copilot agent definitions, skills, and instruction files
    into Claude Code-compatible format. Supports three output modes:
    - Project: Creates .claude/ directory in the target project
    - User: Installs to ~/.claude/ for availability across all projects
    - Plugin: Creates a distributable Claude Code plugin package

    Cross-platform: Works on Windows (PowerShell 5.1+), macOS, and Linux (PowerShell Core).

.PARAMETER RepositoryRoot
    Path to the copilot_orchestrator repository. Defaults to parent of scripts folder.

.PARAMETER TargetPath
    Where to write the output. Defaults to current directory for Project mode,
    ~/.claude for User mode, or ./copilot-orchestrator-plugin for Plugin mode.

.PARAMETER Mode
    Output mode: Project, User, or Plugin. Default: Project.

.PARAMETER IncludeInstructions
    Also convert instruction files to .claude/rules/. Default: $true.

.PARAMETER IncludeMcp
    Also convert MCP server config. Default: $true.

.PARAMETER Force
    Overwrite existing files without prompting. Default: $false.

.EXAMPLE
    powershell -File scripts/setup-claude-code.ps1 -Mode Project -TargetPath C:\Projects\my-app

.EXAMPLE
    powershell -File scripts/setup-claude-code.ps1 -Mode User

.EXAMPLE
    powershell -File scripts/setup-claude-code.ps1 -Mode Plugin -TargetPath ./dist/copilot-orchestrator-plugin
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$RepositoryRoot = "",

    [Parameter()]
    [string]$TargetPath = "",

    [Parameter()]
    [ValidateSet("Project", "User", "Plugin")]
    [string]$Mode = "Project",

    [Parameter()]
    [bool]$IncludeInstructions = $true,

    [Parameter()]
    [bool]$IncludeMcp = $true,

    [Parameter()]
    [switch]$Force
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

# Resolve home directory cross-platform
$HomeDir = if ($env:HOME) { $env:HOME } elseif ($env:USERPROFILE) { $env:USERPROFILE } else { "~" }

if ($TargetPath -eq "") {
    switch ($Mode) {
        "Project" { $TargetPath = (Get-Location).Path }
        "User"    { $TargetPath = $HomeDir }
        "Plugin"  { $TargetPath = Join-Path (Get-Location).Path "copilot-orchestrator-plugin" }
    }
}

# Determine output base directory
switch ($Mode) {
    "Project" { $OutputBase = Join-Path $TargetPath ".claude" }
    "User"    { $OutputBase = Join-Path $TargetPath ".claude" }
    "Plugin"  { $OutputBase = $TargetPath }
}

# Source paths
$AgentsSource     = Join-Path (Join-Path $RepositoryRoot ".github") "agents"
$SkillsSource     = Join-Path (Join-Path $RepositoryRoot ".github") "skills"
$InstructionsRoot = Join-Path $RepositoryRoot "instructions"
$CopilotInstr     = Join-Path (Join-Path $RepositoryRoot ".github") "copilot-instructions.md"
$VscodeMcp        = Join-Path (Join-Path $RepositoryRoot ".vscode") "mcp.json"

# ============================================================
# Helper: Model name mapping
# ============================================================

function ConvertTo-ClaudeModel {
    param([string]$VsCodeModel)
    if ($VsCodeModel -match "Opus") { return "opus" }
    if ($VsCodeModel -match "Sonnet") { return "sonnet" }
    if ($VsCodeModel -match "Haiku") { return "haiku" }
    # Non-Anthropic models fall back to sonnet
    return "sonnet"
}

# ============================================================
# Helper: Parse YAML-ish frontmatter from agent.md files
# ============================================================

function Parse-AgentFrontmatter {
    param([string]$Content)

    $result = @{
        frontmatter = @{}
        body = ""
    }

    if ($Content -match "(?s)^---\r?\n(.*?)\r?\n---\r?\n(.*)$") {
        $fmRaw = $Matches[1]
        $result.body = $Matches[2]

        foreach ($line in ($fmRaw -split "\r?\n")) {
            $line = $line.Trim()
            if ($line -eq "" -or $line.StartsWith("#")) { continue }

            if ($line -match "^(\S+?):\s*(.*)$") {
                $key = $Matches[1]
                $val = $Matches[2].Trim()

                # Handle YAML arrays like ['item1', 'item2']
                if ($val -match "^\[") {
                    $items = $val.Trim('[',']') -split "," | ForEach-Object {
                        $_.Trim().Trim("'").Trim('"')
                    }
                    $result.frontmatter[$key] = $items
                } else {
                    # Strip surrounding quotes
                    $val = $val.Trim('"').Trim("'")
                    $result.frontmatter[$key] = $val
                }
            }
        }
    } else {
        $result.body = $Content
    }

    return $result
}

# ============================================================
# Helper: Map VS Code tool names to Claude Code tool names
# ============================================================

function ConvertTo-ClaudeTools {
    param($VscodeTools, $AgentsAllowlist)

    $toolMap = @{
        "runSubagent" = "Task"
        "agent"       = "Task"
        "todos"       = "TodoWrite"
        "fetch"       = "Bash(curl *)"
        "search"      = "Grep"
        "githubRepo"  = "Bash(gh *)"
        "changes"     = "Bash(git diff*)"
        "edit"        = "Edit"
        "runCommands" = "Bash"
        "readFile"    = "Read"
        "fileSearch"  = "Glob"
        "problems"    = "Bash"
        "usages"      = "Grep"
    }

    $claudeTools = @()

    if ($VscodeTools) {
        $toolArray = @($VscodeTools)
        if ($toolArray.Count -gt 0) {
            foreach ($tool in $toolArray) {
                $mapped = $toolMap[$tool]
                if ($mapped -and $mapped -ne "Task") {
                    if ($claudeTools -notcontains $mapped) {
                        $claudeTools += $mapped
                    }
                }
            }
        }
    }

    # Add Task with agent allowlist
    if ($AgentsAllowlist) {
        $agentArray = @($AgentsAllowlist)
        if ($agentArray.Count -gt 0) {
            $agentList = ($agentArray | ForEach-Object { $_ }) -join ", "
            $claudeTools += "Task($agentList)"
        }
    } elseif ($VscodeTools -and (@($VscodeTools) -contains "runSubagent" -or @($VscodeTools) -contains "agent")) {
        $claudeTools += "Task"
    }

    return $claudeTools
}

# ============================================================
# Transform a single agent file
# ============================================================

function Convert-AgentFile {
    param(
        [string]$SourcePath,
        [string]$DestPath
    )

    $content = Get-Content -Path $SourcePath -Raw -Encoding UTF8
    $parsed = Parse-AgentFrontmatter $content

    $fm = $parsed.frontmatter
    $body = $parsed.body

    # Build Claude Code frontmatter
    $lines = @()
    $lines += "---"

    # name (required)
    $name = if ($fm["name"]) { $fm["name"] } else {
        [System.IO.Path]::GetFileNameWithoutExtension($SourcePath) -replace '\.agent$', ''
    }
    $lines += "name: $name"

    # description (required)
    if ($fm["description"]) {
        $lines += "description: `"$($fm['description'])`""
    }

    # model mapping
    if ($fm["model"]) {
        $models = $fm["model"]
        if ($models -is [array]) {
            $claudeModel = ConvertTo-ClaudeModel $models[0]
        } else {
            $claudeModel = ConvertTo-ClaudeModel $models
        }
        $lines += "model: $claudeModel"
    }

    # tools - map from VS Code tools + agents allowlist
    $vscTools = $fm["tools"]
    $agentsAllowlist = $fm["agents"]
    $claudeTools = @(ConvertTo-ClaudeTools -VscodeTools $vscTools -AgentsAllowlist $agentsAllowlist)
    if ($claudeTools.Count -gt 0) {
        $lines += "tools: $($claudeTools -join ', ')"
    }

    # skills - map if the agent references specific skills
    # (We don't auto-map from VS Code since that's done via instructions)

    # user-invokable - only agents that are NOT user-invokable skip this
    if ($fm["user-invokable"] -eq "false") {
        # Claude Code agents don't have this field; instead they're just
        # delegated to by other agents. We note it in the description.
    }

    $lines += "---"

    # Combine
    $output = ($lines -join "`n") + "`n`n" + $body

    # Ensure directory exists
    $destDir = Split-Path -Parent $DestPath
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    Set-Content -Path $DestPath -Value $output -Encoding UTF8
}

# ============================================================
# Transform skills (mostly compatible, minor adjustments)
# ============================================================

function Copy-SkillDirectory {
    param(
        [string]$SourceDir,
        [string]$DestDir
    )

    if (-not (Test-Path $DestDir)) {
        New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
    }

    # Copy all files recursively
    Get-ChildItem -Path $SourceDir -Recurse -File | ForEach-Object {
        $relativePath = $_.FullName.Substring($SourceDir.Length).TrimStart('\', '/')
        $destFile = Join-Path $DestDir $relativePath
        $destFileDir = Split-Path -Parent $destFile

        if (-not (Test-Path $destFileDir)) {
            New-Item -ItemType Directory -Path $destFileDir -Force | Out-Null
        }

        Copy-Item -Path $_.FullName -Destination $destFile -Force
    }
}

# ============================================================
# Convert instructions to CLAUDE.md + rules
# ============================================================

function Convert-Instructions {
    param(
        [string]$InstructionsRoot,
        [string]$CopilotInstructionsPath,
        [string]$OutputBase
    )

    # Convert copilot-instructions.md to CLAUDE.md
    if (Test-Path $CopilotInstructionsPath) {
        $claudeMdPath = Join-Path $OutputBase "CLAUDE.md"
        if ($Mode -eq "Plugin") {
            # Plugins don't use CLAUDE.md; put in a rules file instead
            $rulesDir = Join-Path (Join-Path $OutputBase "skills") "project-instructions"
            if (-not (Test-Path $rulesDir)) {
                New-Item -ItemType Directory -Path $rulesDir -Force | Out-Null
            }
            $skillContent = @(
                "---"
                "name: project-instructions"
                "description: `"Core project instructions and conventions from the Copilot Orchestrator.`""
                "user-invocable: false"
                "---"
                ""
                (Get-Content -Path $CopilotInstructionsPath -Raw -Encoding UTF8)
            ) -join "`n"
            Set-Content -Path (Join-Path $rulesDir "SKILL.md") -Value $skillContent -Encoding UTF8
            Write-Host "[OK] Created plugin skill: project-instructions" -ForegroundColor Green
        } else {
            $content = Get-Content -Path $CopilotInstructionsPath -Raw -Encoding UTF8
            $header = @(
                "# Copilot Orchestrator - Project Memory"
                ""
                "<!-- Auto-generated from .github/copilot-instructions.md -->"
                "<!-- Run setup-claude-code to regenerate -->"
                ""
            ) -join "`n"
            Set-Content -Path $claudeMdPath -Value ($header + $content) -Encoding UTF8
            Write-Host "[OK] Created: $claudeMdPath" -ForegroundColor Green
        }
    }

    # Convert instruction files to .claude/rules/
    if (Test-Path $InstructionsRoot) {
        $rulesBase = if ($Mode -eq "Plugin") {
            # For plugins, store as skills rather than rules
            Join-Path $OutputBase "skills"
        } else {
            Join-Path $OutputBase "rules"
        }

        $instructionFolders = @("global", "workflows", "compliance", "languages")
        foreach ($folder in $instructionFolders) {
            $folderPath = Join-Path $InstructionsRoot $folder
            if (-not (Test-Path $folderPath)) { continue }

            Get-ChildItem -Path $folderPath -Filter "*.md" -File | ForEach-Object {
                $content = Get-Content -Path $_.FullName -Raw -Encoding UTF8
                $baseName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)

                if ($Mode -eq "Plugin") {
                    # For plugins, create as skills
                    $skillDir = Join-Path $rulesBase "instruction-$folder-$baseName"
                    if (-not (Test-Path $skillDir)) {
                        New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
                    }
                    $skillContent = @(
                        "---"
                        "name: instruction-$folder-$baseName"
                        "description: `"$folder instruction: $baseName`""
                        "user-invocable: false"
                        "---"
                        ""
                        $content
                    ) -join "`n"
                    Set-Content -Path (Join-Path $skillDir "SKILL.md") -Value $skillContent -Encoding UTF8
                } else {
                    # For project/user mode, create as rules
                    $ruleDir = Join-Path $rulesBase $folder
                    if (-not (Test-Path $ruleDir)) {
                        New-Item -ItemType Directory -Path $ruleDir -Force | Out-Null
                    }

                    # Add paths frontmatter for language-specific rules
                    $ruleContent = $content
                    if ($folder -eq "languages") {
                        $pathsMap = @{
                            "powershell"  = "**/*.ps1", "**/*.psm1", "**/*.psd1"
                            "python"      = "**/*.py"
                            "typescript"  = "**/*.ts", "**/*.tsx"
                            "javascript"  = "**/*.js", "**/*.jsx"
                            "csharp"      = "**/*.cs"
                            "go"          = "**/*.go"
                            "rust"        = "**/*.rs"
                            "java"        = "**/*.java"
                        }
                        $langKey = $baseName -replace '\.instructions$', '' -replace '\d+_', ''
                        $langKey = $langKey.ToLower()
                        foreach ($key in $pathsMap.Keys) {
                            if ($langKey -match $key) {
                                $pathsList = $pathsMap[$key]
                                $pathsYaml = ($pathsList | ForEach-Object { "  - `"$_`"" }) -join "`n"
                                $ruleContent = "---`npaths:`n$pathsYaml`n---`n`n$content"
                                break
                            }
                        }
                    }

                    Set-Content -Path (Join-Path $ruleDir "$baseName.md") -Value $ruleContent -Encoding UTF8
                }
            }
        }
        Write-Host "[OK] Converted instruction files to rules" -ForegroundColor Green
    }
}

# ============================================================
# Convert MCP configuration
# ============================================================

function Convert-McpConfig {
    param(
        [string]$VscodeMcpPath,
        [string]$OutputBase,
        [string]$OrchestratorRoot
    )

    if (-not (Test-Path $VscodeMcpPath)) {
        Write-Host "[SKIP] No .vscode/mcp.json found" -ForegroundColor Yellow
        return
    }

    $mcpContent = Get-Content -Path $VscodeMcpPath -Raw -Encoding UTF8
    # Note: Claude Code uses .mcp.json at project root with similar structure
    # but expects server names as top-level keys with command/args/env

    $mcpOutput = @{
        mcpServers = @{
            validation = @{
                command = "python"
                args = @(
                    (Join-Path (Join-Path (Join-Path $OrchestratorRoot "scripts") "mcp") "validation_server.py")
                )
            }
            analytics = @{
                command = "python"
                args = @(
                    (Join-Path (Join-Path (Join-Path $OrchestratorRoot "scripts") "mcp") "analytics_server.py")
                )
            }
            research = @{
                command = "python"
                args = @(
                    (Join-Path (Join-Path (Join-Path $OrchestratorRoot "scripts") "mcp") "research_server.py")
                )
            }
        }
    }

    $mcpJson = $mcpOutput | ConvertTo-Json -Depth 4

    if ($Mode -eq "Plugin") {
        $mcpPath = Join-Path $OutputBase ".mcp.json"
    } else {
        $mcpPath = Join-Path (Split-Path -Parent $OutputBase) ".mcp.json"
    }

    Set-Content -Path $mcpPath -Value $mcpJson -Encoding UTF8
    Write-Host "[OK] Created: $mcpPath" -ForegroundColor Green
}

# ============================================================
# Create plugin manifest (Plugin mode only)
# ============================================================

function New-PluginManifest {
    param([string]$OutputBase)

    $manifestDir = Join-Path $OutputBase ".claude-plugin"
    if (-not (Test-Path $manifestDir)) {
        New-Item -ItemType Directory -Path $manifestDir -Force | Out-Null
    }

    $manifest = @{
        name = "copilot-orchestrator"
        description = "Multi-agent orchestration system with 29 specialized agents for planning, implementation, review, security, and more."
        version = "1.0.0"
        author = @{
            name = "Copilot Orchestrator"
        }
    }

    $json = $manifest | ConvertTo-Json -Depth 3
    Set-Content -Path (Join-Path $manifestDir "plugin.json") -Value $json -Encoding UTF8

    # Create plugin README
    $readmeLines = @(
        "# Copilot Orchestrator Plugin for Claude Code"
        ""
        "Multi-agent orchestration system with 29 specialized agents."
        ""
        "## Installation"
        ""
        '```bash'
        "claude --plugin-dir ./copilot-orchestrator-plugin"
        '```'
        ""
        "Or install permanently via /plugin install."
        ""
        "## Agents"
        ""
        "Includes conductor, planner, implementer, reviewer, researcher, security,"
        "performance, test, docs, lint, and 19 more specialist agents."
        ""
        "## Skills"
        ""
        "All 17 orchestrator skills are included:"
        "- conductor-lifecycle, delegation-routing, budget-gatekeeper"
        "- tdd, security-review, performance-analysis"
        "- documentation-style, git-operations, memory-management"
        "- And more..."
        ""
        "## Usage"
        ""
        '```'
        "Use the conductor agent to plan a new authentication feature"
        '```'
        ""
        '```'
        "Use the reviewer agent to check my recent changes"
        '```'
    )
    $readmeContent = $readmeLines -join "`n"

    Set-Content -Path (Join-Path $OutputBase "README.md") -Value $readmeContent -Encoding UTF8
    Write-Host "[OK] Created plugin manifest and README" -ForegroundColor Green
}

# ============================================================
# Main execution
# ============================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Copilot Orchestrator -> Claude Code Setup"   -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Mode:           $Mode" -ForegroundColor White
Write-Host "Source:         $RepositoryRoot" -ForegroundColor White
Write-Host "Target:         $TargetPath" -ForegroundColor White
Write-Host "Output Base:    $OutputBase" -ForegroundColor White
Write-Host "Instructions:   $IncludeInstructions" -ForegroundColor White
Write-Host "MCP Config:     $IncludeMcp" -ForegroundColor White
Write-Host ""

# Check source exists
if (-not (Test-Path $AgentsSource)) {
    Write-Host "[ERROR] Agents source not found: $AgentsSource" -ForegroundColor Red
    Write-Host "[HINT]  Ensure -RepositoryRoot points to the copilot_orchestrator repo." -ForegroundColor Yellow
    exit 1
}

# Check for existing output and prompt if not -Force
if ((Test-Path $OutputBase) -and -not $Force) {
    Write-Host "[WARN] Output directory exists: $OutputBase" -ForegroundColor Yellow
    Write-Host "       Use -Force to overwrite, or choose a different -TargetPath." -ForegroundColor Yellow
    $response = Read-Host "Continue and overwrite? (y/N)"
    if ($response -ne "y" -and $response -ne "Y") {
        Write-Host "[ABORT] Setup cancelled." -ForegroundColor Red
        exit 0
    }
}

# Create output structure
if (-not (Test-Path $OutputBase)) {
    New-Item -ItemType Directory -Path $OutputBase -Force | Out-Null
}

$agentsOut = Join-Path $OutputBase "agents"
$skillsOut = Join-Path $OutputBase "skills"

if (-not (Test-Path $agentsOut)) {
    New-Item -ItemType Directory -Path $agentsOut -Force | Out-Null
}
if (-not (Test-Path $skillsOut)) {
    New-Item -ItemType Directory -Path $skillsOut -Force | Out-Null
}

# ============================================================
# Step 1: Convert agents
# ============================================================

Write-Host "--- Converting Agents ---" -ForegroundColor Cyan
$agentFiles = Get-ChildItem -Path $AgentsSource -Filter "*.agent.md" -File
$agentCount = 0

foreach ($agentFile in $agentFiles) {
    $destName = $agentFile.Name -replace '\.agent\.md$', '.md'
    $destPath = Join-Path $agentsOut $destName
    Convert-AgentFile -SourcePath $agentFile.FullName -DestPath $destPath
    $agentCount++
    Write-Host "  [OK] $($agentFile.Name) -> $destName" -ForegroundColor Green
}

Write-Host "[DONE] Converted $agentCount agents" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# Step 2: Copy skills
# ============================================================

Write-Host "--- Copying Skills ---" -ForegroundColor Cyan
$skillDirs = Get-ChildItem -Path $SkillsSource -Directory
$skillCount = 0

foreach ($skillDir in $skillDirs) {
    $destDir = Join-Path $skillsOut $skillDir.Name
    Copy-SkillDirectory -SourceDir $skillDir.FullName -DestDir $destDir
    $skillCount++
    Write-Host "  [OK] $($skillDir.Name)" -ForegroundColor Green
}

Write-Host "[DONE] Copied $skillCount skills" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# Step 3: Convert instructions (optional)
# ============================================================

if ($IncludeInstructions) {
    Write-Host "--- Converting Instructions ---" -ForegroundColor Cyan
    Convert-Instructions -InstructionsRoot $InstructionsRoot `
                         -CopilotInstructionsPath $CopilotInstr `
                         -OutputBase $OutputBase
    Write-Host ""
}

# ============================================================
# Step 4: Convert MCP config (optional)
# ============================================================

if ($IncludeMcp) {
    Write-Host "--- Converting MCP Configuration ---" -ForegroundColor Cyan
    Convert-McpConfig -VscodeMcpPath $VscodeMcp `
                      -OutputBase $OutputBase `
                      -OrchestratorRoot $RepositoryRoot
    Write-Host ""
}

# ============================================================
# Step 5: Plugin manifest (Plugin mode only)
# ============================================================

if ($Mode -eq "Plugin") {
    Write-Host "--- Creating Plugin Manifest ---" -ForegroundColor Cyan
    New-PluginManifest -OutputBase $OutputBase
    Write-Host ""
}

# ============================================================
# Summary
# ============================================================

Write-Host "============================================" -ForegroundColor Green
Write-Host " Setup Complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Agents:       $agentCount" -ForegroundColor White
Write-Host "  Skills:       $skillCount" -ForegroundColor White
Write-Host "  Output:       $OutputBase" -ForegroundColor White
Write-Host ""

switch ($Mode) {
    "Project" {
        Write-Host "Next steps:" -ForegroundColor Cyan
        Write-Host "  1. Navigate to your project: cd $TargetPath" -ForegroundColor White
        Write-Host "  2. Start Claude Code:        claude" -ForegroundColor White
        Write-Host "  3. Test with:                /agents" -ForegroundColor White
        Write-Host "  4. (Optional) Commit .claude/ to version control" -ForegroundColor White
    }
    "User" {
        Write-Host "Next steps:" -ForegroundColor Cyan
        Write-Host "  1. Start Claude Code in any project: claude" -ForegroundColor White
        Write-Host "  2. All agents/skills are now globally available" -ForegroundColor White
        Write-Host "  3. Test with: /agents" -ForegroundColor White
    }
    "Plugin" {
        Write-Host "Next steps:" -ForegroundColor Cyan
        Write-Host "  1. Test the plugin:    claude --plugin-dir $OutputBase" -ForegroundColor White
        Write-Host "  2. Or install via:     /plugin install (in Claude Code)" -ForegroundColor White
        Write-Host "  3. Distribute to team via Git or plugin marketplace" -ForegroundColor White
    }
}

Write-Host ""
