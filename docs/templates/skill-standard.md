---
title: "Skill standard template"
version: "1.0.0"
lastUpdated: "2026-03-10"
status: "active"
reviewOwners:
  - "Copilot Orchestrator maintainers"
aiAssistance: "Drafted with GitHub Copilot and intended for review with Pester plus validate-copilot-assets.ps1."
---

# Skill standard template

Canonical reference for normalizing `.github/skills/*/SKILL.md` during the Agent & Skill Quality Review. This template preserves the current skill pattern used by focused skills such as `delegation-routing` and `budget-gatekeeper` while making activation guidance explicit and easier to audit.

## Required frontmatter

| Key | Required | Notes |
|-----|----------|-------|
| `name` | Yes | Must match the skill directory name |
| `description` | Yes | One-line purpose with discovery-friendly wording |
| `version` | Yes | Semver for future review and change tracking |

## Canonical template

````markdown
---
name: "{skill-name}"
description: "{one-line purpose}"
version: "1.0.0"
---

# {Skill Name}

## Description

<!-- INSTRUCTIONS: Explain what capability this skill adds and why an agent would load it. -->

{1-2 concise paragraphs}

## When to Use

<!-- INSTRUCTIONS: Make activation criteria explicit. Include both positive triggers and a `When NOT to Use` subsection. -->

- Use when {condition 1}
- Use when {condition 2}
- Use when {condition 3}

### When NOT to Use

- Do not use when {condition better handled elsewhere}
- Do not use when {scope is too small, too broad, or belongs to another primitive}

## Entry Points

<!-- INSTRUCTIONS: Name the agents or workflows that should load this skill, and at what point in their flow. -->

- **Agent or workflow:** {who loads it}
- **Trigger:** {when it should be loaded}
- **Expected outcome:** {what it enables}

## Core Knowledge

<!-- INSTRUCTIONS: Put the durable workflow, protocol, decision table, checklist, or reference content here. -->

{primary skill content}

<!-- INSTRUCTIONS: Insert optional domain-specific sections here, between `## Core Knowledge` and `## Examples`. -->
<!-- INSTRUCTIONS: Examples include routing tables, cost models, protocol phases, security checklists, or glossary sections. -->

## Examples

<!-- INSTRUCTIONS: Provide concrete examples of invocation, output shape, or decision patterns. -->

### Example: {scenario}

{example content}

## References

<!-- INSTRUCTIONS: Link related files, instructions, guides, or external documentation that readers should consult. -->

- `{path-or-url}` — {why it matters}
````

## Notes for normalizing existing skills

- Keep `## Description`, `## When to Use`, `## Entry Points`, `## Core Knowledge`, `## Examples`, and `## References` in that order.
- Move bulky reference material into bundled assets only when it materially reduces noise in `SKILL.md`.
- If a skill is narrow and self-explanatory, keep examples short rather than padding the file.
- Use `### When NOT to Use` inside `## When to Use`; that guidance is required, not optional.

## Related references

- [Agent standard template](./agent-standard.md)
- [Workspace guidance](../../AGENTS.md)
- [VS Code agent skills documentation](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
