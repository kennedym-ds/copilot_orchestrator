<#
.SYNOPSIS
    Artifact lifecycle management -- rolloff, compaction, and index generation.

.DESCRIPTION
    Scans YAML frontmatter in artifact Markdown files to enforce retention policies:
    - Permanent artifacts are never touched
    - Seasonal artifacts past TTL are moved to .archive/
    - Ephemeral artifacts past TTL are deleted
    - Artifacts with no frontmatter default to seasonal/90 days
    Generates compacted summaries (.compact.md) for seasonal artifacts at 75% TTL.
    Rebuilds artifact-index.md from all active artifacts.

.PARAMETER RepositoryRoot
    Path to the repository root. Defaults to current directory.

.PARAMETER DryRun
    Preview changes without modifying any files.

.PARAMETER Force
    Skip confirmation prompts for deletions.

.EXAMPLE
    powershell -File scripts/cleanup-artifacts.ps1

.EXAMPLE
    powershell -File scripts/cleanup-artifacts.ps1 -DryRun

.EXAMPLE
    powershell -File scripts/cleanup-artifacts.ps1 -RepositoryRoot "C:\Projects\my-app" -Force
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$RepositoryRoot = (Get-Location).Path,

    [Parameter()]
    [switch]$DryRun,

    [Parameter()]
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$artifactsPath = Join-Path $RepositoryRoot "artifacts"
$archivePath   = Join-Path $artifactsPath ".archive"
$indexPath     = Join-Path $artifactsPath "artifact-index.md"

# Retention defaults (days)
$DefaultRetention = @{
    permanent  = [int]::MaxValue
    seasonal   = 90
    ephemeral  = 14
}

$CompactionThreshold = 0.75  # Compact at 75% of TTL

# Counters
$stats = @{
    Scanned   = 0
    Archived  = 0
    Deleted   = 0
    Compacted = 0
    Skipped   = 0
    Errors    = 0
}

# ── Helpers ──────────────────────────────────────────────────────────────

function Parse-YamlFrontmatter {
    <#
    .SYNOPSIS
        Extracts simple YAML frontmatter key-value pairs from a Markdown file.
    #>
    param([string]$FilePath)

    $lines = Get-Content -Path $FilePath -Encoding UTF8 -ErrorAction Stop
    $meta = @{}

    if ($lines.Count -lt 2 -or $lines[0].Trim() -ne '---') {
        return $meta
    }

    for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Trim() -eq '---') { break }
        if ($lines[$i] -match '^\s*([^:]+):\s*(.*)$') {
            $key   = $Matches[1].Trim()
            $value = $Matches[2].Trim()
            $meta[$key] = $value
        }
    }
    return $meta
}

function Get-ArtifactAge {
    <#
    .SYNOPSIS
        Returns the age in days based on the 'date' frontmatter field.
    #>
    param([hashtable]$Meta)

    if ($Meta.ContainsKey('date') -and $Meta['date']) {
        try {
            $created = [datetime]::Parse($Meta['date'])
            return ([datetime]::Now - $created).Days
        } catch {
            return -1
        }
    }
    return -1
}

function Get-RetentionTier {
    param([hashtable]$Meta)
    if ($Meta.ContainsKey('retention') -and $Meta['retention']) {
        $tier = $Meta['retention'].ToLower()
        if ($DefaultRetention.ContainsKey($tier)) { return $tier }
    }
    return 'seasonal'  # Default
}

function Get-TtlDays {
    param([hashtable]$Meta, [string]$Tier)
    if ($Meta.ContainsKey('ttl-days') -and $Meta['ttl-days']) {
        try { return [int]$Meta['ttl-days'] } catch { }
    }
    return $DefaultRetention[$Tier]
}

# ── Scan & Process ───────────────────────────────────────────────────────

if (-not (Test-Path $artifactsPath)) {
    Write-Error "Artifacts folder not found at: $artifactsPath"
    exit 1
}

# Ensure archive folder exists
if (-not (Test-Path $archivePath)) {
    New-Item -ItemType Directory -Path $archivePath -Force | Out-Null
}

