---
title: "Copilot Orchestrator Quick Reference"
version: "3.0.0"
lastUpdated: "2026-04-16"
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
  "github.copilot.chat.implementAgent.model": "GPT-5 mini (copilot)",
  "chat.thinking.style": "collapsed",
  "chat.agent.thinking.collapsedTools": true,
  "chat.agent.thinking.terminalTools": true,
  "chat.tools.autoExpandFailures": true,
  "github.copilot.chat.anthropic.thinking.budgetTokens": 10000,
  "chat.subagents.allowInvocationsFromSubagents": true,
  "chat.viewSessions.enabled": true,
  "chat.viewSessions.orientation": "sideBySide",
  "chat.restoreLastPanelSession": false,
  "chat.agentsControl.enabled": true,
  "git.enableWorktrees": true,
  "git.worktreeIncludeFiles": [".env.local", "token-thresholds.json"]
}
```

---

## Agent Roster (16 agents)

### Core Agents (11)

| Agent | Tier | Purpose |
|-------|------|---------|
| conductor | Premium | Lifecycle orchestration, delegation, pause points |
| planner | Premium | Multi-phase planning, risk analysis |
| reviewer | Premium | Multi-mode review: standard, security, adversarial, performance |
| implementer | Execution | TDD execution, validation |
| researcher | Execution | Evidence gathering, citation |
| ops | Execution | Issues, PRs, CI/CD, releases, telemetry |
| test | Execution | Test authoring, coverage analysis |
| iac | Execution | Terraform, Bicep, Pulumi |
| gui-tester | Execution | Browser automation, visual regression |
| docs | Fast | Documentation, onboarding |
| ux | Fast | UX review, WCAG accessibility, diagrams |

### Translation Agents (5)

| Agent | Purpose |
|-------|---------|
| translation-conductor | Full-repo translation orchestration |
| translator | File-level code translation |
| translation-analyzer | Dependency graph, complexity assessment |
| translation-validator | Validation stack, confidence scoring |
| translation-styler | Target language idioms |

---

## Model Tiers

| Tier | Primary → Fallback | Target Usage |
|------|-------------------|--------------|
| **Premium** | GPT-5 mini → GPT-5 mini → GPT-4.1 | ~15% of invocations |
| **Execution** | GPT-5 mini → GPT-5 mini → GPT-4.1 | ~75% of invocations |
| **Fast** | GPT-4.1 → GPT-5 mini → GPT-5 mini | ~10% of invocations |

Never pin a single model. Models deprecate monthly.

---

## New Features

- **Pushback System** — Reviewer challenges implementer assumptions, triggers re-work cycles
- **File Risk Classification** — 🟢 Safe / 🟡 Moderate / 🔴 Critical risk scoring
- **Baseline Capture** — Snapshot working state before changes for rollback
- **Evidence-Based Verification** — Test execution results, not just static analysis
- **Confidence Levels** — Findings scored by evidence strength to filter false positives
- **Auto-Commit** — Optional commit-on-green after successful verification
- **Context7 MCP** — Live library documentation fetching (implementer, researcher)
- **Wiki Memory** — Karpathy-style wiki pattern in `artifacts/memory/wiki/`
- **Skills Ecosystem** — Compatible with [vercel-labs/skills](https://github.com/vercel-labs/skills)

---

## Artifact Folders

```
artifacts/
├── plans/          # Implementation plans
├── reviews/        # Code review verdicts
├── research/       # Research briefs
├── decisions/      # Architectural Decision Records (ADRs)
├── sessions/       # Session state JSON
├── tests/          # Test reports
├── specs/          # Project specifications
├── memory/         # Active context + wiki/
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
   [Pushback cycle if needed]
   [Pause for commit]

3. Completion
   Conductor → Final Report
```

---

## Directory Structure

| Path | Purpose |
|------|---------|
| `.github/agents/` | Agent definitions (16 files) |
| `.github/prompts/` | Reusable prompts |
| `.github/skills/` | Skill modules (12 skills) |
| `instructions/` | Layered instruction mesh |
| `scripts/` | Validation and tooling |
| `scripts/mcp/` | MCP servers (validation, analytics, research, translation) |
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
