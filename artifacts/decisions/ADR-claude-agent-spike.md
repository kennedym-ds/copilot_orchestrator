---
version: 1.0.0
date: 2026-04-22
status: accepted
gaps_closed: [G29]
recommendation: reject
---

# ADR — Claude Agent Session Type Evaluation (Spike 4.3)

## Status

**Reject**, 2026-04-22. Our conductor pattern is a superset of Claude Agent sessions.

## Context

Gap G29 asked whether Anthropic's "Claude Agent" session type (a first-party, hosted agent-session API) should replace, complement, or be rejected relative to our conductor.

## Findings

### What Claude Agent provides

- Hosted session runtime with built-in tool-use, memory, and turn management
- First-party via `anthropic.agents.sessions` SDK
- Cross-conversation memory (similar to Copilot Memory)
- No orchestration primitives — a session is a single agent, not a multi-agent pipeline

### Feature comparison

| Capability | Claude Agent session | Our conductor |
|-----------|----------------------|---------------|
| Single-agent tool-use loop | Built-in | Via Copilot chat |
| Multi-agent delegation (planner → implementer → reviewer) | No | Yes |
| Complexity-tier routing (INSTANT/STANDARD/DEEP/ULTRA) | No | Yes |
| Pause points for human approval | No | Yes |
| Budget gatekeeping | No | Yes (skill: budget-gatekeeper) |
| Confidence-scoring for review findings | No | Yes (skill: confidence-scoring) |
| Works in VS Code Chat, Copilot CLI, Agents app | Partial | Yes |
| Vendor lock-in | Anthropic API only | Multi-model (Copilot chooses from fallback array) |

### Where Claude Agent could complement

Only one scenario survives scrutiny: a dedicated long-running "research" session that spans days and benefits from the session API's persistent memory. But we already get this via Copilot Memory + `artifacts/research/*` ADRs — no net win.

## Decision

**Reject.** Adopting Claude Agent would:
1. Lock the conductor to a single vendor (Anthropic)
2. Lose multi-agent delegation (the primary differentiator)
3. Lose complexity-tier routing and confidence scoring (both depend on multi-agent)
4. Duplicate session-memory with Copilot Memory (already chosen in ADR-memory-layers)

## What we keep

- Current conductor design (multi-agent, tier-routed, budget-gated)
- Copilot Memory as the single cross-session layer (ADR-memory-layers)
- Model fallback arrays to preserve multi-vendor flexibility

## When to revisit

- Anthropic exposes multi-agent orchestration primitives in the Agent API
- Copilot ceases to support Claude models (would force vendor diversification)
- A specific workflow emerges that genuinely needs Anthropic-hosted session state that our setup cannot replicate

## Consequences

**Positive:**
- No churn; preserves multi-model strategy
- Preserves the "Senior Principal Engineer" orchestrator semantics (our differentiator)
- No new vendor dependency

**Negative:**
- If Anthropic ships multi-agent orchestration in 2027, we evaluate again

## Related

- Gap: G29
- Plan row: 4.3
- Depends on: ADR-memory-layers.md (memory layer decision)