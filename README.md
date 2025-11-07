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
| `.github/copilot-instructions.md` | Main instructions for GitHub Copilot (both VS Code extension and coding agent). |
| `.github/copilot-setup-steps.yml` | Development environment setup for Copilot coding agent. |
| `docs/workflows/` | Planning, blueprint, and setup documentation. |
| `docs/templates/` | Reusable templates (plan format, phase reports, etc.). |
| `instructions/` | Layered instruction files for global, workflow, language, and compliance scopes. |
| `scripts/` | Validation and automation utilities. |
| `plans/` | Generated plan and phase artifacts (ignored by default). |

## Working with GitHub Copilot

This repository is optimized for use with GitHub Copilot, including both the VS Code extension and the GitHub Copilot coding agent.

### For GitHub Copilot Coding Agent

To delegate tasks to the Copilot coding agent:

1. **Create a clear, well-scoped issue** with specific acceptance criteria
2. **Assign the issue to `@copilot`** - the agent will automatically start working
3. **Review the pull request** that Copilot creates - treat it like any other contributor's work
4. **Provide feedback** via PR comments mentioning `@copilot` for iterations

The agent is configured via `.github/copilot-instructions.md` and will automatically:
- Run validation scripts before submitting changes
- Follow the conductor workflow for complex tasks
- Use appropriate custom agents for specialized work (security, performance, documentation)

### For VS Code Copilot Chat

Developers using VS Code should:

1. Install **VS Code Insiders** for full Agent Sessions support
2. Enable chat modes and nested `AGENTS.md` support (see `.github/copilot-instructions.md`)
3. Start complex work in `conductor` mode for orchestrated workflows
4. Use handoff buttons to delegate to specialized agents

See `docs/guides/onboarding.md` and `docs/guides/vscode-copilot-configuration.md` for detailed setup instructions.

## Next Actions

- Finalize root `AGENTS.md` and nested instruction files.
- Author `conductor.chatmode.md` alongside planner, researcher, implementer, and reviewer agents.
- Port or redesign prompts from the legacy repository using the new templates.
- Configure GitHub Actions validation workflow.

Track progress in `docs/workflows/orchestration-rebuild-plan.md` and update `docs/CHANGELOG.md` once the initial scaffold is complete.
