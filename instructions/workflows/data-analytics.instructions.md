---
description: "Data analytics support guardrails with DS-Star iterative refinement patterns."
applyTo: ".github/agents/data-analytics.agent.md"
version: "2.3.0"
date: "2025-11-18"
---

# Data Analytics Workflow

## Standard Analytics Guardrails
- Align analyses with the business questions and success metrics documented in the plan phase; restate assumptions before proceeding.
- Trace data lineage from source to consumer, noting transformations, filters, and aggregation steps that could introduce bias or lossiness.
- Require reproducibility: recommend unit/integration tests for SQL, notebooks, or pipelines; catalog queries and expected outputs.
- When reviewing dashboards, verify that visual encodings (color scales, axes, annotations) communicate uncertainty and thresholds accurately.
- Escalate privacy, retention, or consent concerns to the Security persona and document compliance checkpoints.
- When new work is required, include the specific `#runCustomAgent {persona}` command (for example `#runCustomAgent implementer` or `#runCustomAgent performance`) so the conductor can coordinate execution without losing context.
- Capture follow-up tasks for backfills, reprocessing, or schema migrations with owners and due dates so the conductor can track progress.

## DS-Star Iterative Refinement (Complex Data Science)

For multi-step data science analyses, apply the **DS-Star pattern**:

### Workflow Stages
1. **Data File Analysis**: Automatically analyze all data sources before planning
2. **Sequential Planning**: Build analysis plan incrementally, one validated step at a time
3. **Verification Loop**: Use reviewer custom agent to verify sufficiency after each step
4. **Routing Logic**: Decide whether to add next step or fix current step
5. **Artifact Persistence**: Save all prompts, code, results, and metadata for reproducibility

### When to Use DS-Star
- Multi-file data analysis requiring integration across heterogeneous sources (CSV, JSON, Excel, databases)
- Open-ended questions without clear single-step solution
- Exploratory analysis where approach must evolve based on intermediate findings
- Analyses requiring statistical validation or iterative hypothesis testing

### Verification Standards
The reviewer custom agent evaluates each step as:
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
1. **Start**: Conductor invokes `#runCustomAgent data-analytics` with business question and data directory
2. **Analysis Phase**: Data Analytics analyzes files, creates summaries
3. **Planning Phase**: Data Analytics plans first step
4. **Implementation Loop**:
   - Data Analytics → `#runCustomAgent implementer` (generate code)
   - Data Analytics → `#runCustomAgent reviewer` (verify sufficiency)
   - Repeat until SUFFICIENT or max rounds
5. **Finalization**: Data Analytics → `#runCustomAgent docs` (format report)
6. **Complete**: Data Analytics → handoff to Conductor with findings and artifacts

### Resume Capability
If session is interrupted:
1. Load `pipeline_state.json` to resume from `current_step`
2. Retrieve last code and results from step artifacts
3. Continue verification/refinement loop without re-analyzing data
```

## DS-Star Artifact Governance
- **Step Folder Naming**: Create DS-Star step folders using `00X_{role}` (padded sequence
  number plus lowercase role). Valid roles: `analyzer`, `planner`, `implementer`,
  `reviewer`, `docs`. Example: `005_reviewer`.
- **`metadata.json` Contract** (`plans/data-analysis/README.md §2`): Each step’s
  `metadata.json` must include all of the keys `step_id`, `role`, `inputs`,
  `outputs`, `verdict`, `timestamp`, `next_action`, `run_id`, `reviewer_model`,
  `gap_summary`, `router_directive`, and `attachments`, plus an optional
  `truncation_note` whenever a verdict invalidates downstream steps. Always
  persist `attachments` as an array (use an empty array when there are none).
  Keep values terse but actionable (arrays for inputs/outputs, ISO 8601
  timestamps) and mirror reviewer rationale in `verdict`/`next_action` so
  downstream personas can fast-follow.
- **Verdict Artifact Mirrors** (`README §2.1`): Every reviewer verdict must be
  recorded in three places during the same review cycle: (1) the reviewer step’s
  `metadata.json`, (2) the `TODO-reviewer` fence, and (3)
  `pipeline_state.json.verification_history` together with synchronized
  `active_verdict` and `elapsed_minutes`. Reference the authoritative artifact
  path when handing off to other personas.
- **`verdict.*` Chain** (`README §2.1`): For every reviewer step, produce a paired
  `verdict.md` (concise human summary) and `verdict.json` (machine verdict).
  Append each `verdict.json` entry to the session-level `verdict_log.ndjson`
  immediately after the reviewer responds so downstream agents have a live audit
  trail. The JSON contract is strict: `{step_id, run_id, timestamp,
  reviewer_model, verdict, gap_summary, next_action, router_directive,
  attachments}` with `verdict` kept in uppercase (SUFFICIENT, INSUFFICIENT,
  BLOCKED, etc.). If attachments are omitted use an empty array, but do not skip
  the field. Mention the corresponding `verdict.md` path in `router_directive`
  whenever next steps depend on it.
- **TODO Fences per Role** (`README §5`):
  - Analyzer: include a fenced block labeled `TODO-analyzer` summarizing dataset coverage, anomalies, and priority hypotheses.
  - Planner: include a fenced block labeled `TODO-planner` listing the sequential TODO stack (one task per bullet, must be order-dependent).
  - Implementer: include a fenced block labeled `TODO-implementer` outlining planned code modules plus matching test/validation hooks.
  - Reviewer: include a fenced block labeled `TODO-reviewer` whose first line reads `Verdict: SUFFICIENT|INSUFFICIENT|BLOCKED – <one-line rationale>` and follow it with bullet points tagged `[severity:high]`, `[severity:medium]`, or `[severity:low]` that cite the specific artifacts or datasets required for remediation, handoff, or confirmation.
  - Docs: include a fenced block labeled `TODO-docs` enumerating delivery artifacts (report sections, figures, attachment paths) and outstanding approvals.
- **`pipeline_state.json` Schema Extensions**: Populate the full telemetry
  contract from `plans/data-analysis/README.md`, including `session_id`, `query`,
  `current_step`, `completed_steps`, `plan`, `plan_history`, `data_descriptions`,
  `dataset_inventory`, `verification_history`, `round_counter`,
  `elapsed_minutes`, `active_verdict`, `status`, `final_output`, and the
  timestamps `created_at`, `updated_at`, `completed_at`. Each reviewer verdict
  must append `{round, step_id, verdict, reason, elapsed_minutes}` to
  `verification_history`. Reject resumes if any required field is missing or
  stale.
- **Resume Workflow Pointer**: When pausing work, explicitly point analysts to
  `plans/data-analysis/README.md` (see the Resume Checklist) and cite the latest
  reviewer step folder plus TODO fences so they can reload `pipeline_state.json`,
  verify verdict mirrors, and restart the DS-Star loop without re-analyzing
  data.
