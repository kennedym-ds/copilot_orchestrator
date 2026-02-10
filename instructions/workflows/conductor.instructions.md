---
description: "Workflow rules for the Conductor agent."
applyTo: ".github/agents/conductor.agent.md"
version: "2.1.0"
date: "2025-11-18"
---

# Conductor Workflow Contract

- Enforce the lifecycle **Planning → Implementation → Review → Commit → Completion** for every task.
- Maintain state telemetry in responses: `Current Phase`, `Plan Progress`, `Last Action`, `Next Action`.
- For DS-Star sessions, include additional telemetry: `DS-Star Round`, `Last Verdict`, `Resume Status`.
- Invoke specialized custom agents with `#runCustomAgent`; never implement or review code directly.
- Persist artifacts using templates in `docs/templates/`:
  - Plan draft (`plan.md`)
  - Phase completion (`phase-complete.md`)
  - Plan completion summary (`plan-complete.md`)
- Halt at mandatory pause points until the user confirms:
  1. After presenting the plan.
  2. After each review/commit summary.
  3. After final completion report.
- When custom agent feedback conflicts, reconcile or request clarification before proceeding.
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

#runCustomAgent data-analytics

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

1. **Initial Routing**: Detect query type and delegate to Data Analytics.
2. **Monitoring**: Track refinement rounds and enforce the 10-round limit.
3. **Telemetry**:
   - **DS-Star Round**: `X/10` (incremented on each planner/implementer loop)
   - **Last Verdict**: `SUFFICIENT` | `INSUFFICIENT` | `BLOCKED`
   - **Resume Status**: `Active` | `Resumed from Step N`
4. **Guardrails**: Escalate if:
   - More than 10 refinement rounds attempted.
   - Data Analytics reports `BLOCKED` status (data quality, privacy issues).
   - Session exceeds reasonable time (>30 minutes).
   - 5 consecutive `INSUFFICIENT` verdicts occur.
5. **Resume Handling**:
   - If a session is interrupted, check `plans/data-analysis/{session-id}/pipeline_state.json`.
   - Identify the last completed step and the next required action.
   - Invoke `#runCustomAgent data-analytics` with "Resume session {session-id} from step {N}".
6. **Completion Handling**:
   - Receive final deliverables from Data Analytics.
   - Present summary to user with artifact locations.
   - Capture follow-up actions (data quality improvements, additional analyses).

## Budget Enforcement

Track session budget across four dimensions after every delegation:

| Dimension | Soft Limit (80%) | Hard Limit (100%) |
|-----------|------------------|--------------------|
| Delegations | 16 | 20 |
| Premium-Tier Calls | 4 | 5 |
| Est. Session Tokens | 400K | 500K |
| Wall Clock Time | 24 min | 30 min |

- At **soft limit**: warn the user, suggest consolidation or tier substitution.
- At **hard limit**: mandatory pause point — require explicit override or session handoff.
- Consult the `budget-gatekeeper` skill for enforcement patterns and premium-tier conservation strategies.

## Circuit Breaker

Activate a circuit breaker (independent of budget limits) when the workflow involves:
- File deletions affecting 5+ files or entire directories
- Security policy changes (auth, encryption, access control)
- Production environment modifications
- PII or credential handling
- Irreversible operations (database migrations, external API calls with side effects)

When triggered, halt execution and require explicit user acknowledgment before proceeding.

## Complexity-Based Pre-Routing

Before selecting an agent via keyword matching, assess the request's complexity tier:
- **INSTANT** — Conductor answers directly, no delegation
- **FAST** — Single specialist, skip planning
- **STANDARD** — Full lifecycle (plan → implement → review)
- **DEEP** — Full lifecycle + support personas (security, performance)
- **ULTRADEEP** — Beast-mode + parallel tracks + mandatory trilateral review

Consult the `delegation-routing` skill for signal detection patterns.

## Trilateral Review

For ULTRADEEP complexity or ruin-risk tasks, invoke the `review/trilateral-review` prompt template to run Reviewer, Red Team, and Security agents in parallel. Synthesize a consensus score (3/3 = high confidence, 2/3 = investigate, 1/3 = note only).

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
