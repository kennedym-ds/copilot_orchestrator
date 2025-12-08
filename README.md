---
title: "Copilot Orchestrator"
version: "0.4.0"
lastUpdated: "2025-12-08"
status: stable
---

# Copilot Orchestrator

A centrally managed GitHub Copilot configuration implementing a multi-agent orchestration pattern. This repository provides a complete workflow system (conductor → planner → implementer → reviewer → completion) with specialized support agents for security, performance, accessibility, and documentation tasks.

Use this repository as a shared configuration source across workspaces. Configure VS Code to reference this location and all participating projects inherit consistent agent behaviors, tool permissions, and lifecycle guardrails.

## Features

- **Multi-phase orchestration**: Structured workflow with mandatory pause points for human review
- **22 specialized agents**: Core workflow agents plus support personas for security, performance, accessibility, IaC, and more
- **Local artifact persistence**: Session outputs stored in consuming repositories via `artifacts/` folder
- **Validation tooling**: PowerShell scripts for asset validation, token budgeting, and linting
- **Central deployment support**: Deploy agents at org level while storing artifacts locally per repository

## Quick Start

### 1. Configure VS Code

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
| Conductor | Orchestrates lifecycle, enforces pause points, delegates to subagents | Claude Sonnet 4.5 |
| Planner | Drafts multi-phase plans with research and risk analysis | GPT-5 |
| Implementer | Executes phases using TDD methodology | GPT-5 Mini |
| Reviewer | Provides severity-tagged code review findings | Claude Sonnet 4.5 |
| Researcher | Gathers context from documentation and external sources | Gemini 2.5 Pro |
| Maintainer | Triages issues, coordinates releases, manages PR logistics | GPT-5 |

### Support Personas

| Agent | Purpose |
|-------|---------|
| Security | Threat modeling, compliance review, vulnerability assessment |
| Performance | Runtime analysis, memory profiling, optimization recommendations |
| Accessibility | WCAG compliance auditing, ARIA implementation review |
| Docs | Documentation drafting, onboarding materials, knowledge base |
| Observability | Telemetry analysis, platform integrations (Dynatrace, PagerDuty) |
| Visualizer | UX review, diagram creation, accessibility checkpoints |
| Data Analytics | DS-Star iterative analysis workflow, data quality assessment |

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
| Beast Mode | Extended reasoning with visible thinking for complex problems |

## Directory Structure

| Path | Purpose |
|------|---------|
| `.github/agents/` | Agent definitions (22 `.agent.md` files) |
| `.github/prompts/` | Reusable prompt library |
| `instructions/` | Layered instruction mesh (global, workflow, compliance, language) |
| `scripts/` | Validation and tooling scripts |
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
| [docs/operations.md](docs/operations.md) | Monitoring, metrics, and backlog |
| [docs/CHANGELOG.md](docs/CHANGELOG.md) | Version history |

## License

See repository license file for terms.
