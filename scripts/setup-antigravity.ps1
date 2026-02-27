<#
.SYNOPSIS
    Export Copilot Orchestrator agents, skills, and instructions to Antigravity IDE format.

.DESCRIPTION
    Transforms VS Code Copilot agent definitions, skills, instruction files,
    and prompt templates into Antigravity IDE-compatible format. Supports two
    output modes:
    - Project: Creates .agent/ directory in the target project
    - User: Installs skills globally to ~/.gemini/antigravity/skills/

    Antigravity is a Google DeepMind AI coding IDE that uses:
    - .agent/agents/*.md   for agent definitions
    - .agent/skills/       for skills (SKILL.md format)
    - .agent/workflows/    for slash-command workflows ($ARGUMENTS)
    - .agent/rules/        for project rules/instructions
    - .agent/mcp_config.json for MCP server configuration

    Cross-platform: Works on Windows (PowerShell 5.1+), macOS, and Linux (PowerShell Core).

.PARAMETER RepositoryRoot
    Path to the copilot_orchestrator repository. Defaults to parent of scripts folder.

.PARAMETER TargetPath
    Where to write the output. Defaults to current directory for Project mode,
    or ~/.gemini/antigravity/skills for User mode.

.PARAMETER Mode
    Output mode: Project or User. Default: Project.

.PARAMETER IncludeInstructions
    Also convert instruction files to .agent/rules/. Default: $true.

.PARAMETER IncludeMcp
    Also convert MCP server config. Default: $true.

.PARAMETER IncludeWorkflows
    Generate slash-command workflows from agent definitions. Default: $true.

.PARAMETER Force
    Overwrite existing files without prompting. Default: $false.

.EXAMPLE
    powershell -File scripts/setup-antigravity.ps1 -Mode Project -TargetPath C:\Projects\my-app

.EXAMPLE
    powershell -File scripts/setup-antigravity.ps1 -Mode User

.EXAMPLE
    powershell -File scripts/setup-antigravity.ps1 -Mode Project -TargetPath ~/projects/my-app -Force
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$RepositoryRoot = "",

    [Parameter()]
    [string]$TargetPath = "",

    [Parameter()]
    [ValidateSet("Project", "User")]
    [string]$Mode = "Project",

    [Parameter()]
    [bool]$IncludeInstructions = $true,

    [Parameter()]
    [bool]$IncludeMcp = $true,

    [Parameter()]
    [bool]$IncludeWorkflows = $true,

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
        "User"    { $TargetPath = Join-Path (Join-Path (Join-Path $HomeDir ".gemini") "antigravity") "skills" }
    }
}

# Determine output base directory
switch ($Mode) {
    "Project" { $OutputBase = Join-Path $TargetPath ".agent" }
    "User"    { $OutputBase = $TargetPath }
}

# Source paths
$AgentsSource     = Join-Path (Join-Path $RepositoryRoot ".github") "agents"
$SkillsSource     = Join-Path (Join-Path $RepositoryRoot ".github") "skills"
$PromptsSource    = Join-Path (Join-Path $RepositoryRoot ".github") "prompts"
$InstructionsRoot = Join-Path $RepositoryRoot "instructions"
$CopilotInstr     = Join-Path (Join-Path $RepositoryRoot ".github") "copilot-instructions.md"
$VscodeMcp        = Join-Path (Join-Path $RepositoryRoot ".vscode") "mcp.json"

# ============================================================
# Helper: Model name mapping
# ============================================================

function ConvertTo-AntigravityModel {
    param([string]$VsCodeModel)
    # Antigravity uses "inherit" as default (uses IDE-configured model)
    # For explicit assignments, map VS Code model names
    if ($VsCodeModel -match "Opus") { return "opus" }
    if ($VsCodeModel -match "Sonnet") { return "sonnet" }
    if ($VsCodeModel -match "Haiku") { return "haiku" }
    if ($VsCodeModel -match "Gemini") { return "gemini-pro" }
    if ($VsCodeModel -match "GPT|Codex") { return "inherit" }
    return "inherit"
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
# Helper: Map VS Code tool names to Antigravity tool names
# ============================================================

function ConvertTo-AntigravityTools {
    param($VscodeTools, $AgentsAllowlist)

    # Antigravity uses: Read, Grep, Glob, Bash, Edit, Write
    $toolMap = @{
        "runSubagent" = $null
        "agent"       = $null
        "todos"       = "Bash"
        "fetch"       = "Bash"
        "search"      = "Grep"
        "githubRepo"  = "Bash"
        "changes"     = "Bash"
        "edit"        = "Edit"
        "runCommands" = "Bash"
        "readFile"    = "Read"
        "fileSearch"  = "Glob"
        "problems"    = "Bash"
        "usages"      = "Grep"
    }

    $agTools = @()
    # Always include core tools for Antigravity
    $coreTools = @("Read", "Grep", "Glob", "Bash", "Edit", "Write")

    if ($VscodeTools) {
        $toolArray = @($VscodeTools)
        if ($toolArray.Count -gt 0) {
            foreach ($tool in $toolArray) {
                $mapped = $toolMap[$tool]
                if ($mapped -and $agTools -notcontains $mapped) {
                    $agTools += $mapped
                }
            }
        }
    }

    # Merge with core tools, dedup
    foreach ($core in $coreTools) {
        if ($agTools -notcontains $core) {
            $agTools += $core
        }
    }

    return $agTools
}

# ============================================================
# Helper: Build skills list from agent body/skills references
# ============================================================

function Get-AgentSkillReferences {
    param([string]$Body, $FrontmatterSkills)

    $skills = @()

    # Pull from frontmatter if present
    if ($FrontmatterSkills) {
        $skillArray = @($FrontmatterSkills)
        foreach ($s in $skillArray) {
            if ($skills -notcontains $s) { $skills += $s }
        }
    }

    # Also scan body for skill references (common pattern: `delegation-routing` skill)
    $skillMatches = [regex]::Matches($Body, '`([a-z0-9-]+)`\s+skill')
    foreach ($m in $skillMatches) {
        $name = $m.Groups[1].Value
        if ($skills -notcontains $name) { $skills += $name }
    }

    return $skills
}

# ============================================================
# Transform a single agent file to Antigravity format
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

    # Antigravity format: body first, then frontmatter at bottom
    # But many Antigravity repos also use top-YAML.
    # We use top-YAML for consistency with the source format.

    # Build Antigravity frontmatter
    $lines = @()
    $lines += "---"

    # name (required)
    $name = if ($fm["name"]) { $fm["name"] } else {
        [System.IO.Path]::GetFileNameWithoutExtension($SourcePath) -replace '\.agent$', ''
    }
    $lines += "name: $name"

    # description (required)
    if ($fm["description"]) {
        $desc = $fm["description"]
        # Escape quotes in description
        $desc = $desc -replace '"', '\"'
        $lines += "description: $desc"
    }

    # tools - map from VS Code tools
    $vscTools = $fm["tools"]
    $agentsAllowlist = $fm["agents"]
    $agTools = @(ConvertTo-AntigravityTools -VscodeTools $vscTools -AgentsAllowlist $agentsAllowlist)
    if ($agTools.Count -gt 0) {
        $lines += "tools: $($agTools -join ', ')"
    }

    # model mapping
    if ($fm["model"]) {
        $models = $fm["model"]
        if ($models -is [array]) {
            $agModel = ConvertTo-AntigravityModel $models[0]
        } else {
            $agModel = ConvertTo-AntigravityModel $models
        }
        $lines += "model: $agModel"
    } else {
        $lines += "model: inherit"
    }

    # skills references
    $skillRefs = @(Get-AgentSkillReferences -Body $body -FrontmatterSkills $null)
    if ($skillRefs.Count -gt 0) {
        $lines += "skills: $($skillRefs -join ', ')"
    }

    $lines += "---"

    # Combine: frontmatter + body
    $output = ($lines -join "`n") + "`n`n" + $body

    # Ensure directory exists
    $destDir = Split-Path -Parent $DestPath
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    Set-Content -Path $DestPath -Value $output -Encoding UTF8
}

# ============================================================
# Transform skills (mostly compatible, copy with adjustments)
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
# Generate slash-command workflows from prompt templates
# ============================================================

function Convert-PromptsToWorkflows {
    param(
        [string]$PromptsSource,
        [string]$WorkflowsDir
    )

    if (-not (Test-Path $PromptsSource)) {
        Write-Host "[SKIP] No prompts directory found" -ForegroundColor Yellow
        return 0
    }

    if (-not (Test-Path $WorkflowsDir)) {
        New-Item -ItemType Directory -Path $WorkflowsDir -Force | Out-Null
    }

    $count = 0
    Get-ChildItem -Path $PromptsSource -Filter "*.prompt.md" -File -Recurse | ForEach-Object {
        $content = Get-Content -Path $_.FullName -Raw -Encoding UTF8
        $parsed = Parse-AgentFrontmatter $content

        $fm = $parsed.frontmatter
        $body = $parsed.body

        $promptName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name) -replace '\.prompt$', ''

        # Build workflow file
        $wfLines = @()
        $wfLines += "---"

        if ($fm["description"]) {
            $wfLines += "description: $($fm['description'])"
        } else {
            $wfLines += "description: Workflow generated from prompt $promptName"
        }

        $wfLines += "---"
        $wfLines += ""
        $wfLines += "# /$promptName"
        $wfLines += ""
        $wfLines += '$ARGUMENTS'
        $wfLines += ""
        $wfLines += $body

        $wfContent = $wfLines -join "`n"
        $wfPath = Join-Path $WorkflowsDir "$promptName.md"
        Set-Content -Path $wfPath -Value $wfContent -Encoding UTF8
        $count++
    }

    return $count
}

# ============================================================
# Convert instructions to .agent/rules/
# ============================================================

function Convert-Instructions {
    param(
        [string]$InstructionsRoot,
        [string]$CopilotInstructionsPath,
        [string]$OutputBase
    )

    # Convert copilot-instructions.md to ARCHITECTURE.md (Antigravity convention)
    if (Test-Path $CopilotInstructionsPath) {
        $archPath = Join-Path $OutputBase "ARCHITECTURE.md"
        $content = Get-Content -Path $CopilotInstructionsPath -Raw -Encoding UTF8
        $header = @(
            "# Copilot Orchestrator - Project Architecture"
            ""
            "<!-- Auto-generated from .github/copilot-instructions.md -->"
            "<!-- Run setup-antigravity to regenerate -->"
            ""
        ) -join "`n"
        Set-Content -Path $archPath -Value ($header + $content) -Encoding UTF8
        Write-Host "[OK] Created: $archPath" -ForegroundColor Green
    }

    # Convert instruction files to .agent/rules/
    if (Test-Path $InstructionsRoot) {
        $rulesBase = Join-Path $OutputBase "rules"

        $instructionFolders = @("global", "workflows", "compliance", "languages")
        foreach ($folder in $instructionFolders) {
            $folderPath = Join-Path $InstructionsRoot $folder
            if (-not (Test-Path $folderPath)) { continue }

            Get-ChildItem -Path $folderPath -Filter "*.md" -File | ForEach-Object {
                $fileContent = Get-Content -Path $_.FullName -Raw -Encoding UTF8
                $baseName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)

                $ruleDir = Join-Path $rulesBase $folder
                if (-not (Test-Path $ruleDir)) {
                    New-Item -ItemType Directory -Path $ruleDir -Force | Out-Null
                }

                Set-Content -Path (Join-Path $ruleDir "$baseName.md") -Value $fileContent -Encoding UTF8
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

    # Antigravity uses .agent/mcp_config.json
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
    $mcpPath = Join-Path $OutputBase "mcp_config.json"

    Set-Content -Path $mcpPath -Value $mcpJson -Encoding UTF8
    Write-Host "[OK] Created: $mcpPath" -ForegroundColor Green
}

# ============================================================
# Main execution
# ============================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Copilot Orchestrator -> Antigravity Setup"  -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Mode:           $Mode" -ForegroundColor White
Write-Host "Source:         $RepositoryRoot" -ForegroundColor White
Write-Host "Target:         $TargetPath" -ForegroundColor White
Write-Host "Output Base:    $OutputBase" -ForegroundColor White
Write-Host "Instructions:   $IncludeInstructions" -ForegroundColor White
Write-Host "MCP Config:     $IncludeMcp" -ForegroundColor White
Write-Host "Workflows:      $IncludeWorkflows" -ForegroundColor White
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

$agentsOut    = Join-Path $OutputBase "agents"
$skillsOut    = Join-Path $OutputBase "skills"
$workflowsOut = Join-Path $OutputBase "workflows"
$rulesOut     = Join-Path $OutputBase "rules"

foreach ($dir in @($agentsOut, $skillsOut)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
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
# Step 3: Generate workflows from prompts (optional)
# ============================================================

$workflowCount = 0
if ($IncludeWorkflows) {
    Write-Host "--- Generating Workflows ---" -ForegroundColor Cyan
    $workflowCount = Convert-PromptsToWorkflows -PromptsSource $PromptsSource `
                                                 -WorkflowsDir $workflowsOut
    Write-Host "[DONE] Generated $workflowCount workflows" -ForegroundColor Cyan
    Write-Host ""
}

# ============================================================
# Step 4: Convert instructions (optional)
# ============================================================

if ($IncludeInstructions) {
    Write-Host "--- Converting Instructions ---" -ForegroundColor Cyan
    Convert-Instructions -InstructionsRoot $InstructionsRoot `
                         -CopilotInstructionsPath $CopilotInstr `
                         -OutputBase $OutputBase
    Write-Host ""
}

# ============================================================
# Step 5: Convert MCP config (optional)
# ============================================================

if ($IncludeMcp) {
    Write-Host "--- Converting MCP Configuration ---" -ForegroundColor Cyan
    Convert-McpConfig -VscodeMcpPath $VscodeMcp `
                      -OutputBase $OutputBase `
                      -OrchestratorRoot $RepositoryRoot
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
Write-Host "  Workflows:    $workflowCount" -ForegroundColor White
Write-Host "  Output:       $OutputBase" -ForegroundColor White
Write-Host ""

switch ($Mode) {
    "Project" {
        Write-Host "Next steps:" -ForegroundColor Cyan
        Write-Host "  1. Open project in Antigravity IDE" -ForegroundColor White
        Write-Host "  2. Agents auto-detected from .agent/agents/" -ForegroundColor White
        Write-Host "  3. Use slash commands like /plan, /review" -ForegroundColor White
        Write-Host "  4. Skills load automatically by context" -ForegroundColor White
        Write-Host ""
        Write-Host "Directory structure:" -ForegroundColor Cyan
        Write-Host "  .agent/" -ForegroundColor White
        Write-Host "  +-- agents/         ($agentCount agent files)" -ForegroundColor White
        Write-Host "  +-- skills/         ($skillCount skill directories)" -ForegroundColor White
        Write-Host "  +-- workflows/      ($workflowCount workflow files)" -ForegroundColor White
        Write-Host "  +-- rules/          (instruction rules)" -ForegroundColor White
        Write-Host "  +-- mcp_config.json (MCP server config)" -ForegroundColor White
        Write-Host "  +-- ARCHITECTURE.md (project context)" -ForegroundColor White
    }
    "User" {
        Write-Host "Next steps:" -ForegroundColor Cyan
        Write-Host "  1. Open Antigravity IDE in any project" -ForegroundColor White
        Write-Host "  2. Skills load globally from ~/.gemini/antigravity/skills/" -ForegroundColor White
        Write-Host "  3. For agents/workflows, also run with -Mode Project" -ForegroundColor White
    }
}

Write-Host ""
