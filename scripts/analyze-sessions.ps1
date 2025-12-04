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
    - DS-Star adoption, refinement rounds, and verdict telemetry

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

.PARAMETER DSStarPath
    Path to DS-Star session directories (pipeline_state.json files).
    Default: ./plans/data-analysis

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
    [string]$DSStarPath = "./plans/data-analysis",
    
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
    # Enhanced telemetry per StepSecurity recommendations
    AgentActions = @{
        ByAgent = @{}
        ByTool = @{}
        TotalActions = 0
    }
    SecurityFindings = @{
        Blocker = 0
        High = 0
        Medium = 0
        Low = 0
        Total = 0
    }
    ModelBreakdown = @{
        ByModel = @{}
        ByAgent = @{}
    }
}

$script:DsStarMetrics = @{
    Sessions = [System.Collections.Generic.List[object]]::new()
    Summary = @{
        TotalSessions = 0
        CompletedSessions = 0
        InProgressSessions = 0
        BlockedSessions = 0
        ResumeReadySessions = 0
        AvgRounds = 0.0
        AvgDurationMinutes = 0.0
        AvgStepsPerSession = 0.0
        Verdicts = @{
            SUFFICIENT = 0
            INSUFFICIENT = 0
            BLOCKED = 0
        }
    }
    SourcePath = $null
}

$script:SupportsJsonDepthParameter = (Get-Command -Name ConvertFrom-Json).Parameters.ContainsKey('Depth')

function ConvertFrom-JsonSafe {
    param(
        [string]$Json,
        [int]$Depth = 10
    )

    if ($script:SupportsJsonDepthParameter) {
        return $Json | ConvertFrom-Json -Depth $Depth
    }

    return $Json | ConvertFrom-Json
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

    # Track agent actions (per StepSecurity recommendations)
    if ($Session.agentActions) {
        foreach ($action in $Session.agentActions) {
            $script:SessionMetadata.AgentActions.TotalActions++
            
            # Track by agent
            $agentName = if ($action.agent) { $action.agent } else { 'unknown' }
            if (-not $script:SessionMetadata.AgentActions.ByAgent.ContainsKey($agentName)) {
                $script:SessionMetadata.AgentActions.ByAgent[$agentName] = 0
            }
            $script:SessionMetadata.AgentActions.ByAgent[$agentName]++
            
            # Track by tool
            $toolName = if ($action.tool) { $action.tool } else { 'unknown' }
            if (-not $script:SessionMetadata.AgentActions.ByTool.ContainsKey($toolName)) {
                $script:SessionMetadata.AgentActions.ByTool[$toolName] = 0
            }
            $script:SessionMetadata.AgentActions.ByTool[$toolName]++
        }
    }

    # Track security findings
    if ($Session.securityFindings) {
        foreach ($finding in $Session.securityFindings) {
            $script:SessionMetadata.SecurityFindings.Total++
            switch ($finding.severity) {
                'blocker' { $script:SessionMetadata.SecurityFindings.Blocker++ }
                'high' { $script:SessionMetadata.SecurityFindings.High++ }
                'medium' { $script:SessionMetadata.SecurityFindings.Medium++ }
                'low' { $script:SessionMetadata.SecurityFindings.Low++ }
            }
        }
    }

    # Track model breakdown by model name and agent
    if ($Session.modelUsage) {
        foreach ($usage in $Session.modelUsage) {
            $modelName = if ($usage.model) { $usage.model } else { 'unknown' }
            if (-not $script:SessionMetadata.ModelBreakdown.ByModel.ContainsKey($modelName)) {
                $script:SessionMetadata.ModelBreakdown.ByModel[$modelName] = @{ calls = 0; cost = 0.0 }
            }
            $script:SessionMetadata.ModelBreakdown.ByModel[$modelName].calls++
            $script:SessionMetadata.ModelBreakdown.ByModel[$modelName].cost += ($usage.cost -as [double])
            
            $agentName = if ($usage.agent) { $usage.agent } else { 'unknown' }
            if (-not $script:SessionMetadata.ModelBreakdown.ByAgent.ContainsKey($agentName)) {
                $script:SessionMetadata.ModelBreakdown.ByAgent[$agentName] = @{ calls = 0; cost = 0.0 }
            }
            $script:SessionMetadata.ModelBreakdown.ByAgent[$agentName].calls++
            $script:SessionMetadata.ModelBreakdown.ByAgent[$agentName].cost += ($usage.cost -as [double])
        }
    }
}

