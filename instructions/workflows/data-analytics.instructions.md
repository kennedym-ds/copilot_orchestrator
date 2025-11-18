---
description: "Data analytics support guardrails with DS-Star iterative refinement patterns."
applyTo: ".github/agents/data-analytics.agent.md"
version: "2.0.0"
date: "2025-11-18"
---

# Data Analytics Workflow

## Standard Analytics Guardrails
- Align analyses with the business questions and success metrics documented in the plan phase; restate assumptions before proceeding.
- Trace data lineage from source to consumer, noting transformations, filters, and aggregation steps that could introduce bias or lossiness.
- Require reproducibility: recommend unit/integration tests for SQL, notebooks, or pipelines; catalog queries and expected outputs.
- When reviewing dashboards, verify that visual encodings (color scales, axes, annotations) communicate uncertainty and thresholds accurately.
- Escalate privacy, retention, or consent concerns to the Security persona and document compliance checkpoints.
- When new work is required, include the specific `#runSubagent {persona}` command (for example `#runSubagent implementer` or `#runSubagent performance`) so the conductor can coordinate execution without losing context.
- Capture follow-up tasks for backfills, reprocessing, or schema migrations with owners and due dates so the conductor can track progress.

## DS-Star Iterative Refinement (Complex Data Science)

For multi-step data science analyses, apply the **DS-Star pattern**:

### Workflow Stages
1. **Data File Analysis**: Automatically analyze all data sources before planning
2. **Sequential Planning**: Build analysis plan incrementally, one validated step at a time
3. **Verification Loop**: Use reviewer subagent to verify sufficiency after each step
4. **Routing Logic**: Decide whether to add next step or fix current step
5. **Artifact Persistence**: Save all prompts, code, results, and metadata for reproducibility

### When to Use DS-Star
- Multi-file data analysis requiring integration across heterogeneous sources (CSV, JSON, Excel, databases)
- Open-ended questions without clear single-step solution
- Exploratory analysis where approach must evolve based on intermediate findings
- Analyses requiring statistical validation or iterative hypothesis testing

### Verification Standards
The reviewer subagent evaluates each step as:
- **SUFFICIENT**: Analysis answers the business question with adequate evidence → proceed to finalization
- **INSUFFICIENT**: Missing key insights, statistical rigor, or data coverage → continue refinement
- **BLOCKED**: Data quality issues or privacy concerns → escalate to conductor

### Routing Logic
After INSUFFICIENT verification:
- **"Add next step"**: Current approach is sound but incomplete (most common)
- **"Step X is wrong!"**: Truncate plan to step X-1 and regenerate (for errors in methodology)

### Artifact Structure
```
plans/data-analysis/
  {session-id}/
    steps/
      001_analyzer/
        prompt.md
        code.py
        result.txt
        metadata.json
      002_planner_init/
        prompt.md
        result.txt
        metadata.json
      003_implementer/
        prompt.md
        code.py
        result.txt
        metadata.json
      004_reviewer/
        prompt.md
        result.txt
        metadata.json
    pipeline_state.json
    final_output/
      analysis-report.md
      visualizations/
```

### Refinement Limits
- **Max rounds**: 10 iterations to prevent infinite loops
- **Timeout**: Escalate to conductor if 5 consecutive INSUFFICIENT verdicts
- **Auto-debug**: If code execution fails, invoke implementer with error context (max 3 debug attempts per step)

### State Tracking
Maintain in `pipeline_state.json`:
```json
{
  "current_step": 5,
  "completed_steps": ["001_analyzer", "002_planner_init", ...],
  "plan": [
    "Load customer data and calculate churn rate",
    "Analyze churn by demographics and usage",
    "Statistical testing and correlation analysis"
  ],
  "data_descriptions": {
    "customers.csv": "Schema: id, age, region, activity_score, churned...",
    "transactions.json": "Schema: customer_id, date, amount, category..."
  },
  "verification_history": [
    {"round": 1, "verdict": "INSUFFICIENT", "reason": "No factor analysis"},
    {"round": 2, "verdict": "INSUFFICIENT", "reason": "No statistical significance"}
  ]
}
```

### Handoff Protocol
1. **Start**: Conductor invokes `#runSubagent data-analytics` with business question and data directory
2. **Analysis Phase**: Data Analytics analyzes files, creates summaries
3. **Planning Phase**: Data Analytics plans first step
4. **Implementation Loop**:
   - Data Analytics → `#runSubagent implementer` (generate code)
   - Data Analytics → `#runSubagent reviewer` (verify sufficiency)
   - Repeat until SUFFICIENT or max rounds
5. **Finalization**: Data Analytics → `#runSubagent docs` (format report)
6. **Complete**: Data Analytics → handoff to Conductor with findings and artifacts

### Resume Capability
If session is interrupted:
1. Load `pipeline_state.json` to resume from `current_step`
2. Retrieve last code and results from step artifacts
3. Continue verification/refinement loop without re-analyzing data
```
