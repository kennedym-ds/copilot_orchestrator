[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RepositoryRoot = (Get-Location).Path,

    [switch]$FailOnWarning
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

function Get-FrontMatter {
    param(
        [string]$FilePath
    )

    $lines = Get-Content -LiteralPath $FilePath
    if ($lines.Count -lt 3) {
        return $null
    }

    if ($lines[0].Trim() -ne '---') {
        return $null
    }

    $endIndex = $null
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Trim() -eq '---') {
            $endIndex = $i
            break
        }
    }

    if ($null -eq $endIndex) {
        return $null
    }

    $frontMatterLines = $lines[1..($endIndex - 1)]
    return [string]::Join("`n", $frontMatterLines)
}

function Add-Issue {
    param(
        [System.Collections.Generic.List[object]]$Collector,
        [string]$File,
        [string]$Severity,
        [string]$Message
    )

    $Collector.Add([PSCustomObject]@{
            File     = $File
            Severity = $Severity
            Message  = $Message
        }) | Out-Null
}

function Test-YamlKeyPresence {
    param(
        [string]$FrontMatter,
        [string[]]$RequiredKeys
    )

    $missing = @()
    foreach ($key in $RequiredKeys) {
        if ($FrontMatter -notmatch ("(?m)^" + [Regex]::Escape($key) + ":")) {
            $missing += $key
        }
    }

    return $missing
}

if (-not (Test-Path -LiteralPath $RepositoryRoot)) {
    throw "Repository root '$RepositoryRoot' was not found."
}

$RepoRoot = (Resolve-Path -LiteralPath $RepositoryRoot).ProviderPath
$issues = New-Object System.Collections.Generic.List[object]

Write-Host "Scanning Copilot assets under $RepoRoot ..." -ForegroundColor Cyan

# 1. Ensure AGENTS.md exists
$agentsPath = Join-Path -Path $RepoRoot -ChildPath 'AGENTS.md'
if (-not (Test-Path -LiteralPath $agentsPath)) {
    Add-Issue -Collector $issues -File 'AGENTS.md' -Severity 'Error' -Message 'Root AGENTS.md file is missing.'
}

# 2. Validate instruction files
$instructionFiles = @(Get-ChildItem -Path $RepoRoot -Recurse -Filter '*.instructions.md' -File -ErrorAction SilentlyContinue)
foreach ($instruction in $instructionFiles) {
    $frontMatter = Get-FrontMatter -FilePath $instruction.FullName
    if (-not $frontMatter) {
        Add-Issue -Collector $issues -File $instruction.FullName.Replace($RepoRoot + [IO.Path]::DirectorySeparatorChar, '') -Severity 'Error' -Message 'Missing or malformed YAML front matter.'
        continue
    }

    $missing = @(Test-YamlKeyPresence -FrontMatter $frontMatter -RequiredKeys @('applyTo', 'description'))
    if ($missing.Length -gt 0) {
        Add-Issue -Collector $issues -File $instruction.FullName.Replace($RepoRoot + [IO.Path]::DirectorySeparatorChar, '') -Severity 'Error' -Message "Missing required front matter keys: $([string]::Join(', ', $missing))."
    }
}

if ($instructionFiles.Count -eq 0) {
    Add-Issue -Collector $issues -File '(repository)' -Severity 'Warning' -Message 'No *.instructions.md files were found. Ensure workflow guidance is committed.'
}

# 3. Validate agent and chat mode definitions
$agentFiles = @()
$agentFiles += Get-ChildItem -Path (Join-Path $RepoRoot '.github/agents') -Filter '*.agent.md' -File -ErrorAction SilentlyContinue

# Define valid model names (updated for current model allocation)
$validModels = @(
    'Claude Opus 4.6 (copilot)',
    'Claude Opus 4.7 (copilot)',
    'Claude Sonnet 4.6 (copilot)',

    'Claude Haiku 4.5 (copilot)',
    'GPT-5.4 (copilot)',
    'GPT-5.4 mini (copilot)',
    'GPT-5.3-Codex (copilot)',
    'GPT-5.1-Codex-Mini (copilot)',
    'GPT-5 mini (copilot)',
    'GPT-4.1 (copilot)',
    'GPT-4o (copilot)',
    'Gemini 3.1 Pro (Preview) (copilot)',
    'Gemini 3 Flash (copilot)',
    'Raptor mini (copilot)'
)

