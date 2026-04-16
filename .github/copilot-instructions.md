# Copilot Orchestrator Workspace Instructions

Multi-agent orchestration system with 16 specialized agents. See `AGENTS.md` for complete details.

## Architecture

```
.github/agents/      → 11 core + 5 translation agents
.github/prompts/     → Prompt templates by phase
.github/skills/      → 12 reusable skill modules
instructions/        → Global, workflow, and compliance instructions
scripts/             → PowerShell validation and tooling
scripts/mcp/         → MCP servers (validation, analytics, research, translation)
artifacts/           → Local session outputs
```

## Core Workflow

**Lifecycle:** Conductor → Planner → Implementer → Reviewer → Completion

Complexity scales the ceremony — simple tasks route directly to Implementer.

## Commands

```powershell
pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .
pwsh -File scripts/run-lint.ps1 -RepositoryRoot .
pwsh -File scripts/run-smoke-tests.ps1 -RepositoryRoot .
pwsh -File scripts/add-prompt-metadata.ps1 -RepositoryRoot . -CheckOnly
pwsh -File scripts/token-report.ps1 -Path .
```

## Key References

- `AGENTS.md` — Agent roster, model allocation, safety guardrails
- `docs/guides/onboarding.md` — New contributor setup
- `docs/templates/` — Plan, phase, and completion templates
- `INSTRUCTION_CHANGELOG.md` — Instruction change history
