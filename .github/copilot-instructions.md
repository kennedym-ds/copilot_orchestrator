# Copilot Orchestrator Workspace Instructions

Welcome! This workspace is tuned for the conductor-led multi-agent workflow defined in `AGENTS.md` and `docs/workflows/`. Follow these guardrails to keep VS Code, Copilot agents, and repository automation in sync.

## Repository Overview

This is a greenfield conductor workspace for GitHub Copilot that implements a multi-agent orchestration pattern. The repository contains:
- **Custom agents**: Specialized AI agents for planning, implementation, review, security, performance, and documentation tasks
- **Chat modes**: Orchestrated workflows with handoffs between different agent personas
- **Instructions**: Layered guidance files for global, workflow-specific, language-specific, and compliance behaviors
- **Validation tooling**: PowerShell scripts to ensure quality and consistency of Copilot assets

## Technology Stack

- **Primary languages**: PowerShell (.ps1), Python (.py), Markdown (.md)
- **Configuration**: YAML, JSON
- **Testing**: Pester (PowerShell), pytest (Python)
- **Platform**: Cross-platform (Windows, Linux, macOS) with PowerShell Core support
- **Dependencies**: Minimal external dependencies; see `requirements.txt` for Python packages

## Project Conventions

- **File naming**: Use kebab-case for markdown files (e.g., `agent-instructions.md`), PascalCase for PowerShell scripts (e.g., `Validate-Assets.ps1`)
- **Documentation**: All new features require documentation updates in `docs/`
- **Commit messages**: Follow conventional commits format: `type(scope): description`
- **Line length**: Maximum 400 characters for markdown files (warnings issued by linter)
- **Whitespace**: No trailing whitespace; use spaces instead of tabs (except where language-specific conventions differ)

## Build, Test, and Validation

**Testing Commands:**
```powershell
# Run PowerShell unit tests
Invoke-Pester -Path tests -Output Detailed

# Run Python tests (if applicable)
pytest tests/

# Run all validation checks
pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .
pwsh -File scripts/add-prompt-metadata.ps1 -RepositoryRoot . -CheckOnly
pwsh -File scripts/run-lint.ps1 -RepositoryRoot .
pwsh -File scripts/run-smoke-tests.ps1 -RepositoryRoot .
pwsh -File scripts/token-report.ps1 -Path . -ConfigPath token-thresholds.json
```

**Validation Requirements:**
- All changes must pass the validation suite before opening a pull request
- Lint warnings about trailing whitespace and line length should be addressed
- Token usage should stay within thresholds defined in `token-thresholds.json`
- New instructions/prompts require metadata validation

## Working with GitHub Copilot Coding Agent

When an issue is assigned to `@copilot`, the cloud coding agent should:

1. **Read this file and `AGENTS.md`** to understand the conductor workflow, validation contracts, and escalation guardrails.
2. **Adhere to the lifecycle sequence** (planning → implementation → review → completion) and use the appropriate persona prompts under `.github/prompts/`.
3. **Run the validation suite** before opening a pull request (see Build, Test, and Validation section above).
4. **Update `docs/CHANGELOG.md`** and attach validation output to the PR description whenever instructions, prompts, or agent definitions change.
5. **Persist lifecycle artifacts** (plans, phase summaries, completion reports) using the templates in `docs/templates/`.

## Task Assignment Guidance

**Great fits for the Copilot agent**

- Documentation improvements, knowledge base updates, onboarding guides.
- Test authoring and maintenance (unit, integration, smoke) aligned with TDD expectations.
- Bug fixes or refactors with well-scoped reproduction steps.
- Prompt, agent, or instruction updates that follow existing patterns and validations.
- Enhancements to the PowerShell validation/tooling scripts in `scripts/`.

**Require human approval or pairing**

- Architectural shifts to the conductor workflow or instruction mesh.
- Security, privacy, or compliance changes outside the documented overlays.
- Model allocation changes that affect cost tiers or fallbacks.
- Introduction of new external dependencies or infrastructure.

Always capture open questions and escalate blockers via the conductor before proceeding.

## VS Code Configuration (Developers & Agents)

