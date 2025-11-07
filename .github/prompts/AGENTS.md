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
