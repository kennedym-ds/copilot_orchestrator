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
