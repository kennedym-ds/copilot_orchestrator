# Session Analytics Guide

## Overview

The Copilot Orchestrator session analytics system provides data-driven insights into workflow performance, cost efficiency, and quality metrics. This enables continuous improvement through evidence-based instruction optimization.

## Quick Start

### Generate a Report

```powershell
# Analyze last 30 days (default)
.\scripts\analyze-sessions.ps1

# Analyze specific date range
.\scripts\analyze-sessions.ps1 -StartDate "2025-10-01" -EndDate "2025-10-31"

# Generate JSON output
.\scripts\analyze-sessions.ps1 -Format JSON
```

### View the Dashboard

After running the analytics script, open:
```
docs/dashboards/workflow-metrics.md
```

## Session Metadata Structure

Sessions are tracked using JSON metadata files stored in `plans/sessions/`.

### Required Fields

- **sessionId**: Unique identifier (kebab-case)
- **startTime**: ISO 8601 timestamp
- **status**: `in_progress`, `complete`, `failed`, or `paused`

### Tracked Metrics

#### 1. Session Status
- Total sessions
- Completed vs. failed vs. in-progress
- Success rate over time

#### 2. Phase Distribution
- Time spent in each lifecycle phase
- Current phase distribution across active sessions
- Bottleneck identification

#### 3. Escalation Patterns
- Frequency by tier (Tier1/2/3)
- Common escalation triggers
- Resolution patterns
- Cost impact of escalations

#### 4. Model Usage & Cost
- Premium vs. efficient model invocations
- Cost breakdown by agent
- Adherence to 80/20 cost optimization target
- Total estimated costs

#### 5. Quality Metrics
- Review pass rate (target: ≥90%)
- Findings by severity (BLOCKER, MAJOR, MINOR, NIT)
- Rework frequency
- Test coverage trends

#### 6. Performance
- Average phase durations
- Total session duration
- Velocity trends over time

## Creating Session Metadata

### Manual Creation

For manual session tracking, create a JSON file following the schema:

```json
{
  "sessionId": "my-task-2025-11-07",
  "title": "Implement feature X",
  "startTime": "2025-11-07T10:00:00Z",
  "status": "in_progress",
  "currentPhase": "Planning",
  "totalPhases": 4,
  "completedPhases": 0
}
```

See `plans/sessions/example-session-2025-11-07.json` for a complete example.

### Automated Collection (Future)

Future enhancement will add automatic session metadata collection:
- Conductor agent emits structured state updates
- Agents log escalations and model usage
- Reviews automatically record findings
- Metrics aggregated in real-time

## Understanding the Dashboard

### Session Overview
Shows total sessions and their statuses. Target: >80% completion rate.

### Phase Distribution
Pie chart showing where sessions are spending time. Look for:
- **Bottlenecks**: Disproportionate time in one phase
- **Balance**: Healthy distribution across phases

### Escalation Analysis
Tracks escalation frequency and patterns. Monitor for:
- **High Tier1 rate**: Instructions may need clarification
- **High Tier2 rate**: Consider lowering escalation thresholds
- **Low overall rate**: Good instruction quality

### Model Usage & Cost
Tracks adherence to 80/20 cost optimization target:
- **Target**: ≤20% premium model usage
- **Acceptable**: ≤25% premium model usage
- **Review needed**: >25% premium model usage

### Quality Metrics
Review outcomes and findings. Target: ≥90% approval rate.
- **High approval**: Good implementation quality
- **High revision**: May need better TDD discipline
- **High failure**: Review escalation patterns

## Insights & Recommendations

The dashboard auto-generates recommendations based on:

### Escalation Patterns
- Frequent Tier1: Instruction tuning needed
- Frequent Tier2: Consider instruction clarification
- Rare escalations: Healthy workflow

### Cost Efficiency
- <20% premium: Excellent optimization
- 20-25% premium: Within target
- >25% premium: Review escalation triggers

### Quality Trends
- ≥90% approval: Meeting quality target
- <90% approval: Process enhancement needed

## Best Practices

### 1. Regular Reporting
Run analytics weekly or monthly to track trends:
```powershell
# Weekly report
.\scripts\analyze-sessions.ps1 -StartDate (Get-Date).AddDays(-7)

# Monthly report
.\scripts\analyze-sessions.ps1 -StartDate (Get-Date).AddMonths(-1)
```

### 2. Correlation with Changes
When updating instructions (see `INSTRUCTION_CHANGELOG.md`):
1. Capture baseline metrics before change
2. Apply instruction update
3. Collect metrics for 1-2 weeks
4. Compare before/after using analytics
5. Document impact in changelog

### 3. Pattern Recognition
Look for recurring patterns:
- Same escalation triggers → Instruction gap
- Consistent phase bottleneck → Process improvement needed
- Cost spikes → Review model allocation
- Quality dips → Additional review gates needed

### 4. Continuous Improvement
Use analytics to drive improvements:
- Update escalation triggers based on false positive rate
- Refine instructions based on common confusion points
- Adjust model allocation based on cost trends
- Add review criteria based on common findings

## Metrics Targets

| Metric | Target | Acceptable | Review Needed |
|--------|--------|------------|---------------|
| Completion Rate | ≥80% | ≥70% | <70% |
| Review Pass Rate | ≥90% | ≥80% | <80% |
| Premium Model % | ≤20% | ≤25% | >25% |
| Escalation Rate | <0.5 per session | <1.0 per session | ≥1.0 per session |
| Avg Phase Duration | Trending down | Stable | Trending up |

## Troubleshooting

### No Data Available
**Issue**: Report shows "No session data available"

**Solutions**:
1. Check that `plans/sessions/` contains JSON files
2. Verify date range includes session timestamps
3. Ensure JSON files follow the schema
4. Check for parsing errors in script output

### Unexpected Metrics
**Issue**: Metrics don't match expectations

**Solutions**:
1. Validate session metadata against schema
2. Check for duplicate session IDs
3. Review timestamp ranges
4. Verify enum values (status, tier, verdict)

### Missing Insights
**Issue**: Dashboard insights section is generic

**Solutions**:
1. Collect more session data (need ≥5 sessions for patterns)
2. Ensure all optional fields are populated
3. Add metadata for richer analysis

## Future Enhancements

Planned improvements (see `docs/research/sota-agent-design-review-2025.md`):

1. **Real-time Dashboard** - Live updates during active sessions
2. **Automated Collection** - Agents emit structured telemetry
3. **Trend Analysis** - Historical comparisons and forecasting
4. **Alerting** - Notifications for anomalous patterns
5. **A/B Testing** - Compare instruction variants with metrics
6. **Correlation Analysis** - Link metrics to instruction versions

## Related Documentation

- `INSTRUCTION_CHANGELOG.md` - Track instruction changes
- `docs/research/sota-agent-design-review-2025.md` - Design rationale
- `docs/operations.md` - Operational procedures
- `plans/sessions/session-metadata.schema.json` - Metadata schema

---

**Guide Status:** Active  
**Version:** 1.0.0  
**Last Updated:** 2025-11-07  
**Owner:** Copilot Guild  
**Feedback:** Submit via docs/operations.md or create issue