# Collect all markdown files (exclude .archive, artifact-index.md, README.md)
$mdFiles = @(Get-ChildItem -Path $artifactsPath -Recurse -Filter "*.md" |
    Where-Object {
        $_.FullName -notlike "*\.archive\*" -and
        $_.Name -ne "artifact-index.md" -and
        $_.Name -ne "README.md" -and
        $_.Name -notlike "*.compact.md"
    })

Write-Host "`n=== Artifact Cleanup ===" -ForegroundColor Cyan
Write-Host "Scanning: $artifactsPath"
if ($DryRun) { Write-Host "[DRY RUN] No files will be modified." -ForegroundColor Yellow }
Write-Host ""

foreach ($file in $mdFiles) {
    $stats.Scanned++

    $meta = Parse-YamlFrontmatter -FilePath $file.FullName
    $tier = Get-RetentionTier -Meta $meta
    $ttl  = Get-TtlDays -Meta $meta -Tier $tier
    $age  = Get-ArtifactAge -Meta $meta

    # Skip if no parseable date
    if ($age -lt 0) {
        $stats.Skipped++
        Write-Host "  [SKIP] $($file.Name) -- no parseable date" -ForegroundColor DarkGray
        continue
    }

    # Permanent -- never touch
    if ($tier -eq 'permanent') {
        $stats.Skipped++
        Write-Host "  [PERM] $($file.Name) -- permanent, age ${age}d" -ForegroundColor DarkGreen
        continue
    }

    $relativePath = $file.FullName.Substring($artifactsPath.Length + 1)

    # Past TTL -- archive or delete
    if ($age -ge $ttl) {
        if ($tier -eq 'ephemeral') {
            Write-Host "  [DEL]  $($file.Name) -- ephemeral, age ${age}d > TTL ${ttl}d" -ForegroundColor Red
            if (-not $DryRun) {
                Remove-Item -Path $file.FullName -Force
            }
            $stats.Deleted++
        } else {
            # Seasonal past TTL -- archive
            $archiveDest = Join-Path $archivePath $relativePath
            $archiveDir  = Split-Path $archiveDest -Parent
            Write-Host "  [ARC]  $($file.Name) -- seasonal, age ${age}d > TTL ${ttl}d -> .archive/" -ForegroundColor Yellow
            if (-not $DryRun) {
                if (-not (Test-Path $archiveDir)) {
                    New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null
                }
                Move-Item -Path $file.FullName -Destination $archiveDest -Force
            }
            $stats.Archived++
        }
        continue
    }

    # Approaching TTL (75%) -- generate compact if not already present
    $compactionAge = [math]::Floor($ttl * $CompactionThreshold)
    $compactPath   = $file.FullName -replace '\.md$', '.compact.md'

    if ($age -ge $compactionAge -and -not (Test-Path $compactPath)) {
        $msg = "  [CMP]  {0} -- age {1}d >= {2}d [75pct of {3}d], compacting" -f $file.Name, $age, $compactionAge, $ttl
        Write-Host $msg -ForegroundColor Magenta
        if (-not $DryRun) {
            # Generate a minimal compact stub -- agents should refine this
            $compactContent = @"
---
date: $(Get-Date -Format 'yyyy-MM-dd')
status: compacted
original: $($file.Name)
retention: $tier
ttl-days: $ttl
compacted-date: $(Get-Date -Format 'yyyy-MM-dd')
---

## $($file.BaseName) (Compacted)

**Key Findings:**
- _Auto-compacted. Review and summarize key findings._

**Decisions Made:**
- _Extract decisions from the original artifact._

**Outcome:** _Summarize the outcome._

**Full artifact:** artifacts/$relativePath
"@
            Set-Content -Path $compactPath -Value $compactContent -Encoding UTF8
        }
        $stats.Compacted++
    } else {
        Write-Host "  [OK]   $($file.Name) -- $tier, age ${age}d / TTL ${ttl}d" -ForegroundColor Green
    }
}

# ── Rebuild Index ────────────────────────────────────────────────────────

