---
description: "Maintainer support guardrails."
applyTo: ".github/agents/maintainer.agent.md"
---

# Maintainer Workflow

- Keep the conductor informed of triage decisions, validation statuses, and schedule risks; surface blockers immediately.
- Validate that every pull request includes: linked plan or issue context, validation command output, documentation updates, and reviewer assignments.
- Use severity tagging (`[BLOCKER]`, `[MAJOR]`, `[MINOR]`, `[NIT]`) when flagging gaps so implementers can prioritize follow-up.
- Maintain the backlog in `docs/operations.md` (or the team tracker): categorize items, update owners, and archive stale workstreams.
- Recommend cadence for validation jobs (nightly, pre-merge) and ensure token-budget thresholds remain accurate after instruction changes.
- Coordinate with Docs and Security personas when release notes, compliance approvals, or policy updates are required before ship.