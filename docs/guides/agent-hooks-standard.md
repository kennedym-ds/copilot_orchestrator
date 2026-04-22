---
title: "Agent hooks standard"
version: "2.0.0"
lastUpdated: "2026-04-22"
status: "active"
reviewOwners:
  - "Copilot Orchestrator maintainers"
---

# Agent hooks standard

Agent-scoped hooks attach deterministic shell-level behavior to an agent's lifecycle events via a `hooks` section in frontmatter. All hooks run PowerShell scripts under `scripts/hooks/` and emit structured JSONL to `artifacts/sessions/hooks/`.

## Frontmatter syntax

```yaml
hooks:
  - trigger: <event-name>
    when:                         # optional — scope by tool or path
      tool: <tool-name>
      pathGlob: "**/*.ps1"
    run:
      command: powershell
      args: ["-File", "scripts/hooks/<script>.ps1"]
      timeoutMs: 5000
    on_fail: continue | block | escalate
```

`on_fail` controls what happens if the hook script exits non-zero:

| Value | Behaviour |
|-------|-----------|
| `continue` | Log the failure; agent proceeds normally |
| `block` | Halt the agent turn; surface the error to the user |
| `escalate` | Re-run the validation step; treat failure as a blocking finding |

## Supported triggers

| Trigger | When it fires | Scripts |
|---------|---------------|---------|
| `session-pause` | Agent emits a pause point (phase gate, plan approval) | `session-pause.ps1` |
| `user-prompt-submit` | Before each user prompt is processed | `user-prompt-submit.ps1` |
| `subagent-start` | Before a nested subagent is launched | `subagent-start.ps1` |
| `subagent-stop` | After a nested subagent completes | `subagent-stop.ps1` |
| `post-tool-failure` | After any tool call exits non-zero | `post-tool-failure.ps1` |
| `pre-compact` | Before a `/compact` context compaction | `pre-compact.ps1` |
| `task-created` | When a task is created in the session | `task-created.ps1` |
| `task-completed` | When a task is marked complete | `task-completed.ps1` |
| `post-tool` (conditional) | After a specific tool, filtered by `when.tool` and `when.pathGlob` | `validate-copilot-assets.ps1` |

## Environment variables

Hook scripts receive context via environment variables set by the runtime:

| Variable | Set by trigger | Purpose |
|----------|---------------|---------|
| `COPILOT_PARENT_AGENT` | `subagent-start` | Parent agent name |
| `COPILOT_CHILD_AGENT` | `subagent-start` | Child agent name |
| `COPILOT_SUBAGENT_DEPTH` | `subagent-start` | Current nesting depth |
| `COPILOT_TASK_ID` | `task-created`, `task-completed` | Task identifier |
| `COPILOT_TASK_ASSIGNEE` | `task-created`, `task-completed` | Assigned agent |
| `COPILOT_TASK_STATUS` | `task-completed` | Final status string |
| `COPILOT_SESSION_ID` | `user-prompt-submit` | Session identifier |
| `COPILOT_SESSION_TOKENS` | `user-prompt-submit` | Tokens used so far |
| `COPILOT_SESSION_BUDGET` | `user-prompt-submit` | Budget ceiling (0 = no limit) |
| `COPILOT_ACTIVE_AGENT` | `pre-compact`, `post-tool-failure` | Active agent name |
| `COPILOT_CONTEXT_TOKENS` | `pre-compact` | Context size at compaction |
| `COPILOT_TOOL_NAME` | `post-tool-failure` | Tool that failed |
| `COPILOT_TOOL_EXIT_CODE` | `post-tool-failure` | Exit code |
| `COPILOT_TOOL_ERROR_TAIL` | `post-tool-failure` | Last lines of stderr |
| `COPILOT_ACTIVE_CONTEXT` | `pre-compact` | Serialised context snapshot |

## Deployed hooks (conductor)

The conductor has the most hooks. All other agents inherit none by default — add hooks to an agent frontmatter only when there is a concrete observability or enforcement need.

