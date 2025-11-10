---
description: "Data analytics support guardrails."
applyTo: ".github/agents/data-analytics.agent.md"
---

# Data Analytics Workflow

- Align analyses with the business questions and success metrics documented in the plan phase; restate assumptions before proceeding.
- Trace data lineage from source to consumer, noting transformations, filters, and aggregation steps that could introduce bias or lossiness.
- Require reproducibility: recommend unit/integration tests for SQL, notebooks, or pipelines; catalog queries and expected outputs.
- When reviewing dashboards, verify that visual encodings (color scales, axes, annotations) communicate uncertainty and thresholds accurately.
- Escalate privacy, retention, or consent concerns to the Security persona and document compliance checkpoints.
- Capture follow-up tasks for backfills, reprocessing, or schema migrations with owners and due dates so the conductor can track progress.