<#
.SYNOPSIS
    Analyzes agent session metadata and generates metrics reports.

.DESCRIPTION
    This script collects and analyzes session data from the Copilot Orchestrator
    to provide insights into workflow performance, cost efficiency, and quality metrics.
    
    It generates reports on:
    - Escalation patterns and frequency
    - Model usage and cost breakdown
    - Phase duration and bottlenecks
    - Review outcomes and quality trends
    - Common failure patterns

.PARAMETER SessionsPath
    Path to directory containing session metadata JSON files.
    Default: ./plans/sessions

.PARAMETER OutputPath
    Path where analysis reports will be saved.
    Default: ./docs/dashboards

.PARAMETER StartDate
    Start date for analysis window (ISO 8601 format).
    Default: 30 days ago

.PARAMETER EndDate
    End date for analysis window (ISO 8601 format).
    Default: Today

.PARAMETER Format
    Output format: Markdown, JSON, or CSV.
    Default: Markdown

.EXAMPLE
    .\analyze-sessions.ps1
    Analyzes last 30 days with default settings

.EXAMPLE
    .\analyze-sessions.ps1 -StartDate "2025-10-01" -EndDate "2025-10-31" -Format JSON
    Analyzes October 2025 and outputs JSON

.NOTES
    Version: 1.0.0
    Author: Copilot Orchestrator Team
    Created: 2025-11-07
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$SessionsPath = "./plans/sessions",
    
    [Parameter()]
    [string]$OutputPath = "./docs/dashboards",
    
    [Parameter()]
    [datetime]$StartDate = (Get-Date).AddDays(-30),
    
    [Parameter()]
    [datetime]$EndDate = (Get-Date),
    
    [Parameter()]
    [ValidateSet('Markdown', 'JSON', 'CSV')]
    [string]$Format = 'Markdown'
)

# Initialize session metadata structure
$script:SessionMetadata = @{
    TotalSessions = 0
    CompletedSessions = 0
    FailedSessions = 0
    InProgressSessions = 0
    Phases = @{
        Planning = 0
        Implementation = 0
        Review = 0
        Complete = 0
    }
    Escalations = @{
        Tier1 = 0
        Tier2 = 0
        Tier3 = 0
        Total = 0
    }
    ModelUsage = @{
        Premium = 0
        Efficient = 0
        TotalCost = 0.0
    }
    Reviews = @{
        Approved = 0
        NeedsRevision = 0
        Failed = 0
        TotalReviews = 0
    }
    AverageDurations = @{
        Planning = @()
        Implementation = @()
        Review = @()
        Total = @()
    }
    FailurePatterns = @{}
}

function Get-SessionFiles {
    <#
    .SYNOPSIS
        Retrieves session metadata files within the date range.
    #>
    param(
        [string]$Path,
        [datetime]$Start,
        [datetime]$End
    )
    
    if (-not (Test-Path $Path)) {
        Write-Warning "Sessions path not found: $Path"
        Write-Host "Creating sessions directory for future use..."
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        return @()
    }
    
    Get-ChildItem -Path $Path -Filter "*.json" -File | Where-Object {
        $_.LastWriteTime -ge $Start -and $_.LastWriteTime -le $End
    }
}

function Read-SessionMetadata {
    <#
    .SYNOPSIS
        Parses a session metadata JSON file.
    #>
    param(
        [System.IO.FileInfo]$File
    )
    
    try {
        $content = Get-Content -Path $File.FullName -Raw | ConvertFrom-Json
        return $content
    }
    catch {
        Write-Warning "Failed to parse $($File.Name): $_"
        return $null
    }
}

