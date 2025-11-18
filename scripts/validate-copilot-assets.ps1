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

foreach ($agent in $agentFiles) {
    $frontMatter = Get-FrontMatter -FilePath $agent.FullName
    $relativePath = $agent.FullName.Replace($RepoRoot + [IO.Path]::DirectorySeparatorChar, '')

    if (-not $frontMatter) {
        Add-Issue -Collector $issues -File $relativePath -Severity 'Error' -Message 'Missing YAML front matter.'
        continue
    }

    $missing = @(Test-YamlKeyPresence -FrontMatter $frontMatter -RequiredKeys @('name', 'description', 'model', 'tools'))
    if ($missing.Length -gt 0) {
        Add-Issue -Collector $issues -File $relativePath -Severity 'Error' -Message "Missing required front matter keys: $([string]::Join(', ', $missing))."
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

# 6. Validate DS-Star data analysis sessions
$dataAnalysisRoot = Join-Path $RepoRoot 'plans/data-analysis'
if (Test-Path -LiteralPath $dataAnalysisRoot) {
    $dataAnalysisSessions = @(Get-ChildItem -Path $dataAnalysisRoot -Directory -ErrorAction SilentlyContinue)
    
    foreach ($session in $dataAnalysisSessions) {
        $stateFile = Join-Path $session.FullName 'pipeline_state.json'
        $relativePath = $session.FullName.Replace($RepoRoot + [IO.Path]::DirectorySeparatorChar, '')
        
        # Check for required pipeline_state.json
        if (-not (Test-Path -LiteralPath $stateFile)) {
            Add-Issue -Collector $issues -File $relativePath -Severity 'Error' -Message 'DS-Star session missing pipeline_state.json (required for resume capability)'
            continue
        }
        
        try {
            $state = Get-Content -LiteralPath $stateFile -Raw | ConvertFrom-Json
            
            # Check for infinite loops (max 10 rounds)
            if ($state.current_round -and $state.current_round -gt 10) {
                Add-Issue -Collector $issues -File "$relativePath/pipeline_state.json" -Severity 'Error' -Message "Session exceeded max refinement rounds: $($state.current_round) (limit: 10)"
            }
            
            # Validate artifact completeness for completed steps
            if ($state.completed_steps) {
                foreach ($step in $state.completed_steps) {
                    $stepDir = Join-Path $session.FullName "steps/$step"
                    
                    if (Test-Path -LiteralPath $stepDir) {
                        # Check for required metadata
                        $metadataFile = Join-Path $stepDir 'metadata.json'
                        if (-not (Test-Path -LiteralPath $metadataFile)) {
                            Add-Issue -Collector $issues -File "$relativePath/steps/$step" -Severity 'Warning' -Message 'Step directory missing metadata.json'
                        }
                        
                        # Check for prompt file
                        $promptFile = Join-Path $stepDir 'prompt.md'
                        if (-not (Test-Path -LiteralPath $promptFile)) {
                            Add-Issue -Collector $issues -File "$relativePath/steps/$step" -Severity 'Warning' -Message 'Step directory missing prompt.md (required for reproducibility)'
                        }
                    }
                }
            }
            
            # Check for final output if status is completed
            if ($state.status -eq 'completed') {
                $finalReport = Join-Path $session.FullName 'final_output/analysis-report.md'
                if (-not (Test-Path -LiteralPath $finalReport)) {
                    Add-Issue -Collector $issues -File "$relativePath/final_output" -Severity 'Error' -Message 'Completed DS-Star session missing final analysis report'
                }
                
                # Check for final code
                $finalCode = Join-Path $session.FullName 'final_output/final_analysis.py'
                if (-not (Test-Path -LiteralPath $finalCode)) {
                    Add-Issue -Collector $issues -File "$relativePath/final_output" -Severity 'Warning' -Message 'Completed session missing final_analysis.py (recommended for reproducibility)'
                }
            }
            
            # Validate verification history
            if ($state.verification_history -and $state.verification_history.Count -gt 0) {
                $lastVerification = $state.verification_history[-1]
                if ($state.status -eq 'completed' -and $lastVerification.verdict -ne 'SUFFICIENT') {
                    Add-Issue -Collector $issues -File "$relativePath/pipeline_state.json" -Severity 'Warning' -Message "Session marked completed but last verification was $($lastVerification.verdict)"
                }
            }
            
        } catch {
            Add-Issue -Collector $issues -File "$relativePath/pipeline_state.json" -Severity 'Error' -Message "Invalid JSON format: $($_.Exception.Message)"
        }
    }
}

# Present results
if ($issues.Count -eq 0) {
    Write-Host '✅ All Copilot assets passed validation.' -ForegroundColor Green
    exit 0
}

$errors = @($issues | Where-Object { $_.Severity -eq 'Error' })
$warnings = @($issues | Where-Object { $_.Severity -eq 'Warning' })

if ($errors.Count -gt 0) {
    Write-Host "❌ Found $($errors.Count) error(s):" -ForegroundColor Red
    foreach ($errItem in $errors) {
        Write-Host "  [$($errItem.Severity)] $($errItem.File): $($errItem.Message)" -ForegroundColor Red
    }
}

if ($warnings.Count -gt 0) {
    Write-Host "⚠️  Found $($warnings.Count) warning(s):" -ForegroundColor Yellow
    foreach ($warnItem in $warnings) {
        Write-Host "  [$($warnItem.Severity)] $($warnItem.File): $($warnItem.Message)" -ForegroundColor Yellow
    }
}

if ($errors.Count -gt 0 -or ($FailOnWarning.IsPresent -and $warnings.Count -gt 0)) {
    exit 1
}

exit 0