function Get-DsStarSessions {
    <#
    .SYNOPSIS
        Collects DS-Star session telemetry from pipeline_state.json files.
    #>
    param(
        [string]$Path
    )

    $collection = [System.Collections.Generic.List[object]]::new()

    if (-not (Test-Path -LiteralPath $Path)) {
        return $collection
    }

    $directories = Get-ChildItem -Path $Path -Directory -ErrorAction SilentlyContinue
    foreach ($directory in $directories) {
        $stateFile = Join-Path $directory.FullName 'pipeline_state.json'
        if (-not (Test-Path -LiteralPath $stateFile)) {
            continue
        }

        try {
            $stateJson = Get-Content -LiteralPath $stateFile -Raw
            $state = ConvertFrom-JsonSafe -Json $stateJson -Depth 50
        }
        catch {
            Write-Warning "Failed to parse DS-Star pipeline state for $($directory.Name): $_"
            continue
        }

        $rounds = $null
        if ($state.current_round) {
            $rounds = [int]$state.current_round
        }
        elseif ($state.round_counter) {
            $rounds = [int]$state.round_counter
        }
        elseif ($state.verification_history) {
            $rounds = [int]$state.verification_history.Count
        }

        $steps = if ($state.completed_steps) { [int]$state.completed_steps.Count } else { 0 }

        $duration = $null
        if ($state.duration_minutes) {
            $duration = [double]$state.duration_minutes
        }
        elseif ($state.completed_at -and $state.created_at) {
            try {
                $duration = (([datetime]$state.completed_at) - ([datetime]$state.created_at)).TotalMinutes
            }
            catch {
                $duration = $null
            }
        }

        $lastVerdict = $null
        if ($state.verification_history -and $state.verification_history.Count -gt 0) {
            $lastVerdict = $state.verification_history[-1].verdict
        }
        elseif ($state.active_verdict) {
            $lastVerdict = $state.active_verdict
        }

        $resumeReady = $false
        if ($state.status -eq 'in-progress' -and $state.current_step -and $state.plan -and $state.plan.Count -gt 0) {
            $resumeReady = $true
        }

        $collection.Add([PSCustomObject]@{
                SessionId       = if ($state.session_id) { $state.session_id } else { $directory.Name }
                Directory       = $directory.FullName
                Status          = if ($state.status) { $state.status } else { 'unknown' }
                Rounds          = $rounds
                Steps           = $steps
                DurationMinutes = $duration
                LastVerdict     = $lastVerdict
                ResumeReady     = $resumeReady
                LastWriteTime   = $directory.LastWriteTime
            }) | Out-Null
    }

    return $collection
}