function Update-Metrics {
    <#
    .SYNOPSIS
        Updates aggregated metrics from a session.
    #>
    param($Session)
    
    $script:SessionMetadata.TotalSessions++
    
    # Track session status
    switch ($Session.status) {
        'complete' { $script:SessionMetadata.CompletedSessions++ }
        'failed' { $script:SessionMetadata.FailedSessions++ }
        'in_progress' { $script:SessionMetadata.InProgressSessions++ }
    }
    
    # Track current phase
    if ($Session.currentPhase) {
        $phase = $Session.currentPhase
        if ($script:SessionMetadata.Phases.ContainsKey($phase)) {
            $script:SessionMetadata.Phases[$phase]++
        }
    }
    
    # Track escalations
    if ($Session.escalations) {
        foreach ($escalation in $Session.escalations) {
            $tier = $escalation.tier
            if ($script:SessionMetadata.Escalations.ContainsKey($tier)) {
                $script:SessionMetadata.Escalations[$tier]++
            }
            $script:SessionMetadata.Escalations.Total++
        }
    }
    
    # Track model usage
    if ($Session.modelUsage) {
        foreach ($usage in $Session.modelUsage) {
            if ($usage.tier -eq 'premium') {
                $script:SessionMetadata.ModelUsage.Premium++
                $script:SessionMetadata.ModelUsage.TotalCost += ($usage.cost -as [double])
            }
            elseif ($usage.tier -eq 'efficient') {
                $script:SessionMetadata.ModelUsage.Efficient++
                $script:SessionMetadata.ModelUsage.TotalCost += ($usage.cost -as [double])
            }
        }
    }
    
    # Track review outcomes
    if ($Session.reviews) {
        foreach ($review in $Session.reviews) {
            $script:SessionMetadata.Reviews.TotalReviews++
            switch ($review.verdict) {
                'APPROVED' { $script:SessionMetadata.Reviews.Approved++ }
                'NEEDS_REVISION' { $script:SessionMetadata.Reviews.NeedsRevision++ }
                'FAILED' { $script:SessionMetadata.Reviews.Failed++ }
            }
        }
    }
    
    # Track durations
    if ($Session.phaseDurations) {
        foreach ($duration in $Session.phaseDurations) {
            $phase = $duration.phase
            $minutes = $duration.durationMinutes -as [double]
            if ($script:SessionMetadata.AverageDurations.ContainsKey($phase)) {
                $script:SessionMetadata.AverageDurations[$phase] += $minutes
            }
        }
    }
    
    # Track failure patterns
    if ($Session.status -eq 'failed' -and $Session.failureReason) {
        $reason = $Session.failureReason
        if ($script:SessionMetadata.FailurePatterns.ContainsKey($reason)) {
            $script:SessionMetadata.FailurePatterns[$reason]++
        }
        else {
            $script:SessionMetadata.FailurePatterns[$reason] = 1
        }
    }
}

