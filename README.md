---
title: "Copilot Orchestrator"
version: "0.1.0"
lastUpdated: "2025-11-07"
status: draft
---

# Copilot Orchestrator

This repository hosts the greenfield, conductor-driven GitHub Copilot configuration. It embraces the multi-agent workflow introduced by GitHub Copilot Orchestra and the latest VS Code agent platform features (Agent Sessions, handoffs, context-isolated subagents).

## Getting Started

1. Review the planning documents in `docs/workflows/`:
   - `orchestration-rebuild-plan.md`
   - `new-workspace-blueprint.md`
   - `new-workspace-setup-checklist.md`
2. Configure VS Code Insiders with agent mode, handoffs, and nested `AGENTS.md` support.
3. Copy validation scripts from the legacy `copilot_config` repository or author replacements under `scripts/`.
4. Flesh out the instruction mesh (`AGENTS.md`, `.instructions.md`) and scaffold conductor/subagent chat modes under `.github/chatmodes/`.

## Repository Layout

| Path | Purpose |
| --- | --- |
| `.github/chatmodes/` | Conductor and subagent chat modes (to be authored). |
| `.github/prompts/` | Slash-command style prompts tied to orchestrated workflows. |
| `docs/workflows/` | Planning, blueprint, and setup documentation. |
| `docs/templates/` | Reusable templates (plan format, phase reports, etc.). |
| `instructions/` | Layered instruction files for global, workflow, language, and compliance scopes. |
| `scripts/` | Validation and automation utilities. |
| `plans/` | Generated plan and phase artifacts (ignored by default). |

## Next Actions

- Finalize root `AGENTS.md` and nested instruction files.
- Author `conductor.chatmode.md` alongside planner, researcher, implementer, and reviewer agents.
- Port or redesign prompts from the legacy repository using the new templates.
- Configure GitHub Actions validation workflow.

Track progress in `docs/workflows/orchestration-rebuild-plan.md` and update `docs/CHANGELOG.md` once the initial scaffold is complete.
