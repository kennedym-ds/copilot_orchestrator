# Copilot CLI Plugin Packaging

Status: Draft (Phase 3 row 3.5, pilot) | Last Updated: 2026-04-22

This guide describes how we package MCP servers as Copilot CLI plugins. The analytics server is the first pilot (see `plugins/analytics/`). If it graduates, the remaining servers follow the same layout.

## Layout

```
plugins/
└── <plugin-name>/
    ├── plugin.yaml      # Manifest (name, version, tools, compatibility)
    └── README.md        # Install + usage notes
```

The `plugin.yaml` is the contract. Keep `entrypoint.command` relative to the repository root; Copilot CLI resolves it from the install location.

## Manifest fields

| Field | Purpose |
|-------|---------|
| `name` | Unique plugin id — `<org>/<name>` on install |
| `version` | SemVer; bump on every release |
| `kind` | Always `mcp-server` for this repo's plugins |
| `entrypoint.command` / `entrypoint.args` | How Copilot CLI spawns the server |
| `requirements.python` | Minimum Python version |
| `requirements.packages` | pip requirements installed at plugin install time |
| `tools[]` | Tool surface; used by the CLI for `copilot plugins info` |
| `compatibility.copilot-cli` | Minimum CLI version (`>=0.5.0`) |
| `compatibility.platforms` | Windows/Linux/macOS support |

## Install (user-facing)

```bash
copilot plugins install kennedym-ds/copilot-orchestrator-analytics
```

The CLI reads `plugin.yaml`, resolves requirements, and registers the MCP server into the user's Copilot configuration. Subsequent `copilot chat --agent <any>` sessions see the plugin's tools automatically.

## Uninstall

```bash
copilot plugins uninstall copilot-orchestrator-analytics
```

## Local development

```bash
# From the repo root
copilot plugins install ./plugins/analytics
```

Tests the manifest and server locally without publishing.

## Publishing

Publishing is out of scope for the pilot. Once the analytics plugin proves stable, publishing via `copilot plugins publish` will be part of the next release.

## Graduation criteria (pilot -> general)

- One-week soak with no plugin-related bug reports
- Cross-platform install validated (Windows, Linux, macOS)
- `plugins/<name>/plugin.yaml` passes the manifest validator (to be added in Phase 5)

## References

- Gap G14
- Plan row 3.5: `artifacts/plans/close-all-gaps/plan.md`
- Pilot plugin: `plugins/analytics/`