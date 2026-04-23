# ADR: Collections as Legacy Fallback

**Date:** 2026-04-23
**Status:** Accepted
**Closes:** F5 (SOTA alignment 2026-04-22)

---

## Context

The `.github/collections/` directory contains 3 YAML files:
- `orchestrator-core.collection.yaml`
- `support-personas.collection.yaml`
- `data-science.collection.yaml`

These were created before VS Code 1.110 introduced agent plugins as the canonical grouping mechanism. The 2026-04-22 SOTA gap analysis flagged them as potentially superseded with no active documentation.

## Decision

**Retain `.github/collections/` as a legacy fallback.** Do not delete. Do not migrate to agent plugins at this time.

## Rationale

1. **No confirmed breakage:** The collection files do not cause errors and may still be consumed by tooling that pre-dates agent plugins.
2. **Plugin migration cost unclear:** The 2026-04-22 SOTA plan includes a Phase 7 agent plugins spike (see `ADR-agent-plugins-go-no-go.md`) to evaluate migration cost before committing. Deleting collections before that evaluation would require recreating them if plugins prove unsuitable.
3. **Risk asymmetry:** Retaining unused YAML files costs nothing. Deleting them and discovering they were load-bearing for some surface (VS Code extension, Copilot CLI, CI) would require rollback.

## Consequences

- Collections are not actively maintained. If their YAML schema drifts from any consuming tooling, errors may surface.
- If Phase 7 concludes "go" on agent plugins, revisit and delete `.github/collections/` as part of the plugin migration.
- If Phase 7 concludes "no-go," document collections as the authoritative grouping mechanism and add them to the validator.

## Review Trigger

Re-evaluate this ADR after Phase 7 (agent plugins spike) completes.