function Update-DsStarMetricsSummary {
    <#
    .SYNOPSIS
        Aggregates DS-Star telemetry into summary stats.
    #>
    param(
        [System.Collections.Generic.List[object]]$Sessions,
        [string]$SourcePath
    )

    $script:DsStarMetrics.SourcePath = $SourcePath
    $script:DsStarMetrics.Sessions = $Sessions
    $summary = $script:DsStarMetrics.Summary

    $summary.TotalSessions = $Sessions.Count
    $summary.CompletedSessions = ($Sessions | Where-Object { $_.Status -eq 'completed' }).Count
    $summary.InProgressSessions = ($Sessions | Where-Object { $_.Status -eq 'in-progress' }).Count
    $summary.BlockedSessions = ($Sessions | Where-Object { $_.Status -eq 'blocked' }).Count
    $summary.ResumeReadySessions = ($Sessions | Where-Object { $_.ResumeReady }).Count

    $roundSamples = $Sessions | Where-Object { $_.Rounds -ne $null } | Select-Object -ExpandProperty Rounds
    if ($roundSamples) {
        $summary.AvgRounds = [math]::Round((($roundSamples | Measure-Object -Average).Average), 1)
    }
    else {
        $summary.AvgRounds = 0.0
    }

    $durationSamples = $Sessions | Where-Object { $_.DurationMinutes -ne $null } | Select-Object -ExpandProperty DurationMinutes
    if ($durationSamples) {
        $summary.AvgDurationMinutes = [math]::Round((($durationSamples | Measure-Object -Average).Average), 1)
    }
    else {
        $summary.AvgDurationMinutes = 0.0
    }

    $stepSamples = $Sessions | Where-Object { $_.Steps -gt 0 } | Select-Object -ExpandProperty Steps
    if ($stepSamples) {
        $summary.AvgStepsPerSession = [math]::Round((($stepSamples | Measure-Object -Average).Average), 1)
    }
    else {
        $summary.AvgStepsPerSession = 0.0
    }

    $summary.Verdicts.SUFFICIENT = ($Sessions | Where-Object { $_.LastVerdict -eq 'SUFFICIENT' }).Count
    $summary.Verdicts.INSUFFICIENT = ($Sessions | Where-Object { $_.LastVerdict -eq 'INSUFFICIENT' }).Count
    $summary.Verdicts.BLOCKED = ($Sessions | Where-Object { $_.LastVerdict -eq 'BLOCKED' }).Count
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

$(Get-ModelBreakdownSection)

---

## Agent Action Telemetry

$(Get-AgentActionSection)

---

## Security Findings

$(Get-SecurityFindingsSection)

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

$(Get-DsStarMarkdownSection)

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

function Get-ModelBreakdownSection {
    <#
    .SYNOPSIS
        Generates model usage breakdown by model name and agent.
    #>

    $breakdown = $script:SessionMetadata.ModelBreakdown

    if ($breakdown.ByModel.Count -eq 0) {
        return "_No detailed model usage data available._"
    }

    $modelLines = $breakdown.ByModel.GetEnumerator() | ForEach-Object {
        "| $($_.Key) | $($_.Value.calls) | `$$($_.Value.cost.ToString('F2'))` |"
    }

    $agentLines = $breakdown.ByAgent.GetEnumerator() | ForEach-Object {
        "| $($_.Key) | $($_.Value.calls) | `$$($_.Value.cost.ToString('F2'))` |"
    }

    return @"
### By Model

| Model | Calls | Cost |
|-------|-------|------|
$($modelLines -join "`n")

### By Agent

| Agent | Calls | Cost |
|-------|-------|------|
$($agentLines -join "`n")
"@
}

function Get-AgentActionSection {
    <#
    .SYNOPSIS
        Generates agent action telemetry section.
    #>

    $actions = $script:SessionMetadata.AgentActions

    if ($actions.TotalActions -eq 0) {
        return "_No agent action data available. Enable action logging in session metadata to track tool usage and agent activity._"
    }

    $agentLines = $actions.ByAgent.GetEnumerator() | Sort-Object -Property Value -Descending | ForEach-Object {
        $pct = [math]::Round(($_.Value / $actions.TotalActions) * 100, 1)
        "| $($_.Key) | $($_.Value) | $pct% |"
    }

    $toolLines = $actions.ByTool.GetEnumerator() | Sort-Object -Property Value -Descending | Select-Object -First 10 | ForEach-Object {
        $pct = [math]::Round(($_.Value / $actions.TotalActions) * 100, 1)
        "| $($_.Key) | $($_.Value) | $pct% |"
    }

    return @"
**Total Actions Logged:** $($actions.TotalActions)

### Actions by Agent

| Agent | Actions | Share |
|-------|---------|-------|
$($agentLines -join "`n")

### Top Tools Used

| Tool | Usage | Share |
|------|-------|-------|
$($toolLines -join "`n")
"@
}

function Get-SecurityFindingsSection {
    <#
    .SYNOPSIS
        Generates security findings summary section.
    #>

    $findings = $script:SessionMetadata.SecurityFindings

    if ($findings.Total -eq 0) {
        return "_No security findings logged. This is expected for sessions without security reviews._"
    }

    return @"
| Severity | Count | Percentage |
|----------|-------|------------|
| Blocker | $($findings.Blocker) | $(if ($findings.Total -gt 0) { [math]::Round(($findings.Blocker / $findings.Total) * 100, 1) } else { 0 })% |
| High | $($findings.High) | $(if ($findings.Total -gt 0) { [math]::Round(($findings.High / $findings.Total) * 100, 1) } else { 0 })% |
| Medium | $($findings.Medium) | $(if ($findings.Total -gt 0) { [math]::Round(($findings.Medium / $findings.Total) * 100, 1) } else { 0 })% |
| Low | $($findings.Low) | $(if ($findings.Total -gt 0) { [math]::Round(($findings.Low / $findings.Total) * 100, 1) } else { 0 })% |
| **Total** | **$($findings.Total)** | **100%** |

**Security Status:** $(if ($findings.Blocker -gt 0) { '🚫 Blockers present - require resolution' } elseif ($findings.High -gt 0) { '⚠️ High-severity findings present' } else { '✅ No critical security issues' })
"@
}

function Get-DsStarMarkdownSection {
    <#
    .SYNOPSIS
        Builds the DS-Star metrics section for the Markdown dashboard.
    #>

    $summary = $script:DsStarMetrics.Summary
    $sourcePath = if ($script:DsStarMetrics.SourcePath) { $script:DsStarMetrics.SourcePath } else { $DSStarPath }

    if ($summary.TotalSessions -eq 0) {
        return @"
## DS-Star Workflow Metrics

_No DS-Star sessions detected in ``$sourcePath`` during this reporting window. Add data science sessions under `plans/data-analysis/` to populate adoption metrics._
"@
    }

    $completionRate = [math]::Round((($summary.CompletedSessions / [math]::Max($summary.TotalSessions, 1)) * 100), 1)
    $resumeRate = if ($summary.InProgressSessions -gt 0) {
        [math]::Round((($summary.ResumeReadySessions / $summary.InProgressSessions) * 100), 1)
    } else { 0 }

    $avgRounds = [math]::Round($summary.AvgRounds, 1)
    $avgDuration = [math]::Round($summary.AvgDurationMinutes, 1)
    $avgSteps = [math]::Round($summary.AvgStepsPerSession, 1)

    $verdicts = $summary.Verdicts
    $latestSessions = $script:DsStarMetrics.Sessions | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 3
    $latestLines = ($latestSessions | ForEach-Object {
            $roundDisplay = if ($_.Rounds -ne $null) { $_.Rounds } else { 'n/a' }
            $durationDisplay = if ($_.DurationMinutes -ne $null) { "{0:N1} min" -f [double]$_.DurationMinutes } else { 'n/a' }
            $verdictDisplay = if ([string]::IsNullOrWhiteSpace($_.LastVerdict)) { 'n/a' } else { $_.LastVerdict }
            "- ``$($_.SessionId)`` - $($_.Status) (Rounds: $roundDisplay, Verdict: $verdictDisplay, Duration: $durationDisplay)"
        }) -join "`n"

    return @"
## DS-Star Workflow Metrics

| Metric | Value |
|--------|-------|
| Sessions Analyzed | $($summary.TotalSessions) |
| Completion Rate | $completionRate% |
| Avg Rounds | $avgRounds |
| Avg Duration (min) | $avgDuration |
| Avg Steps per Session | $avgSteps |
| In Progress | $($summary.InProgressSessions) |
| Resume-Ready In-Progress Sessions | $($summary.ResumeReadySessions) ($resumeRate%) |

### Verdict Mix

| Verdict | Count |
|---------|-------|
| SUFFICIENT | $($verdicts.SUFFICIENT) |
| INSUFFICIENT | $($verdicts.INSUFFICIENT) |
| BLOCKED | $($verdicts.BLOCKED) |

### Latest Session Highlights
$latestLines

_Data source:_ ``$sourcePath``
"@
}

function Write-DsStarConsoleSummary {
    <#
    .SYNOPSIS
        Emits DS-Star metrics recap to the console output.
    #>

    $summary = $script:DsStarMetrics.Summary
    Write-Host "`nDS-Star Analytics:" -ForegroundColor Cyan

    if ($summary.TotalSessions -eq 0) {
        $sourcePath = if ($script:DsStarMetrics.SourcePath) { $script:DsStarMetrics.SourcePath } else { $DSStarPath }
        Write-Host "  No DS-Star sessions detected in $sourcePath." -ForegroundColor Gray
        return
    }

    $completionRate = [math]::Round((($summary.CompletedSessions / [math]::Max($summary.TotalSessions, 1)) * 100), 1)
    $avgRounds = [math]::Round($summary.AvgRounds, 1)
    $avgDuration = [math]::Round($summary.AvgDurationMinutes, 1)
    $verdicts = $summary.Verdicts

    Write-Host "  Sessions: $($summary.TotalSessions) (Completed: $($summary.CompletedSessions), In Progress: $($summary.InProgressSessions), Blocked: $($summary.BlockedSessions))" -ForegroundColor Gray
    Write-Host "  Completion Rate: $completionRate% | Resume-Ready In-Progress: $($summary.ResumeReadySessions)" -ForegroundColor Gray
    Write-Host "  Avg Rounds: $avgRounds | Avg Duration: $avgDuration min" -ForegroundColor Gray
    Write-Host "  Verdict Mix (S/I/B): $($verdicts.SUFFICIENT)/$($verdicts.INSUFFICIENT)/$($verdicts.BLOCKED)" -ForegroundColor Gray
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

$resolvedDsStarPath = $DSStarPath
try {
    if (Test-Path -LiteralPath $DSStarPath) {
        $resolvedDsStarPath = (Resolve-Path -LiteralPath $DSStarPath).ProviderPath
    }
}
catch {
    $resolvedDsStarPath = $DSStarPath
}

$dsStarSessions = Get-DsStarSessions -Path $resolvedDsStarPath
Update-DsStarMetricsSummary -Sessions $dsStarSessions -SourcePath $resolvedDsStarPath

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

Write-DsStarConsoleSummary
