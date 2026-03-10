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

## Agent Roster

### Core Workflow Agents

| Agent | Purpose | Model |
|-------|---------|-------|
| Conductor | Orchestrates lifecycle, enforces pause points, delegates to subagents | Claude Opus 4.6 |
| Planner | Drafts multi-phase plans with research and risk analysis | Claude Opus 4.6 |
| Implementer | Executes phases using TDD methodology | Claude Sonnet 4.6 |
| Reviewer | Provides severity-tagged code review findings | Claude Opus 4.6 |
| Researcher | Gathers context from documentation and external sources | Claude Opus 4.6 |
| Maintainer | Triages issues, coordinates releases, manages PR logistics | GPT-5.3-Codex |

### Support Personas

| Agent | Purpose |
|-------|---------|
| Security | Threat modeling, compliance review, vulnerability assessment |
| Performance | Runtime analysis, memory profiling, optimization recommendations |
| Accessibility | WCAG compliance auditing, ARIA implementation review |
| Docs | Documentation drafting, onboarding materials, knowledge base |
| Observability | Telemetry analysis, platform integrations (Dynatrace, PagerDuty) |
| Visualizer | UX review, diagram creation, accessibility checkpoints |

### Specialist Agents

| Agent | Purpose |
|-------|---------|
| Test | TDD test writing, coverage analysis, Pester framework |
| Lint | Code style enforcement, formatting fixes |
| GitHub Ops | Issue/PR management, workflow operations, release management |
| Red Team | Adversarial testing, edge case identification |
| Deployment | CI/CD pipeline review, release readiness assessment |
| Terraform | Infrastructure-as-code planning, drift detection |
| Bicep | Azure IaC implementation, ARM template migration |
| Design | Architecture design, brand system queries, component validation |
| Beast Mode | Extended reasoning with visible thinking for complex problems |
| GUI Tester | Browser automation, visual regression, interaction testing |
| Rubber Duck | Socratic problem-solving, guided debugging |

### Translation Workflow Agents

| Agent | Purpose |
|-------|--------|
| Translation Conductor | Full-repo translation orchestration, 6-phase lifecycle |
| Translator | File-level code translation with pattern mapping |
| Translation Analyzer | Dependency graph, manifest, complexity assessment |
| Translation Validator | 6-layer validation stack, confidence scoring |
| Translation Styler | Target language idioms and conventions |

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
# Validate all assets
pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .

# Check prompt metadata
pwsh -File scripts/add-prompt-metadata.ps1 -RepositoryRoot . -CheckOnly

# Run linting
pwsh -File scripts/run-lint.ps1 -RepositoryRoot .

# Run smoke tests
pwsh -File scripts/run-smoke-tests.ps1 -RepositoryRoot .

# Token budget report
pwsh -File scripts/token-report.ps1 -Path .

# Initialize artifacts folder
pwsh -File scripts/init-artifacts.ps1

# Run Pester tests
Invoke-Pester -Path tests -Output Detailed
```

## Documentation

| Document | Purpose |
|----------|---------|
| [AGENTS.md](AGENTS.md) | Agent playbook, workflow guardrails, development environment |
| [docs/guides/onboarding.md](docs/guides/onboarding.md) | New contributor guide |
| [docs/guides/central-deployment.md](docs/guides/central-deployment.md) | Org-level deployment with local artifacts |
| [docs/guides/vscode-copilot-configuration.md](docs/guides/vscode-copilot-configuration.md) | VS Code settings reference |
| [docs/guides/background-agents-worktrees.md](docs/guides/background-agents-worktrees.md) | Parallel execution with Git worktrees |
| [docs/guides/claude-skills-migration.md](docs/guides/claude-skills-migration.md) | Migrating prompts to Claude skills |
| [docs/guides/translation-guide.md](docs/guides/translation-guide.md) | Code translation workflow guide |
| [docs/operations.md](docs/operations.md) | Monitoring, metrics, and backlog |
| [docs/CHANGELOG.md](docs/CHANGELOG.md) | Version history |

## License

See [LICENSE](LICENSE) for terms.
