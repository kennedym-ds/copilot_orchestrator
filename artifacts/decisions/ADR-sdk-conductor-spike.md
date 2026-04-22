---
version: 1.0.0
date: 2026-04-22
status: accepted
gaps_closed: [G9]
recommendation: defer
---

# ADR — SDK-based Conductor Prototype (Spike 4.1)

## Status

**Defer**, 2026-04-22. Keep PowerShell orchestration; re-evaluate at Phase 5 Row 5.4 research refresh.

## Context

Gap G9 raised the question of replacing the PowerShell orchestration surface with an official Copilot SDK (Python or TypeScript). The theoretical benefit: fewer lines, better type safety, idiomatic error handling, and cross-platform parity.

Today's PowerShell surface that would be in scope for replacement:
- `scripts/validate-copilot-assets.ps1` (asset/frontmatter validator)
- `scripts/run-smoke-tests.ps1` (repo hygiene smoke)
- `scripts/run-lint.ps1` (markdownlint + prose checks)
- `scripts/add-prompt-metadata.ps1` (prompt metadata normaliser)
- `scripts/token-report.ps1` (token budget report)
- `scripts/analyze-sessions.ps1` (session analytics)

Total: ~6 scripts, ~1,200 lines of PowerShell.

## Findings

### SDK surface available today

| SDK | Status | Fit for our surface |
|-----|--------|---------------------|
| `@github/copilot-sdk` (TypeScript) | Preview | Targets chat/completion APIs; does not expose agent lifecycle, frontmatter parsing, or workspace validation. |
| `github-copilot-sdk` (Python) | Preview | Same surface as TS; no workspace-level primitives. |
| Copilot CLI automation via `copilot chat -p` | GA (1.109+) | Already used for headless review (Phase 3.6). Not an SDK. |

None of the preview SDKs expose workspace asset validation or frontmatter-schema checking. Our PowerShell scripts do not interact with the chat/completion API at all — they validate local files.

### Measured replacement surface

After tracing each script's responsibilities:
- **0 scripts** would genuinely benefit from an SDK — the SDKs target runtime chat interactions, not repo tooling
- **6 scripts** would require a full rewrite with *no API surface win* — equivalent Python would also be ~1,200 lines
- Cross-platform parity is already achieved via pwsh 7 (ships on macOS/Linux)

### Cost

Rewriting 6 scripts: ~2 weeks; forces introduction of pytest-based validator tests (we already have them for MCP servers, but not for validator scripts); creates a dual-runtime repo (PowerShell for some things, Python for others).

## Decision

**Defer indefinitely.** The SDK targets a different problem (runtime chat) than our orchestration problem (repo asset hygiene). No adopt-path makes sense today.

## When to revisit

- Copilot ships a workspace-validation SDK with frontmatter primitives
- A Linux-only contributor hits a Windows-PowerShell 5.1-specific blocker we can't fix
- We outgrow the 1,200-line ceiling on our PowerShell surface (not in sight)

## Consequences

**Positive:**
- No churn; existing PowerShell stays authoritative
- No dual-runtime burden
- Matches the operator's stated Windows-first environment

**Negative:**
- If SDK adds a workspace-validation primitive in 2027, we may be late to adopt
- Mitigation: Phase 5 row 5.4 research refresh will catch any API surface change

## Related

- Gap: G9
- Plan row: 4.1
- Revisit trigger: Phase 5 row 5.4