---
version: 1.0.0
date: 2026-04-22
status: accepted
gaps_closed: [G28]
---

# ADR — `chatLanguageModels.json` Workspace Config

## Status

**Defer — extended**, 2026-04-23. VS Code 1.116 (Apr 15) and 1.117 (Apr 22) both shipped without promoting `chatLanguageModels.json` to stable. The schema is not announced as GA in either release. Deferral continues; next review trigger: first release that explicitly marks the feature GA or deprecates frontmatter `model:` arrays.

## Context

VS Code 1.114 preview added `chatLanguageModels.json` — a workspace-level registry that declares which language models are available for chat. It solves a real problem: today each agent embeds its `model:` fallback array in frontmatter, and there is no single place to gate models per workspace (e.g., "this repo only uses Opus + Sonnet + Haiku").

## Decision

Defer adoption until 1.116 GA. Our current `model:` array + `thinkingEffort:` hint pattern is working; no acute pain point forces the move now.

## Rationale

### Why defer

1. **Still preview.** The schema has changed twice in the 1.114 preview cycle. Locking 16 agents onto a preview schema buys instability.
2. **Duplication, not contradiction.** `chatLanguageModels.json` and `model:` arrays are complementary: the workspace registry *gates* what's usable, the per-agent array *prefers* within that set. We can adopt it later without breaking existing agents.
3. **Branch model conflict.** Our fallback arrays encode *deprecation strategy* — first-choice primary, graceful degradation. The workspace registry doesn't express "fall back to X if Y unavailable" today.
4. **Low actual value in single-user workspace.** The primary benefit is *org-level* model governance. A single-user enterprise repo gets marginal value.

### When to revisit

- 1.116 GA ships with stable schema
- Schema supports per-model `disabled:` and fallback ordering
- Or: a second contributor needs workspace-wide model constraints
- Or: security review mandates pinned models (today's prompt-level Opus pin in `security-review.prompt.md` is sufficient)

## Consequences

**Positive:**
- No churn against a moving target
- Existing 16-agent fallback arrays keep working unchanged
- Security mode's prompt-level override stays authoritative

**Negative:**
- If VS Code deprecates frontmatter `model:` in favor of `chatLanguageModels.json`, we're behind
- Mitigation: Phase 5 row 5.4 (research refresh) will catch any deprecation within two release cycles

## Alternatives Considered

1. **Adopt now, ship minimal config** — rejected; preview schema churn
2. **Partial adoption (security review only)** — rejected; prompt-level override already achieves this without config surface
3. **Adopt the 1.114 schema, pin to it** — rejected; no escape hatch if 1.115 breaks it

## Related

- Gap: G28
- Plan: `artifacts/plans/close-all-gaps/plan.md` row 3.7
- Revisit: Phase 5 row 5.4