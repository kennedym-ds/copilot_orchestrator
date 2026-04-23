# ADR: Scriptless Skills Architecture

**Date:** 2026-04-23
**Status:** Accepted
**Closes:** F22, F24 (SOTA alignment 2026-04-22)

---

## Context

The `.github/skills/` directory contains 12 SKILL.md files providing reusable capability overlays for agents. During the 2026-04-22 SOTA gap analysis, an external review assumed each skill directory would contain runnable scripts (`.ps1` or `.sh`). Filesystem inspection confirmed 0 scripts exist across all 12 skill directories.

## Decision

Skills in this repository are **pure Markdown instruction overlays** — no executable scripts. Each SKILL.md declares `name`, `description`, `user-invocable`, and `argument-hint` frontmatter and contains prose instructions that agents read and follow.

## Rationale

1. **Separation of concerns:** Runnable automation belongs in `scripts/hooks/` (lifecycle events) and `scripts/mcp/` (tool servers). Skills are advisory, not imperative.
2. **Agent-interpreted, not machine-executed:** Skill content is injected into agent context. Agents interpret and apply the guidance; there is no runtime invocation.
3. **Simpler maintenance:** Pure Markdown skills can be updated without testing a script execution environment. No shebang lines, no permission bits, no OS-specific paths.
4. **Compatibility with vercel-labs/skills standard:** The upstream skills ecosystem (`SKILL.md` format) treats skills as documentation overlays consumed by LLM agents, not shell scripts.

## Consequences

- Contributors must not add `.ps1` or `.sh` files to `.github/skills/` subdirectories. Any automation should go in `scripts/hooks/` or `scripts/mcp/`.
- The validator (`scripts/validate-copilot-assets.ps1`) does not check for script files in skills directories; this is intentional.
- External reviewers may flag the absence of scripts as incomplete. This ADR is the authoritative explanation.

## Alternatives Considered

- **Script per skill:** Rejected. Would require defining a call convention, handling errors, and maintaining cross-platform compatibility for 12 skills with no clear benefit.
- **Hybrid (scripts optional):** Rejected. Inconsistency would confuse contributors about when scripts are appropriate.