Write-Host "`n--- Rebuilding artifact-index.md ---" -ForegroundColor Cyan

# Re-scan active artifacts after cleanup
$activeFiles = @(Get-ChildItem -Path $artifactsPath -Recurse -Filter "*.md" |
    Where-Object {
        $_.FullName -notlike "*\.archive\*" -and
        $_.Name -ne "artifact-index.md" -and
        $_.Name -ne "README.md" -and
        $_.Name -notlike "*.compact.md"
    })

$compactFiles = @(Get-ChildItem -Path $artifactsPath -Recurse -Filter "*.compact.md" |
    Where-Object { $_.FullName -notlike "*\.archive\*" })

$decisions   = @()
$plans       = @()
$research    = @()
$reviews     = @()
$other       = @()

foreach ($f in $activeFiles) {
    $rel  = $f.FullName.Substring($artifactsPath.Length + 1).Replace('\', '/')
    $m    = Parse-YamlFrontmatter -FilePath $f.FullName
    $tier = Get-RetentionTier -Meta $m
    $age  = Get-ArtifactAge -Meta $m
    $ageStr = if ($age -ge 0) { "${age}d" } else { "?" }
    $entry = "- [$($f.Name)]($rel) -- $tier, age $ageStr"

    if ($rel -like "decisions/*")    { $decisions += $entry }
    elseif ($rel -like "plans/*")    { $plans     += $entry }
    elseif ($rel -like "research/*") { $research  += $entry }
    elseif ($rel -like "reviews/*")  { $reviews   += $entry }
    else                              { $other     += $entry }
}

$compactedEntries = @()
foreach ($c in $compactFiles) {
    $rel = $c.FullName.Substring($artifactsPath.Length + 1).Replace('\', '/')
    $compactedEntries += "- [$($c.Name)]($rel)"
}

$indexContent = @"
---
generated: $(Get-Date -Format 'yyyy-MM-dd')
status: active
---

# Artifact Index

Auto-generated by ``scripts/cleanup-artifacts.ps1``. Do not edit manually.

## Active Decisions ($($decisions.Count))

$(if ($decisions.Count -gt 0) { $decisions -join "`n" } else { "_No decisions recorded yet._" })

## Active Plans ($($plans.Count))

$(if ($plans.Count -gt 0) { $plans -join "`n" } else { "_No active plans._" })

## Recent Research ($($research.Count))

$(if ($research.Count -gt 0) { $research -join "`n" } else { "_No recent research._" })

## Recent Reviews ($($reviews.Count))

$(if ($reviews.Count -gt 0) { $reviews -join "`n" } else { "_No recent reviews._" })

## Other Active Artifacts ($($other.Count))

$(if ($other.Count -gt 0) { $other -join "`n" } else { "_None._" })

## Compacted Artifacts ($($compactedEntries.Count))

$(if ($compactedEntries.Count -gt 0) { $compactedEntries -join "`n" } else { "_No compacted artifacts._" })

## Statistics

- Total active artifacts: $($activeFiles.Count)
- Total compacted: $($compactFiles.Count)
- Total archived (this run): $($stats.Archived)
- Total deleted (this run): $($stats.Deleted)
"@

if (-not $DryRun) {
    Set-Content -Path $indexPath -Value $indexContent -Encoding UTF8
    Write-Host "[OK] Index written: $indexPath" -ForegroundColor Green
} else {
    Write-Host "[DRY RUN] Would write index to: $indexPath" -ForegroundColor Yellow
}

# ── Summary ──────────────────────────────────────────────────────────────

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "  Scanned:   $($stats.Scanned)"
Write-Host "  Skipped:   $($stats.Skipped)"
Write-Host "  Archived:  $($stats.Archived)"
Write-Host "  Deleted:   $($stats.Deleted)"
Write-Host "  Compacted: $($stats.Compacted)"
Write-Host "  Errors:    $($stats.Errors)"
if ($DryRun) { Write-Host "`n[DRY RUN] No changes were made." -ForegroundColor Yellow }
Write-Host ""
