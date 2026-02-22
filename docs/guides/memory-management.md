---
title: "Memory Management Guide"
version: "1.0.0"
lastUpdated: "2026-02-20"
status: stable
---

# Memory Management Guide

How agent memory works across sessions, how to record decisions, and how artifacts are retained, compacted, and archived.

---

## Overview

The orchestrator uses three memory layers to avoid "institutional amnesia" — the problem where each session starts fresh with no knowledge of prior decisions or context.

| Layer | What It Stores | Lifespan | Read Pattern |
|-------|---------------|----------|--------------|
| **Copilot Memory** | Durable facts (conventions, commands, model tiers) | Until replaced or forgotten | Auto-injected at session start |
| **Artifact Storage** | Structured documents (plans, reviews, ADRs) | Tier-based (14d / 90d / forever) | Via `artifact-index.md` |
| **Session Context** | Current focus, open questions, active plan | Single session | `memory/activeContext.md` |

---

## Memory Routing: Centralized vs. Per-Repo

The system has two physical tiers. Understanding which tier owns a fact prevents duplication and ensures the right information is available in the right context.

```
┌──────────────────────────────────────────────────────────┐
│          Centralized (Copilot Memory)            │
│  Cross-repo, cross-session, auto-injected        │
│  Org conventions, shell quirks, model tiers       │
└──────────────────────────────────────────────────────────┘
              │ Available in ALL repos
    ┌─────────┼───────────────────┐
    ▼                    ▼                    ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│   Repo A      │ │   Repo B      │ │   Repo C      │
│  artifacts/   │ │  artifacts/   │ │  artifacts/   │
│  decisions/   │ │  decisions/   │ │  decisions/   │
│  memory/      │ │  memory/      │ │  memory/      │
└───────────────┘ └───────────────┘ └───────────────┘
  Per-repo artifacts (isolated, never shared)
```

### Routing Rules

| Fact Type | Store In | Why |
|-----------|----------|-----|
| OS/shell quirks (e.g., `powershell` not `pwsh`) | Copilot Memory | Applies to all repos on this machine |
| Model tiers and fallback conventions | Copilot Memory | Org-wide standard, rarely changes |
| Agent frontmatter patterns | Copilot Memory | Org-wide convention |
| Verified build/test commands for a repo | Copilot Memory | Repo-specific but durable, useful cross-session |
| Architecture decisions for a repo | `artifacts/decisions/` | Needs full rationale, alternatives, consequences |
| Current plan progress | `artifacts/memory/activeContext.md` | Repo-specific, overwritten each session |
| Research findings for a feature | `artifacts/research/` | Repo-specific, seasonal retention |
| Review verdicts and findings | `artifacts/reviews/` | Repo-specific, tied to code changes |
| Session-specific debug context | `artifacts/sessions/` | Ephemeral, repo-scoped |

### Decision Rule

When deciding where to store a fact, ask:

1. **Would this help in a different repo?** -> Copilot Memory
2. **Does it need rationale and alternatives?** -> ADR in `artifacts/decisions/`
3. **Is it tied to current work in this repo?** -> `artifacts/` (appropriate subfolder)
4. **Will it be irrelevant next week?** -> `activeContext.md` or skip entirely

### Cross-Repo Consistency

Copilot Memory is the glue. When a convention is established in one repo and should apply everywhere:

1. Record the decision as an ADR in the originating repo's `artifacts/decisions/`
2. Store the convention as a Copilot Memory fact (short, actionable)
3. The memory is auto-injected everywhere -- no need to copy artifacts between repos

Existing Copilot Memory facts (visible in `repository_memories` at session start) already serve as the centralized store. Each repo's `artifacts/` folder is fully isolated -- agents never read another repo's artifacts.

---

## Quick Start

### 1. Initialize Artifacts

If the `artifacts/` folder doesn't exist yet:

```powershell
powershell -File scripts/init-artifacts.ps1
```

This creates 17 subfolders including `decisions/`, `memory/`, and `.archive/`.

### 2. Record a Decision

When a meaningful architectural or design decision is made:

1. Copy the template:
   ```
   docs/templates/decision.md → artifacts/decisions/DEC-001-{slug}.md
   ```
2. Fill in the frontmatter and body:
   ```yaml
   ---
   date: 2026-02-20
   status: proposed
   decision-id: DEC-001
   retention: permanent
   tags: [memory, architecture]
   superseded-by: null
   ---
   ```
3. Reference the DEC-ID in the related plan or review artifact.

### 3. Run Cleanup

Preview what would happen:

```powershell
powershell -File scripts/cleanup-artifacts.ps1 -DryRun
```

Execute for real (moves/deletes files, regenerates index):

```powershell
powershell -File scripts/cleanup-artifacts.ps1
```

---

## Retention Tiers

Every artifact should include `retention` and `ttl-days` in its YAML frontmatter. If missing, the cleanup script defaults to `seasonal` / `90 days`.

