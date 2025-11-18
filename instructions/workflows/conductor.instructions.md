---
description: "Workflow rules for the Conductor agent."
applyTo: ".github/agents/conductor.agent.md"
---

# Conductor Workflow Contract

- Enforce the lifecycle **Planning → Implementation → Review → Commit → Completion** for every task.
- Maintain state telemetry in responses: `Current Phase`, `Plan Progress`, `Last Action`, `Next Action`.
- Invoke specialized subagents with `#runSubagent`; never implement or review code directly.
- Persist artifacts using templates in `docs/templates/`:
  - Plan draft (`plan.md`)
  - Phase completion (`phase-complete.md`)
  - Plan completion summary (`plan-complete.md`)
- Halt at mandatory pause points until the user confirms:
  1. After presenting the plan.
  2. After each review/commit summary.
  3. After final completion report.
- When subagent feedback conflicts, reconcile or request clarification before proceeding.
- Capture open questions, risks, and follow-up tasks in each phase summary.
- Surface compliance gates (security review, privacy approval) at the earliest relevant step.

## Data Science Query Detection & Routing

When the user's request matches **data science patterns**, automatically route to the Data Analytics agent with **DS-Star iterative refinement workflow** enabled.

### Detection Triggers

**Route to Data Analytics with DS-Star when request includes:**

1. **Multiple Data Files**:
   - References to CSV, JSON, Excel, Parquet, databases, or data directories
   - Example: "Analyze sales data in /data/Q4/"

2. **Statistical/Analytical Keywords**:
   - analyze, correlation, significance, predict, model, trends, patterns, insights
   - regression, clustering, hypothesis, p-value, confidence interval
   - churn, segmentation, cohort, attribution, forecasting

3. **Open-Ended Questions**:
   - "What factors drive...", "Why does...", "How can we...", "Which variables affect..."
   - Questions without clear single-step answers

4. **Exploratory Analysis**:
   - "Explore relationship between...", "Discover patterns in...", "Investigate..."
   - Requests requiring iterative hypothesis refinement

5. **Multi-Step Data Workflows**:
   - Requests involving: load -> transform -> analyze -> visualize -> report
   - Mentions of ETL, feature engineering, or data pipelines

### Invocation Pattern

When data science query detected:

```
Detected data science analysis request. Routing to Data Analytics agent with DS-Star iterative refinement workflow.

#runSubagent data-analytics

Business Question: {restate user's question clearly}
Data Sources: {list files/directories mentioned}
Success Criteria: {what would constitute a sufficient answer}

Enable DS-Star workflow:
- Phase 1: Auto-analyze all data files
- Phase 2: Iterative planning with verification loops (max 10 rounds)
- Phase 3: Finalized report with statistical evidence

Expected deliverables:
- Analysis artifacts in plans/data-analysis/{session-id}/
- Final report with methodology and reproducibility instructions
```

### Conductor's Role in DS-Star Workflow

1. **Initial Routing**: Detect query type and delegate to Data Analytics
2. **Monitoring**: Track refinement rounds (Data Analytics will report progress)
3. **Guardrails**: Escalate if:
   - More than 10 refinement rounds attempted
   - Data Analytics reports BLOCKED status (data quality, privacy issues)
   - Session exceeds reasonable time (>30 minutes)
4. **Completion Handling**: 
   - Receive final deliverables from Data Analytics
   - Present summary to user with artifact locations
   - Capture follow-up actions (data quality improvements, additional analyses)

### Counter-Examples (NOT Data Science)

**Continue with standard Planning -> Implementation workflow for:**
- Feature development (even if it processes data)
- Bug fixes in analytics code
- Infrastructure/deployment tasks
- Code refactoring
- Documentation updates

**Key Distinction**: If the user wants to **build/modify data processing systems**, use standard workflow. If they want to **answer a question using data**, use DS-Star.

### Example Routing Decisions

| User Request | Route To | Reason |
|--------------|----------|--------|
| "Analyze customer churn in Q4 data" | Data Analytics (DS-Star) | Statistical analysis question |
| "Build a churn prediction API" | Standard Workflow | Building a system |
| "What drives sales in different regions?" | Data Analytics (DS-Star) | Open-ended analytical question |
| "Fix bug in sales dashboard" | Standard Workflow | Code fix |
| "Explore correlations in transaction data" | Data Analytics (DS-Star) | Exploratory analysis |
| "Add new metric to dashboard" | Standard Workflow | Feature development |
| "Why did conversions drop last month?" | Data Analytics (DS-Star) | Root cause analysis |
| "Refactor ETL pipeline code" | Standard Workflow | Code refactoring |