| Trigger | Script | `on_fail` | Purpose |
|---------|--------|-----------|---------|
| `session-pause` | `session-pause.ps1` | continue | Log pause point to `pause-log.txt` |
| `user-prompt-submit` | `user-prompt-submit.ps1` | continue | Budget cap check; warn at 80% |
| `subagent-start` | `subagent-start.ps1` | **block** | Enforce nested-subagent allowlist; `exit 1` on violation |
| `subagent-stop` | `subagent-stop.ps1` | continue | Log completion metrics |
| `post-tool-failure` | `post-tool-failure.ps1` | continue | Capture tool failure to JSONL |
| `pre-compact` | `pre-compact.ps1` | continue | Snapshot active context before compaction |
| `task-created` | `task-created.ps1` | continue | Log task creation event |
| `task-completed` | `task-completed.ps1` | continue | Update `team-state.json` task status |

The implementer adds one conditional hook:

| Trigger | Condition | Script | `on_fail` | Purpose |
|---------|-----------|--------|-----------|---------|
| `post-tool` | `tool: edit`, `pathGlob: .github/**` | `validate-copilot-assets.ps1` | escalate | Re-validate assets after any edit to `.github/` |

## Shared helpers (`scripts/hooks/_common.ps1`)

All hook scripts dot-source `_common.ps1` which provides:

- `Write-HookEvent -Event <name> -Payload <hashtable>` — appends a JSON record to `artifacts/sessions/hooks/<name>.jsonl`
- `Write-HookError -Agent -Trigger -ExitCode -StderrTail` — appends to `artifacts/sessions/hooks-errors.jsonl` (legacy path, kept for back-compat)

## Hard safety rules

1. Hooks **MUST NOT** bypass user approval flows.
2. Hooks **MUST NOT** perform destructive operations silently.
3. Hooks **MUST NOT** carry secrets or credentials.
4. Every hook **MUST** be documented in the owning agent's frontmatter — no undocumented magic.
5. Hooks **MUST** be idempotent — safe to re-run without changing meaning or state.
6. `on_fail: block` is reserved for enforcement hooks (allowlist, security gates). Observability hooks use `continue`.

## Adding a new hook

1. Write the script to `scripts/hooks/<name>.ps1`. Dot-source `_common.ps1`, call `Write-HookEvent`.
2. If the hook can block, add `exit 1` explicitly — `Write-HookError` does **not** exit.
3. Add the hook to the agent frontmatter with the appropriate `on_fail`.
4. Add a Pester test in `tests/powershell/Test-Hooks.Tests.ps1` covering at least: exit code on success, exit code on failure, JSONL record schema.
5. Run `Invoke-Pester -Path tests` and `pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .` — both must pass.

## JSONL output locations

```
artifacts/sessions/hooks/
├── subagent-start.jsonl      # Every subagent invocation (allowed + denied)
├── subagent-stop.jsonl       # Subagent completions
├── task-created.jsonl
├── task-completed.jsonl
├── pre-compact.jsonl
├── post-tool-failure.jsonl
├── user-prompt-submit.jsonl
├── session-pause.jsonl (via session-pause.ps1 → pause-log.txt)
└── snapshots/                # pre-compact-<timestamp>.txt context snapshots
artifacts/sessions/hooks-errors.jsonl  # legacy error stream
```

## Verification

After adding or updating hooks:

1. Run `Invoke-Pester -Path tests/powershell/Test-Hooks.Tests.ps1 -Output Detailed`.
2. Trigger the hook manually by invoking the script with test parameters.
3. Confirm the expected JSONL record appears in `artifacts/sessions/hooks/`.
4. Run `pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .` — must be green.

## Related references

- `scripts/hooks/` — all hook scripts
- `scripts/hooks/_common.ps1` — shared JSONL helpers
- `tests/powershell/Test-Hooks.Tests.ps1` — hook unit tests (7 tests)
- `AGENTS.md § Nested Subagent Allow-List` — allowlist enforced by `subagent-start.ps1`
- [Agent standard template](../templates/agent-standard.md)
