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
| Agent definitions | `.github/agents/` | 22 agent definitions with tool scopes and handoffs |
| Prompt library | `.github/prompts/` | Reusable prompts for each workflow phase |
| Plan templates | `docs/templates/` | Standard structures for plans and phase summaries |
| Sample artifacts | `plans/samples/` | Completed examples of conductor deliverables |

## Setup Steps

### 1. Review Documentation

Read `AGENTS.md` and this onboarding guide to understand the conductor workflow and agent responsibilities.

### 2. Configure VS Code

Add these settings to your user or workspace `settings.json`:

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
   "chat.modeFilesLocations": [".github/agents", ".github/chatmodes"],
   "github.copilot.chat.tools.memory.enabled": true
}
```

See `docs/guides/vscode-copilot-configuration.md` for detailed configuration notes.

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

## Agent Handoffs

The conductor delegates to specialized agents via handoff buttons or `#runSubagent` commands:

- **Planner**: Research and multi-phase plan creation
- **Implementer**: TDD execution and validation
- **Reviewer**: Code review with severity-tagged findings
- **Support personas**: Security, Performance, Accessibility, Docs as needed

## Next Steps

1. Review sample artifacts in `plans/samples/`
2. Try a simple task with the conductor to see the full workflow
3. Log questions or feedback in `docs/operations.md`
4. For issues, check the validation output and consult the troubleshooting section in `docs/quick-reference.md`
