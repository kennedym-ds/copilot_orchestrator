---
title: "Copilot Orchestrator"
version: "3.0.0"
lastUpdated: "2026-04-16"
status: stable
---

<p align="center">
  <img src="docs/logo.png" alt="Copilot Orchestrator" width="200">
</p>

# Copilot Orchestrator

A multi-agent orchestration system for GitHub Copilot. Provides a structured workflow (conductor → planner → implementer → reviewer → completion) with 16 specialized agents (11 core + 5 translation), reusable skills, and validation tooling.

Use as a shared configuration source across workspaces. Point VS Code at this repo and all projects inherit consistent agent behaviors, tool permissions, and lifecycle guardrails.

## What's Included

| Asset | Count | Location |
|-------|-------|----------|
| Agents | 16 | `.github/agents/` |
| Skills | 12 | `.github/skills/` |
| Prompt templates | 22 | `.github/prompts/` |
| Instruction files | 15 | `instructions/` |
| Validation scripts | 6 | `scripts/` |
| MCP servers | 6 | `scripts/mcp/` |

## Quick Start

### 1. Configure VS Code

Add these settings to your user or workspace `settings.json`:

```json
{
   "chat.useAgentsMdFile": true,
   "chat.useNestedAgentsMdFiles": true,
   "chat.instructionsFilesLocations": ["instructions"],
   "chat.promptFilesLocations": [".github/prompts"],
   "chat.agentFilesLocations": { ".github/agents": true },
   "chat.agentSkillsLocations": { ".github/skills": true },
   "chat.useAgentSkills": true,
   "chat.useClaudeSkills": true,
   "chat.agentCustomizationSkill.enabled": true,
   "chat.customAgentInSubagent.enabled": true,
   "chat.subagents.allowInvocationsFromSubagents": true,
   "github.copilot.chat.searchSubagent.enabled": true,
   "github.copilot.chat.customAgents.showOrganizationAndEnterpriseAgents": true,
   "github.copilot.chat.cli.customAgents.enabled": true,
   "github.copilot.chat.organizationInstructions.enabled": true,
   "chat.thinking.style": "collapsed",
   "chat.agent.thinking.collapsedTools": true,
   "chat.agent.thinking.terminalTools": true,
   "chat.tools.autoExpandFailures": true,
   "chat.askQuestions.enabled": true,
   "github.copilot.chat.anthropic.thinking.budgetTokens": 10000,
   // Note: github.copilot.chat.anthropic.thinking.effort and responsesApiReasoningEffort are deprecated in 1.113.
   // Configure thinking effort via the model picker submenu instead.
   "github.copilot.chat.anthropic.toolSearchTool.enabled": true,
   "github.copilot.chat.anthropic.contextEditing.enabled": true,
   "github.copilot.chat.copilotMemory.enabled": true,
   "github.copilot.chat.advanced.workspace.codeSearchExternalIngest.enabled": true,
   "chat.viewSessions.enabled": true,
   "chat.viewSessions.orientation": "sideBySide",
   "chat.restoreLastPanelSession": false,
   "chat.agentsControl.enabled": true,
   "chat.agentsControl.clickBehavior": "cycle",
   "workbench.startupEditor": "agentSessionsWelcomePage",
   "github.copilot.chat.implementAgent.model": "GPT-5 mini (copilot)",
   "chat.tools.terminal.enableAutoApprove": true,
   "chat.tools.terminal.autoApproveWorkspaceNpmScripts": true,
   "chat.tools.terminal.preventShellHistory": true,
   "terminal.integrated.enableKittyKeyboardProtocol": true,
   "workbench.browser.openLocalhostLinks": true,
   "simpleBrowser.useIntegratedBrowser": true,
   "git.worktreeIncludeFiles": [".env.local", "token-thresholds.json"]
}
```

### 2. Validate Installation

```powershell
pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .
```

### 3. Initialize Artifacts (Optional)

```powershell
pwsh -File scripts/init-artifacts.ps1
```

This creates the local `artifacts/` folder structure for session persistence.

## Other Platforms

The orchestrator works across five platforms. VS Code is native (no setup needed). The others require a one-time setup script.

| Platform | Setup | Guide |
|----------|-------|-------|
| **VS Code** | Built-in — clone and open | [VS Code Configuration](docs/guides/vscode-copilot-configuration.md) |
| **Visual Studio** | `powershell -File scripts/setup-vs-cli.ps1 -Strategy Symlink -TargetPath <project>` | [Visual Studio Onboarding](docs/guides/visual-studio-onboarding.md) |
| **Copilot CLI** | `powershell -File scripts/setup-vs-cli.ps1 -Strategy Symlink -TargetPath <project>` | [Copilot CLI Onboarding](docs/guides/copilot-cli-onboarding.md) |
| **Claude Code** | `powershell -File scripts/setup-claude-code.ps1 -Mode Project -TargetPath <project>` | [Claude Code Onboarding](docs/guides/claude-code-onboarding.md) |
| **Antigravity** | `powershell -File scripts/setup-antigravity.ps1 -Mode Project -TargetPath <project>` | [Antigravity Onboarding](docs/guides/antigravity-onboarding.md) |

macOS/Linux users: use the `.sh` equivalents (`setup-vs-cli.sh`, `setup-claude-code.sh`, `setup-antigravity.sh`). See [Multi-Platform Setup Reference](docs/guides/multi-platform-setup.md) for full details.

## Model Tiers

