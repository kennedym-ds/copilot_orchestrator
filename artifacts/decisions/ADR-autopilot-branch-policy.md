---
version: 1.0.0
date: 2026-04-22
status: accepted
gaps_closed: [G2]
---

# ADR — Autopilot Permitted on `enterprise` Branch

## Status

Accepted, 2026-04-22. Ratified by human operator; overrides the conservative provisional policy drafted during Phase 1.

## Context

Phase 1 added a Permission & Complexity Tier Matrix to `AGENTS.md`. The branch policy was drafted conservatively:

- `free` / `pro`: Autopilot for INSTANT only
- `pro-plus`: Autopilot for INSTANT + read-only STANDARD
- `enterprise`: Autopilot disallowed

The operator's assessment: the orchestrator's hooks (Phase 3 row 3.1) and confidence-scoring discipline are strong enough to run Autopilot safely on `enterprise`. The provisional policy was over-cautious.

## Decision

Autopilot is **permitted on the `enterprise` branch** for agents classified Autopilot-safe in the per-agent matrix (read-only and edit-bounded classes). Judgement-critical and state-changing agents still require human approval.

### Updated branch policy

| Branch | Autopilot policy |
|--------|------------------|
| free / pro | INSTANT only |
| pro-plus | INSTANT + read-only STANDARD |
| enterprise | INSTANT + STANDARD + DEEP for read-only and edit-bounded agents; judgement-critical and state-changing agents still require human approval |

### Always-human-confirmed regardless of branch

1. Security review (`reviewer --security`)
2. Ops agent destructive operations (merges, deletes, force-pushes, releases)
3. IaC apply / deploy steps
4. GUI-tester runs against production endpoints
5. Translation-conductor final merge commits

## Rationale

The operator's reasoning (recorded verbatim for future reference):

- Hooks (Phase 3 row 3.1) provide observability and automatic validation, catching regressions Autopilot would otherwise hide
- Confidence-scoring (skill: `confidence-scoring`) already gates reviewer findings; Autopilot inherits that discipline
- `enterprise` branch has full CI (Pester + pytest + validator via `ci/validate.yml`) gating every merge
- The primary human operator is a senior engineer who can handle the blast radius if Autopilot misbehaves
- Locking `enterprise` out of Autopilot makes it the most restrictive branch, which contradicts its role as the source of truth that the other branches sync *from*

## Consequences

**Positive:**
- Faster iteration on `enterprise` for researcher/docs/ux/test work
- Edit-bounded agents (test, iac, translator, translation-validator) can land small changes without ceremony

**Negative:**
- Higher blast radius for a bad Autopilot response
- Requires Phase 3 hooks to ship before this takes effect in practice — premature Autopilot on `enterprise` without hook observability is a regression

## Guardrails

1. Autopilot on `enterprise` takes effect **only after Phase 3 row 3.1 (hooks) ships and is observed stable for one week**
2. First Autopilot failure that reaches production triggers an automatic policy review; a single incident may tighten the policy
3. Security review is never Autopilot-eligible (no exception)
4. CI failure on any Autopilot-landed commit triggers `ops` agent to open an incident issue automatically

## Alternatives Considered

1. **Keep the conservative policy (Autopilot disallowed on enterprise)**: rejected by operator — over-restrictive given the hook and CI guardrails
2. **Autopilot everywhere including state-changing**: rejected — state-changing agents (ops, gui-tester, iac apply) have destructive verbs; Autopilot there is a bridge too far
3. **Autopilot gated by a `.copilot-autopilot.yaml` file**: rejected — adds config surface without clear benefit over the per-agent class rules

## Related

- Gap: G2 (extension)
- Supersedes: the provisional branch-policy row in `AGENTS.md` (Phase 1 commit `a9d8c07`, now updated)
- Depends on: Phase 3 row 3.1 (hooks must ship first)