# Copilot Orchestrator Workspace Instructions

Welcome! This workspace is tuned for the conductor-led multi-agent workflow defined in `AGENTS.md` and `docs/workflows/`. Follow these guardrails to keep VS Code, Copilot agents, and repository automation in sync.

## Repository Overview

This is a greenfield conductor workspace for GitHub Copilot that implements a multi-agent orchestration pattern. The repository contains:
- **Custom agents**: Specialized AI agents for planning, implementation, review, security, performance, and documentation tasks
- **Chat modes**: Orchestrated workflows with handoffs between different agent personas
- **Instructions**: Layered guidance files for global, workflow-specific, language-specific, and compliance behaviors
- **Validation tooling**: PowerShell scripts to ensure quality and consistency of Copilot assets

## Working with GitHub Copilot Coding Agent

When assigned to this repository via issue assignment (`@copilot`), the coding agent should:

1. **Review this file first** to understand repository structure, conventions, and validation requirements
2. **Follow the conductor workflow** outlined in `AGENTS.md` for complex tasks
3. **Run validation scripts** before submitting pull requests:
   - `pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .`
   - `pwsh -File scripts/add-prompt-metadata.ps1 -RepositoryRoot . -CheckOnly`
4. **Update `docs/CHANGELOG.md`** when making notable changes to instructions, prompts, chat modes, or agent configurations
5. **Use templates** from `docs/templates/` when creating plans, phase reports, or completion summaries

## Best Practices for Task Assignment

**Suitable Tasks for Copilot Coding Agent:**
- Documentation updates and improvements
- Adding or updating tests
- Bug fixes with clear reproduction steps
- Refactoring with well-defined scope
- Updating validation scripts or tooling
- Adding new prompts or chat modes following existing patterns

**Tasks Requiring Human Oversight:**
- Major architectural changes to the conductor workflow
- Security or compliance instruction modifications
- Changes to core agent behavior or model allocations
- Integration of new external dependencies

## Workspace Configuration (for VS Code Users)
- Use **VS Code Insiders** so you can access Agent Sessions, chat handoffs, and nested `AGENTS.md` support.
- Enable the GitHub Copilot Chat extension and sign in with a subscription that unlocks premium and efficiency models.
- Add the following settings (user or workspace) to ensure prompt, chat mode, and nested instruction files load correctly:

```json
{
	"chat.useAgentsMdFile": true,
	"chat.useNestedAgentsMdFiles": true,
	"chat.promptFiles": true,
	"chat.modeFilesLocations": [".github/chatmodes"],
	"chat.promptFilesLocations": [".github/prompts"]
}
```

## Instruction Mesh
- Treat the root `AGENTS.md` as the canonical overview of architecture, tooling, and guardrails.
- Workflow-specific behaviors live under `instructions/workflows/`; language or compliance overlays live under `instructions/global/` and `instructions/compliance/`.
- Nested `AGENTS.md` files in `.github/prompts/` and other directories may supplement the root file; VS Code Insiders loads them automatically when the settings above are enabled.

## Lifecycle Guardrails
- Always begin complex work in the `conductor` chat mode; it orchestrates planning → implementation → review → completion and enforces pause points.
- Use handoff buttons (Planner → Implementer → Reviewer → Conductor) instead of switching modes manually so context and prompts stay aligned.
- Persist artifacts in `plans/` (plan draft, per-phase summaries, completion report) using templates from `docs/templates/`.

## Validation & Tooling
- After modifying instructions, prompts, or chat modes, run:
	- `pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .`
	- `pwsh -File scripts/add-prompt-metadata.ps1 -RepositoryRoot . -CheckOnly`
	- `pwsh -File scripts/token-report.ps1 -Path .`
- Capture command output in PR descriptions and update `docs/CHANGELOG.md` for notable instruction or prompt changes.

## Documentation & Onboarding
- Review `docs/workflows/orchestration-rebuild-plan.md`, `docs/workflows/new-workspace-blueprint.md`, and the new `docs/workflows/agent-instruction-gap-analysis.md` for roadmap and gap insights.
- Reference `docs/guides/onboarding.md` and `docs/operations.md` for enablement materials, metrics, and backlog tracking.
- Log gaps or follow-up work in `docs/operations.md` so the conductor can prioritize the next iteration.
