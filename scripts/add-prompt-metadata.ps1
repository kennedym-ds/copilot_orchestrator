[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RepositoryRoot = (Get-Location).Path,

    [switch]$CheckOnly,
    [switch]$Fix
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

function Get-FrontMatterBlock {
    param(
        [string]$FilePath
    )

    $lines = Get-Content -LiteralPath $FilePath
    if ($lines.Count -lt 3 -or $lines[0].Trim() -ne '---') {
        return @()
    }

    $endIndex = $null
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Trim() -eq '---') {
            $endIndex = $i
            break
        }
    }

    if ($null -eq $endIndex) {
        return @()
    }

    return $lines[0..$endIndex]
}

if (-not (Test-Path -LiteralPath $RepositoryRoot)) {
    throw "Repository root '$RepositoryRoot' was not found."
}

$RepoRoot = (Resolve-Path -LiteralPath $RepositoryRoot).ProviderPath
$promptRoot = Join-Path -Path $RepoRoot -ChildPath '.github/prompts'

if (-not (Test-Path -LiteralPath $promptRoot)) {
    Write-Host 'Prompt directory not found. Nothing to normalize.' -ForegroundColor Yellow
    exit 0
}

$promptFiles = Get-ChildItem -Path $promptRoot -Filter '*.prompt.md' -Recurse -File -ErrorAction SilentlyContinue
if (-not $promptFiles -or $promptFiles.Count -eq 0) {
    Write-Host 'Prompt directory contains no *.prompt.md files.' -ForegroundColor Yellow
    exit 0
}

$requiredKeys = @('name', 'description', 'model', 'agent', 'tools')
$missingMetadata = @()

foreach ($prompt in $promptFiles) {
    $frontMatterBlock = Get-FrontMatterBlock -FilePath $prompt.FullName
    $relativePath = $prompt.FullName.Replace($RepoRoot + [IO.Path]::DirectorySeparatorChar, '')

    if ($frontMatterBlock.Count -eq 0) {
        if ($Fix.IsPresent) {
            $title = ($prompt.BaseName -replace '[_\-]', ' ')
            $defaultFrontMatter = @(
                '---',
                "name: '$title'",
                "description: 'TODO: add description for $title prompt.'",
                "model: GPT-5-Codex (Preview)",
                "mode: planner",
                "tools:",
                "  - todos",
                "  - readFile",
                "  - fetch",
                "  - search",
                "version: 0.1.0",
                "tags:",
                "  - orchestrator",
                '---'
            )

            $content = Get-Content -LiteralPath $prompt.FullName -Raw
            $body = if ($content) { $content.TrimStart() } else { '' }
            $newContent = [string]::Join("`n", $defaultFrontMatter) + "`n`n" + ($body -replace '^---.*?---\s*', '', 'Singleline')
            Set-Content -LiteralPath $prompt.FullName -Value $newContent
            Write-Host "Injected default front matter into $relativePath" -ForegroundColor Cyan
            $frontMatterBlock = $defaultFrontMatter
        } else {
            $missingMetadata += [PSCustomObject]@{ File = $relativePath; Missing = 'front matter' }
            continue
        }
    }

    $frontMatter = [string]::Join("`n", ($frontMatterBlock | Select-Object -Skip 1 | Select-Object -SkipLast 1))
    foreach ($key in $requiredKeys) {
        if ($frontMatter -notmatch ("(?m)^" + [regex]::Escape($key) + ":")) {
            $missingMetadata += [PSCustomObject]@{ File = $relativePath; Missing = $key }
        }
    }
}

if ($missingMetadata.Count -gt 0) {
    Write-Host 'Found prompts with missing metadata:' -ForegroundColor Red
    $missingMetadata | Sort-Object File | ForEach-Object {
        Write-Host "  $($_.File) → missing $($_.Missing)" -ForegroundColor Red
    }

    if (-not $CheckOnly.IsPresent -and -not $Fix.IsPresent) {
        Write-Host 'Use -CheckOnly to run in CI or -Fix to populate default front matter for empty prompts.' -ForegroundColor Yellow
    }
    exit 1
}

if ($Fix.IsPresent) {
    Write-Host 'Prompt metadata normalization complete.' -ForegroundColor Green
} else {
    Write-Host 'Prompt metadata check passed.' -ForegroundColor Green
}
