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
$agentFiles += Get-ChildItem -Path (Join-Path $RepoRoot '.github/chatmodes') -Filter '*.chatmode.md' -File -ErrorAction SilentlyContinue

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
