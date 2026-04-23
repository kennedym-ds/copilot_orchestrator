# ADR: Agent Plugins Go/No-Go

**Date:** 2026-04-23
**Status:** Accepted — plugin-ready, no structural migration
**Closes:** F7 (SOTA alignment 2026-04-22)

---

## Context

VS Code 1.110 introduced **agent plugins** as a new way to package and distribute agent definitions. The current repo uses the pre-1.110 single-file convention: each agent is a standalone `.github/agents/<name>.agent.md` file.

The 2026-04-22 SOTA gap analysis flagged the absence of a plugin manifest (F7, Medium severity).

## Spike Executed — 2026-04-23

**Scope:** Full plugin format research + minimal conductor manifest.

**Format confirmed from official docs** (`code.visualstudio.com/docs/copilot/customization/agent-plugins`, fetched 2026-04-23):

### Plugin manifest (`plugin.json`)

VS Code auto-detects `plugin.json` at these locations (checked in order):
1. `.plugin/plugin.json`
2. `plugin.json` (repo root) ← **our choice**
3. `.github/plugin/plugin.json`
4. `.claude-plugin/plugin.json`

Required field: `name` (kebab-case, no slashes/colons, max 64 chars).

Optional fields: `description`, `version`, `author`, `skills` (path), `agents` (path), `hooks` (path/object), `mcpServers` (path/object).

### Directory structure for our repo

No restructuring needed. The `agents` and `skills` fields accept paths to existing directories:

```
plugin.json            ← created; points to .github/agents/ and .github/skills/
.github/
  agents/             ← 16 .agent.md files (unchanged)
  skills/             ← 12 skill directories (unchanged)
```

### Key constraints confirmed

- Status: **Preview** — requires `chat.plugins.enabled: true` in settings (already set at line 103)
- Cross-tool: same `plugin.json` works for VS Code, Copilot CLI, and Claude Code
- Local plugin test: register via `chat.pluginLocations: { "/path/to/repo": true }` in user settings
- **Duplicate loading risk**: do NOT add `chat.pluginLocations` to `.vscode/settings.json` — workspace discovery and plugin loading would both load `.github/agents/` and cause duplicates. The plugin manifest is for external distribution only.
- Install from source: `copilot plugin install github/kennedym-ds/copilot_orchestrator` (once repo is public/listed)

## Decision

**Go — plugin-ready, no structural migration.**

Created `plugin.json` at repo root. This makes the repo immediately distributable as a plugin (`copilot plugin install` from source, or listing in a marketplace). No agent or skill files were moved; workspace discovery remains the primary mechanism for local development.

**Full structural migration** (moving agents to `agents/`, skills to `skills/`) is **rejected** because:
1. The current `.github/agents/` and `.github/skills/` paths are the VS Code workspace discovery conventions — restructuring would break workspace loading.
2. `plugin.json` supports arbitrary paths via the `agents:` and `skills:` fields — no restructuring required.
3. Migration cost exceeds benefit: all 16 agents work correctly today without any restructuring.

## Consequences

- `plugin.json` at repo root enables `copilot plugin install` from source for external users.
- Local development: unchanged. VS Code workspace discovery loads `.github/agents/` and `.github/skills/` natively.
- If the repo is published to a marketplace, bump `version` in `plugin.json` before each release.
- Collections ADR (`ADR-collections-legacy.md`) referenced this spike as a dependency. Conclusion: plugins and collections serve different purposes; retain collections as legacy fallback per that ADR.

## Factors that drove the decision

| Factor | Assessment |
|--------|-----------|
| Capability gap vs single-file | None for local dev; plugin adds marketplace distribution |
| Format stability | Documented at 1.110, refined through 1.112; no breaking changes observed |
| Migration cost | Near-zero (one JSON file; no restructuring) |
| Duplicate loading risk | Real — mitigated by not adding `chat.pluginLocations` to workspace settings |
| Preview status | Acceptable — `chat.plugins.enabled` already enabled in `.vscode/settings.json` |

