---
description: "Artifact storage conventions — naming, templates, JSONL schema, retention, and activeContext discipline."
applyTo: "artifacts/**"
version: "1.0.0"
lastUpdated: "2026-04-23"
---

# Artifact Standards

## Directory Map

```
artifacts/
├── plans/{feature}/          # Plan.md + per-phase completion records
├── reviews/{feature}/        # Reviewer findings
├── research/{slug}.md        # Research briefs with citations
├── decisions/DEC-{slug}.md   # ADRs — permanent, git-tracked
├── sessions/                 # Session state (team-state.json, hooks JSONL)
├── sessions/hooks/           # Per-event hook JSONL streams
├── sessions/snapshots/       # Pre-compact context snapshots
└── memory/activeContext.md   # Live session context — updated at every pause
```

Initialize with: `pwsh -File scripts/init-artifacts.ps1`

## Templates

Always use the provided templates — do not create artifact files freehand:

| Artifact type | Template | Save to |
|--------------|----------|---------|
| Implementation plan | `docs/templates/plan.md` | `artifacts/plans/{feature}/plan.md` |
| Phase completion | `docs/templates/phase-complete.md` | `artifacts/plans/{feature}/phase-{N}-complete.md` |
| Plan completion | `docs/templates/plan-complete.md` | `artifacts/plans/{feature}/plan-complete.md` |
| Decision / ADR | `docs/templates/decision.md` | `artifacts/decisions/DEC-{slug}.md` |

## Naming Conventions

- **Feature slugs**: kebab-case, date-prefixed for plans: `2026-04-23-auth-refactor`
- **Phase records**: `phase-1-complete.md`, `phase-2-complete.md` (numeric, no zero-padding gaps)
- **Research**: `{topic}-{date}.md` e.g. `hook-format-2026-04-23.md`
- **Decisions**: `DEC-{topic}.md` e.g. `DEC-scriptless-skills.md` — short, noun-only slug

## JSONL Standards

All hook event streams and session records use JSONL (one JSON object per line):

- UTF-8 encoding, no BOM
- One JSON object per line, no trailing comma
- Required fields: `event` (PascalCase), `ts` (ISO 8601)
- Append-only — never mutate existing records
- `hooks-errors.jsonl` is legacy; new error streams go to `{EventName}.jsonl`

Example well-formed record:
```jsonl
{"event":"SubagentStart","ts":"2026-04-23T10:00:00.000Z","session_id":"sess-abc-123","parent":"conductor","child":"implementer","depth":1,"allowed":true}
```

## `activeContext.md` Discipline

`artifacts/memory/activeContext.md` must be updated at every conductor pause point with:
- **Current phase** and progress
- **Last decision** (what was approved or rejected)
- **Open questions** (blocking the next phase)
- **Files modified** (list with brief description)
- **Next action** (what the next agent should do)

This file is the handoff contract between sessions. A stale or empty `activeContext.md` forces the next session to re-derive context from git history — wasteful and error-prone.

## Retention

| Type | Retention | Deletion policy |
|------|-----------|-----------------|
| Decisions (`artifacts/decisions/`) | Permanent | Never delete; write a superseding ADR |
| Plans, reviews, research | 30 days from last touch | Manual or via `scripts/cleanup-artifacts.ps1` |
| Sessions, hooks | 7 days | Auto-cleaned by session init |
| Snapshots | 3 days | Auto-cleaned by session init |
