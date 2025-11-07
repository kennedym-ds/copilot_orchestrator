---
title: "VS Code Copilot Configuration"
version: "0.1.0"
lastUpdated: "2025-11-07"
status: draft
---

## Purpose
This guide shows how to configure VS Code Insiders so the Copilot Orchestrator workspace loads custom chat modes, instruction overlays, prompt files, and tool sets that power the conductor workflow.

## Prerequisites
- VS Code Insiders 1.101 or later with GitHub Copilot Chat enabled.
- Repository cloned locally with access to `.github/chatmodes`, `.github/prompts`, and `instructions/` folders.
- Copilot subscription tier that unlocks GPT-5-Codex (Preview) and premium reasoning models referenced in mode files.

## Core Settings
Add the following block to `.vscode/settings.json` (or user settings) to register the workspace assets:

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
    ".github/chatmodes"
  ]
}
```

These settings unlock:
- `AGENTS.md` plus nested variants for persona and workflow rules.
- Scoped `*.instructions.md` overlays (global, compliance, language-specific) under `instructions/`.
- Prompt library files (`.prompt.md`) for planning, implementation, review, research, and support personas.
- Custom chat modes with handoffs (`planner`, `conductor`, `implementer`, and support agents).

## Optional Enhancements
- Define tool set collections via `chat.tools.sets` when you create shared tool groups in `.github/toolsets.jsonc`.
- Control terminal approvals with `chat.tools.terminal.autoApprove` to match your security posture.
- Sync prompt and instruction files across machines by enabling Settings Sync for “Prompts and Instructions.”

## Verification Checklist
1. Restart VS Code Insiders after saving the settings.
2. Open the Chat view and confirm custom modes (Conductor, Planner, Implementer, Reviewer, Researcher, Security, Performance, Docs) appear in the mode picker.
3. Type `/` in chat and ensure prompt files from `.github/prompts` are listed.
4. Select a mode and verify handoff buttons appear after responses.
5. Run `./scripts/run-lint.ps1`, `./scripts/run-smoke-tests.ps1`, and `Invoke-Pester -Path tests` to confirm instructions and prompts remain valid.

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
