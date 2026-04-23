---
type: compliance
description: "Deny rules for the semantic firewall PreToolUse hook. Evaluated before every tool execution by the conductor and implementer agents."
applyTo: ".github/agents/conductor.agent.md,.github/agents/implementer.agent.md"
version: "1.0.0"
lastUpdated: "2026-04-23"
requires: "VS Code 1.111+ (PreToolUse hooks with decision:deny support)"
---

# Semantic Firewall Rules

Evaluated by `scripts/hooks/semantic-firewall.ps1` on every `PreToolUse` event.
A match on any DENY rule returns `{"decision": "deny", "reason": "..."}` to VS Code, which blocks the tool call and surfaces the reason to the user.

All patterns are case-insensitive. Rule evaluation stops at the first match.

---

## Rule Format

Each rule has:
- **tool**: VS Code tool name or `*` for any tool
- **field**: The JSON field in `tool_input` to match against (`command`, `url`, `path`, `*` for full input string)
- **pattern**: PowerShell regex pattern
- **reason**: Human-readable denial message shown to the user

---

## DENY Rules

### Category 1 — Destructive Shell Commands

These patterns catch common "rm -rf"-style mistakes and adversarial injections.

| # | Tool | Field | Pattern | Reason |
|---|------|-------|---------|--------|
| D01 | `execute` | `command` | `rm\s+-[rf]{1,2}\s+/` | Recursive delete of root-relative paths is blocked. Use explicit, scoped deletes. |
| D02 | `execute` | `command` | `Remove-Item.*-Recurse.*-Force\s+[/\\]` | Recursive forced remove of root-relative paths is blocked. |
| D03 | `execute` | `command` | `del\s+/[sfq]*\s+[a-z]:\\\\` | `del /s /f` on drive root is blocked. |
| D04 | `execute` | `command` | `format\s+[a-z]:` | Disk format commands are blocked. |
| D05 | `execute` | `command` | `rd\s+/[sq]*\s+[a-z]:\\\\` | `rd /s` on drive root is blocked. |

### Category 2 — Secret and Credential Exfiltration

These patterns detect attempts to dump environment variables or credential stores.

| # | Tool | Field | Pattern | Reason |
|---|------|-------|---------|--------|
| E01 | `execute` | `command` | `\$env:\w*(key\|token\|secret\|password\|pass\|pwd\|cred\|apikey)` | Accessing secret-named env vars in a shell command requires explicit user approval — do not pipe to output. |
| E02 | `execute` | `command` | `printenv\|Get-ChildItem\s+Env:\s*\|[Ee]nv\s*\|\s*sort` | Bulk env dump detected. |
| E03 | `execute` | `command` | `cat\s+~/.ssh\|Get-Content.*\.ssh\|type.*id_rsa` | Reading SSH key files is blocked. |
| E04 | `execute` | `command` | `cmdkey\s+/list\|credential\s+manager` | Reading Windows Credential Manager entries is blocked. |

### Category 3 — Unsafe Network Fetch Targets

| # | Tool | Field | Pattern | Reason |
|---|------|-------|---------|--------|
| N01 | `fetch` | `url` | `^file://` | Fetching `file://` URIs is blocked (local file exfiltration risk). |
| N02 | `fetch` | `url` | `\\\\\\\\[a-z0-9]` | UNC path fetch blocked (SMB share access). |
| N03 | `fetch` | `url` | `raw\.githubusercontent\.com.*\.(sh\|ps1\|py\|exe\|bat\|cmd)` | Fetching raw executable scripts from GitHub without review is blocked. Download to a path and review first. |
| N04 | `fetch` | `url` | `pastebin\.com\|gist\.github\.com/[^/]+/[^/]+/raw` | Fetching raw content from paste sites or anonymous gists is blocked. |
| N05 | `execute` | `command` | `(curl\|wget\|Invoke-WebRequest\|iwr)\s+.*\.(exe\|bat\|ps1\|sh\|cmd)\s*\|\s*(sh\|bash\|pwsh\|powershell)` | Curl-pipe-to-shell pattern is blocked. Download, review, then execute. |

### Category 4 — Path Traversal

| # | Tool | Field | Pattern | Reason |
|---|------|-------|---------|--------|
| P01 | `*` | `path` | `\.\.[/\\]` | Path traversal (`../`) in tool arguments is blocked. |
| P02 | `edit` | `path` | `^\.\./\|^/etc/\|^/usr/\|^C:\\\\Windows\\\\` | Editing files outside the workspace is blocked. |

### Category 5 — Eval / Code Injection

| # | Tool | Field | Pattern | Reason |
|---|------|-------|---------|--------|
| C01 | `execute` | `command` | `Invoke-Expression\s+\$\|iex\s+\$\|Invoke-Expression.*\(.*\)` | `Invoke-Expression` with a variable argument is blocked (code injection risk). |
| C02 | `execute` | `command` | `\beval\b.*\$\|\bexec\b.*\$` | `eval`/`exec` with variable content is blocked. |

---

## ALLOW List (Override)

The following patterns are explicitly allowed even if they superficially match a DENY rule. Evaluated first.

| Pattern | Reason |
|---------|--------|
| `Remove-Item.*artifacts/` | Artifact cleanup is safe and expected. |
| `Remove-Item.*\.cache` | Cache clearing is safe. |
| `Remove-Item.*__pycache__` | Python cache clearing is safe. |

---

## Telemetry

Every DENY event is logged to `artifacts/sessions/hooks/semantic-firewall.jsonl`:

```json
{"event": "PreToolUse.denied", "rule": "D01", "tool": "execute", "ts": "..."}
```

Every ALLOW bypass is logged to the same file with `"decision": "allow-override"`.

---

## Maintenance

- Add new rules in the appropriate category table.
- Increment `version` on any change.
- Run `Invoke-Pester -Path tests -ExcludeTag Slow` after adding rules — the test suite validates the firewall hook against known-good and known-bad inputs.
- False positives: if a legitimate workflow is blocked, add it to the ALLOW list with justification.
