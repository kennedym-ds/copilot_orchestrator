---
title: "Copilot Orchestrator Onboarding Guide"
version: "0.3.0"
lastUpdated: "2025-12-08"
status: stable
---

## Overview

This guide provides setup instructions for contributors joining the Copilot Orchestrator project. It covers tooling requirements, key documents, validation commands, and the conductor workflow.

## Prerequisites

- Windows PowerShell 5.1 with execution policy permitting local scripts
- VS Code with GitHub Copilot extension
- Familiarity with the repository structure in `AGENTS.md`

## Core Resources

| Resource | Location | Purpose |
|----------|----------|---------|
| Agent playbook | `AGENTS.md` | Agent roster, commands, workflow guardrails |
| Validation scripts | `scripts/*.ps1` | Asset validation, linting, token reporting |
| Agent definitions | `.github/agents/` | 28 agent definitions with tool scopes and delegation patterns |
| Prompt library | `.github/prompts/` | Reusable prompts for each workflow phase |
| Plan templates | `docs/templates/` | Standard structures for plans and phase summaries |
| Sample artifacts | `plans/samples/` | Completed examples of conductor deliverables |

## Setup Steps

### 1. Review Documentation

Read `AGENTS.md` and this onboarding guide to understand the conductor workflow and agent responsibilities.

### 2. Configure VS Code

VS Code settings control where agents, skills, instructions, and prompts are discovered. Choose the right scope:

- **Workspace-level** (`.vscode/settings.json`): Agents available only when this repo is open
- **User-level** (`Ctrl+Shift+P` → "Open User Settings (JSON)"): Agents available in **every** VS Code window

#### Workspace Settings (Minimum)

Add to `.vscode/settings.json` in this repo (or your user settings):

```json
{
   "chat.useAgentsMdFile": true,
   "chat.useNestedAgentsMdFiles": true,
   "chat.instructionsFilesLocations": {
      "instructions": true
   },
   "chat.promptFilesLocations": { ".github/prompts": true },
   "chat.agentFilesLocations": { ".github/agents": true },
   "chat.agentSkillsLocations": { ".github/skills": true },
   "github.copilot.chat.copilotMemory.enabled": true
}
```

#### Global Agent Availability (Recommended)

To use orchestrator agents in **any** VS Code window, add these to your **user** `settings.json` with tilde paths:

```json
{
   "chat.agentFilesLocations": {
      "~/OneDrive/Documents/Projects/copilot_orchestrator/.github/agents": true
   },
   "chat.agentSkillsLocations": {
      "~/OneDrive/Documents/Projects/copilot_orchestrator/.github/skills": true
   },
   "chat.instructionsFilesLocations": {
      "~/OneDrive/Documents/Projects/copilot_orchestrator/instructions": true
   },
   "chat.promptFilesLocations": {
      "~/OneDrive/Documents/Projects/copilot_orchestrator/.github/prompts": true
   }
}
```

> **Note:** Use `~` (tilde) instead of absolute paths like `C:\\Users\\...`. VS Code expands `~` to your home directory. Adjust the path after `~` to match your local clone location.

See `docs/guides/vscode-copilot-configuration.md` for the complete settings reference, troubleshooting, and feature explanations.

### 3. Validate Installation

Run the validation suite to confirm your environment is configured correctly:

```powershell
pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .
pwsh -File scripts/add-prompt-metadata.ps1 -RepositoryRoot . -CheckOnly
pwsh -File scripts/run-lint.ps1 -RepositoryRoot .
pwsh -File scripts/run-smoke-tests.ps1 -RepositoryRoot .
pwsh -File scripts/token-report.ps1 -Path .
Invoke-Pester -Path tests -Output Detailed
```

### 4. Initialize Artifacts Folder

Create the local artifacts folder structure for session outputs:

```powershell
pwsh -File scripts/init-artifacts.ps1
```

This creates folders for plans, reviews, research, security audits, and session state.

### 5. Start a Conductor Session

1. Open VS Code and select the **conductor** agent from the chat panel
2. Describe a task to begin the planning phase
3. Review the generated plan and approve to proceed
4. Follow handoffs through implementation and review phases
5. Artifacts are saved to `artifacts/` as each phase completes

## Workflow Overview

The conductor progresses tasks through a structured lifecycle:

```
Planning → Implementation → Review → Completion
```

Each phase produces artifacts in the local `artifacts/` folder:

