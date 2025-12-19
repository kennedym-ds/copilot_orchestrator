---
title: "VS Code Copilot Configuration"
version: "0.5.0"
lastUpdated: "2025-12-19"
status: stable
---

## Purpose
This guide shows how to configure VS Code Insiders so the Copilot Orchestrator workspace loads custom chat modes, instruction overlays, prompt files, and tool sets that power the conductor workflow.

## Prerequisites
- VS Code 1.107 or later (stable channel now supports all features).
- A central configuration repository that stores shared agents, prompts, and instruction meshes.
- Local clones of any workspaces that should consume the central configuration (for example `copilot_orchestrator`).
- GitHub Copilot subscription (Individual, Business, or Enterprise).

## Setup Overview
Most teams keep a single **configuration hub** (for example `C:\CopilotConfig`) that holds reusable chat modes, agent definitions, prompts, and instruction overlays. Individual workspaces, such as `copilot_orchestrator`, inherit those assets by pointing VS Code to both the hub and the workspace-local definitions.

You can register the paths globally in your user `settings.json` (recommended for shared devices) and optionally add a minimal `.vscode/settings.json` in the workspace if you need repository-specific overrides.

## Step-by-Step Configuration
1. Clone the central configuration repository and note its absolute path (replace `C:\CopilotConfig` below with your location).
2. Clone any workspace repositories that rely on those assets (for example `C:\Workspaces\copilot_orchestrator`).
3. Open VS Code Insiders and update your user `settings.json` with the following block:

   ```json
   {
     "chat.useAgentsMdFile": true,
     "chat.useNestedAgentsMdFiles": true,
     "chat.promptFiles": true,
     "chat.instructionsFilesLocations": {
       "C:\\CopilotConfig\\instructions": true,
       "C:\\Workspaces\\copilot_orchestrator\\instructions": true,
       "C:\\Workspaces\\copilot_orchestrator\\.github\\instructions": true
     },
     "chat.promptFilesLocations": {
       "C:\\CopilotConfig\\prompts": true,
       "C:\\Workspaces\\copilot_orchestrator\\.github\\prompts": true
     },
     "chat.modeFilesLocations": {
       "C:\\CopilotConfig\\chatmode": true,
       "C:\\Workspaces\\copilot_orchestrator\\.github\\agents": true,
       "C:\\Workspaces\\copilot_orchestrator\\.github\\chatmodes": true
     },
     "github.copilot.chat.tools.memory.enabled": true,
     "chat.agentSessionsViewLocation": "panel",
     "chat.emptyState.history.enabled": true,
     "chat.customAgentInSubagent.enabled": true,
     "github.copilot.chat.reviewSelection.instructions": [
       {
         "file": "C:\\CopilotConfig\\.copilot-review-instructions.md"
       }
     ]
   }
   ```

   VS Code silently skips any paths that are missing, making it safe to reuse this block across machines where only a subset of repositories exists.

4. (Optional) Create `.vscode/settings.json` inside `copilot_orchestrator` if you want repository-specific additions. Include only the paths that live inside the workspace so the file remains portable:

   ```json
   {
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

## What the Settings Unlock
- `AGENTS.md` plus nested variants for persona and workflow rules.
- Scoped instruction overlays under `instructions/` and `.github/instructions/` (behavior, compliance, language-specific).
- Prompt libraries for planning, implementation, review, research, and support personas.
- Chat modes and agent definitions with full handoff buttons (Conductor, Planner, Implementer, Reviewer, Researcher, Maintainer, Security, Performance, Visualizer, Data Analytics, Docs).
- **Agent Sessions view** in the panel for unified monitoring of local and cloud agent workflows.
- **Recent chat history** when starting new sessions for quick context switching.
- **Cross-agent custom agents** that allow specialized agents to invoke other agent personas.

## Optional Enhancements
- Define tool set collections via `chat.tools.sets` when you create shared tool groups in `.github/toolsets.jsonc`.
- Control terminal approvals with `chat.tools.terminal.autoApprove` to match your security posture.
- Sync prompt and instruction files across machines by enabling Settings Sync for “Prompts and Instructions.”
- Review the **Chat History & Memory** panel to curate notes that custom agents should inherit; with memory enabled, the conductor and `#runCustomAgent` calls can re-use decisions from prior sessions.

## Custom Agent Handoffs in Practice
- Launch complex work in the Conductor, then delegate using the handoff buttons or explicit `#runCustomAgent` commands (for example `#runCustomAgent planner`).
- **Cross-agent custom agents**: With `chat.customAgentInSubagent.enabled`, you can invoke different agent personas from within a custom agent:
  ```
  Run the researcher agent as a custom agent to investigate authentication patterns.
  Use the security agent in a custom agent to threat-model the API design.
  ```
- **Monitor all sessions**: Open the Agent Sessions view (Panel → Agent Sessions) to see conductor workflows, delegated cloud agents, and CLI sessions in one place.
- When delegating manually, include scope, files, and expectations so memory captures the context for follow-up personas.
- Encourage specialists (Security, Performance, Visualizer, Data Analytics, Docs) to append memory notes summarizing their findings for downstream agents.
- Clear or update memory entries before starting a new initiative to avoid cross-talk between projects.

## Saving Successful Sessions
When a conductor session produces a valuable workflow, capture it for reuse:

1. After completing the workflow, type `/savePrompt` in the chat input.
2. VS Code generates a `.prompt.md` file with placeholders for variable inputs.
3. Review the generated prompt and save it to `.github/prompts/` for team use.
4. Document the new prompt in `docs/CHANGELOG.md` and add metadata with `scripts/add-prompt-metadata.ps1`.

Example use cases:
- Complex refactoring patterns that worked well
- Multi-phase implementation workflows
- Effective research + planning + implementation sequences

## Verification Checklist
1. Restart VS Code Insiders after saving the settings.
2. Open the Chat view and confirm custom modes (Conductor, Planner, Implementer, Reviewer, Researcher, Maintainer, Security, Performance, Visualizer, Data Analytics, Docs) appear in the mode picker.
3. Type `/` in chat and ensure prompt files from `.github/prompts` are listed.
4. Select a mode and verify handoff buttons or `#runCustomAgent` invocations appear after responses.
5. Confirm the memory indicator shows as enabled (gear icon → “Chat > Tools > Memory”) and pin any critical context for the next session.
6. Run the following commands to confirm instructions and prompts remain valid:
   - `./scripts/run-lint.ps1`
   - `./scripts/run-smoke-tests.ps1`
   - `Invoke-Pester -Path tests`

## Troubleshooting
- If modes or prompts are missing, ensure the settings paths match the workspace layout and that `chat.promptFiles` is enabled.
- Handoffs only appear in VS Code Insiders; update to the latest build if buttons are absent.
- If tool approvals appear too often, adjust the per-tool approval settings or consolidate tool sets.
- Regenerate the token budget report (`./scripts/token-report.ps1`) after adding new instructions or prompts to keep CI thresholds current.

## References
- [Custom chat modes in VS Code](https://code.visualstudio.com/docs/copilot/customization/custom-chat-modes)
- [Use custom instructions](https://code.visualstudio.com/docs/copilot/customization/custom-instructions)
- [Use prompt files](https://code.visualstudio.com/docs/copilot/customization/prompt-files)
- [Use tools in chat](https://code.visualstudio.com/docs/copilot/chat/chat-tools)
