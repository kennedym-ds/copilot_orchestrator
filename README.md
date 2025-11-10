---
title: "Copilot Orchestrator"
version: "0.3.0"
lastUpdated: "2025-11-10"
status: draft
---

# Copilot Orchestrator

This repository is the centrally managed Copilot instruction pack used by VS Code Insiders across multiple workspaces. It ships a complete multi-agent workflow (conductor → planner → implementer → reviewer → completion) with handoffs, context-isolated subagents, and support personas for security, performance, and documentation.

Use it as the single source of truth for instructions, agent definitions, prompts, and validation tooling. Point your VS Code settings at this repo and every workspace inherits the same guardrails, tool permissions, and lifecycle handoffs.

## Configure VS Code Insiders

1. **Clone or reference this repo** from a location accessible to all participating workspaces (for example `~/Copilot/copilot_orchestrator`).
2. **Enable the following settings** in _user_ or _workspace_ `settings.json` (update the path to match your environment):

    ```json
    {
       "chat.useAgentsMdFile": true,
       "chat.useNestedAgentsMdFiles": true,
       "chat.instructionsFilesLocations": [
          "instructions",
          ".github/instructions"
       ],
       "chat.promptFiles": true,
       "chat.promptFilesLocations": [
          ".github/prompts"
       ],
       "chat.modeFilesLocations": [
          ".github/agents",
          ".github/chatmodes"
       ],
       "github.copilot.chat.tools.memory.enabled": true
    }
    ```

    - `chat.modeFilesLocations` loads the persona definitions under `.github/agents` (new schema) and retains backward compatibility with any legacy `.chatmode.md` wrappers.
    - `github.copilot.chat.tools.memory.enabled` persists contextual notes across sessions so subagents remember decisions and follow-ups.
    - Instructions and prompts are automatically available in the Chat view and `/` command palette once these settings are active.
3. **Restart VS Code Insiders** and open the **Agent Sessions** view to confirm the custom agents appear alongside the built-in options. Test a conductor session and verify the handoff buttons or `#runSubagent` commands launch planner, implementer, reviewer, and specialist personas.

Detailed environment notes live in `docs/guides/vscode-copilot-configuration.md` and `docs/guides/onboarding.md`.

## Agent Lineup

All personas are authored as `.agent.md` files with explicit tool scopes and handoffs:

- **Conductor** — orchestrates the entire lifecycle, enforces pause points, and delegates via `#runSubagent`.
- **Planner** — performs deep research, drafts multi-phase plans, and cites every external source.
- **Implementer** — executes phases with TDD discipline and comprehensive validation logs.
- **Reviewer** — delivers severity-tagged findings and guards quality, security, and compliance.
- **Researcher** — gathers context with recursive fetches and option analysis.
- **Maintainer** — triages issues, packages pull requests, and keeps validation artifacts current.
- **Security**, **Performance**, **Visualizer**, **Data Analytics**, **Docs** — specialist personas for targeted follow-ups and release readiness.

Each agent surfaces consistent handoffs so user-facing workflows remain one click away (for example Planner → Implementer → Reviewer → Conductor, with optional Security/Performance/Docs checkpoints).

## Directory Map

| Path | Purpose |
| --- | --- |
| `.github/agents/` | Canonical agent definitions (used by VS Code Insiders handoffs). |
| `.github/chatmodes/` | Legacy wrappers and compatibility placeholders. Prefer the `.agent.md` files. |
| `.github/prompts/` | Reusable `/` prompt library scoped per persona and workflow. |
| `instructions/` | Layered instruction mesh (global, workflow, compliance, language). |
| `docs/` | Guides, onboarding material, roadmaps, and analysis. |
| `scripts/` | Validation utilities (`validate-copilot-assets`, `add-prompt-metadata`, `token-report`, lint, smoke tests). |
| `plans/` | Generated plans, phase summaries, and completion artifacts (samples included). |

## Validation Suite

Run the following commands before publishing changes or updating downstream repositories:

```powershell
pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .
pwsh -File scripts/add-prompt-metadata.ps1 -RepositoryRoot . -CheckOnly
pwsh -File scripts/run-lint.ps1 -RepositoryRoot .
pwsh -File scripts/run-smoke-tests.ps1 -RepositoryRoot .
pwsh -File scripts/token-report.ps1 -Path . -ConfigPath token-thresholds.json
Invoke-Pester -Path tests -Output Detailed
```

Record validation output in pull requests and update `docs/CHANGELOG.md` for notable instruction or agent changes.

## Learn More

- `AGENTS.md` — mission, architecture, and workflow guardrails.
- `docs/workflows/` — strategic plans, blueprints, and setup checklists.
- `docs/guides/` — onboarding, VS Code configuration, sample agent transcripts.
- `docs/templates/` — plan, phase, and completion templates used by the conductor.
- `docs/operations.md` — monitoring cadence, metrics, and backlog tracking.
- `docs/posts/orchestrator-launch-promo.md` — promotional overview with end-to-end dataflow diagram for a sample request.

The repository is production-ready; downstream workspaces simply reference it via settings to adopt the same multi-agent conductor experience.