| Tier | Default TTL | At 75% TTL | At 100% TTL | Use For |
|------|-------------|------------|-------------|---------|
| **Permanent** | Never | No action | No action | ADRs, compliance audits, architecture decisions |
| **Seasonal** | 90 days | Auto-compact (`.compact.md`) | Move to `.archive/` | Plans, research briefs, review verdicts |
| **Ephemeral** | 14 days | No action | Delete | Session logs, `activeContext.md`, debug traces |

### Setting Retention

Add to any artifact's YAML frontmatter:

```yaml
---
retention: seasonal
ttl-days: 90
---
```

Override the default TTL with `ttl-days`. For example, a research brief you want to keep for 6 months:

```yaml
---
retention: seasonal
ttl-days: 180
---
```

---

## Session Read-Back

At the start of every Conductor session, these files are read to restore context:

1. **`artifacts/artifact-index.md`** — Inventory of all active artifacts with their retention tier and age
2. **`artifacts/memory/activeContext.md`** — Current focus, recent decisions, open questions, active plan

### Budget Rule

Combined read-back should stay under **10K tokens**. If the index is large, read only sections relevant to the current task. Never bulk-read all artifacts into context.

---

## Session Write-Back

At the end of every session (or at major pause points), the Conductor updates `artifacts/memory/activeContext.md`:

```markdown
## Current Focus
Implementing memory management system with rolloff and compaction.

## Recent Decisions
- DEC-042: Chose hybrid rolloff strategy (time-based + explicit pins)
- DEC-043: Set 10K token memory budget cap at session start
- DEC-044: Three retention tiers — permanent, seasonal, ephemeral

## Open Questions
- Should cleanup run automatically at session start?
- What threshold triggers compaction for the index file itself?

## Active Plan
memory-management / Phase 5 of 5
```

This file is `ephemeral` (TTL: 7 days) — it's meant to be overwritten each session.

---

## Artifact Compaction

When a seasonal artifact reaches 75% of its TTL, the cleanup script generates a `.compact.md` stub alongside the original:

```
artifacts/research/topic-slug.md           ← Full artifact
artifacts/research/topic-slug.compact.md   ← Compacted summary
```

The compact file contains:
- Key findings (max 5 bullets)
- Decisions made (DEC-IDs)
- Outcome summary (1 sentence)
- Link to the full artifact

**Agents should prefer reading `.compact.md` over the full artifact** when only a summary is needed. This keeps context windows lean.

### Compact Template

Use `docs/templates/compact.md` as the structure. The cleanup script auto-generates a stub, but agents should refine it with actual summaries.

---

## Decision Records (ADRs)

Architectural Decision Records capture the "why" behind choices. They prevent re-debating settled decisions across sessions.

### When to Create an ADR

| Create | Skip |
|--------|------|
| Architecture pattern chosen | Code-level implementation detail |
| Technology selection | Bug fix with no design impact |
| Convention established | Formatting or style change |
| Trade-off resolved | Temporary workaround |

### ADR Template

Located at `docs/templates/decision.md`. Key sections:

- **Context** — What problem required a decision
- **Decision** — What was decided
- **Rationale** — Why this option over alternatives
- **Alternatives Considered** — ALT-001, ALT-002, etc.
- **Consequences** — POS-001 (positive), NEG-001 (negative)
- **Scope** — Which agents, files, or systems are affected

### ADR Lifecycle

```
proposed → accepted → deprecated → superseded
```

When a decision is replaced, set `superseded-by: DEC-{NNN}` in the old ADR and `status: accepted` in the new one. Agents skip superseded decisions when reading back.

---

## Cleanup Script Reference

`scripts/cleanup-artifacts.ps1` handles rolloff, compaction, and index regeneration.

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-RepositoryRoot` | string | Current directory | Path to the repo root |
| `-DryRun` | switch | Off | Preview changes without modifying files |
| `-Force` | switch | Off | Skip confirmation prompts |

### What It Does

1. **Scans** all `.md` files in `artifacts/` (excluding `.archive/`, `README.md`, `artifact-index.md`, `*.compact.md`)
2. **Parses** YAML frontmatter for `retention`, `ttl-days`, and `date`
3. **Skips** files with no parseable date or `retention: permanent`
4. **Deletes** ephemeral artifacts past TTL
5. **Archives** seasonal artifacts past TTL (moves to `.archive/`)
6. **Compacts** seasonal artifacts at 75% TTL (creates `.compact.md` stub)
7. **Rebuilds** `artifact-index.md` from all remaining active artifacts

### Output Codes

| Code | Meaning |
|------|---------|
| `[SKIP]` | No parseable date — can't determine age |
| `[PERM]` | Permanent retention — untouched |
| `[OK]` | Active, within TTL |
| `[CMP]` | Compacted — `.compact.md` generated |
| `[ARC]` | Archived — moved to `.archive/` |
| `[DEL]` | Deleted — ephemeral past TTL |

### Example Output

```
=== Artifact Cleanup ===
Scanning: C:\Projects\my-app\artifacts
[DRY RUN] No files will be modified.

  [PERM] DEC-001-hybrid-rolloff.md -- permanent, age 30d
  [OK]   activeContext.md -- ephemeral, age 2d / TTL 7d
  [CMP]  old-research-brief.md -- age 70d >= 67d [75pct of 90d], compacting
  [ARC]  expired-plan.md -- seasonal, age 95d > TTL 90d -> .archive/

