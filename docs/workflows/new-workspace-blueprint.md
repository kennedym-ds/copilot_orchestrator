---
title: "Greenfield Orchestrator Workspace Blueprint"
version: "0.1.0"
lastUpdated: "2025-11-07"
status: draft
owner: "Copilot Guild"
---

## Purpose

Define the target architecture, folder structure, and governance guardrails for the new repository that hosts our conductor-led, multi-agent Copilot configuration. This blueprint ensures the workspace launches with world-class defaults for planning, implementation, and review personas.

## Guiding Principles

- **Conductor-Centric:** All workflows originate from a Conductor agent that coordinates research, implementation, review, and documentation artifacts.
- **Instruction Mesh:** `AGENTS.md` files provide the canonical context, with layered `.instructions.md` overrides for language, workflow, and compliance scopes.
- **Cost-Aware Model Mix:** Reasoning phases use premium models (GPT-5, Claude Sonnet 4.5, Gemini 2.5 Pro, Claude Opus); implementation phases default to efficient models (GPT-5 Mini, Claude Haiku 4.5, GPT-4.1).
- **Async Subagents:** Planning, research, implementation, and review subagents run via `#runSubagent`, allowing parallel execution and context isolation.
- **Artifact Trail:** Every phase emits Markdown records (plans, phase completion, final summary) stored under `plans/` to enable auditability and resumability.

## Repository Layout

| Path | Purpose | Notes |
| --- | --- | --- |
| `.github/` | GitHub workflows, issue templates, repo instructions | Include validation workflow invoking `scripts/validate-copilot-assets.ps1`. |
| `.github/copilot-instructions.md` | Root instructions referencing `AGENTS.md` and critical policies | Keep concise; link to detailed docs. |
| `.github/chatmodes/` | Core agents (`conductor`, `planner`, `implementer`, `reviewer`, support personas) | Use YAML front matter with `model`, `tools`, `handoffs`, `target`. |
| `.github/prompts/` | Slash commands and reusable prompts mapped to orchestrated workflows | Group by phase (plan, implement, review, support). |
| `AGENTS.md` | Primary instruction corpus for all agents | Mirror sample from `docs/templates/agents/root.md`. |
| `instructions/` | Layered `.instructions.md` files per domain (global, languages, workflows, compliance) | Keep directories shallow and names descriptive. |
| `plans/` | Auto-generated plan, phase, and completion artifacts | Add to `.gitignore` by default but allow commits when audit trail needed. |
| `docs/` | Governance, runbooks, architecture diagrams | Include `docs/workflows/` and `docs/templates/`. |
| `scripts/` | Validation utilities (PowerShell) | Replicate existing validators, add orchestrator-specific checks. |

## Instruction Strategy

1. **Root `AGENTS.md`:** Summarizes product vision, architecture, build/test commands, security obligations, and validation rules.
2. **Nested Files:** Enable `chat.useNestedAgentsMdFiles` and place AGENTS variants in `.github/chatmodes/`, `.github/prompts/`, and major submodules.
3. **Workflow Instructions:** Create `.instructions.md` for conductor, planning, TDD implementation, code review, security audits, and docs generation.
4. **Compliance Overlay:** Maintain `instructions/compliance/*.instructions.md` with regulatory requirements referenced in conductor outputs.

## Agent Definitions

| Agent | Description | Default Model | Key Tools | Handoffs |
| --- | --- | --- | --- | --- |
| `conductor` | Orchestrates plan → implement → review → commit → completion | Claude Sonnet 4.5 | `runSubagent`, `todos`, `fetch`, `search`, `githubRepo`, `edit`, `changes`, `runCommands` | Planner, Implementer, Reviewer, Support |
| `planner` | Drafts plans from research findings and user clarifications | GPT-5 | `todos`, `fetch`, `search`, `readFile` | Handoff to Conductor (Phase Kickoff) |
| `researcher` | Deep research, context gathering, option analysis | Gemini 2.5 Pro | `search`, `fetch`, `githubRepo`, `readFile`, `usages`, `problems` | Returns findings to Conductor/Planner |
| `implementer` | Executes TDD implementation per phase | GPT-5 Mini | `edit`, `runCommands`, `search`, `todos`, `changes`, `problems` | Handoff to Reviewer |
| `reviewer` | Performs structured code review with severity tagging | Claude Sonnet 4.5 | `changes`, `search`, `usages`, `problems` | Handoff to Conductor for summary |
| Support Personas | Accessibility, Security, Performance, Docs | Model-appropriate | Minimal toolsets per domain | Optional handoffs from Conductor |

## Automation & CI/CD

- **Validation Workflow:** GitHub Actions job running PowerShell scripts (`validate-copilot-assets.ps1`, `add-prompt-metadata.ps1`, `token-report.ps1`). Fail build on warnings.
- **Token Budgets:** Commit `token-report.json` artifacts in PRs for large prompt changes.
- **Linting:** Add markdown linting (`markdownlint-cli2`) and YAML schema validation for agent files.
- **Agent Smoke Tests:** Scheduled job invoking key prompts in headless mode to ensure instructions remain coherent.

## Documentation Requirements

- `docs/workflows/orchestration-rebuild-plan.md` (this repo).
- `docs/workflows/new-workspace-setup-checklist.md` (operational steps).
- `docs/templates/` containing reusable templates (AGENTS root, nested AGENTS, plan style guide, phase completion guide).
- `docs/CHANGELOG.md` documenting milestones.
- Architecture diagram (Mermaid) illustrating conductor/subagent flow.

## Security & Compliance

- Integrate `instructions/compliance/security.instructions.md` referencing data handling, secrets, and access control.
- Conductor must flag compliance-required approvals at plan stage.
- Include automated policy checks for prompts referencing restricted tools or commands.

## Success Criteria

- Repository bootstrapped with validated instructions and chat modes on initial commit.
- Conductor workflow runs end-to-end in VS Code Insiders with Agent Sessions view reflecting state updates.
- Documentation and templates enable contributors to add new agents/prompts without ambiguity.

## Open Questions

1. Which organization owns maintenance of the new repo?
2. Do we mirror legacy prompts for backwards compatibility or start fresh?
3. How do we manage access to premium models (billing, quotas) in the new workspace?
4. Should `plans/` artifacts be committed by default or only on demand?
