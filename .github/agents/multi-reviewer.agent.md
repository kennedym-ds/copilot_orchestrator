---
name: multi-reviewer
description: "Run multiple review subagents in parallel and consolidate findings into a single review artifact."
user-invokable: false
disable-model-invocation: true
agents: ['reviewer']
tools: [agent, todo, search, read, fileSearch, githubRepo, problems, usages, multi_tool_use.parallel, runSubagent]
---

# Multi-Reviewer — Parallel Review Orchestrator

Purpose: run several reviewer subagents in parallel (for example `reviewer`, `reviewer-gpt`, `reviewer-gemini` where available) and consolidate their findings into a single, severity-tagged review artifact. This agent is hidden and intended to be invoked by the `Orchestrator` or other control-plane agents when multi-model or multi-perspective review is desired.

Parallelism policy

- Default reviewers: `reviewer` (always present). Additional reviewer agents may be added to the `requested_reviewers` list at runtime if the project exposes them (for example `reviewer-gpt`, `reviewer-gemini`).
- Use `PARALLEL xN` semantics: spawn N reviewer subagents concurrently when N reviewers are requested.
- Limit parallelism to a safe default (3) to avoid runaway cost; the Orchestrator may override this limit.

Runtime invocation examples

- Explicit `runSubagent` parallel call (recommended from Orchestrator):

  - `#runSubagent multi-reviewer "PARALLEL: reviewers=[reviewer,reviewer-gpt,reviewer-gemini]; changes: [PR#123]"`

- Programmatic parallel invocation (control plane implementation):

  - Use the `multi_tool_use.parallel` wrapper to call each reviewer in parallel and await results.

Consolidation logic (required)

- Collect each subagent's findings artifact (verdict, severity-tagged findings, file, line, recommendation).
- Normalize findings by canonical key: (file path, nearest function/class, line-range, normalized short description).
- Merge duplicates and produce a `consensus_level` per finding:
  - `consensus: unanimous` — all reviewers reported the same finding
  - `consensus: majority` — >50% reported the finding
  - `consensus: single` — only one reviewer reported it
- For conflicting remediation advice, surface all variants and mark as `conflict: true` with a short rationale.
- Attach reviewer provenance: list reviewer agent names, timestamps, and confidence estimates if provided.

Output artifact

- Persist consolidated review to `artifacts/reviews/{YYYY-MM-DD}-{feature-slug}-multi.md` with:
  - `verdict` (APPROVED / NEEDS_REVISION / BLOCKED)
  - consolidated `findings` table (severity, consensus_level, file, line, issue, recommendation, provenance)
  - raw subagent outputs stored under `artifacts/reviews/{slug}/subagents/`

Handoffs and follow-ups

- On `BLOCKED` or `NEEDS_REVISION`, auto-create an implementer task and optionally call:
  - `#runSubagent implementer "Fix findings: [list]. Priority: BLOCKER first. Re-run reviews after fixes."`
- Return consolidated results to `Conductor` with schema `HS-QUALITY` including `action` = `approve` | `request-changes` | `escalate`, `findings` array, and `subagent_outputs` links.

Operational notes

- Keep this agent hidden and `disable-model-invocation: true` so it acts as an orchestrator only — model work happens inside the reviewer subagents.
- Use git worktrees or `/delegate` when parallel reviewers require filesystem isolation for long-running rechecks.
- Track cost: Orchestrator should enforce budget thresholds when requesting more than one reviewer model.

Example consolidation pseudo-workflow (control plane logic):

1. Accept request `reviewers=[R1,R2,R3], changes=CH`.
2. Spawn parallel calls: `multi_tool_use.parallel([{recipient_name: 'functions.runSubagent', parameters: {prompt: 'Review CH', agent: R1}}, ...])`.
3. Await results, then run normalization & dedupe.
4. Emit consolidated artifact and handoff to `Conductor`.

For implementation details refer to `docs/guides/agent-workflow.md` and `scripts/` helpers for artifacts naming and retention rules.
