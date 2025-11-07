---
name: plan-multi-phase-delivery
description: "Planner prompt for breaking complex requests into conductor-ready phases with risks, compliance, and TODO tracking."
model: GPT-5-Codex (Preview)
agent: planner
tools:
  - todos
  - readFile
  - fetch
  - search
  - githubRepo
---

## Purpose
Guide the planner persona through producing a full plan artifact aligned with `docs/templates/plan.md`, ensuring every assumption, risk, and compliance checkpoint is captured before implementation begins.

## Instructions
- Confirm understanding of the task, constraints, and success metrics based on the latest conversation context and repository docs.
- Read all relevant files (minimum 2,000 surrounding lines when browsing code) before proposing any work.
- Use `fetch_webpage` for every URL encountered in source material or user input to avoid stale references.
- Build and maintain a TODO list inside triple backticks using checkbox syntax. Keep it updated throughout the planning flow.
- If gaps remain, launch the `researcher` agent via `#runSubagent` with specific questions before finalizing the plan.
- Map the plan to numbered phases with explicit objectives, target files, test strategy, risks, mitigations, and compliance checkpoints.
- Highlight open questions separately and recommend validation steps (unit/integration tests, manual QA, monitoring hooks) for each phase.

## Output Format
Return markdown compatible with `docs/templates/plan.md`:
- Title heading: `## Plan: {Task Title}`
- TL;DR paragraph summarizing the overall strategy.
- Numbered **Phases** list with nested details (Objective, Files/Functions, Tests, Steps).
- Sections for **Open Questions**, **Risks & Mitigations**, and **Compliance Checkpoints**.
- Conclude with a short "Ready for approval" statement and reference any required follow-ups.

## Validation Checklist
- ✅ TODO list reflects the final plan state with all items checked or intentionally deferred.
- ✅ Every cited resource has been retrieved with `fetch_webpage`.
- ✅ At least one test strategy is specified for each phase.
- ✅ Risks enumerate mitigation paths and make escalation points explicit.
- ✅ No implementation commands or file edits are performed by this prompt; planning only.
