---
title: "Copilot Orchestrator"
version: "2.1.0"
lastUpdated: "2026-03-10"
status: stable
---

<p align="center">
  <img src="docs/logo.png" alt="Copilot Orchestrator" width="200">
</p>

# Copilot Orchestrator

A multi-agent orchestration system for GitHub Copilot. Provides a structured workflow (conductor → planner → implementer → reviewer → completion) with 29 specialized agents, reusable skills, and validation tooling.

Use as a shared configuration source across workspaces. Point VS Code at this repo and all projects inherit consistent agent behaviors, tool permissions, and lifecycle guardrails.

## What's Included

| Asset | Count | Location |
|-------|-------|----------|
| Agents | 29 | `.github/agents/` |
| Skills | 17 | `.github/skills/` |
| Prompt templates | 22 | `.github/prompts/` |
| Instruction files | 37 | `instructions/` |
| Validation scripts | 6 | `scripts/` |
| MCP servers | 8 | `scripts/mcp/` |

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
   "github.copilot.chat.implementAgent.model": "Claude Sonnet 4.6 (copilot)",
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
| `main` | Premium | GPT-5.4 (22 agents), Claude Opus 4.6 (3) | Claude Sonnet 4.6 (1), Claude Haiku 4.5 (3) | Full capability — optimized per agent role |
| `low-cost` | Budget | Claude Sonnet 4.6 (3 agents), Claude Haiku 4.5 (26) | — | ~64% savings — Opus→Sonnet 4.6, rest→Haiku 4.5 |
| `free-cost` | Zero (0×) | GPT-5 mini | GPT-4.1 | Zero premium requests — 24 agents on GPT-5 mini, 5 on GPT-4.1 |

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

### Free-Cost Agent Allocation

| Model | Agents | Rationale |
|-------|--------|-----------|
| GPT-5 mini | 24 agents (conductor, planner, implementer, reviewer, researcher, security, performance, red-team, etc.) | Strongest 0× model — SWE-bench 71%, COLLIE 98.5% instruction following |
| GPT-4.1 | 5 agents (docs, lint, rubber-duck, visualizer, gui-tester) | Speed-first tasks where deep reasoning is unnecessary |

> See [artifacts/research/0x-model-benchmark-report.md](artifacts/research/0x-model-benchmark-report.md) for the full benchmark analysis behind these assignments.

> **Deep dive:** [Three Branches, One Codebase](docs/guides/branching-for-copilot-cost-optimization.md) — explains the design choices, sync mechanism, and lessons learned.

## Agent Roster

29 specialized agents across three model tiers. Push to `main` and the `low-cost` / `free-cost` branches sync automatically. See [Model Tiers](#model-tiers) for details.

| Agent | Category | Main (Premium) | Low-Cost (Budget) | Free-Cost (0×) |
|-------|----------|----------------|--------------------|--------------------|
| Conductor | Core | Claude Opus 4.6 | Claude Sonnet 4.6 | GPT-5 mini |
| Planner | Core | Claude Opus 4.6 | Claude Sonnet 4.6 | GPT-5 mini |
| Implementer | Core | GPT-5.4 | Claude Haiku 4.5 | GPT-5 mini |
| Reviewer | Core | GPT-5.4 | Claude Haiku 4.5 | GPT-5 mini |
| Researcher | Core | GPT-5.4 | Claude Haiku 4.5 | GPT-5 mini |
| Maintainer | Core | GPT-5.4 | Claude Haiku 4.5 | GPT-5 mini |
| Spec | Core | GPT-5.4 | Claude Haiku 4.5 | GPT-5 mini |
| Security | Support | Claude Opus 4.6 | Claude Sonnet 4.6 | GPT-5 mini |
| Performance | Support | GPT-5.4 | Claude Haiku 4.5 | GPT-5 mini |
| Accessibility | Support | GPT-5.4 | Claude Haiku 4.5 | GPT-5 mini |
| Docs | Support | GPT-5.4 | Claude Haiku 4.5 | GPT-4.1 |
| Observability | Support | GPT-5.4 | Claude Haiku 4.5 | GPT-5 mini |
| Visualizer | Support | Claude Haiku 4.5 | Claude Haiku 4.5 | GPT-4.1 |
| Test | Specialist | GPT-5.4 | Claude Haiku 4.5 | GPT-5 mini |
| Lint | Specialist | Claude Haiku 4.5 | Claude Haiku 4.5 | GPT-4.1 |
| GitHub Ops | Specialist | GPT-5.4 | Claude Haiku 4.5 | GPT-5 mini |
| Red Team | Specialist | GPT-5.4 | Claude Haiku 4.5 | GPT-5 mini |
| Deployment | Specialist | GPT-5.4 | Claude Haiku 4.5 | GPT-5 mini |
| Terraform | Specialist | GPT-5.4 | Claude Haiku 4.5 | GPT-5 mini |
| Bicep | Specialist | GPT-5.4 | Claude Haiku 4.5 | GPT-5 mini |
| Design | Specialist | GPT-5.4 | Claude Haiku 4.5 | GPT-5 mini |
| Beast Mode | Specialist | GPT-5.4 | Claude Haiku 4.5 | GPT-5 mini |
| GUI Tester | Specialist | GPT-5.4 | Claude Haiku 4.5 | GPT-4.1 |
| Rubber Duck | Specialist | Claude Haiku 4.5 | Claude Haiku 4.5 | GPT-4.1 |
| Translation Conductor | Translation | Claude Sonnet 4.6 | Claude Haiku 4.5 | GPT-5 mini |
| Translator | Translation | GPT-5.4 | Claude Haiku 4.5 | GPT-5 mini |
| Translation Analyzer | Translation | GPT-5.4 | Claude Haiku 4.5 | GPT-5 mini |
| Translation Validator | Translation | GPT-5.4 | Claude Haiku 4.5 | GPT-5 mini |
| Translation Styler | Translation | GPT-5.4 | Claude Haiku 4.5 | GPT-5 mini |

## Directory Structure

| Path | Purpose |
|------|---------|
| `.github/agents/` | 29 agent definitions |
| `.github/prompts/` | 22 prompt templates |
| `.github/skills/` | 17 agent skills |
| `instructions/` | 37 instruction files (global, workflow, compliance, language) |
| `scripts/` | Validation and tooling (PowerShell 5.1) |
| `scripts/mcp/` | 8 MCP servers |
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
