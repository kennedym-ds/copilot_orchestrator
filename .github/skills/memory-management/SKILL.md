---
name: memory-management
description: "Memory lifecycle patterns for artifact retention, decision recording, context compaction, and Copilot Memory hygiene. Use for session context management, ADR creation, and rolloff strategies."
---

# Memory Management

Teaches agents how to manage institutional memory across sessions -- recording decisions, maintaining context, compacting artifacts, and using Copilot Memory effectively.

## Description

This skill covers the full memory lifecycle: what to remember, where to store it, when to compact or forget it, and how to read it back efficiently. It bridges three memory layers: Copilot Memory (cross-session facts), artifact storage (structured documents), and session context (active working memory).

## When to Use

- Starting a new session (read-back phase)
- Making architectural or design decisions
- Completing a plan phase or review cycle
- Running artifact cleanup or compaction
- Storing or refreshing Copilot Memory facts
- Context window approaching capacity

### When NOT to Use

- Do not use for runtime budget enforcement — use the `budget-gatekeeper` skill instead.
- Do not use for code-level implementation details or transient debugging state that will not be relevant next session.

## Entry Points

**Trigger Phrases:** "record this decision", "what did we decide", "clean up artifacts", "memory budget", "active context"

**Context Patterns:** Session start, plan approval, review completion, phase transitions, context overflow

## Core Knowledge

### Three Memory Layers

| Layer | Scope | TTL | Owner | Read Pattern |
|-------|-------|-----|-------|--------------|
| **Copilot Memory** | Cross-session facts | Until replaced/forgotten | All agents | Auto-injected at session start |
| **Artifact Storage** | Structured documents | Tier-based (14d/90d/forever) | Producing agent | Read via artifact-index.md |
| **Session Context** | Current working state | Session only | Conductor | activeContext.md |

### Memory Routing: Centralized vs. Per-Repo

The system operates on two physical tiers:

- **Copilot Memory** = centralized. Cross-repo, auto-injected into every session. Stores durable facts that help in any repo.
- **`artifacts/`** = per-repo. Each consuming repository has its own isolated artifacts folder. Never shared across repos.

**Routing decision tree:**
1. Would this help in a different repo? -> Copilot Memory
2. Does it need rationale and alternatives? -> ADR in `artifacts/decisions/`
3. Tied to current work in this repo? -> `artifacts/` (appropriate subfolder)
4. Irrelevant next week? -> `activeContext.md` or skip

**Cross-repo pattern:** When a convention applies everywhere, store a short fact in Copilot Memory (centralized) AND record the full ADR in the originating repo's `artifacts/decisions/` (per-repo). The memory propagates automatically; the ADR preserves the reasoning.

### Retention Tiers

| Tier | Default TTL | Rolloff Action | Examples |
|------|-------------|----------------|----------|
| **Permanent** | Never | Never archived | ADRs, compliance audits, architecture decisions |
| **Seasonal** | 90 days | Compact at 75% TTL, archive at 100% | Plans, research briefs, reviews |
| **Ephemeral** | 14 days | Delete at 100% TTL | Session logs, activeContext.md, debug traces |

Set tier via YAML frontmatter:
```yaml
---
retention: seasonal
ttl-days: 90
---
```

### Decision Recording

When to create an ADR:
- Architecture pattern chosen (e.g., "use event-driven over polling")
- Technology selection (e.g., "chose PostgreSQL over DynamoDB")
- Convention established (e.g., "all agents use model fallback arrays")
- Trade-off resolved (e.g., "accepted eventual consistency for performance")

When NOT to create an ADR:
- Code-level implementation detail (function names, import paths)
- Bug fix with no design implications
- Formatting or style change

Template: `docs/templates/decision.md`
Storage: `artifacts/decisions/DEC-{NNN}-{slug}.md`

### Session Read-Back Protocol

At session start, the Conductor reads:
1. `artifacts/artifact-index.md` -- inventory of all active artifacts
2. `artifacts/memory/activeContext.md` -- current focus, recent decisions, open questions

Budget: Combined read-back should stay under 10K tokens. If the index is large, read only sections relevant to the current task.

### Session Write-Back Protocol

At session end or major pause points, update `artifacts/memory/activeContext.md`:
```markdown
## Current Focus
{What we're working on}

## Recent Decisions
- DEC-042: Chose hybrid rolloff strategy
- DEC-043: Set 10K token memory budget

## Open Questions
- Should cleanup run automatically on session start?

## Active Plan
memory-management / Phase 4 of 5
```

### Artifact Compaction

When artifacts approach 75% of their TTL, the cleanup script generates a `.compact.md` stub:
- Contains key findings (max 5 bullets), decisions made, outcome summary
- Links to the full artifact for deep dives
- Agents should prefer reading `.compact.md` over full artifacts when only a summary is needed