--- Rebuilding artifact-index.md ---
[DRY RUN] Would write index to: artifacts/artifact-index.md

=== Summary ===
  Scanned:   12
  Skipped:   3
  Archived:  1
  Deleted:   0
  Compacted: 1
  Errors:    0
```

---

## Copilot Memory Hygiene

Copilot Memory stores cross-session facts that are auto-injected into every conversation. Use it wisely.

### Store

- Durable conventions unlikely to change (`"use powershell not pwsh on this machine"`)
- Facts not discoverable from a limited code sample (`"model tiers: Premium, Execution, Routine"`)
- Verified build/test commands (`"powershell -File scripts/run-lint.ps1 -RepositoryRoot ."`)
- Architectural constraints (`"all agents use model fallback arrays"`)

### Skip

- Facts obvious from reading the code (function signatures, import paths)
- Transient info (current branch, today's error count, session-specific context)
- Anything already in `instructions/` or `AGENTS.md`
- Secrets, tokens, or PII — never store these

### Refresh

When you use a stored memory and verify it's still accurate, re-store it. Only recent memories are retained; refreshing extends the retention window.

---

## Folder Structure

After initialization, the artifacts folder contains:

```
artifacts/
├── plans/              # Implementation plans
├── reviews/            # Code review verdicts
├── research/           # Research briefs
├── security/           # Security audits
├── sessions/           # Session state (JSON)
├── performance/        # Performance reports
├── docs/               # Documentation drafts
├── releases/           # Release notes
├── telemetry/          # Telemetry analysis
├── deployments/        # Deployment plans
├── red-team/           # Adversarial analysis
├── accessibility/      # WCAG audits
├── tests/              # Test reports
├── ux/                 # UX reviews
├── decisions/          # Architectural Decision Records
├── memory/             # Active context (activeContext.md)
│   └── activeContext.md
├── artifact-index.md   # Auto-generated inventory
├── .archive/           # Rolled-off artifacts
├── .gitignore
└── README.md
```

---

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Plans | `plans/{feature-slug}/plan.md` | `plans/auth-oauth2/plan.md` |
| Phase records | `plans/{feature-slug}/phase-N-complete.md` | `plans/auth-oauth2/phase-1-complete.md` |
| Decisions | `decisions/DEC-{NNN}-{slug}.md` | `decisions/DEC-042-hybrid-rolloff.md` |
| Reviews | `reviews/{YYYY-MM-DD}-{slug}.md` | `reviews/2026-02-20-memory-system.md` |
| Research | `research/{topic-slug}.md` | `research/copilot-memory-management-2026.md` |
| Compacted | `{folder}/{filename}.compact.md` | `research/old-brief.compact.md` |
| Active context | `memory/activeContext.md` | Always this exact path |

---

## Troubleshooting

### "No parseable date" for most artifacts

Existing artifacts created before the memory system may lack `date:` in their YAML frontmatter. Add frontmatter to track them:

```yaml
---
date: 2026-02-15
retention: seasonal
ttl-days: 90
---
```

### Cleanup script encoding errors on Windows

The script uses `--` (double dash) instead of em dashes to avoid PowerShell 5.1 encoding issues where UTF-8 em dashes are misread as smart quotes. If you see parse errors, ensure the file is saved as UTF-8 without BOM.

### Artifact index is empty after cleanup

This happens when no artifacts have parseable `date:` frontmatter. The index still lists all files — they just show `age: ?` in the inventory.

### Context window growing too large

1. Run `cleanup-artifacts.ps1` to compact old artifacts
2. Read `.compact.md` files instead of full artifacts
3. Use `artifact-index.md` to find relevant artifacts — don't read everything
4. Split large phases into smaller ones with artifact handoffs

---

## Related Documentation

| Document | Purpose |
|----------|---------|
| `AGENTS.md` | Agent roster, memory lifecycle overview |
| `.github/skills/memory-management/SKILL.md` | Skill file teaching agents memory patterns |
| `instructions/global/00_behavior.instructions.md` | Memory hygiene rules in behavior section |
| `instructions/workflows/escalation-patterns.instructions.md` | Context overflow prevention with compaction |
| `docs/templates/decision.md` | ADR template |
| `docs/templates/compact.md` | Compaction template |
| `scripts/cleanup-artifacts.ps1` | Cleanup script source |