function Format-MarkdownReport {
    <#
    .SYNOPSIS
        Formats metrics as a Markdown dashboard.
    #>
    
    $mermaidChart = @"
``````mermaid
pie title Current Phase Distribution
    "Planning" : $($script:SessionMetadata.Phases.Planning)
    "Implementation" : $($script:SessionMetadata.Phases.Implementation)
    "Review" : $($script:SessionMetadata.Phases.Review)
    "Complete" : $($script:SessionMetadata.Phases.Complete)
``````
"@
    
    $noDataMessage = @"
**No session data available for this period.**

To start collecting analytics:
1. Ensure session metadata is being written to ``$SessionsPath``
2. Follow the session metadata schema (see docs/templates/)
3. Run this script again after sessions complete
"@

    $insightsWithData = @"
### Escalation Patterns
- $(if ($script:SessionMetadata.Escalations.Total -eq 0) { "No escalations recorded - excellent!" } elseif (($script:SessionMetadata.Escalations.Total / $script:SessionMetadata.TotalSessions) -gt 0.5) { "High escalation rate suggests instruction tuning needed" } else { "Escalation rate is healthy" })

### Cost Efficiency
- $(if (($script:SessionMetadata.ModelUsage.Premium + $script:SessionMetadata.ModelUsage.Efficient) -eq 0) { "No model usage data available" } elseif ((($script:SessionMetadata.ModelUsage.Premium / ($script:SessionMetadata.ModelUsage.Premium + $script:SessionMetadata.ModelUsage.Efficient)) * 100) -le 20) { "Excellent cost optimization - below 20% premium usage" } elseif ((($script:SessionMetadata.ModelUsage.Premium / ($script:SessionMetadata.ModelUsage.Premium + $script:SessionMetadata.ModelUsage.Efficient)) * 100) -le 25) { "Good cost control - within 25% target" } else { "Consider reviewing escalation triggers - premium usage high" })

### Quality Trends
- $(if ($script:SessionMetadata.Reviews.TotalReviews -eq 0) { "No review data available" } elseif ((($script:SessionMetadata.Reviews.Approved / $script:SessionMetadata.Reviews.TotalReviews) * 100) -ge 90) { "Excellent quality - meeting 90% approval target" } else { "Review processes may need enhancement" })

### Next Actions
- Review INSTRUCTION_CHANGELOG.md for recent instruction changes
- Check docs/operations.md for planned improvements
- Monitor trends over next reporting period
"@
    
    $insights = if ($script:SessionMetadata.TotalSessions -eq 0) { $noDataMessage } else { $insightsWithData }
    
    $report = @"
# Workflow Metrics Dashboard

**Report Period:** $($StartDate.ToString('yyyy-MM-dd')) to $($EndDate.ToString('yyyy-MM-dd'))
**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

---

## Session Overview

| Metric | Count | Percentage |
|--------|-------|------------|
| Total Sessions | $($script:SessionMetadata.TotalSessions) | 100% |
| Completed | $($script:SessionMetadata.CompletedSessions) | $(if ($script:SessionMetadata.TotalSessions -gt 0) { [math]::Round(($script:SessionMetadata.CompletedSessions / $script:SessionMetadata.TotalSessions) * 100, 1) } else { 0 })% |
| Failed | $($script:SessionMetadata.FailedSessions) | $(if ($script:SessionMetadata.TotalSessions -gt 0) { [math]::Round(($script:SessionMetadata.FailedSessions / $script:SessionMetadata.TotalSessions) * 100, 1) } else { 0 })% |
| In Progress | $($script:SessionMetadata.InProgressSessions) | $(if ($script:SessionMetadata.TotalSessions -gt 0) { [math]::Round(($script:SessionMetadata.InProgressSessions / $script:SessionMetadata.TotalSessions) * 100, 1) } else { 0 })% |

---

## Phase Distribution

$mermaidChart

---

## Escalation Analysis

| Tier | Count | Rate per 10 Sessions |
|------|-------|---------------------|
| Tier 1 (Automatic) | $($script:SessionMetadata.Escalations.Tier1) | $(if ($script:SessionMetadata.TotalSessions -gt 0) { [math]::Round(($script:SessionMetadata.Escalations.Tier1 / $script:SessionMetadata.TotalSessions) * 10, 1) } else { 0 }) |
| Tier 2 (Recommended) | $($script:SessionMetadata.Escalations.Tier2) | $(if ($script:SessionMetadata.TotalSessions -gt 0) { [math]::Round(($script:SessionMetadata.Escalations.Tier2 / $script:SessionMetadata.TotalSessions) * 10, 1) } else { 0 }) |
| Tier 3 (Optional) | $($script:SessionMetadata.Escalations.Tier3) | $(if ($script:SessionMetadata.TotalSessions -gt 0) { [math]::Round(($script:SessionMetadata.Escalations.Tier3 / $script:SessionMetadata.TotalSessions) * 10, 1) } else { 0 }) |
| **Total** | **$($script:SessionMetadata.Escalations.Total)** | **$(if ($script:SessionMetadata.TotalSessions -gt 0) { [math]::Round(($script:SessionMetadata.Escalations.Total / $script:SessionMetadata.TotalSessions) * 10, 1) } else { 0 })** |

---

## Model Usage & Cost

| Metric | Value |
|--------|-------|
| Premium Model Calls | $($script:SessionMetadata.ModelUsage.Premium) |
| Efficient Model Calls | $($script:SessionMetadata.ModelUsage.Efficient) |
| Total Calls | $($script:SessionMetadata.ModelUsage.Premium + $script:SessionMetadata.ModelUsage.Efficient) |
| Premium Usage % | $(if (($script:SessionMetadata.ModelUsage.Premium + $script:SessionMetadata.ModelUsage.Efficient) -gt 0) { [math]::Round(($script:SessionMetadata.ModelUsage.Premium / ($script:SessionMetadata.ModelUsage.Premium + $script:SessionMetadata.ModelUsage.Efficient)) * 100, 1) } else { 0 })% |
| **Target Premium Usage** | **20%** |
| Estimated Total Cost | `$$($script:SessionMetadata.ModelUsage.TotalCost.ToString('F2'))` |

**Status:** $(if (($script:SessionMetadata.ModelUsage.Premium + $script:SessionMetadata.ModelUsage.Efficient) -gt 0 -and (($script:SessionMetadata.ModelUsage.Premium / ($script:SessionMetadata.ModelUsage.Premium + $script:SessionMetadata.ModelUsage.Efficient)) * 100) -le 25) { '✅ Within target (≤25%)' } else { '⚠️ Above target (>25%)' })

---

## Quality Metrics

| Metric | Count | Percentage |
|--------|-------|------------|
| Total Reviews | $($script:SessionMetadata.Reviews.TotalReviews) | 100% |
| Approved | $($script:SessionMetadata.Reviews.Approved) | $(if ($script:SessionMetadata.Reviews.TotalReviews -gt 0) { [math]::Round(($script:SessionMetadata.Reviews.Approved / $script:SessionMetadata.Reviews.TotalReviews) * 100, 1) } else { 0 })% |
| Needs Revision | $($script:SessionMetadata.Reviews.NeedsRevision) | $(if ($script:SessionMetadata.Reviews.TotalReviews -gt 0) { [math]::Round(($script:SessionMetadata.Reviews.NeedsRevision / $script:SessionMetadata.Reviews.TotalReviews) * 100, 1) } else { 0 })% |
| Failed | $($script:SessionMetadata.Reviews.Failed) | $(if ($script:SessionMetadata.Reviews.TotalReviews -gt 0) { [math]::Round(($script:SessionMetadata.Reviews.Failed / $script:SessionMetadata.Reviews.TotalReviews) * 100, 1) } else { 0 })% |

**Target:** ≥90% approval rate  
**Status:** $(if ($script:SessionMetadata.Reviews.TotalReviews -gt 0 -and (($script:SessionMetadata.Reviews.Approved / $script:SessionMetadata.Reviews.TotalReviews) * 100) -ge 90) { '✅ Meeting target' } elseif ($script:SessionMetadata.Reviews.TotalReviews -gt 0) { '⚠️ Below target' } else { 'ℹ️ No data' })

---

## Insights & Recommendations

$insights

---

**Dashboard Status:** Active  
**Next Update:** Run ``scripts/analyze-sessions.ps1`` as needed  
**Data Source:** ``$SessionsPath``
"@
    
    return $report
}

