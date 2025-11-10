---
title: "Copilot Orchestrator Onboarding Guide"
version: "0.2.0"
lastUpdated: "2025-11-10"
status: draft
---

## Overview
This guide accelerates new contributors joining the Copilot Orchestrator project. It explains required tooling, key documents, validation commands, and example artifacts so teammates can navigate the conductor workflow confidently.

## Audience & Goals
- **Audience:** Engineers, content designers, and operator personas participating in the multi-agent orchestration workflow.
- **Goals:** Establish repository context, demonstrate conductor lifecycle artifacts, and highlight validation/CI expectations.

## Prerequisites
- Windows PowerShell 5.1 (default in the workspace) with execution policy permitting local scripts.
- Familiarity with the global guardrails in `instructions/global/*.instructions.md` and workflow overlays in `instructions/workflows/`.
- Access to VS Code Insiders with Agent Sessions enabled.
- Optional but recommended: familiarity with `docs/workflows/orchestration-rebuild-plan.md` and `AGENTS.md`.

## Core Artifacts
| Asset | Location | Purpose |
| --- | --- | --- |
| Root instructions | `AGENTS.md` | Source-of-truth for roles, tooling, and validation expectations. |
| Validation scripts | `scripts/*.ps1` | Automated checks for instructions, prompts, token budgets, and now covered by Pester tests. |
| Prompt library | `.github/prompts/` | Personas-specific prompts used by the conductor, subagents, and support reviewers. |
| Support personas | `.github/agents/{maintainer,security,performance,visualizer,data-analytics,docs}.agent.md` | Specialists covering triage, security, performance, UX, analytics, and documentation follow-ups. |
| Plan templates | `docs/templates/` | Structures for plan, phase summary, and completion artifacts. |
| Sample plans | `plans/samples/` | Filled examples demonstrating the conductor deliverables. |
| Operations backlog | `docs/operations.md` | Tracks outstanding tasks, owners, and status. |

## Getting Started Steps
1. **Review Guidance:** Read `AGENTS.md`, relevant workflow instructions, and this onboarding guide.
2. **Configure VS Code:** Enable the following settings (user or workspace) to load nested instructions, chat agents, and prompts (see `docs/guides/vscode-copilot-configuration.md` for details):
   ```json
    {
       "chat.useAgentsMdFile": true,
       "chat.useNestedAgentsMdFiles": true,
       "chat.instructionsFilesLocations": [
            "instructions",
            ".github/instructions"
         ],
         "chat.promptFiles": true,
       "chat.promptFilesLocations": [".github/prompts"],
       "chat.modeFilesLocations": [
          ".github/agents",
          ".github/chatmodes"
       ]
    }
   ```
3. **Explore Samples:** Open files under `plans/samples/` to see completed plan, phase, and completion artifacts.
4. **Validate Local Clone:**
   ```
   pwsh -File scripts/run-lint.ps1
   pwsh -File scripts/run-smoke-tests.ps1
   pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .
   pwsh -File scripts/add-prompt-metadata.ps1 -RepositoryRoot . -CheckOnly
   pwsh -File scripts/token-report.ps1 -Path . -ConfigPath token-thresholds.json
   Invoke-Pester -Path tests
   ```
5. **Launch Conductor:** Use the `conductor` chat mode (`.github/chatmodes/conductor.chatmode.md`) with a simple task to walkthrough plan → implementation → review, invoking support personas when triage, security, performance, visual, analytics, or documentation follow-ups arise.
6. **Capture Notes:** Log questions, risks, or missing guidance in `docs/operations.md` under the backlog table.

## Agent Sessions & Handoffs
- Open the **Agent Sessions** view in VS Code Insiders to monitor conductor, subagent, and support persona activity. Each lifecycle response includes `Current Phase`, `Plan Progress`, `Last Action`, and `Next Action` telemetry.
- Use handoff buttons (Planner → Implementer → Reviewer → Support) instead of switching modes manually; the prefilled prompts preserve context and enforce pause points.
- When reviewing transcripts, confirm that plans, phase summaries, and completion reports are persisted under `plans/` and that support personas captured follow-up tasks.
- If handoff buttons are missing, re-run the validation scripts above and confirm the chat/agent settings remain enabled.

## Sample Agent Session
A walkthrough transcript is provided at `docs/guides/sample-agent-session.md`. It showcases the conductor engaging planner, implementer, and reviewer subagents, plus the resulting artifacts in `plans/samples/`.

## Next Steps & Feedback
- Pair with a maintainer for your first conductor-run task.
- Submit PRs updating documentation or prompts alongside validation outputs.
- Share feedback via the repository issues list or add notes to `docs/operations.md`.