Run compaction: `powershell -File scripts/cleanup-artifacts.ps1`
Preview only: `powershell -File scripts/cleanup-artifacts.ps1 -DryRun`

### Copilot Memory Rules

**Store** when the fact is:
- A durable convention (naming patterns, shell commands, model tiers)
- Not discoverable from limited code (e.g., "use `powershell` not `pwsh`")
- Actionable for future tasks (build commands, test patterns)
- Independent of in-flight work

**Skip** when the fact is:
- Obvious from reading the code
- Transient (branch names, session IDs)
- Already in instructions or AGENTS.md
- Contains secrets or PII

**Refresh** -- re-store a memory you use and verify, to extend its retention.

### Context Window Discipline

1. **Never bulk-read artifacts** -- use the index to identify what's relevant, then read selectively
2. **Prefer compacted versions** -- `.compact.md` over full artifacts for summaries
3. **Progressive disclosure** -- start with index, drill into specific artifacts as needed
4. **Phase splitting** -- when context grows, split work into smaller phases with artifact handoffs
5. **Decision-first reading** -- read ADRs before code to avoid re-debating settled choices

### Wiki Knowledge Base (Karpathy Pattern)

Beyond `activeContext.md` (session-scoped), agents maintain a **wiki** — a set of topic-organized living documents in `artifacts/memory/wiki/`. The wiki is the agent's institutional memory: facts discovered during work, curated and refined over time.

**Wiki pages:**

| Page | Purpose | Update Trigger |
|------|---------|----------------|
| `codebase-patterns.md` | Discovered conventions, architecture patterns, file organization | After implementation or review |
| `build-and-test.md` | Verified build commands, test commands, CI quirks | After running build/test successfully |
| `lessons-learned.md` | Mistakes made, fixes found, reviewer catches | After review findings or debugging |
| `dependencies.md` | Key dependency notes, version constraints, known issues | After dependency changes |
| `tooling.md` | Working tool configurations, MCP servers, editor settings | After tool discovery or setup |

**Wiki rules:**

1. **Append, don't rewrite** — add new facts to the relevant page. Remove only when a fact is verified stale.
2. **One fact per bullet** — keep entries scannable. No paragraphs.
3. **Date-stamp entries** — `- [2026-04-16] PowerShell 5.1 requires semicolons, not && for chaining`
4. **Max 50 lines per page** — if a page exceeds 50 lines, prune the oldest/least-useful entries.
5. **Read wiki at session start** — after `activeContext.md`, scan wiki pages relevant to the current task.
6. **Write wiki after verification** — only store facts that have been verified through tool execution, not assumed.

**Wiki vs. Copilot Memory:**
- Wiki = per-repo, detailed, living — "PowerShell tests use `Invoke-Pester -Path tests -Output Detailed`"
- Copilot Memory = cross-repo, durable conventions — "Always use model fallback arrays"

**Initialization:** `pwsh -File scripts/init-artifacts.ps1` creates the wiki folder with empty starter pages.

## Examples

### Pattern: New Decision

```
1. Identify the decision point during planning/review
2. Create ADR: artifacts/decisions/DEC-{NNN}-{slug}.md
3. Set retention: permanent (architecture) or seasonal (tactical)
4. Reference DEC-ID in the plan/review artifact
5. Update activeContext.md with the decision summary
6. Store in Copilot Memory if it's a durable convention
```

### Pattern: Session Resume

```
1. Read artifacts/artifact-index.md (scan for relevant sections)
2. Read artifacts/memory/activeContext.md (full)
3. Check Copilot Memory for relevant stored facts
4. Identify current phase and pending work
5. Proceed with implementation
```

### Pattern: Artifact Cleanup

```
1. Run: powershell -File scripts/cleanup-artifacts.ps1 -DryRun
2. Review proposed actions (archive, delete, compact)
3. Run without -DryRun to execute
4. Verify artifact-index.md was regenerated
5. Spot-check any .compact.md stubs and refine summaries
```

## Boundaries

- Agents MUST set `retention` and `ttl-days` frontmatter on new artifacts
- Agents MUST NOT bulk-read all artifacts into context
- Agents SHOULD prefer `.compact.md` over full artifacts for non-current work
- Conductor MUST read-back activeContext.md at session start
- Conductor MUST write-back activeContext.md at session end
- Only `scripts/cleanup-artifacts.ps1` moves files to `.archive/` -- never move manually

## References

- `scripts/cleanup-artifacts.ps1` — artifact compaction, archival, and cleanup workflow
- `docs/templates/decision.md` — ADR template for recording durable decisions
- `.github/agents/conductor.agent.md` — session read-back and write-back responsibilities
- `artifacts/memory/activeContext.md` — active session context handoff document
