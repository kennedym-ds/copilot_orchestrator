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
    Default: ./artifacts/sessions

.PARAMETER HooksPath
    Path to directory containing hook JSONL files.
    Default: ./artifacts/sessions/hooks

.PARAMETER OutputPath
    Path where analysis reports will be saved.
    Default: ./docs/dashboards

.PARAMETER ExportPath
    Optional explicit output file path. When set, overrides OutputPath and Format file naming.

.PARAMETER UseHooks
    When true, merges hook-derived sessions from HooksPath into analytics.

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
    [string]$SessionsPath = "./artifacts/sessions",

    [Parameter()]
    [string]$HooksPath = "./artifacts/sessions/hooks",

    [Parameter()]
    [string]$OutputPath = "./docs/dashboards",

    [Parameter()]
    [string]$ExportPath = "",

    [Parameter()]
    [datetime]$StartDate = (Get-Date).AddDays(-30),

    [Parameter()]
    [datetime]$EndDate = (Get-Date),

    [Parameter()]
    [ValidateSet('Markdown', 'JSON', 'CSV')]
    [string]$Format = 'Markdown',

    [Parameter()]
    [bool]$UseHooks = $true
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

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

function Read-HookEvents {
    param(
        [string]$Path,
        [datetime]$Start,
        [datetime]$End
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return @()
    }

    $events = New-Object System.Collections.Generic.List[object]
    $files = Get-ChildItem -Path $Path -Filter "*.jsonl" -File -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        $lines = Get-Content -LiteralPath $file.FullName -ErrorAction SilentlyContinue
        foreach ($line in $lines) {
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            try {
                $record = ConvertFrom-JsonSafe -Json $line -Depth 12
            } catch {
                continue
            }
            if (-not $record.ts) { continue }
            try {
                $ts = [datetime]$record.ts
            } catch {
                continue
            }
            if ($ts -lt $Start -or $ts -gt $End) { continue }
            $record | Add-Member -NotePropertyName "_ts" -NotePropertyValue $ts -Force
            $events.Add($record) | Out-Null
        }
    }

    return $events
}

