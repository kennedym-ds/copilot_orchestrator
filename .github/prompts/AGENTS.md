# Prompt Library Guidance

This directory hosts prompt templates for orchestrated workflows. Follow these guardrails when authoring or updating prompts:

- Align each prompt with a specific agent (`agent:` front matter) and ensure the listed tools match the agent's permissions.
- Restrict front matter keys to the supported schema (`name`, `description`, `model`, `agent`, `tools`, optional `argument-hint`). Use hyphenated identifiers for `name`.
- Reference `AGENTS.md` at the repository root plus workflow instructions in `instructions/workflows/` for persona-specific nuances.
- Require every prompt body to include **Purpose**, **Instructions**, **Output Format**, and **Validation Checklist** sections so downstream agents have predictable structure.
- Reinforce mandatory practices: 2,000-line contextual reads, recursive `fetch_webpage` usage for all URLs, TODO lists in triple backticks, and explicit validation/test expectations.
- Avoid implementation guidance in research or planning prompts; enforce clear stop conditions so the conductor can gate progress.
- After adding or modifying prompts, run:
  - `pwsh -File scripts/add-prompt-metadata.ps1 -RepositoryRoot . -CheckOnly`
  - `pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .`
  - `pwsh -File scripts/token-report.ps1 -Path .`
  Document outcomes in `docs/CHANGELOG.md` and backlog items in `docs/operations.md` if follow-ups are required.

## Prompt Index

### Lifecycle Prompts (Conductor Workflow)

| Prompt | Agent | Purpose |
|--------|-------|---------|
| `planning/multi-phase-plan` | planner | Draft multi-phase implementation plans |
| `planning/ds-star-step` | data-analytics | DS-Star iterative analysis round |
| `implementation/execute-phase` | implementer | TDD execution of a single plan phase |
| `research/context-dossier` | researcher | Gather context and evidence |
| `review/structured-review` | reviewer | Severity-tagged code review checklist |
| `support/performance-audit` | performance | Runtime/memory/cost analysis |
| `support/security-review` | security | Threat modeling and compliance check |
| `support/onboarding-playbook` | docs | Generate onboarding materials |

### Quick-Action Prompts (Any Chat Mode)

| Prompt | Model Tier | Purpose |
|--------|-----------|---------|
| `quick/debug-issue` | Execution | Structured debugging: reproduce, isolate, fix, verify |
| `quick/refactor-code` | Execution | Refactor for clarity and maintainability |
| `quick/generate-tests` | Execution | Generate unit/integration tests with edge cases |
| `quick/pr-description` | Routine | Generate PR description from current diff |
| `quick/commit-message` | Routine | Generate conventional commit message from diff |
| `quick/quick-review` | Execution | Fast code review without full conductor workflow |

### Root-Level Prompts

| Prompt | Purpose |
|--------|---------|
| `review` | General code review (maps to structured-review) |
| `new-agent` | Scaffold a new agent definition file |
| `commit` | Generate conventional commit message |

**Rationale for root placement:** These three prompts are intentionally at the
root of `.github/prompts/` rather than in subdirectories. They serve as
high-frequency entry points that VS Code surfaces in the prompt picker without
navigating subdirectories. The awesome-copilot community uses subdirectories for
domain grouping but keeps commonly-used prompts accessible at root. `review` and
`commit` are the two most-invoked prompts; `new-agent` is the primary
scaffolding prompt for contributors.

### Translation Prompts

| Prompt | Agent | Purpose |
|--------|-------|---------|
| `translation/analyze-repo` | translation-analyzer | Dependency graph and manifest |
| `translation/translate-module` | translator | File-level code translation |
| `translation/validate-translation` | translation-validator | 6-layer validation stack |
| `translation/generate-docs` | docs | Translation documentation |
| `translation/final-report` | translation-conductor | Full translation summary |
