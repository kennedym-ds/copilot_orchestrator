---
version: 1.0.0
date: 2026-04-22
status: accepted
gaps_closed: [G32]
implements_in: phase-3 row 3.4
---

# ADR — Headless Conductor Behavior (`copilot chat -p`)

## Status

Accepted, 2026-04-22. Ratified by human operator.

## Context

`copilot chat -p "<prompt>"` runs non-interactively. Today the conductor's pause-point protocol assumes a human is present to approve plans and reviews. Running the conductor headlessly (CI, cron, file-watchers, git hooks) currently hangs on the first pause.

## Decision

The conductor detects headless mode (no TTY / `--print` flag / `COPILOT_HEADLESS=1` env var) and adopts a **degraded but deterministic** behavior:

| Complexity tier | Headless behavior |
|-----------------|-------------------|
| **INSTANT**     | Execute normally. No plan, no review. Same as interactive. |
| **STANDARD**    | **Auto-approve the inline plan** and proceed. Reviewer runs but findings are emitted as a report, not a block. Exit 0 on success; exit 10 on reviewer HIGH+ findings. |
| **DEEP**        | **Fail closed.** Emit the plan to stdout, exit 20 with message "headless DEEP requires human approval". No code changes written. |
| **ULTRADEEP**   | **Fail closed.** Same as DEEP. Exit 21. |
| **Security review** | Runs normally; never auto-proceeds. Exit 30 on BLOCKER findings. |

## Exit Code Scheme

| Code | Meaning |
|-----:|---------|
| 0 | Success |
| 10 | STANDARD completed with reviewer HIGH+ findings (code landed; findings reported) |
| 20 | DEEP refused — plan emitted, no changes written |
| 21 | ULTRADEEP refused — plan emitted, no changes written |
| 30 | Security review found BLOCKER — no commit, no push |
| 40 | Hook failure that hit `on_fail: escalate` |
| 50 | Timeout |
| 60 | Internal error (budget exceeded, model unavailable after fallbacks) |

## Environment Variables

| Variable | Purpose | Default |
|----------|---------|---------|
| `COPILOT_HEADLESS` | Force headless mode even on TTY | unset |
| `COPILOT_HEADLESS_MAX_TIER` | Upper tier conductor will execute (INSTANT, STANDARD, DEEP, ULTRADEEP) | STANDARD |
| `COPILOT_HEADLESS_NO_COMMIT` | If set, conductor runs but never commits — useful for CI dry-runs | unset |
| `COPILOT_HEADLESS_REVIEWER_MODE` | Override reviewer mode (standard, security, adversarial) | standard |

## Consequences

**Positive:**
- CI and git hooks can run INSTANT and STANDARD tasks autonomously
- Deterministic exit codes allow shell scripts to branch on outcome
- DEEP/ULTRA fail closed -> no silent high-risk changes
- Security review is never auto-approved -> safe default

**Negative:**
- STANDARD auto-approval means a bad plan ships if the reviewer misses it. Mitigation: exit 10 signals findings; caller must treat non-zero as needing human eyes
- Hook failures in headless mode have no user to escalate to — `on_fail: escalate` becomes `on_fail: abort` with exit 40
- Users may set `COPILOT_HEADLESS_MAX_TIER=DEEP` thinking they're permissive; document the security implications clearly in the CLI guide

## Alternatives Considered

1. **Auto-approve everything up to ULTRADEEP**: rejected — removes the pause-point discipline that is the orchestrator's differentiator
2. **Fail closed on all non-INSTANT**: rejected — too restrictive; STANDARD is demonstrably safe for the conductor (one-agent implementation, single review)
3. **Require a `--approve-plan` flag per invocation**: rejected — breaks fire-and-forget CI use cases, which are the primary headless audience

## Implementation Checklist (Phase 3 row 3.4)

- [ ] Conductor detects headless mode (env var or no-TTY)
- [ ] Implement tier-to-behavior matrix above
- [ ] Emit structured exit codes (document in `docs/guides/copilot-cli-usage.md`)
- [ ] Add `examples:` block with headless one-liners to every agent frontmatter
- [ ] CI step in `.github/workflows/ci/validate.yml` runs reviewer headless on every PR (Phase 3 row 3.6)

## Related

- Gap: G32
- Source brief: §10 of `artifacts/research/copilot-sota-gap-analysis-2026-04-22.md`
- Consumer: `.github/workflows/ci/validate.yml` (Phase 3 row 3.6)