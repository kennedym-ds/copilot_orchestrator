---
title: "Copilot Orchestrator Quick Reference"
version: "2.1.0"
lastUpdated: "2026-02-09"
status: stable
---

# Quick Reference

Command and configuration reference for the Copilot Orchestrator.

---

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

# Artifact cleanup (preview)
powershell -File scripts/cleanup-artifacts.ps1 -DryRun

# Artifact cleanup (execute)
powershell -File scripts/cleanup-artifacts.ps1

# Session analytics
pwsh -File scripts/analyze-sessions.ps1

# Run Pester tests
Invoke-Pester -Path tests -Output Detailed
```

---

## VS Code Configuration

```json
{
  "chat.useAgentsMdFile": true,
  "chat.useNestedAgentsMdFiles": true,
  "chat.useAgentSkills": true,
  "chat.useClaudeSkills": true,
  "chat.agentCustomizationSkill.enabled": true,
  "chat.customAgentInSubagent.enabled": true,
  "chat.askQuestions.enabled": true,
  "chat.instructionsFilesLocations": { "instructions": true },
  "chat.promptFilesLocations": { ".github/prompts": true },
  "chat.agentFilesLocations": { ".github/agents": true },
  "chat.agentSkillsLocations": { ".github/skills": true },
  "github.copilot.chat.copilotMemory.enabled": true,
  "github.copilot.chat.searchSubagent.enabled": true,
  "github.copilot.chat.organizationInstructions.enabled": true,
  "github.copilot.chat.customAgents.showOrganizationAndEnterpriseAgents": true,
  "github.copilot.chat.cli.customAgents.enabled": true,
  "github.copilot.chat.implementAgent.model": "Claude Sonnet 4.6 (copilot)",
  "chat.thinking.style": "collapsed",
  "chat.agent.thinking.collapsedTools": true,
  "chat.agent.thinking.terminalTools": true,
  "chat.tools.autoExpandFailures": true,
  "github.copilot.chat.anthropic.thinking.budgetTokens": 10000,
  "chat.viewSessions.enabled": true,
  "chat.viewSessions.orientation": "sideBySide",
  "chat.restoreLastPanelSession": false,
  "chat.agentsControl.enabled": true,
  "git.enableWorktrees": true,
  "git.worktreeIncludeFiles": [".env.local", "token-thresholds.json"]
}
```

---

## Agent Roster (26 Agents)

### Core Workflow

| Agent | Model | Purpose |
|-------|-------|---------|
| conductor | Claude Opus 4.6 | Lifecycle orchestration |
| planner | Claude Opus 4.6 | Multi-phase planning |
| implementer | Claude Sonnet 4.6 | TDD execution |
| reviewer | Claude Opus 4.6 | Code review |
| researcher | Claude Opus 4.6 | Context gathering |
| maintainer | GPT-5.3-Codex | Issue triage, releases |

### Support Personas

| Agent | Purpose |
|-------|---------|
| security | Threat modeling, compliance |
| performance | Runtime/memory analysis |
| accessibility | WCAG compliance |
| docs | Documentation |
| observability | Telemetry, integrations |
| visualizer | UX review, diagrams |
| deployment | CI/CD review |
| red-team | Adversarial testing |

### Specialists

| Agent | Purpose |
|-------|---------|
| test | TDD test writing |
| lint | Code style |
| github-ops | Issue/PR/workflow management |
| terraform | Multi-cloud IaC |
| bicep | Azure IaC |
| design | Architecture |
| beast-mode | Extended reasoning |

### Translation Workflow

| Agent | Purpose |
|-------|--------|
| translation-conductor | Full-repo translation orchestration |
| translator | File-level code translation |
| translation-analyzer | Dependency graph, complexity assessment |
| translation-validator | 6-layer validation, confidence scoring |
| translation-styler | Target language idioms |

---

## Artifact Folders

```
artifacts/
├── plans/          # Implementation plans
├── reviews/        # Code review verdicts
├── research/       # Research briefs
├── security/       # Security audits
├── sessions/       # Session state (JSON)
├── performance/    # Performance reports
├── docs/           # Documentation drafts
├── releases/       # Release notes
├── telemetry/      # Telemetry analysis
├── deployments/    # Deployment plans
├── red-team/       # Adversarial analysis
├── accessibility/  # WCAG audits
├── tests/          # Test reports
├── ux/             # UX reviews
├── decisions/      # Architectural Decision Records
├── memory/         # Active context (session write-back)
├── artifact-index.md  # Auto-generated inventory
└── .archive/       # Rolled-off artifacts past TTL
```

---

## Workflow Lifecycle

```
1. Planning
   User → Conductor → Planner → Plan
   [Pause for approval]

2. Implementation (per phase)
   Conductor → Implementer → Code
   Conductor → Reviewer → Findings
   [Pause for commit]

3. Completion
   Conductor → Final Report
```

---

## Directory Structure

| Path | Purpose |
|------|---------|
| `.github/agents/` | Agent definitions (27 files) |
| `.github/prompts/` | Reusable prompts |
| `instructions/` | Layered instruction mesh |
| `scripts/` | Validation and tooling |
| `docs/` | Guides and templates |
| `plans/` | Generated plan artifacts |
| `artifacts/` | Local session outputs |

---

## Key Documentation

| Document | Purpose |
|----------|---------|
| `README.md` | Project overview |
| `AGENTS.md` | Agent playbook |
| `docs/guides/onboarding.md` | Setup guide |
| `docs/guides/central-deployment.md` | Org-level deployment || `docs/guides/background-agents-worktrees.md` | Git worktrees for parallel execution |
| `docs/guides/claude-skills-migration.md` | Prompt to skill migration || `docs/guides/memory-management.md` | Memory lifecycle, cleanup, ADRs |
| `docs/operations.md` | Monitoring and backlog |

---

## Troubleshooting

### Agents not appearing

1. Verify VS Code settings are configured correctly
2. Restart VS Code after changing settings
3. Run `validate-copilot-assets.ps1` to check for errors

### Validation failures

1. Check command output for specific errors
2. Ensure all required fields are present in agent definitions
3. Verify YAML frontmatter syntax is valid

### Artifacts not persisted

1. Run `init-artifacts.ps1` to create folder structure
2. Verify write permissions in repository
3. Check agent has `edit` tool in its definition