function Format-JsonReport {
    <#
    .SYNOPSIS
        Formats metrics as JSON.
    #>
    
    $report = @{
        reportPeriod = @{
            start = $StartDate.ToString('yyyy-MM-dd')
            end = $EndDate.ToString('yyyy-MM-dd')
            generated = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        }
        metrics = $script:SessionMetadata
    }
    
    return ($report | ConvertTo-Json -Depth 10)
}

# Main execution
Write-Host "Analyzing sessions from $($StartDate.ToString('yyyy-MM-dd')) to $($EndDate.ToString('yyyy-MM-dd'))..." -ForegroundColor Cyan

$sessionFiles = Get-SessionFiles -Path $SessionsPath -Start $StartDate -End $EndDate
Write-Host "Found $($sessionFiles.Count) session files" -ForegroundColor Gray

foreach ($file in $sessionFiles) {
    $session = Read-SessionMetadata -File $file
    if ($session) {
        Update-Metrics -Session $session
    }
}

# Ensure output directory exists
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

# Generate report
$outputFile = Join-Path $OutputPath "workflow-metrics.md"
$report = switch ($Format) {
    'Markdown' { Format-MarkdownReport }
    'JSON' { Format-JsonReport }
    'CSV' { Write-Warning "CSV format not yet implemented"; Format-MarkdownReport }
    default { Format-MarkdownReport }
}

# Save report
Set-Content -Path $outputFile -Value $report -Encoding UTF8
Write-Host "`n✅ Report generated: $outputFile" -ForegroundColor Green

# Display summary
Write-Host "`nQuick Summary:" -ForegroundColor Cyan
Write-Host "  Total Sessions: $($script:SessionMetadata.TotalSessions)" -ForegroundColor Gray
Write-Host "  Completed: $($script:SessionMetadata.CompletedSessions)" -ForegroundColor Green
Write-Host "  Failed: $($script:SessionMetadata.FailedSessions)" -ForegroundColor $(if ($script:SessionMetadata.FailedSessions -gt 0) { 'Yellow' } else { 'Gray' })
if (($script:SessionMetadata.ModelUsage.Premium + $script:SessionMetadata.ModelUsage.Efficient) -gt 0) {
    $premiumPct = [math]::Round(($script:SessionMetadata.ModelUsage.Premium / ($script:SessionMetadata.ModelUsage.Premium + $script:SessionMetadata.ModelUsage.Efficient)) * 100, 1)
    Write-Host "  Premium Usage: $premiumPct% (target: ≤20%)" -ForegroundColor $(if ($premiumPct -le 20) { 'Green' } elseif ($premiumPct -le 25) { 'Yellow' } else { 'Red' })
}
