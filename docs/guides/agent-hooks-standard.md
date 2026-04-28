---
title: "Agent hooks standard"
version: "3.1.0"
lastUpdated: "2026-04-23"
status: "active"
reviewOwners:
  - "Copilot Orchestrator maintainers"
---

# Agent hooks standard

Agent-scoped hooks attach deterministic shell-level behavior to an agent's lifecycle events via a `hooks` map in the agent's YAML frontmatter. All hooks run PowerShell scripts under `scripts/hooks/` and emit structured JSONL to `artifacts/sessions/hooks/`.

> **Requires:** `"chat.useCustomAgentHooks": true` in `.vscode/settings.json` (Preview feature, VS Code 1.111+).

## Two hook systems — do not conflate

| System | Location | Event casing | Input | Key |
|--------|----------|-------------|-------|-----|
| **VS Code agent hooks** (this doc) | Agent `hooks:` frontmatter | PascalCase | stdin JSON | `command:`/`windows:` |
| **GitHub Cloud Agent hooks** | `.github/hooks/hooks.json` | lowerCamelCase | stdin JSON | `bash:`/`powershell:` |

The scripts in `scripts/hooks/` target the **VS Code** system only.

## Frontmatter syntax

```yaml
hooks:
  EventName:
    - type: command
      command: "pwsh -File scripts/hooks/script.ps1"
      windows: "powershell -File scripts/hooks/script.ps1"
  AnotherEvent:
    - type: command
      command: "pwsh -File scripts/hooks/other.ps1 -Arg value"
      windows: "powershell -File scripts/hooks/other.ps1 -Arg value"
```

- Keys are PascalCase VS Code event names (see canonical list below).
- `command:` runs on Linux/macOS (pwsh = PowerShell Core).
- `windows:` overrides on Windows (powershell = Windows PowerShell 5.1).
- Multiple hooks per event are supported (array of entries).
- `pathGlob` / `when` matchers are **parsed but permanently ignored** by VS Code — do not rely on them for scoping.

## Canonical VS Code hook events

| Event | When it fires | stdin extras |
|-------|---------------|--------------|
| `SessionStart` | Start of a new chat session | — |
| `UserPromptSubmit` | Before each user prompt is processed | — |
| `PreToolUse` | Before a tool call is executed | `tool_name`, `tool_input` |
| `PostToolUse` | After any tool call completes | `tool_name`, `tool_input`, `tool_exit_code` |
| `PreCompact` | Before a `/compact` context compaction | — |
| `SubagentStart` | Before a nested subagent is launched | `agent_id`, `agent_type` |
| `SubagentStop` | After a nested subagent completes | `agent_id`, `agent_type` |
| `Stop` | When the agent session ends | — |

All events receive these standard fields via stdin JSON:

```json
{
  "timestamp": "2026-04-23T10:00:00Z",
  "cwd": "/workspace",
  "sessionId": "abc-123",
  "hookEventName": "PostToolUse",
  "transcript_path": "/path/to/transcript.jsonl"
}
```

## Hook output (stdout JSON)

Scripts can return JSON to stdout to inject context or control flow:

| Field | Supported by | Purpose |
|-------|-------------|---------|
| `additionalContext` | `SessionStart`, `SubagentStart`, `PostToolUse` | Inject text into the assistant's context |
| `permissionDecision` (`"allow"/"deny"/"ask"`) | `PreToolUse` | Gate tool execution |
| `block` + `reason` | `Stop`, `SubagentStop`, `PostToolUse` | Halt the operation with explanation |

Exit code non-zero signals a hook error; behavior depends on the event type.

## Shared helpers (`scripts/hooks/_common.ps1`)

All hook scripts dot-source `_common.ps1` which provides:

- `Read-HookInput` — reads stdin JSON; returns parsed object or empty object if no stdin
- `Write-AdditionalContext -Context <string>` — emits `{additionalContext: ...}` JSON to stdout
- `Write-HookEvent -Event <name> -Payload <hashtable>` — appends a JSON record to `artifacts/sessions/hooks/<name>.jsonl`
- `Write-HookError -Agent -Trigger -ExitCode -StderrTail` — appends to `artifacts/sessions/hooks-errors.jsonl`

## Deployed hooks

### conductor

| Event | Script | Purpose |
|-------|--------|---------|
| `SessionStart` | `session-start.ps1` | Inject runtime context (Python/venv, repo metadata) |
| `UserPromptSubmit` | `user-prompt-submit.ps1` | Budget cap check; warn at 80% |
| `SubagentStart` | `subagent-start.ps1` | Enforce nested-subagent allowlist; exit 1 on violation |
| `SubagentStop` | `subagent-stop.ps1` | Log completion metrics |
| `PostToolUse` | `post-tool-failure.ps1` | Capture tool failures (exit_code ≠ 0) to JSONL |
| `PreCompact` | `pre-compact.ps1` | Copy transcript to snapshots before compaction |
| `Stop` | `session-stop.ps1` | Append a session recap and emit SessionStop JSONL |

