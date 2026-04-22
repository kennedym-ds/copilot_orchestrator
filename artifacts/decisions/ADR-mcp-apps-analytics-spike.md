---
version: 1.0.0
date: 2026-04-22
status: accepted
gaps_closed: [G27]
recommendation: adopt-partial
---

# ADR — MCP Apps Dashboard for Analytics Server (Spike 4.2)

## Status

**Adopt partial**, 2026-04-22. Ship a minimal MCP Apps UI for the analytics server in Phase 5; do not replace `artifact-index.md`.

## Context

Gap G27 proposed exposing the analytics MCP server via MCP Apps (VS Code 1.113+) — a rich-UI channel for MCP servers that renders structured data inside the VS Code chat view. The question: does it replace our `artifacts/artifact-index.md` static index?

## Findings

### What MCP Apps offers

- Server exposes UI intents (`ui.render`, `ui.card`, `ui.table`) alongside regular tools
- VS Code renders structured JSON as cards, tables, charts in the chat view
- Hot-reload: server pushes updates; UI re-renders without a new prompt
- Works alongside existing `@mcp.tool()` and `@mcp.resource()` decorators

### Fit assessment

| Use case | Static `artifact-index.md` | MCP Apps UI | Winner |
|----------|---------------------------|-------------|--------|
| Searchable via grep/VS Code search | Yes | No (dynamic) | static |
| Git-tracked diff | Yes | No | static |
| Live session state (running delegations, token spend) | No | Yes | MCP Apps |
| Sortable, filterable | No (manual) | Yes | MCP Apps |
| Works in headless CI | Yes | No | static |
| Works without MCP server running | Yes | No | static |

**Conclusion**: the two serve different audiences. Static index = audit trail. MCP Apps = live dashboard during a session.

### Prototype scope

A 2-day prototype built two Apps endpoints on the analytics server:
1. `ui.table` — list recent delegations with cost, duration, status
2. `ui.card` — current session budget (tokens used / threshold / % remaining)

Both work locally. Feedback loop inside the chat view is significantly faster than re-running `scripts/analyze-sessions.ps1`.

## Decision

**Adopt partial** in Phase 5 (row 5.3 graduates from this spike):

1. Add the 2 UI endpoints to `scripts/mcp/analytics_server.py`
2. Document the endpoints in `docs/guides/mcp-integration.md`
3. **Keep `artifacts/artifact-index.md` as-is** — it's the audit-grade static record

Non-goals:
- Do not port all analytics to UI (headless CI still needs text output)
- Do not build a standalone dashboard app
- Do not version the UI contract until VS Code 1.116 stabilises the MCP Apps API

## Consequences

**Positive:**
- Live session visibility without leaving the chat view
- Incremental adoption — falls back to text when UI is unavailable
- No change to git-tracked artifacts

**Negative:**
- Adds MCP Apps API surface to maintain; breaking changes in VS Code minor releases need patching
- Mitigation: keep the UI endpoints thin; all business logic stays in existing `@mcp.tool()` functions

## Consequences — estimated effort for Phase 5 graduate

- Server changes: ~80 lines Python
- Docs: 1 subsection in mcp-integration.md
- Tests: mock MCP client call for each UI endpoint (~30 lines)

## Related

- Gap: G27
- Plan row: 4.2 (spike), 5.3 (graduate)
- Affects: `scripts/mcp/analytics_server.py`, `docs/guides/mcp-integration.md`