The orchestrator ships three branches, each targeting a different cost profile. Push to `main` and GitHub Actions automatically syncs the other two.

| Branch | Cost | Primary Model | Secondary Model | Use Case |
|--------|------|---------------|-----------------|----------|
| `main` | Premium | GPT-5 mini (3 agents), GPT-5 mini (11), GPT-4.1 (2) | — | Full capability — optimized per agent role |
| `low-cost` | Budget | GPT-5 mini (3 agents), GPT-4.1 (13) | — | ~64% savings — Opus→Sonnet 4.6, Sonnet→Haiku 4.5 |
| `free-cost` | Zero (0×) | GPT-5 mini | GPT-4.1 | Zero premium requests — all agents on GPT-5 mini or GPT-4.1 |

### How It Works

1. **Develop on `main`** — all agents run premium models with full capability.
2. **Push to `main`** — two GitHub Actions workflows trigger automatically:
   - [`sync-low-cost-branch.yml`](.github/workflows/sync-low-cost-branch.yml) resets `low-cost` from `main` and applies budget model substitutions.
   - [`sync-free-cost-branch.yml`](.github/workflows/sync-free-cost-branch.yml) resets `free-cost` from `main` and applies 0× model substitutions.
3. **Switch tiers** — clone or checkout the branch matching your budget:
   ```bash
   git checkout free-cost   # Zero-cost tier
   git checkout low-cost    # Budget tier
   git checkout main        # Premium tier
   ```

> **Deep dive:** [Three Branches, One Codebase](docs/guides/branching-for-copilot-cost-optimization.md) — explains the design choices, sync mechanism, and lessons learned.

## Agent Roster

16 specialized agents across three model tiers. Push to `main` and the `low-cost` / `free-cost` branches sync automatically. See [Model Tiers](#model-tiers) for details.

| Agent | Tier | Model (Main) | Purpose |
|-------|------|--------------|---------|
| Conductor | Premium | GPT-5 mini | Lifecycle orchestration |
| Planner | Premium | GPT-5 mini | Multi-phase planning |
| Reviewer | Premium | GPT-5 mini | Multi-mode code review |
| Implementer | Execution | GPT-5 mini | TDD implementation |
| Researcher | Execution | GPT-5 mini | Evidence gathering |
| Ops | Execution | GPT-5 mini | Issues, PRs, CI/CD |
| Test | Execution | GPT-5 mini | Test authoring |
| IaC | Execution | GPT-5 mini | Terraform/Bicep/Pulumi |
| GUI Tester | Execution | GPT-5 mini | Browser automation |
| Docs | Fast | GPT-4.1 | Documentation |
| UX | Fast | GPT-4.1 | UX/accessibility review |
| Translation Conductor | Execution | GPT-5 mini | Translation orchestration |
| Translator | Execution | GPT-5 mini | File-level translation |
| Translation Analyzer | Execution | GPT-5 mini | Dependency analysis |
| Translation Validator | Execution | GPT-5 mini | Validation scoring |
| Translation Styler | Execution | GPT-5 mini | Target language idioms |

## Directory Structure

| Path | Purpose |
|------|---------|
| `.github/agents/` | 16 agent definitions |
| `.github/prompts/` | 22 prompt templates |
| `.github/skills/` | 12 agent skills |
| `instructions/` | 15 instruction files (global, workflow, compliance, language) |
| `scripts/` | Validation and tooling (PowerShell 5.1) |
| `scripts/mcp/` | 6 MCP servers |
| `docs/` | Guides, templates, and operational docs |
| `artifacts/` | Local session outputs (plans, reviews, research, security) |

## Validation

```powershell
# Validate all assets
powershell -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .

# Check prompt metadata
powershell -File scripts/add-prompt-metadata.ps1 -RepositoryRoot . -CheckOnly

# Run linting
powershell -File scripts/run-lint.ps1 -RepositoryRoot .

# Run smoke tests
powershell -File scripts/run-smoke-tests.ps1 -RepositoryRoot .

# Token budget report
powershell -File scripts/token-report.ps1 -Path .

# Initialize artifacts folder
powershell -File scripts/init-artifacts.ps1

# Run Pester tests
Invoke-Pester -Path tests -Output Detailed
```

## Documentation

| Document | Purpose |
|----------|---------|
| [AGENTS.md](AGENTS.md) | Agent playbook, workflow guardrails, development environment |
| [docs/guides/onboarding.md](docs/guides/onboarding.md) | New contributor guide |
| [docs/guides/model-tiers.md](docs/guides/model-tiers.md) | Model tier strategy, per-agent rationale, cost analysis |
| [docs/guides/central-deployment.md](docs/guides/central-deployment.md) | Org-level deployment with local artifacts |
| [docs/guides/vscode-copilot-configuration.md](docs/guides/vscode-copilot-configuration.md) | VS Code settings reference |
| [docs/guides/background-agents-worktrees.md](docs/guides/background-agents-worktrees.md) | Parallel execution with Git worktrees |
| [docs/guides/claude-skills-migration.md](docs/guides/claude-skills-migration.md) | Migrating prompts to Claude skills |
| [docs/guides/translation-guide.md](docs/guides/translation-guide.md) | Code translation workflow guide |
| [docs/operations.md](docs/operations.md) | Monitoring, metrics, and backlog |
| [docs/CHANGELOG.md](docs/CHANGELOG.md) | Version history |

## License

See [LICENSE](LICENSE) for terms.
