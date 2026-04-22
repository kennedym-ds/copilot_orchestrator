---
version: 1.0.0
date: 2026-04-22
status: accepted
gaps_closed: [G10, G37]
---

# ADR — Memory Layer Ownership: Migrate to Copilot Memory

## Status

Accepted, 2026-04-22. Ratified by human operator in conductor session.

## Context

Three memory surfaces exist today:

1. **Orchestrator filesystem memory**: `artifacts/memory/activeContext.md`, `artifacts/memory/wiki/` — git-ignored, written by conductor at pause points
2. **Copilot Memory** (official, 2026): persistent cross-session notes loaded into agent context automatically
3. **Copilot CLI cross-session memory** (February 2026): `--resume <session-id>`, transcript replay

Gap G10 flagged duplication between (1) and (2). Gap G37 flagged no documented relationship between (2) and (3).

## Decision

**Migrate active working context to Copilot Memory. Retire `artifacts/memory/activeContext.md` as a live state file.**

Split of responsibilities:

| Concern | Canonical source | Reason |
|---------|------------------|--------|
| Active working context (current objectives, open questions, next action) | **Copilot Memory** (`/memories/session/`) | Auto-loaded; user can inspect via memory tool; survives tool-use cycles |
| Cross-session learnings (patterns, pitfalls, repo-wide facts) | **Copilot Memory** (`/memories/` user + `/memories/repo/` repo) | Designed for this exact purpose |
| CLI transcripts (turn-by-turn) | **Copilot CLI `--resume`** | Native replay |
| Historical audit trail (committed plans, reviews, ADRs, research) | **`artifacts/` filesystem (git-tracked subset)** | Immutable provenance; grep-able; survives Copilot account loss |
| Ephemeral session state (in-flight JSON, token reports) | **`artifacts/sessions/`** (git-ignored) | Not audit-grade; 30-day TTL |

## Migration Plan

1. Stop writing `activeContext.md` from conductor pause-point hook (Phase 3 row 3.1 — implement as part of M4 hooks)
2. Replace with Copilot Memory write: `subject: "active-context"`, `fact: <snapshot>`, `category: "session"` under `/memories/session/`
3. Keep existing `artifacts/memory/activeContext.md` as read-only historical artifact; add deprecation banner
4. Update [AGENTS.md](../../AGENTS.md) "Artifact Storage" section to reflect the split
5. Update [.github/skills/memory-management/SKILL.md](../../.github/skills/memory-management/SKILL.md) to reference Copilot Memory as primary

## Consequences

**Positive:**
- Single live source for active context — no sync burden
- Copilot Memory is auto-loaded into every agent session without conductor relay
- CLI sessions inherit the same context via Copilot Memory (closes G37)
- `artifacts/` folder returns to its proper role: audit-grade history

**Negative / trade-offs:**
- Dependence on Copilot Memory availability (not filesystem-local)
- User must grant memory tool access to agents that read/write active context
- Historical `activeContext.md` snapshots must be preserved during the transition — Phase 3 keeps them as read-only

## Alternatives Considered

1. **Keep both surfaces (dual-write)**: rejected — doubles the sync cost and the source-of-truth ambiguity is the original gap
2. **Filesystem-only (retire Copilot Memory)**: rejected — loses the auto-load benefit and fights the platform
3. **Copilot Memory-only from day zero (no audit trail)**: rejected — loses the git-grep-able history that is the orchestrator's durability story

## Related

- Gap source: `artifacts/research/copilot-sota-gap-analysis-2026-04-22.md` G10, G37
- Implementation: Phase 3 of `artifacts/plans/close-all-gaps/plan.md` (row 3.1 + hook work in M4)
- Skill: [.github/skills/memory-management/SKILL.md](../../.github/skills/memory-management/SKILL.md) (to be updated)