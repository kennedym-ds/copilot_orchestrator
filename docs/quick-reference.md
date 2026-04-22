---
title: "Copilot Orchestrator Quick Reference"
version: "3.1.0"
lastUpdated: "2026-04-22"
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
| conductor | Execution | Lifecycle orchestration, delegation, pause points |
| planner | Premium | Multi-phase planning, risk analysis |
| reviewer | Execution | Multi-mode review: standard, security, adversarial, performance |
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

| Tier | Primary -> Fallback | Target Usage | Typical effort |
|------|---------------------|--------------|----------------|
| **Premium** | Claude Opus 4.6 -> Claude Opus 4.7 -> Claude Sonnet 4.6 | ~6% (Planner) | high |
| **Execution** | Claude Sonnet 4.6 -> GPT-5.4 -> GPT-5.3-Codex | ~75% (12 agents) | low / medium / high |
| **Fast** | Claude Haiku 4.5 -> GPT-5.4 mini -> GPT-5 mini | ~19% (3 agents) | low / medium |

Each agent declares `defaultEffort:` in frontmatter. Security-mode review pins Opus via a prompt-level override. Never pin a single model. Models deprecate monthly.

---

## New Features

- **Pushback System** â€” Reviewer challenges implementer assumptions, triggers re-work cycles
- **File Risk Classification** â€” ðŸŸ¢ Safe / ðŸŸ¡ Moderate / ðŸ”´ Critical risk scoring
- **Baseline Capture** â€” Snapshot working state before changes for rollback
- **Evidence-Based Verification** â€” Test execution results, not just static analysis
- **Confidence Levels** â€” Findings scored by evidence strength to filter false positives
- **Auto-Commit** â€” Optional commit-on-green after successful verification
- **Context7 MCP** â€” Live library documentation fetching (implementer, researcher)
- **Wiki Memory** â€” Karpathy-style wiki pattern in `artifacts/memory/wiki/`
- **Skills Ecosystem** â€” Compatible with [vercel-labs/skills](https://github.com/vercel-labs/skills)

---

## Artifact Folders

```
artifacts/
â”œâ”€â”€ plans/          # Implementation plans
â”œâ”€â”€ reviews/        # Code review verdicts
â”œâ”€â”€ research/       # Research briefs
â”œâ”€â”€ decisions/      # Architectural Decision Records (ADRs)
â”œâ”€â”€ sessions/       # Session state JSON
â”œâ”€â”€ tests/          # Test reports
â”œâ”€â”€ specs/          # Project specifications
â”œâ”€â”€ memory/         # Active context + wiki/
â””â”€â”€ .archive/       # Rolled-off artifacts past TTL
```

---

## Workflow Lifecycle

```
1. Planning
   User â†’ Conductor â†’ Planner â†’ Plan
   [Pause for approval]

2. Implementation (per phase)
   Conductor â†’ Implementer â†’ Code
   Conductor â†’ Reviewer â†’ Findings
   [Pushback cycle if needed]
   [Pause for commit]

3. Completion
   Conductor â†’ Final Report
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

---

## Key Documentation

| Document | Purpose |
|----------|---------|
| `README.md` | Project overview |
| `AGENTS.md` | Agent playbook |
| `docs/guides/onboarding.md` | Setup guide |
| `docs/guides/central-deployment.md` | Org-level deployment |
| `docs/guides/background-agents-worktrees.md` | Git worktrees for parallel execution |
| `docs/guides/agent-hooks-standard.md` | Hook triggers, scripts, JSONL output |
| `docs/guides/claude-skills-migration.md` | Prompt to skill migration |
| `docs/guides/memory-management.md` | Memory lifecycle, cleanup, ADRs |
| `docs/operations.md` | Monitoring, backlog, deferred gaps |

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
