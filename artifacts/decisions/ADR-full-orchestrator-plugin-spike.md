---
version: 1.0.0
date: 2026-04-22
status: accepted
gaps_closed: [G34]
recommendation: defer
---

# ADR — Full Orchestrator as Copilot CLI Plugin (Spike 4.4)

## Status

**Defer**, 2026-04-22. Keep the MCP-server plugin pilot (Phase 3.5); do not package the whole orchestrator yet.

## Context

Gap G34 asked whether the entire orchestrator (agents + skills + prompts + instructions + MCP servers) should ship as a single `copilot plugins install kennedym-ds/orchestrator` package.

## Findings

### What Copilot CLI plugins can ship today

- MCP servers (proven in Phase 3.5 pilot — `plugins/analytics/`)
- Hooks (via YAML frontmatter in agent files)
- Commands (via prompt files)
- Tool configurations

### What they cannot ship (as of 2026-04)

- `AGENTS.md` (workspace convention, not plugin-distributable)
- `instructions/**` hierarchy (layered instruction files are not a CLI-plugin concept)
- `artifacts/**` workflow outputs (session-scoped by design)
- Cross-file validation scripts (PowerShell validators don't map to CLI plugin primitives)

### Prototype scope

A 2-day manifest prototype produced:
- `plugins/orchestrator/plugin.yaml` (draft — not committed)
- Discovery: ~60% of the orchestrator's value (AGENTS.md, instructions, skills, validator scripts) has no CLI plugin primitive. We would ship a plugin that installs *some* of the orchestrator and silently drops the rest.

### Confusion risk

Users installing the "orchestrator plugin" would get an incomplete orchestrator (no AGENTS.md convention, no layered instructions, no validator). They would file bug reports about missing features that are not bugs — they are CLI plugin limitations.

## Decision

**Defer.** The MCP-server-per-plugin pattern (Phase 3.5) is the correct granularity today. A monolithic orchestrator plugin would ship a degraded product.

## Alternative adopted

Continue the **per-MCP-server** plugin pattern:
- `plugins/analytics/` (pilot, Phase 3.5)
- If pilot graduates: `plugins/validation/`, `plugins/research/`, `plugins/translation/`, `plugins/design/`

The orchestrator itself stays as a "clone-and-use" workspace template (via `setup-vs-cli.ps1` / `setup-claude-code.ps1`).

## When to revisit

- Copilot CLI adds support for workspace-template plugins (AGENTS.md + instructions + validators as a bundle)
- OR: An equivalent primitive emerges (e.g., `copilot workspace install`)

## Consequences

**Positive:**
- No user confusion from partial orchestrator installs
- Continues the proven per-server granularity
- Keeps the workspace-template flow (setup scripts) as the canonical install

**Negative:**
- No single-command "install the whole orchestrator" experience
- Mitigation: `setup-vs-cli.ps1` + `setup-claude-code.ps1` already provide that in a single command each

## Related

- Gap: G34
- Plan row: 4.4
- Depends on: plugin pilot outcome (Phase 3.5)
- Revisit trigger: Copilot CLI workspace-template primitive