<#
.SYNOPSIS
    Validates translation artifacts, confidence scores, and manifest integrity.
.DESCRIPTION
    Checks that all translation workflow artifacts are present, properly structured,
    and consistent. Validates the translation manifest, confidence matrix, and
    phase completion records.
.PARAMETER RepositoryRoot
    Path to the repository root containing artifacts/plans/translation/.
.PARAMETER ManifestPath
    Optional path to manifest.json. Defaults to artifacts/plans/translation/manifest.json.
.EXAMPLE
    pwsh -File scripts/validate-translation.ps1 -RepositoryRoot .
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$RepositoryRoot,

    [string]$ManifestPath
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

# --- Resolve paths ---
$root = Resolve-Path $RepositoryRoot
$translationDir = Join-Path $root 'artifacts' 'plans' 'translation'

if (-not $ManifestPath) {
    $ManifestPath = Join-Path $translationDir 'manifest.json'
}

$errors   = @()
$warnings = @()
$info     = @()

Write-Host "`n=== Translation Artifact Validation ===" -ForegroundColor Cyan
Write-Host "Repository: $root"
Write-Host "Translation Dir: $translationDir`n"

# --- Check translation directory exists ---
if (-not (Test-Path $translationDir)) {
    Write-Host "[FAIL] Translation directory not found: $translationDir" -ForegroundColor Red
    Write-Host "  Run the translation-conductor agent to create translation artifacts."
    exit 1
}

$info += "Translation directory exists: $translationDir"

# --- Check manifest.json ---
Write-Host "Checking manifest.json..." -ForegroundColor Yellow
if (Test-Path $ManifestPath) {
    try {
        $manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Json
        $info += "Manifest loaded: $ManifestPath"

        # Validate required fields
        $requiredFields = @('source', 'target', 'modules', 'dependencyGraph')
        foreach ($field in $requiredFields) {
            if (-not ($manifest.PSObject.Properties.Name -contains $field)) {
                $errors += "Manifest missing required field: $field"
            }
        }

        # Validate source/target info
        if ($manifest.source) {
            if (-not $manifest.source.language) { $errors += "Manifest source.language is missing" }
            if (-not $manifest.source.totalFiles) { $warnings += "Manifest source.totalFiles not set" }
        }
        if ($manifest.target) {
            if (-not $manifest.target.language) { $errors += "Manifest target.language is missing" }
        }

        # Validate modules
        if ($manifest.modules) {
            $moduleCount = $manifest.modules.Count
            $info += "Total modules in manifest: $moduleCount"

            $statuses = @{}
            foreach ($mod in $manifest.modules) {
                if (-not $mod.id) { $errors += "Module missing 'id' field" }
                if (-not $mod.sourcePath) { $errors += "Module $($mod.id) missing 'sourcePath'" }
                if (-not $mod.status) { $warnings += "Module $($mod.id) has no status" }

                $status = if ($mod.status) { $mod.status } else { 'unknown' }
                if (-not $statuses.ContainsKey($status)) { $statuses[$status] = 0 }
                $statuses[$status]++
            }

            Write-Host "  Module Status Distribution:" -ForegroundColor Gray
            foreach ($key in $statuses.Keys | Sort-Object) {
                $count = $statuses[$key]
                $pct = [math]::Round(($count / $moduleCount) * 100, 1)
                Write-Host "    $key : $count ($pct%)"
            }

            # Check confidence scores
            $scored = $manifest.modules | Where-Object { $_.confidence -ne $null }
            if ($scored) {
                $avgConfidence = ($scored | Measure-Object -Property confidence -Average).Average
                $minConfidence = ($scored | Measure-Object -Property confidence -Minimum).Minimum
                $maxConfidence = ($scored | Measure-Object -Property confidence -Maximum).Maximum

                $info += "Confidence Scores: avg=$([math]::Round($avgConfidence, 3)), min=$([math]::Round($minConfidence, 3)), max=$([math]::Round($maxConfidence, 3))"

                # Check for critical scores
                $critical = $scored | Where-Object { $_.confidence -lt 0.5 }
                if ($critical) {
                    foreach ($c in $critical) {
                        $warnings += "CRITICAL confidence ($($c.confidence)) for $($c.sourcePath)"
                    }
                }
            } else {
                $warnings += "No modules have confidence scores yet"
            }
        }

        # Validate dependency graph
        if ($manifest.dependencyGraph -and $manifest.dependencyGraph.layers) {
            $layerCount = $manifest.dependencyGraph.layers.Count
            $info += "Dependency graph layers: $layerCount"
        } else {
            $warnings += "Dependency graph is empty or missing layers"
        }

    } catch {
        $errors += "Failed to parse manifest.json: $($_.Exception.Message)"
    }
} else {
    $errors += "Manifest not found: $ManifestPath"
}

