---
title: "Agent standard template"
version: "1.0.0"
lastUpdated: "2026-03-10"
status: "active"
reviewOwners:
  - "Copilot Orchestrator maintainers"
aiAssistance: "Drafted with GitHub Copilot and intended for review with Pester plus validate-copilot-assets.ps1."
---

# Agent standard template

Canonical reference for normalizing `.github/agents/*.agent.md` in Phases 2-4 of the [Agent & Skill Quality Review spec](../../artifacts/specs/agent-skill-quality-review/spec.md) and the approved [action plan](../../artifacts/plans/2026-agent-skill-quality-action-plan/plan.md). Use this template to standardize durable structure without flattening role-specific intent.

## Required frontmatter

| Key | Required | Notes |
|-----|----------|-------|
| `name` | Yes | Folder/file identity used by routing and discovery |
| `description` | Yes | One-line purpose with clear activation language |
| `argument-hint` | Yes | What the user should provide when invoking the agent |
| `model` | Yes | Primary model or fallback list |
| `tools` | Yes | Minimum viable tool list for the role |
| `agents` | No | Allowlist for subagent delegation |
| `user-invokable` | No | Set `false` for subagent-only personas |
| `disable-model-invocation` | No | Restrict autonomous invocation when needed |
| `mcp-servers` | No | MCP server bindings when justified |
| `handoffs` | No | UI handoff buttons or structured handoff definitions |
| `hooks` | No | Agent-scoped hooks; document them in the body if present |

## Canonical template

````markdown
---
name: {agent-name}
description: "{one-line purpose}"
argument-hint: "{what the user should provide}"
model: 'Claude Haiku 4.5 (copilot)'
tools: [agent, read]

<!-- INSTRUCTIONS: Add optional frontmatter only when the role actually needs it. -->
agents: ['conductor', 'reviewer']
user-invokable: false
disable-model-invocation: true
mcp-servers:
  validation:
    type: stdio
    command: python
    args: ["scripts/mcp/validation_server.py"]
    tools: ["validate_assets"]
handoffs:
  - label: Return to Conductor
    agent: conductor
    prompt: "Summarize completed work and next steps."
    send: false
hooks:
  preResponse:
    - path: ".github/hooks/{agent-name}/pre-response.md"
---

# {Agent Name} — {Role Tagline}

Follow `instructions/workflows/{agent-workflow}.instructions.md`, `AGENTS.md`, and any relevant language/compliance instructions.

Follow the Zen of Engineering tenets from `instructions/global/00_behavior.instructions.md`. Keep recommendations simple, explicit, and auditable.

## Core Capabilities

<!-- INSTRUCTIONS: Use `## Core Capabilities` for core workflow or implementation-focused agents. -->
<!-- INSTRUCTIONS: Use `## Responsibilities` instead for support personas such as security, docs, or accessibility. Do not include both headings. -->

- **Capability or responsibility 1**: {what the agent does}
- **Capability or responsibility 2**: {what the agent does}
- **Capability or responsibility 3**: {what the agent does}

## Response Style

<!-- INSTRUCTIONS: Optional for simple agents. Required for agents whose output shape, verbosity, or tone needs explicit guardrails beyond the global persona. -->
<!-- INSTRUCTIONS: Every agent inherits the global persona from 00_behavior.instructions.md. This section adds role-specific refinements only. -->

- Lead with the answer or deliverable. Skip preamble, self-narration, and ceremonial filler.
- Be direct and concise. Match output length to task complexity — a small fix gets a short answer, a complex plan gets structured depth.
- No hype, no bullshit, no overselling. State trade-offs and limitations plainly. If you don't know, say so.
- {role-specific tone, structure, or output expectations}

## Workflow

1. {Step 1 — understand the request and gather context}
2. {Step 2 — analyze or execute role-specific work}
3. {Step 3 — validate, summarize, and recommend next action}

<!-- INSTRUCTIONS: Insert role-specific sections here, after `## Workflow` and before `## Output Contract`. -->
<!-- INSTRUCTIONS: Good examples from current agents include `## State Tracking`, `## Example Routing`, `## Example Interaction Patterns`, `## Execution Rules`, `## Project Knowledge`, and `## Handoff Package`. -->

## Output Contract

<!-- INSTRUCTIONS: Required for every agent. State exactly what the agent produces and how success is judged. -->

| Artifact | Format | Location | Success Criteria |
|----------|--------|----------|-----------------|
| {artifact-name} | {markdown/json/checklist/etc.} | {path or "inline response"} | {how a reviewer knows it is complete} |

## Local Artifact Storage

<!-- INSTRUCTIONS: Keep this section when the agent creates or updates durable artifacts. If the agent produces inline-only output, omit this section. -->

- Store outputs in `artifacts/{folder}/` using the repository template or naming convention for this role.
- Reference the canonical template or artifact shape the agent must follow.

## Boundaries

- ✅ **Always do:** {required behaviors this agent must always perform}
- ⚠️ **Ask first:** {scope expansions, risky actions, or approvals needed}
- 🚫 **Never do:** {actions this agent must not take}

## Delegation

<!-- INSTRUCTIONS: Required for every agent. Reference handoff schema IDs when applicable. -->

- Delegate with `#runSubagent {target-agent} "{objective and context}"` when work crosses role boundaries.
- Reference formal handoff schemas from `docs/guides/agent-handoff-schemas.md` when the workflow uses a defined contract (for example `HS-PLAN`, `HS-IMPL`, or `HS-RETURN`).
- State escalation conditions clearly so blocked work returns to the conductor or owning orchestrator.
````

## Notes for normalizing existing agents

- Preserve useful role-specific sections; only normalize section order and required visibility.
- Keep role-specific sections between `## Workflow` and `## Output Contract` unless a strong readability reason exists.
- `## Boundaries` and `## Delegation` are required on every agent.
- `## Response Style` is optional for narrowly scoped agents that can rely on the global persona alone.
- If hooks are declared in frontmatter, document their purpose and safety constraints in the agent body.

## Related references

- [Skill standard template](./skill-standard.md)
- [Agent hooks standard](../guides/agent-hooks-standard.md)
- [Agent handoff schemas](../guides/agent-handoff-schemas.md)
- [Workspace guidance](../../AGENTS.md)