function Build-HookSessions {
    param(
        [object[]]$Events
    )

    $sessions = @{}
    foreach ($event in $Events) {
        $sessionId = $event.session_id
        if ([string]::IsNullOrWhiteSpace($sessionId)) { continue }

        if (-not $sessions.ContainsKey($sessionId)) {
            $sessions[$sessionId] = [ordered]@{
                sessionId = $sessionId
                startTime = $event._ts
                endTime = $event._ts
                status = 'in_progress'
                agentActions = @()
            }
        }

        if ($event._ts -lt $sessions[$sessionId].startTime) { $sessions[$sessionId].startTime = $event._ts }
        if ($event._ts -gt $sessions[$sessionId].endTime) { $sessions[$sessionId].endTime = $event._ts }

        if ($event.event -eq 'PostToolUse' -and $event.tool) {
            $sessions[$sessionId].agentActions += [PSCustomObject]@{
                agent = $event.agent
                tool  = $event.tool
            }
        }
    }

    $output = @()
    foreach ($session in $sessions.Values) {
        $output += [PSCustomObject]@{
            sessionId    = $session.sessionId
            startTime    = $session.startTime.ToString('o')
            endTime      = $session.endTime.ToString('o')
            status       = $session.status
            agentActions = $session.agentActions
        }
    }

    return $output
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
        { $_ -in 'complete', 'completed' } { $script:SessionMetadata.CompletedSessions++ }
        'failed' { $script:SessionMetadata.FailedSessions++ }
        { $_ -in 'in_progress', 'in-progress', 'initialized', 'paused' } { $script:SessionMetadata.InProgressSessions++ }
        'blocked' { $script:SessionMetadata.FailedSessions++ }
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
1. Ensure hook telemetry exists under ``$HooksPath``
2. Optionally write session metadata to ``$SessionsPath`` for richer phase and review metrics
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

**Status:** $(if (($script:SessionMetadata.ModelUsage.Premium + $script:SessionMetadata.ModelUsage.Efficient) -gt 0 -and (($script:SessionMetadata.ModelUsage.Premium / ($script:SessionMetadata.ModelUsage.Premium + $script:SessionMetadata.ModelUsage.Efficient)) * 100) -le 25) { 'âœ… Within target (â‰¤25%)' } else { 'âš ï¸ Above target (>25%)' })

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

**Target:** â‰¥90% approval rate
**Status:** $(if ($script:SessionMetadata.Reviews.TotalReviews -gt 0 -and (($script:SessionMetadata.Reviews.Approved / $script:SessionMetadata.Reviews.TotalReviews) * 100) -ge 90) { 'âœ… Meeting target' } elseif ($script:SessionMetadata.Reviews.TotalReviews -gt 0) { 'âš ï¸ Below target' } else { 'â„¹ï¸ No data' })

---

## Insights & Recommendations

$insights

---

**Dashboard Status:** Active
**Next Update:** Run ``scripts/analyze-sessions.ps1`` as needed
**Data Source:** ``$SessionsPath`` + ``$HooksPath``
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

**Security Status:** $(if ($findings.Blocker -gt 0) { 'ðŸš« Blockers present - require resolution' } elseif ($findings.High -gt 0) { 'âš ï¸ High-severity findings present' } else { 'âœ… No critical security issues' })
"@
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

$legacySessionsPath = "./plans/sessions"
if (-not (Test-Path -LiteralPath $SessionsPath) -and (Test-Path -LiteralPath $legacySessionsPath)) {
    Write-Warning "Legacy sessions path detected ($legacySessionsPath). Using it for this run."
    $SessionsPath = $legacySessionsPath
}

$sessionFiles = Get-SessionFiles -Path $SessionsPath -Start $StartDate -End $EndDate
Write-Host "Found $($sessionFiles.Count) session files" -ForegroundColor Gray

$sessionsById = @{}
$sessionList = New-Object System.Collections.Generic.List[object]
foreach ($file in $sessionFiles) {
    $session = Read-SessionMetadata -File $file
    if (-not $session) { continue }
    if ($session.sessionId) {
        $sessionsById[$session.sessionId] = $session
    } else {
        $sessionList.Add($session) | Out-Null
    }
}

$hookSessions = @()
if ($UseHooks) {
    $hookEvents = Read-HookEvents -Path $HooksPath -Start $StartDate -End $EndDate
    $hookSessions = Build-HookSessions -Events $hookEvents
    foreach ($hookSession in $hookSessions) {
        if ($sessionsById.ContainsKey($hookSession.sessionId)) {
            $existing = $sessionsById[$hookSession.sessionId]
            if (-not $existing.startTime -and $hookSession.startTime) {
                $existing | Add-Member -NotePropertyName startTime -NotePropertyValue $hookSession.startTime -Force
            }
            if (-not $existing.endTime -and $hookSession.endTime) {
                $existing | Add-Member -NotePropertyName endTime -NotePropertyValue $hookSession.endTime -Force
            }
            if (-not $existing.agentActions -or $existing.agentActions.Count -eq 0) {
                $existing | Add-Member -NotePropertyName agentActions -NotePropertyValue $hookSession.agentActions -Force
            }
        } else {
            $sessionsById[$hookSession.sessionId] = $hookSession
        }
    }
    Write-Host "Found $($hookSessions.Count) hook-derived sessions" -ForegroundColor Gray
}

foreach ($session in $sessionsById.Values) {
    $sessionList.Add($session) | Out-Null
}

foreach ($session in $sessionList) {
    Update-Metrics -Session $session
}

# Ensure output directory exists
$targetDir = if (-not [string]::IsNullOrWhiteSpace($ExportPath)) {
    Split-Path -Parent $ExportPath
} else {
    $OutputPath
}
if ([string]::IsNullOrWhiteSpace($targetDir)) {
    $targetDir = $OutputPath
}
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

# Generate report
$outputFile = if (-not [string]::IsNullOrWhiteSpace($ExportPath)) {
    $ExportPath
} elseif ($Format -eq 'JSON') {
    Join-Path $OutputPath "workflow-metrics.json"
} else {
    Join-Path $OutputPath "workflow-metrics.md"
}
$report = switch ($Format) {
    'Markdown' { Format-MarkdownReport }
    'JSON' { Format-JsonReport }
    'CSV' { Write-Warning "CSV format not yet implemented"; Format-MarkdownReport }
    default { Format-MarkdownReport }
}

# Save report
Set-Content -Path $outputFile -Value $report -Encoding UTF8
Write-Host "`nâœ… Report generated: $outputFile" -ForegroundColor Green

# Display summary
Write-Host "`nQuick Summary:" -ForegroundColor Cyan
Write-Host "  Total Sessions: $($script:SessionMetadata.TotalSessions)" -ForegroundColor Gray
Write-Host "  Completed: $($script:SessionMetadata.CompletedSessions)" -ForegroundColor Green
Write-Host "  Failed: $($script:SessionMetadata.FailedSessions)" -ForegroundColor $(if ($script:SessionMetadata.FailedSessions -gt 0) { 'Yellow' } else { 'Gray' })
if (($script:SessionMetadata.ModelUsage.Premium + $script:SessionMetadata.ModelUsage.Efficient) -gt 0) {
    $premiumPct = [math]::Round(($script:SessionMetadata.ModelUsage.Premium / ($script:SessionMetadata.ModelUsage.Premium + $script:SessionMetadata.ModelUsage.Efficient)) * 100, 1)
    Write-Host "  Premium Usage: $premiumPct% (target: â‰¤20%)" -ForegroundColor $(if ($premiumPct -le 20) { 'Green' } elseif ($premiumPct -le 25) { 'Yellow' } else { 'Red' })
}