foreach ($agent in $agentFiles) {
    $frontMatter = Get-FrontMatter -FilePath $agent.FullName
    $relativePath = $agent.FullName.Replace($RepoRoot + [IO.Path]::DirectorySeparatorChar, '')

    if (-not $frontMatter) {
        Add-Issue -Collector $issues -File $relativePath -Severity 'Error' -Message 'Missing YAML front matter.'
        continue
    }

    # Core required keys
    $missing = @(Test-YamlKeyPresence -FrontMatter $frontMatter -RequiredKeys @('name', 'description', 'model', 'tools'))
    if ($missing.Length -gt 0) {
        Add-Issue -Collector $issues -File $relativePath -Severity 'Error' -Message "Missing required front matter keys: $([string]::Join(', ', $missing))."
    }

    # Validate argument-hint presence (awesome-copilot pattern)
    if ($frontMatter -notmatch 'argument-hint:') {
        Add-Issue -Collector $issues -File $relativePath -Severity 'Warning' -Message 'Missing argument-hint field. Add for improved discoverability (awesome-copilot pattern).'
    }

    # Validate model is from allowed list (supports single value or array format)
    if ($frontMatter -match "(?m)^model:\s*\[([^\]]+)\]") {
        # Array format: model: ['Model A (copilot)', 'Model B (copilot)']
        $modelList = $Matches[1] -split ',\s*' | ForEach-Object { $_.Trim().Trim("'").Trim('"') }
        foreach ($m in $modelList) {
            if ($validModels -notcontains $m) {
                Add-Issue -Collector $issues -File $relativePath -Severity 'Error' -Message "Invalid model in array: '$m'. Valid models: $([string]::Join(', ', $validModels))."
            }
        }
    } elseif ($frontMatter -match "(?m)^model:\s*['""]?([^'""\r\n\[]+)['""]?") {
        # Single value format: model: Model A (copilot)
        $modelName = $Matches[1].Trim()
        if ($validModels -notcontains $modelName) {
            Add-Issue -Collector $issues -File $relativePath -Severity 'Error' -Message "Invalid model: '$modelName'. Valid models: $([string]::Join(', ', $validModels))."
        }
    }

    # Validate mcp-servers format if present
    if ($frontMatter -match 'mcp-servers:') {
        # Check for proper object format (not array format)
        if ($frontMatter -match 'mcp-servers:\s*\[') {
            Add-Issue -Collector $issues -File $relativePath -Severity 'Error' -Message 'mcp-servers should use object format, not array format. See awesome-copilot patterns.'
        }
        # Check for proper nested structure with type, command, args
        if ($frontMatter -match 'mcp-servers:' -and $frontMatter -notmatch 'type:\s*(stdio|http)') {
            Add-Issue -Collector $issues -File $relativePath -Severity 'Warning' -Message 'mcp-servers block should include type: stdio|http for each server.'
        }
    }

    # Warn about deprecated target field
    if ($frontMatter -match 'target:') {
        Add-Issue -Collector $issues -File $relativePath -Severity 'Warning' -Message 'Deprecated target field found. Remove per awesome-copilot patterns.'
    }

    if ($frontMatter -notmatch "tools:\s*\[" -and $frontMatter -notmatch "(?s)tools:\s*\n") {
        Add-Issue -Collector $issues -File $relativePath -Severity 'Warning' -Message 'Tools list appears empty; confirm tool bindings are defined.'
    }
}

# 4. Validate prompt library
$promptRoot = Join-Path $RepoRoot '.github/prompts'
$promptFiles = @(Get-ChildItem -Path $promptRoot -Filter '*.prompt.md' -Recurse -File -ErrorAction SilentlyContinue)

