# copilot-orchestrator-analytics (plugin pilot)

Status: **pilot** (Phase 3 row 3.5). First MCP server packaged as a Copilot CLI plugin.

## Install

```bash
copilot plugins install kennedym-ds/copilot-orchestrator-analytics
```

## Tools

| Tool | Purpose |
|------|---------|
| `calculate_token_cost` | Estimate token cost for prompt/response |
| `get_session_summary` | Summarise a persisted session artifact |
| `list_recent_delegations` | List recent subagent delegations |

## Development

The plugin wraps `scripts/mcp/analytics_server.py`. The manifest lives in `plugins/analytics/plugin.yaml`. When this pilot graduates, the remaining MCP servers (validation, research, translation, design) follow the same layout under `plugins/<name>/`.

## References

- Gap G14 — MCP as CLI plugin
- Plan: [../../artifacts/plans/close-all-gaps/plan.md](../../artifacts/plans/close-all-gaps/plan.md) row 3.5
- Packaging guide: [../../docs/guides/copilot-cli-plugin-packaging.md](../../docs/guides/copilot-cli-plugin-packaging.md)