### reviewer

| Event | Script | Purpose |
|-------|--------|---------|
| `UserPromptSubmit` | `load-security-context.ps1` | Emit 3 most recent security findings as additionalContext |

### implementer

| Event | Script | Purpose |
|-------|--------|---------|
| `PostToolUse` | `validate-copilot-assets.ps1 -RepositoryRoot .` | Re-validate assets after every tool use |
| `PostToolUse` | `post-tool-lint.ps1 -Agent implementer` | Run markdown lint when a `.md` file is edited |
| `PostToolUse` | `post-tool-format-markdown.ps1` | Trim trailing whitespace in Markdown edits |
| `PostToolUse` | `post-tool-token-report.ps1` | Run token report for docs-related Markdown edits |
| `PostToolUse` | `post-tool-dependency-check.ps1` | Recommend install when dependency files change |
| `PostToolUse` | `post-tool-large-edit.ps1` | Warn on oversized edits for review clarity |

### docs

| Event | Script | Purpose |
|-------|--------|---------|
| `PostToolUse` | `capture-error.ps1 -Agent docs` | Log failed tool calls to `artifacts/sessions/docs-errors/` |
| `PostToolUse` | `post-tool-lint.ps1 -Agent docs` | Run markdown lint when a `.md` file is edited |
| `PostToolUse` | `post-tool-format-markdown.ps1` | Trim trailing whitespace in Markdown edits |
| `PostToolUse` | `post-tool-token-report.ps1` | Run token report for docs-related Markdown edits |
| `PostToolUse` | `post-tool-dependency-check.ps1` | Recommend install when dependency files change |
| `PostToolUse` | `post-tool-large-edit.ps1` | Warn on oversized edits for review clarity |

### All other agents (test, researcher, iac, gui-tester, ux, translator, translation-*)

| Event | Script | Purpose |
|-------|--------|---------|
| `PostToolUse` | `capture-error.ps1 -Agent <name>` | Log failed tool calls to `artifacts/sessions/<agent>-errors/` |

## Hard safety rules

1. Hooks **MUST NOT** bypass user approval flows.
2. Hooks **MUST NOT** perform destructive operations silently.
3. Hooks **MUST NOT** carry secrets or credentials.
4. Every hook **MUST** be documented in the owning agent's frontmatter — no undocumented magic.
5. Hooks **MUST** be idempotent — safe to re-run without changing meaning or state.
6. Blocking hooks (exit 1 / `permissionDecision: deny`) are reserved for enforcement (allowlist, security gates). Observability hooks must exit 0 on success.

## Adding a new hook

1. Write the script to `scripts/hooks/<name>.ps1`. Dot-source `_common.ps1`, call `Write-HookEvent`.
2. Use `Read-HookInput` to get stdin JSON context rather than env vars.
3. If the hook should block, emit JSON with `permissionDecision: deny` / `block: true` AND exit 1.
4. Add the hook to the agent frontmatter using the map-of-arrays syntax above.
5. Add a Pester test in `tests/powershell/Test-Hooks.Tests.ps1` — pipe JSON via stdin, verify exit code and JSONL record.
6. Run `Invoke-Pester -Path tests` and `pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .` — both must pass.

## JSONL output locations

Every JSONL record includes `event` + `ts`, and adds `session_id` when VS Code provides it.

```
artifacts/sessions/hooks/
├── SubagentStart.jsonl       # Every subagent invocation (allowed + denied)
├── SubagentStop.jsonl        # Subagent completions
├── PostToolUse.jsonl         # Tool failures captured by conductor
├── PostToolUseDependencyCheck.jsonl
├── PostToolUseLargeEdit.jsonl
├── PostToolUseMarkdownFormat.jsonl
├── PostToolUseTokenReport.jsonl
├── PreCompact.jsonl
├── SessionStop.jsonl
├── UserPromptSubmit.jsonl
└── snapshots/                # pre-compact-<timestamp>.txt context snapshots
artifacts/sessions/hooks-errors.jsonl  # legacy error stream
artifacts/sessions/<agent>-errors/     # per-agent error logs
```

## Verification

After adding or updating hooks:

1. Run `Invoke-Pester -Path tests/powershell/Test-Hooks.Tests.ps1 -Output Detailed`.
2. Trigger the hook by piping a JSON payload to the script: `'{"agent_type":"test",...}' | pwsh -File scripts/hooks/subagent-start.ps1`.
3. Confirm the expected JSONL record appears in `artifacts/sessions/hooks/`.
4. Run `pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .` — must be green.

## Related references

- `scripts/hooks/` — all hook scripts
- `scripts/hooks/_common.ps1` — shared JSONL helpers
- `tests/powershell/Test-Hooks.Tests.ps1` — hook unit tests
- `AGENTS.md § Nested Subagent Allow-List` — allowlist enforced by `subagent-start.ps1`
- `.vscode/settings.json` — `chat.useCustomAgentHooks: true`
- [Agent standard template](../templates/agent-standard.md)