if ($promptFiles.Count -eq 0) {
    Add-Issue -Collector $issues -File '.github/prompts' -Severity 'Warning' -Message 'Prompt library is empty. Add orchestrated workflow prompts to support agents.'
} else {
    foreach ($prompt in $promptFiles) {
        $frontMatter = Get-FrontMatter -FilePath $prompt.FullName
        $relativePath = $prompt.FullName.Replace($RepoRoot + [IO.Path]::DirectorySeparatorChar, '')

        if (-not $frontMatter) {
            Add-Issue -Collector $issues -File $relativePath -Severity 'Error' -Message 'Missing YAML front matter.'
            continue
        }

        $missing = @(Test-YamlKeyPresence -FrontMatter $frontMatter -RequiredKeys @('name', 'description', 'model', 'agent', 'tools'))
        if ($missing.Length -gt 0) {
            Add-Issue -Collector $issues -File $relativePath -Severity 'Error' -Message "Missing required front matter keys: $([string]::Join(', ', $missing))."
        }

        $content = Get-Content -LiteralPath $prompt.FullName -Raw
        if ($content -notmatch '## Instructions') {
            Add-Issue -Collector $issues -File $relativePath -Severity 'Warning' -Message 'Prompt body should include an "## Instructions" section.'
        }
        if ($content -notmatch '## Output Format') {
            Add-Issue -Collector $issues -File $relativePath -Severity 'Warning' -Message 'Prompt body should document the expected output format.'
        }
    }
}

# 5. Validate plan documents for Mermaid diagrams
$plansRoot = Join-Path $RepoRoot 'plans'
$planFiles = @(Get-ChildItem -Path $plansRoot -Filter '*.md' -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^(?!README).*-plan\.md$|^(?!README).*-phase-\d+\.md$' })

foreach ($plan in $planFiles) {
    $content = Get-Content -LiteralPath $plan.FullName -Raw
    $relativePath = $plan.FullName.Replace($RepoRoot + [IO.Path]::DirectorySeparatorChar, '')

    # Check if this is a complex plan (has multiple phases or architecture keywords)
    $isComplexPlan = $content -match '(?i)(architecture|component|service|workflow|pipeline|state\s+machine)' -or
                     $content -match '(?m)^##?\s*Phase\s+\d+' -and ($content -split '(?m)^##?\s*Phase\s+\d+').Count -gt 3

    if ($isComplexPlan -and $content -notmatch '```mermaid') {
        Add-Issue -Collector $issues -File $relativePath -Severity 'Warning' -Message 'Complex plan should include Mermaid diagrams for architecture, workflow, or state visualization. See docs/examples/mermaid-diagram-patterns.md'
    }

    # Validate Mermaid syntax if diagrams exist
    if ($content -match '```mermaid') {
        $mermaidBlocks = [regex]::Matches($content, '(?s)```mermaid\s*\n(.*?)\n```')
        foreach ($block in $mermaidBlocks) {
            $diagramContent = $block.Groups[1].Value

            # Basic syntax validation
            if ($diagramContent -notmatch '(flowchart|sequenceDiagram|stateDiagram|graph|classDiagram|erDiagram|gantt)') {
                Add-Issue -Collector $issues -File $relativePath -Severity 'Warning' -Message 'Mermaid diagram missing diagram type declaration (flowchart, sequenceDiagram, etc.)'
            }
        }
    }
}

# Present results
if ($issues.Count -eq 0) {
    Write-Host 'âœ… All Copilot assets passed validation.' -ForegroundColor Green
    exit 0
}

$errors = @($issues | Where-Object { $_.Severity -eq 'Error' })
$warnings = @($issues | Where-Object { $_.Severity -eq 'Warning' })

if ($errors.Count -gt 0) {
    Write-Host "âŒ Found $($errors.Count) error(s):" -ForegroundColor Red
    foreach ($errItem in $errors) {
        Write-Host "  [$($errItem.Severity)] $($errItem.File): $($errItem.Message)" -ForegroundColor Red
    }
}

if ($warnings.Count -gt 0) {
    Write-Host "âš ï¸  Found $($warnings.Count) warning(s):" -ForegroundColor Yellow
    foreach ($warnItem in $warnings) {
        Write-Host "  [$($warnItem.Severity)] $($warnItem.File): $($warnItem.Message)" -ForegroundColor Yellow
    }
}

if ($errors.Count -gt 0 -or ($FailOnWarning.IsPresent -and $warnings.Count -gt 0)) {
    exit 1
}

exit 0