| Phase | Artifact Location |
|-------|------------------|
| Planning | `artifacts/plans/{feature}/plan.md` |
| Implementation | `artifacts/plans/{feature}/phase-N-complete.md` |
| Review | `artifacts/reviews/{date}-{feature}.md` |
| Completion | `artifacts/plans/{feature}/plan-complete.md` |

## Agent Delegation

The conductor is the only agent with handoff buttons in the UI. All other agents delegate autonomously via `#runSubagent` using the `delegation-routing` skill for keyword-based routing:

- **Planner**: Research and multi-phase plan creation
- **Implementer**: TDD execution and validation
- **Reviewer**: Code review with severity-tagged findings
- **Support personas**: Security, Performance, Accessibility, Docs as needed

After completing their work, agents return results to the conductor automatically — no manual button clicks required.

## Configuring Language Models

**VS Code 1.109+**: Configure which language models are available to agents and which tools auto-approve.

### Access the Language Models Editor

1. Open Command Palette (`Ctrl+Shift+P` or `Cmd+Shift+P`)
2. Run: **Chat: Manage Language Models**
3. The Language Models editor opens with:
   - **Model Visibility Toggles**: Show/hide models in agent dropdowns
   - **Provider Management**: Enable/disable model providers
   - **Tool Auto-Approval**: Configure which tools run without confirmation

### Model Visibility

Control which models appear in the model picker for chat sessions:

- **GPT-5.3-Codex**: Balanced reasoning and execution (recommended for execution-tier agents)
- **Claude Sonnet 4.6**: Versatile implementation and analysis (recommended for Implementer, Test, and routine tasks)

**Best Practice**: Show only the models appropriate for your workflow to avoid confusion.

### Provider Configuration

Enable/disable model providers:
- **GitHub Copilot**: All default models
- **Custom Providers**: Configure via extensions or VS Code settings

### Tool Auto-Approval Settings

> ⚠️ **Security**: Only auto-approve tools you fully trust. See [Tool Approval Policy](../../instructions/compliance/tool-approval-policy.instructions.md).

**Safe to Auto-Approve**:
- `readFile` - Read workspace files
- `search` - Search for code
- `semanticSearch` - AI-powered code search
- `listFiles` - List directory contents

**Require Manual Approval**:
- `runCommands` - Execute terminal commands
- `editFile` - Modify files
- `runTask` - Run VS Code tasks
- `createFile` - Create new files

**How to Configure**:
1. Open Language Models editor (Chat: Manage Language Models)
2. Scroll to "Tool Permissions" section
3. Toggle checkboxes for each tool
4. Changes save automatically

### Recommended Configuration for This Project

```json
{
  "chat.models.enabledProviders": ["copilot"],
  "chat.tools.eligibleForAutoApproval": [
    "readFile",
    "search",
    "semanticSearch",
    "listFiles",
    "codeSearch",
    "fileSearch"
  ]
}
```

This configuration:
- Uses GitHub Copilot models exclusively
- Auto-approves read-only tools for faster sessions
- Requires confirmation for write/execute operations

### Verification

After configuring models:
1. Open a new Copilot chat session
2. Check the model dropdown - only enabled models should appear
3. Try a tool invocation (e.g., ask to read a file)
4. Auto-approved tools execute immediately, others prompt for confirmation

For advanced configuration, see [VS Code Copilot Configuration Guide](vscode-copilot-configuration.md).

## Other Platforms

The orchestrator agents work beyond VS Code. Dedicated onboarding guides are available for each platform:

- [Claude Code Onboarding](claude-code-onboarding.md) — Setup, model/tool mapping, project/user/plugin modes
- [Antigravity IDE Onboarding](antigravity-onboarding.md) — Setup, workflows (slash commands), project/user modes
- [Visual Studio Onboarding](visual-studio-onboarding.md) — Symlink/copy/reference strategies, validation
- [Copilot CLI Onboarding](copilot-cli-onboarding.md) — Interactive, one-off, chaining, and CI/CD patterns

See [Multi-Platform Setup Reference](multi-platform-setup.md) for the full technical comparison across all platforms.

## Next Steps

1. Review sample artifacts in `plans/samples/`
2. Try a simple task with the conductor to see the full workflow
3. Log questions or feedback in `docs/operations.md`
4. For issues, check the validation output and consult the troubleshooting section in `docs/quick-reference.md`
