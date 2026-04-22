# ADR — SOTA 2026 Remaining Gaps (deferred implementation)

- **Date**: 2026-04-22
- **Status**: Accepted
- **Context tier**: DEEP (multi-phase)
- **Supersedes**: n/a
- **Related**:
  - `artifacts/research/copilot-sota-gap-analysis-2026-04-22.md` (source)
  - `instructions/compliance/tool-approval-policy.instructions.md` §OWASP Framework Mapping

## Context

The 2026-04-22 SOTA review against the MCP 2025-11-25 spec, Claude Code hook surface, and OWASP LLM/Agents Top-10 2026 identified 20 gaps (G48–G67). The current session closed 10 of these directly:

| Closed in commits | Gap IDs |
|------------------|---------|
| `368a2cb` | G48, G52, G53, G54 |
| `c27841d` | G50, G51 |
| `192af01` | G49 |
| This batch | G55 (doc), G56, G57, G60, G61, G62, G64 |

This ADR documents the 5 remaining gaps and the rationale for deferring full implementation plus the concrete next steps to close them.

## Deferred Gaps

### G58 — Agent-quality eval harness
**Scope**: SWE-bench/mini-SWE-agent-style fixture set that replays conductor sessions against a known corpus and scores correctness, cost, and latency.
**Why deferred**: Requires fixture design, golden-output curation, and a runner that can inject seeded prompts into VS Code Copilot. This is a multi-week spike, not a batch fix.
**Next steps**:
1. Spike an offline fixture format in `artifacts/evals/fixtures/*.json` (prompt + expected artifacts).
2. Extend `scripts/mcp/analytics_server.py` with `run_eval(fixture_id)` that replays via a deterministic mock (no real model calls).
3. Decide real-model replay strategy (likely out-of-process via `copilot` CLI with a ledger).

### G59 — MCP Task Augmentation
**Scope**: Adopt `tasks/result` async pattern from the MCP 2025-11-25 spec so long-running tools (validation suite, full translation, analytics rollup) stop blocking the agent.
**Why deferred**: Requires refactoring every long-running tool in all 5 Python servers to return a task handle and implement polling. Pure additive work but large.
**Next steps**:
1. Audit tool runtimes — any tool averaging >2s is a candidate.
2. Wrap candidates with the `tasks/result` pattern using the `mcp` SDK helper (pending SDK v1.x release with the helper stable).
3. Update agent frontmatter `tools:` arrays to prefer async variants.

### G63 — Semantic firewall pattern
**Scope**: Pre-tool pattern-matching layer that denies known-bad tool-argument shapes (e.g. `fetch https://raw.*pastebin`, `runCommand rm -rf /`, secret exfiltration via env dumping) before the approval prompt.
**Why deferred**: Needs a curated ruleset, false-positive budget, and a hook point. VS Code 1.116 doesn't expose pre-approval hooks yet; waiting on `chat.tools.preApprovalHook` (proposed, tracked in VS Code issues).
**Next steps**:
1. Draft the ruleset in `instructions/compliance/semantic-firewall-rules.md`.
2. Once the VS Code API lands, implement `scripts/hooks/semantic-firewall.ps1` fed by that ruleset.
3. Track telemetry via `artifacts/sessions/hooks/semantic-firewall.jsonl`.

### G65 — Skills ecosystem publishing
**Scope**: Publish our 12 Agent Skills to the `skills.sh` catalogue / vercel-labs registry so other orchestrators can install them via `npx skills add kennedym-ds/copilot_orchestrator`.
**Why deferred**: Requires an OWNER-level decision on license and support scope, plus CI pipeline for skill version bumps. Not a code gap — a distribution decision.
**Next steps**:
1. Decide: publish all 12, subset, or none.
2. If publishing, add `.github/workflows/publish-skills.yml` that lints + pushes to the catalogue on tagged release.

### G66 — Community catalogue drift audit
**Scope**: Compare our skills against `obra/superpowers`, `skills.sh`, and `claudeskills.info` to identify overlap/divergence. Feeds G65.
**Why deferred**: Blocked on G65 and needs a one-shot research pass, not production code.
**Next steps**:
1. Run the comparison as a researcher task in a future session.
2. Record findings in `artifacts/research/skills-catalogue-drift-<date>.md`.

## G55 partial closure note

`G55 — MCP protocolVersion declared on servers` is marked **doc-closed** in this session:
- `protocolVersion` is negotiated per-connection by the `mcp` Python SDK (FastMCP handles it automatically).
- `.vscode/mcp.json` and each `scripts/mcp/*.py` header now reference the supported spec version (`2025-11-25`) via comments.
- No runtime code change is required — SDK version in `requirements.txt` is the single source of truth.

If a future SDK upgrade changes protocol negotiation, revisit by pinning `protocolVersion` explicitly in the `FastMCP(...)` constructor once the SDK exposes it.

## Decision

Accept deferral of G58, G59, G63, G65, G66. Track via this ADR; revisit at the next SOTA review (target: 2026-07). Reviewed gaps G48–G64 are closed in this session's commit chain.

## Consequences

- **Positive**: Session closes with a green validation suite, no half-baked eval/firewall/publishing code to maintain.
- **Negative**: Agentic-loop observability has telemetry (G64) but no replay-based evaluation (G58) — quality regressions may slip through for the next quarter.
- **Mitigation**: Until G58 lands, rely on the reviewer agent + Pester/pytest suites + token-report to catch drift. Set a calendar item for the 2026-07 SOTA review.

## Rollback

No rollback needed — this ADR records deferred work, nothing was implemented that must be undone.