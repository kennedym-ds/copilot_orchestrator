---
name: new-agent
description: "Scaffold a new custom agent definition file following repository patterns."
argument-hint: "Describe the agents purpose, domain, and responsibilities"
model: GPT-5.4 (copilot)
agent: agent
tools: [read, fileSearch, search, edit, askQuestions]
---

## Purpose
Create a new `.agent.md` file in `.github/agents/` following the established patterns in this repository.

## Instructions
- Read existing agent files for pattern reference (e.g., `.github/agents/implementer.agent.md`).
- Read `instructions/global/01_quality.instructions.md` § Model Allocation for tier assignments.
- Ask clarifying questions about the agent's purpose, tier, and required tools.
- Generate the agent file with complete frontmatter and body.

### Frontmatter Requirements
- `name`: lowercase, hyphenated
- `description`: one-sentence purpose
- `argument-hint`: what the user should provide
- `model`: array with primary and fallback models
- `tools`: list of tools the agent needs
- `handoffs`: at minimum, a "Return to Conductor" handoff

### Body Requirements
- Agent title and role description
- Core capabilities (3-5 bullet points)
- Reference to corresponding instruction file if applicable
- Boundaries section (always do / ask first / never do)

### Model Tier Assignment
- Premium (~15%): Orchestration, planning, review → Claude Opus 4.6 → GPT-5.4 → GPT-4.1
- Execution (~75%): Implementation, testing, analysis → Claude Sonnet 4.6 → GPT-5.4 → GPT-4.1
- Fast (~10%): Documentation, UX → Claude Haiku 4.5 → GPT-5 mini → Claude Sonnet 4.6

### Invocation Control
- Add `user-invokable: false` for subagent-only agents
- Add `disable-model-invocation: true` to prevent AI spontaneous invocation
- Add `agents: [...]` allowlist for orchestrator agents

## Output Format
A complete `.agent.md` file with:
1. Valid YAML frontmatter with all required keys
2. Markdown body with role, capabilities, and boundaries
3. Model assignment matching the appropriate tier
