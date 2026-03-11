---
name: budget-gatekeeper
description: "Runtime budget enforcement for conductor workflows. Tracks model tier usage, delegation count, and estimated token cost across phases. Provides soft/hard limits with escalation patterns to prevent runaway sessions."
---

# Budget Gatekeeper

Provides runtime budget enforcement patterns for conductor workflows, tracking model tier allocation, delegation count, and estimated token cost to prevent runaway sessions.

## Description

This skill teaches the conductor and delegating agents how to monitor and enforce session budgets in real time. Inspired by Athena's BudgetGatekeeper pattern, it adapts the concept to our multi-agent orchestration model — where the "cost" is distributed across 29 specialized agents using a 3-tier model allocation.

Unlike our existing `token-thresholds.json` (which enforces file-level token limits at validation time), this skill provides **runtime session-level enforcement** during active conductor workflows.

## When to Use

This skill is relevant when:
- Conductor is orchestrating a multi-phase workflow with 3+ phases
- Multiple premium-tier agents are being invoked in sequence
- A workflow involves parallel subagent tracks (ULTRADEEP complexity)
- Session has been running for an extended period (15+ minutes)
- User requests cost-aware execution ("keep this lean", "minimize API usage")

### When NOT to Use

- Do not use for single-turn questions or instant-complexity tasks that complete in one delegation.
- Do not use for static file-level token enforcement — that is handled by `token-thresholds.json` and `scripts/token-report.ps1`.

## Entry Points

### Trigger Phrases
- "budget check", "cost estimate", "token usage"
- "keep this lean", "minimize cost", "efficient execution"
- "how many delegations", "session cost"

### Context Patterns
- Multi-phase workflows with 5+ phases
- Repeated reviewer → implementer iteration loops
- Three or more premium-tier agent invocations in one session
- Extended sessions exceeding 30 minutes

## Core Knowledge

### Budget Tracking Model

The conductor tracks four budget dimensions across a workflow session:

| Dimension | Soft Limit (80%) | Hard Limit (100%) | Action at Soft | Action at Hard |
|-----------|------------------|--------------------|--------------------|---------------------|
| **Delegations** | 16 | 20 | Warn user, suggest consolidation | Pause + require explicit approval |
| **Premium-Tier Calls** | 4 | 5 | Switch to execution-tier alternatives | Block further premium calls |
| **Estimated Session Tokens** | 400K | 500K | Recommend context compaction | Require session handoff |
| **Wall Clock Time** | 24 min | 30 min | Suggest checkpoint + fresh session | Force pause point |

### Model Tier Cost Weights

Each delegation carries a cost weight based on the target agent's model tier:

| Tier | Weight | Agents | Monthly Budget Target |
|------|--------|--------|----------------------|
| Premium (Opus 4.6) | 3x | conductor, planner, security | ≤10% of total delegations |
| Execution (GPT-5.4, Sonnet 4.6) | 1x | implementer, reviewer, researcher, maintainer, spec, performance, accessibility, docs, observability, deployment, red-team, beast-mode, github-ops, terraform, bicep, design, test, gui-tester, translation-conductor, translator, translation-analyzer, translation-validator, translation-styler | ~80% of total delegations |
| Routine (Haiku 4.5) | 0.3x | lint, rubber-duck, visualizer | ~10% of total delegations |

### Budget State Tracking

The conductor maintains a budget state block in its internal tracking, updated after every delegation:

```markdown
## Budget Status
- **Delegations:** {used}/{limit} ({percentage}%)
- **Premium Calls:** {used}/{limit}
- **Est. Tokens:** ~{used}K / {limit}K
- **Session Time:** {elapsed} min / {limit} min
- **Zone:** 🟢 Green | 🟡 Yellow (soft limit) | 🔴 Red (hard limit)
```

### Enforcement Patterns

#### Green Zone (0-79% of any limit)
Normal operation. No special actions needed.

#### Yellow Zone (80-99% of any limit — Soft Limit)
```markdown
⚠️ **Budget Warning**: {dimension} at {percentage}% ({used}/{limit}).
Recommendations:
1. Consolidate remaining phases where possible
2. Consider switching premium agents to execution-tier alternatives:
   - researcher → implementer (if just gathering file contents)
   - planner → conductor (if plan adjustments are minor)
3. Create a handoff artifact if approaching token limit
```

#### Red Zone (100%+ of any limit — Hard Limit)
```markdown
🛑 **Budget Limit Reached**: {dimension} at {used}/{limit}.
**MANDATORY PAUSE POINT**

Options:
a) **Checkpoint & Continue** — Save current progress to `artifacts/sessions/`, start fresh session
b) **Override** — User explicitly approves additional budget: "I acknowledge the budget override for {N} additional {delegations/calls}."
c) **Abort** — Stop workflow, preserve artifacts

Awaiting your decision before proceeding.
```

### Premium-Tier Conservation Strategies

When approaching premium-tier limits, apply these substitution patterns:

| Instead of... | Use... | When acceptable |
|---------------|--------|-----------------|
| `planner` (Opus) | Conductor drafts inline plan | Minor scope adjustments, single-phase additions |
| `researcher` (GPT-5.4) | `implementer` with search tools | Gathering file contents or API docs (not strategic research) |
| `reviewer` (GPT-5.4) | `quick-review` prompt (Haiku) | Minor changes, NIT-only expected findings |
| `red-team` (GPT-5.4) | `reviewer` with adversarial prompt | When red-team findings are optional, not mandatory |
| `beast-mode` (GPT-5.4) | Standard conductor reasoning | When extended thinking is helpful but not required |

### Circuit Breaker Pattern

For destructive or high-risk operations, the conductor activates a circuit breaker **independent of budget limits**:

#### Ruin-Risk Detection

Trigger the circuit breaker when the workflow involves:
- **File deletions** affecting 5+ files or entire directories
- **Security policy changes** (auth, encryption, access control)
- **Production environment modifications** (deployment configs, infrastructure)
- **PII or credential handling** (schema changes, migration scripts)
- **Irreversible operations** (database migrations, external API calls with side effects)

#### Circuit Breaker Ceremony

```markdown
⚠️ **CIRCUIT BREAKER ACTIVATED**

**Detected:** {ruin category} with estimated risk level: {LOW | MEDIUM | HIGH}
**Trigger:** {specific operation that triggered the breaker}
**Impact:** {what could go wrong if this proceeds without review}

**Required:** To proceed, you must:
1. Review the specific changes listed above
2. Confirm with: "I acknowledge the risk and approve proceeding with {operation}."

Any other response or no response = abort this operation.
```

### Integration with Token Thresholds

This skill complements (does not replace) the existing static enforcement:

| Enforcement Layer | Scope | When | Tool |
|-------------------|-------|------|------|
| `token-thresholds.json` | Per-file token limits | Validation time (CI/PR) | `scripts/token-report.ps1` |
| `budget-gatekeeper` skill | Per-session runtime budget | Active conductor workflow | Conductor state tracking |
| `maxFileTokens: 10000` | Individual file size | Validation time | `scripts/validate-copilot-assets.ps1` |

### Session Handoff on Budget Exhaustion

When the conductor needs to hand off to a fresh session due to budget constraints:

```markdown
## Session Handoff Artifact

**Save to:** `artifacts/sessions/{date}-{feature-slug}-handoff.md`

### Progress Summary
- **Original objective:** {user's request}
- **Completed phases:** {list with status}
- **Current phase:** {in-progress work}
- **Pending phases:** {remaining work}

### Context for Next Session
- **Key decisions made:** {list}
- **Open questions:** {list}
- **Artifacts created:** {paths}
- **Budget consumed:** {delegations, premium calls, est. tokens}

### Next Steps
1. {immediate next action}
2. {subsequent actions}

### Files Modified
{list of changed files with brief descriptions}
```

## Examples

### Example 1: Budget Check Mid-Workflow
```markdown
## Budget Status
- **Delegations:** 12/20 (60%)
- **Premium Calls:** 3/5 (planner, reviewer, security)
- **Est. Tokens:** ~280K / 500K
- **Session Time:** 18 min / 30 min
- **Zone:** 🟢 Green

All limits within normal range. Proceeding with Phase 4.
```

### Example 2: Yellow Zone Warning
```markdown
## Budget Status
- **Delegations:** 17/20 (85%)
- **Premium Calls:** 4/5 (80%)
- **Est. Tokens:** ~410K / 500K
- **Session Time:** 22 min / 30 min
- **Zone:** 🟡 Yellow

⚠️ **Budget Warning**: Delegations at 85% (17/20) and premium calls at 80% (4/5).
Recommendations:
1. Consolidate remaining 2 phases into a single implementer delegation
2. Use the `quick-review` prompt instead of full reviewer for the final phase
3. Skip optional documentation update — flag as follow-up task
```

### Example 3: Circuit Breaker Activation
```markdown
⚠️ **CIRCUIT BREAKER ACTIVATED**

**Detected:** Database migration affecting production schema
**Trigger:** Phase 3 implementation includes `ALTER TABLE users DROP COLUMN legacy_id`
**Impact:** Irreversible column deletion; any code referencing `legacy_id` will fail

**Required:** To proceed, you must:
1. Confirm no code references `legacy_id` (grep results show 0 matches)
2. Confirm with: "I acknowledge the risk and approve proceeding with schema migration."

Any other response = abort this operation.
```

## References

- **Token Thresholds**: `token-thresholds.json` — static per-file limits
- **Token Report Script**: `scripts/token-report.ps1` — validate token budgets
- **Conductor Instructions**: `instructions/workflows/conductor.instructions.md` — workflow rules and pause expectations
- **Conductor Agent**: `.github/agents/conductor.agent.md` — runtime orchestration entry point
- **Model Selection**: `instructions/global/03_model-selection.instructions.md` — tier definitions
- **Conductor Lifecycle**: `.github/skills/conductor-lifecycle/SKILL.md` — phase management
- **Delegation Routing**: `.github/skills/delegation-routing/SKILL.md` — agent selection
- **Inspiration**: Athena-Public `BudgetGatekeeper` pattern (MIT License)
