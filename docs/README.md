---
title: "Copilot Orchestrator Documentation Index"
version: "0.1.0"
lastUpdated: "2025-11-07"
status: draft
---

# Documentation Overview

This index summarizes key planning and operational documents for the greenfield Copilot Orchestrator repository.

## Workflows

| Document | Purpose |
| --- | --- |
| `docs/workflows/orchestration-rebuild-plan.md` | End-to-end strategy for adopting the conductor-led workflow. |
| `docs/workflows/new-workspace-blueprint.md` | Repository architecture, agent roles, automation guardrails. |
| `docs/workflows/new-workspace-setup-checklist.md` | Actionable checklist for bootstrapping the workspace. |

## Operations & Governance

| Document | Purpose |
| --- | --- |
| `docs/operations.md` | Monitoring cadence, metrics, backlog, and tooling. |
| `docs/CHANGELOG.md` | Tracks notable changes using Keep a Changelog format. |

## Templates

| Template | Purpose |
| --- | --- |
| `docs/templates/plan.md` | Standard structure for Conductor-generated plans. |
| `docs/templates/phase-complete.md` | Checklist for per-phase summaries (tests, commands, review status). |
| `docs/templates/plan-complete.md` | Final completion report format. |
| `docs/templates/agents-root.md` | Starting point for root/nested `AGENTS.md` files. |

## Guides & Samples

| Guide | Purpose |
| --- | --- |
| `docs/guides/onboarding.md` | Onboarding steps, validation commands, and artifact overview. |
| `docs/guides/sample-agent-session.md` | Example conductor-led session with linked artifacts. |
| `docs/guides/vscode-copilot-configuration.md` | Required VS Code Insiders settings for modes, prompts, instructions, and tool sets. |
| `plans/samples/` | Filled plan, phase, and completion templates for reference. |

## Next Steps

- Add additional templates as new workflows emerge (e.g., security review, documentation handoff).
- Expand workflows section with automation deep dives and advanced validation strategies.
- Ensure README and documentation stay in sync during repository evolution.
