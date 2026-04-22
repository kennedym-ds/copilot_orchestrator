---
version: 1.0.0
date: 2026-04-22
status: accepted
---

# ADR — Agent Skills Pilot: Retire, Do Not Complete

## Status

Accepted, 2026-04-22.

## Context

An earlier experiment referenced two files that never shipped:
- `worktrees-ops/SKILL.md`
- `instructions/global/terminal-formatting.instructions.md`

The SOTA gap analysis (G21) flagged these as orphan references. Links were repaired on 2026-04-21 (commit `38f73ab`), but the pilot itself was never completed.

## Decision

**Retire the pilot.** The concepts it would have explored are better served by:

- Worktrees ops -> folded into the `git-operations` and future `worktree-integration` skills once VS Code 1.109 native background agents are evaluated (gap G8 / G37)
- Terminal formatting -> superseded by the `documentation-style` skill and VS Code 1.113+ terminal output improvements

No new files will be created under `worktrees-ops/` or as `terminal-formatting.instructions.md`. Existing references have been removed.

## Consequences

- Clean documentation with no dead pointers
- The conceptual gap (session/branch forking discipline) is covered by [docs/guides/session-forking.md](../../docs/guides/session-forking.md)
- Future exploration of terminal formatting or worktree ops will open a fresh ADR, not resurrect this pilot

## Alternatives Considered

1. **Complete the pilot**: rejected — scope is no longer clear and newer native surfaces supersede the intent
2. **Leave references in place**: rejected — dead links violate documentation hygiene (see `instructions/compliance/documentation.instructions.md`)

## Related

- Source: `artifacts/research/copilot-sota-gap-analysis-2026-04-22.md` §4.4 G21
- Follow-up gap: G8 (session forking) closed by [../../docs/guides/session-forking.md](../../docs/guides/session-forking.md)