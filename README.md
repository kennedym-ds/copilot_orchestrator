---
title: "Copilot Orchestrator"
version: "2.0.1"
lastUpdated: "2026-02-09"
status: stable
---

# Copilot Orchestrator

A centrally managed GitHub Copilot configuration implementing a multi-agent orchestration pattern. This repository provides a complete workflow system (conductor → planner → implementer → reviewer → completion) with specialized support agents for security, performance, accessibility, and documentation tasks.

Use this repository as a shared configuration source across workspaces. Configure VS Code to reference this location and all participating projects inherit consistent agent behaviors, tool permissions, and lifecycle guardrails.

## Features

- **Multi-phase orchestration**: Structured workflow with mandatory pause points for human review
- **27 specialized agents**: Core workflow agents plus support personas for security, performance, accessibility, IaC, translation, and more
- **13 reusable skills**: Domain-specific capabilities (TDD, security review, delegation routing, code translation, and more)
- **22 prompt templates**: Organized by workflow phase (planning, implementation, review, research, translation)
- **37 instruction files**: Layered mesh across global, workflow, compliance, and language categories
- **Local artifact persistence**: Session outputs stored in consuming repositories via `artifacts/` folder
- **Validation tooling**: PowerShell scripts for asset validation, token budgeting, and linting
- **Central deployment support**: Deploy agents at org level while storing artifacts locally per repository
- **VS Code 1.109+ features**: Agent Skills GA, multi-model fallback, thinking tokens, askQuestions, subagents, Copilot Memory
- **Organization sharing**: Native org-level agent distribution

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
| `.github/agents/` | Agent definitions (27 `.agent.md` files) |
| `.github/prompts/` | Reusable prompt library (22 templates across 7 categories) |
| `.github/skills/` | Reusable agent skills (16 domain-specific capabilities) |
| `instructions/` | Layered instruction mesh (37 files: global, workflow, compliance, language) |
| `scripts/` | Validation and tooling scripts (PowerShell 5.1) |
| `docs/` | Guides, templates, and operational documentation |
| `plans/` | Generated plan artifacts and samples |
| `artifacts/` | Local session outputs (plans, reviews, research, security audits) |

## Validation Commands

```powershell
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
| [docs/guides/agent-skills-pilot.md](docs/guides/agent-skills-pilot.md) | Agent skills pilot evaluation |
| [docs/operations.md](docs/operations.md) | Monitoring, metrics, and backlog |
| [docs/CHANGELOG.md](docs/CHANGELOG.md) | Version history |
| [INSTRUCTION_CHANGELOG.md](INSTRUCTION_CHANGELOG.md) | Instruction file change history |

## License

See repository license file for terms.