- Use **VS Code Insiders** to access Agent Sessions, handoffs, and context-isolated custom agents.
- Sign in with a Copilot subscription tier that exposes GPT-5-Codex (Preview) and the premium models referenced in agent files.
- Add the following `settings.json` snippet (path adjusted to where this repo lives on disk):

    ```json
    {
        "chat.useAgentsMdFile": true,
        "chat.useNestedAgentsMdFiles": true,
        "chat.instructionsFilesLocations": [
            "instructions",
            ".github/instructions"
        ],
        "chat.promptFiles": true,
        "chat.promptFilesLocations": [
            ".github/prompts"
        ],
        "chat.modeFilesLocations": [
            ".github/agents",
            ".github/chatmodes"
        ],
        "github.copilot.chat.tools.memory.enabled": true
    }
    ```

    The `.agent.md` files are the canonical persona definitions. The `.chatmode.md` directory is retained for backward compatibility with older Insider builds.
- Memory-enabled chat ensures custom agents recall prior decisions, risks, and TODOs across phases. After saving the settings, restart VS Code and verify in the Agent Sessions view that Conductor, Planner, Implementer, Reviewer, Researcher, Maintainer, Security, Performance, Visualizer, Data Analytics, and Docs appear in the agent picker.

## Instruction Mesh

- `AGENTS.md` — source-of-truth for mission, model allocation strategy, and lifecycle guardrails.
- `instructions/global/` — behavior, quality, and security overlays applied to every session.
- `instructions/workflows/` — conductor, planner, implementer, reviewer, and researcher personas.
- `instructions/compliance/` — documentation and security compliance requirements.
- `instructions/languages/` — language-specific guidance (for example Python guardrails).
- Nested `AGENTS.md` files under `.github/prompts/` or elsewhere supplement behavior when those assets are loaded.

## Lifecycle Guardrails

- Start complex work in the **Conductor** agent. Maintain telemetry (`Current Phase`, `Plan Progress`, `Last Action`, `Next Action`) in every response.
- Use handoff buttons instead of manual mode switching: Planner → Implementer → Reviewer → Conductor, with optional Maintainer/Security/Performance/Visualizer/Data Analytics/Docs detours.
- Use `#runCustomAgent` for research-heavy or parallel tasks so primary context stays focused, and capture key outcomes in memory notes for future responses.
- Persist plans, phase summaries, and completion reports under `plans/` using the templates in `docs/templates/`.
- Pause after plans and reviews until the human explicitly authorizes the next phase.

## Validation & Tooling

- Run `validate-copilot-assets`, `add-prompt-metadata`, `run-lint`, `run-smoke-tests`, and `token-report` after modifying any instructions, prompts, or agent files.
- Capture command output with timestamps and include it in PR descriptions.
- Monitor token usage with `token-report.ps1 -ConfigPath token-thresholds.json`; adjust thresholds when new assets are added.

## Documentation & Continuous Improvement

- Review `docs/workflows/orchestration-rebuild-plan.md`, `docs/workflows/new-workspace-blueprint.md`, and `docs/workflows/agent-instruction-gap-analysis.md` to understand the roadmap and guardrails.
- Use `docs/guides/onboarding.md`, `docs/guides/vscode-copilot-configuration.md`, and `docs/guides/sample-agent-session.md` for enablement and training.
- Track follow-up work, incidents, and backlog items in `docs/operations.md`; record notable instruction changes in `INSTRUCTION_CHANGELOG.md`.
- Engage the maintainer, security, performance, visualizer, data analytics, and docs personas whenever risks or documentation gaps surface; document all outcomes in the relevant plan or phase artifact.

## Common Tasks and Workflows

**Adding a new custom agent:**
1. Create a new `.agent.md` file in `.github/agents/`
2. Follow the pattern from existing agent files
3. Run validation: `pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .`
4. Update documentation in `AGENTS.md` and relevant workflow docs
5. Add entry to `INSTRUCTION_CHANGELOG.md`

**Updating instructions:**
1. Edit files in `instructions/` directory (global, workflows, compliance, or languages)
2. Include version metadata in YAML frontmatter
3. Run full validation suite
4. Document changes in `INSTRUCTION_CHANGELOG.md` with before/after metrics
5. Update `docs/CHANGELOG.md` for notable changes

**Creating new prompts:**
1. Add prompt file to `.github/prompts/` with appropriate subdirectory
2. Include metadata using `add-prompt-metadata.ps1`
3. Validate with `pwsh -File scripts/add-prompt-metadata.ps1 -RepositoryRoot . -CheckOnly`
4. Test the prompt in VS Code Insiders with the `/` command palette

**Troubleshooting validation failures:**
- Lint warnings: Address trailing whitespace and line length issues
- Token threshold exceeded: Review `token-thresholds.json` and optimize instructions
- Test failures: Check `tests/` directory for specific test requirements
- Metadata missing: Run `add-prompt-metadata.ps1` without `-CheckOnly` to add metadata
