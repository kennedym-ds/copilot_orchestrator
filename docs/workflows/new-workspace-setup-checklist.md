---
title: "Greenfield Workspace Setup Checklist"
version: "0.1.0"
lastUpdated: "2025-11-07"
status: draft
owner: "Dev Experience"
---

## Prerequisites

- [ ] Approve budget for premium and cost-optimized Copilot models.
- [ ] Confirm GitHub organization/repository ownership and access policies.
- [ ] Enable VS Code Insiders with Agent Sessions, handoffs, and nested `AGENTS.md` support.
- [ ] Clone legacy `copilot_config` repo locally for reference during migration.

## Repository Bootstrap

- [ ] Create new repository (`copilot-orchestrator` working name) with default branch `main`.
- [ ] Add `.editorconfig`, `.gitattributes`, `.gitignore` (include `plans/` by default).
- [ ] Scaffold directories: `.github/agents`, `.github/prompts`, `instructions/{global,languages,workflows,compliance}`, `docs/{workflows,templates}`, `scripts`, `plans`.
- [ ] Copy validation scripts from legacy repo and update module imports if necessary.

## Instruction Mesh

- [ ] Draft root `AGENTS.md` referencing product vision, architecture, build/test commands, and security notes.
- [ ] Enable nested agents via repository settings (`settings.json`: `"chat.useNestedAgentsMdFiles": true`).
- [ ] Create sample nested `AGENTS.md` files for `.github/agents/` and `.github/prompts/`.
- [ ] Port `instructions/global/00_behavior.instructions.md` and update for new conductor workflow.
- [ ] Author workflow-specific instructions (conductor, planner, implementer, reviewer) under `instructions/workflows/`.

## Agent & Prompt Scaffold

- [ ] Create `conductor.agent.md` with workflow, subagent instructions, handoffs, and state tracking.
- [ ] Author `planner.agent.md`, `researcher.agent.md`, `implementer.agent.md`, `reviewer.agent.md` using premium/cost-effective model mix.
- [ ] Provide support agents (accessibility, security, performance) with minimal toolsets.
- [ ] Build core prompts (`/plan`, `/implement-phase`, `/review-phase`, `/summarize`) referencing corresponding modes.
- [ ] Include templates in `docs/templates/` for plan, phase completion, plan completion, commit message style guide.

## Automation & CI

- [ ] Configure GitHub Actions workflow `ci/validate.yml` to run PowerShell validators and markdown lint.
- [ ] Add status badge to README for validation workflow.
- [ ] Integrate token budget reporting into PR template.
- [ ] Set default branch protection rules (status checks required, signed commits optional).

## Documentation

- [ ] Copy `docs/workflows/orchestration-rebuild-plan.md` and `docs/workflows/new-workspace-blueprint.md` from source repo.
- [ ] Create quick-start guide (`docs/README.md`) covering Conductor usage and Agent Sessions tips.
- [ ] Update `docs/CHANGELOG.md` with initial release entry.
- [ ] Document operational runbooks in `docs/operations.md` (monitoring, approvals, feedback loops).

## Launch Readiness

- [ ] Dry-run the Conductor workflow on a sample task; verify plans, phase files, and handoffs function in VS Code Insiders.
- [ ] Export sample Agent Sessions transcript for onboarding materials.
- [ ] Review documentation and instructions with security/compliance stakeholders.
- [ ] Announce repository availability, linking to migration checklist and training resources.

## Post-Launch

- [ ] Schedule retrospective after first sprint to capture lessons and adjust instructions.
- [ ] Track adoption metrics (tasks completed via Conductor, validation pass rate).
- [ ] Migrate outstanding legacy assets or archive them with clear redirection notes.
- [ ] Periodically review model allocations to optimize cost vs. quality.