# --- Check phase completion records ---
Write-Host "`nChecking phase completion records..." -ForegroundColor Yellow
$phases = @(
    @{ File = 'phase-2-complete.md'; Name = 'Foundation Types' },
    @{ File = 'phase-3-complete.md'; Name = 'Business Logic' },
    @{ File = 'phase-4-complete.md'; Name = 'Integration Layer' },
    @{ File = 'phase-5-complete.md'; Name = 'QA & Security' },
    @{ File = 'phase-6-complete.md'; Name = 'Documentation' }
)

foreach ($phase in $phases) {
    $phasePath = Join-Path $translationDir $phase.File
    if (Test-Path $phasePath) {
        $info += "Phase complete: $($phase.Name) ($($phase.File))"
        Write-Host "  [OK] $($phase.Name)" -ForegroundColor Green
    } else {
        Write-Host "  [--] $($phase.Name) (not yet complete)" -ForegroundColor Gray
    }
}

# --- Check plan files ---
Write-Host "`nChecking plan files..." -ForegroundColor Yellow
$planFiles = @('plan.md', 'plan-complete.md', 'final-report.md', 'confidence-matrix.json', 'translation-decisions.md')
foreach ($planFile in $planFiles) {
    $filePath = Join-Path $translationDir $planFile
    if (Test-Path $filePath) {
        $info += "Plan artifact found: $planFile"
        Write-Host "  [OK] $planFile" -ForegroundColor Green
    } else {
        Write-Host "  [--] $planFile (not yet created)" -ForegroundColor Gray
    }
}

# --- Check confidence matrix ---
$matrixPath = Join-Path $translationDir 'confidence-matrix.json'
if (Test-Path $matrixPath) {
    Write-Host "`nValidating confidence matrix..." -ForegroundColor Yellow
    try {
        $matrix = Get-Content $matrixPath -Raw | ConvertFrom-Json
        if ($matrix -is [array]) {
            $info += "Confidence matrix entries: $($matrix.Count)"

            $bands = @{ High = 0; Medium = 0; Low = 0; Critical = 0 }
            foreach ($entry in $matrix) {
                $score = $entry.score
                if ($score -ge 0.9) { $bands.High++ }
                elseif ($score -ge 0.7) { $bands.Medium++ }
                elseif ($score -ge 0.5) { $bands.Low++ }
                else { $bands.Critical++ }
            }

            Write-Host "  Confidence Distribution:" -ForegroundColor Gray
            Write-Host "    High (>=0.9):    $($bands.High)" -ForegroundColor Green
            Write-Host "    Medium (0.7-0.89): $($bands.Medium)" -ForegroundColor Yellow
            Write-Host "    Low (0.5-0.69):  $($bands.Low)" -ForegroundColor DarkYellow
            Write-Host "    Critical (<0.5): $($bands.Critical)" -ForegroundColor Red
        }
    } catch {
        $warnings += "Failed to parse confidence-matrix.json: $($_.Exception.Message)"
    }
}

# --- Summary ---
Write-Host "`n=== Validation Summary ===" -ForegroundColor Cyan

if ($info.Count -gt 0) {
    Write-Host "`n[INFO] ($($info.Count)):" -ForegroundColor Blue
    foreach ($i in $info) { Write-Host "  - $i" }
}

if ($warnings.Count -gt 0) {
    Write-Host "`n[WARNINGS] ($($warnings.Count)):" -ForegroundColor Yellow
    foreach ($w in $warnings) { Write-Host "  - $w" }
}

if ($errors.Count -gt 0) {
    Write-Host "`n[ERRORS] ($($errors.Count)):" -ForegroundColor Red
    foreach ($e in $errors) { Write-Host "  - $e" }
    Write-Host "`nValidation FAILED" -ForegroundColor Red
    exit 1
} else {
    Write-Host "`nValidation PASSED" -ForegroundColor Green
    exit 0
}
