---
title: "Sample Agent Session Transcript"
version: "0.2.0"
lastUpdated: "2025-11-18"
status: draft
---

## Scenario Summary
This guide showcases a canonical conductor → planner → implementer → reviewer loop for validation tooling updates.

## Session Timeline — Standard Validation Flow
| Time | Agent | Action | Notes |
| --- | --- | --- | --- |
| T0 | Conductor | Summarizes task, lists constraints, initializes TODO list. | References `AGENTS.md` and backlog. |
| T1 | Planner | Drafts plan using `.github/prompts/planning/multi-phase-plan.prompt.md`. | Produces `plans/samples/tooling-upgrade-plan.md`. |
| T2 | Conductor | Pauses for approval, then launches implementer for Phase 1. | TODO list updated. |
| T3 | Implementer | Executes TDD workflow, running validation scripts. | Outputs captured in summary. |
| T4 | Reviewer | Generates findings with verdict `APPROVED`. | Confirms tests executed and documentation updated. |
| T5 | Conductor | Records phase completion and finalizes completion report. | Stores artifacts under `plans/samples/`. |

## Artifact Links — Standard Flow
- `plans/samples/tooling-upgrade-plan.md`
- `plans/samples/tooling-upgrade-phase-1.md`
- `plans/samples/tooling-upgrade-completion.md`

## Key Takeaways
- Mandatory pause points ensure human approval before moving between phases.
- Each subagent references the prompt library to maintain consistent structure.
- Validation scripts execute within the implementer phase, and results are summarized for auditability.
- The conductor maintains Current Phase, Plan Progress, Last Action, and Next Action metadata in every response.

## Follow-Up
Recreate this flow locally by loading the conductor chat mode in VS Code and assigning a similar task (e.g., updating documentation). Compare your generated artifacts with the samples to ensure alignment.
