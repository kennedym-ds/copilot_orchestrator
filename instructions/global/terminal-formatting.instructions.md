---
description: "Terminal formatting patterns for agent output and validation scripts."
applyTo: "scripts/**/*.ps1"
version: "2.0.0"
lastUpdated: "2026-03-11"
status: stable
---

# Terminal Formatting Instructions

Use these rules when authoring PowerShell validation scripts and other agent-facing terminal output in this repository. Keep output scannable, accessible, and consistent with the canonical glyphs and fallbacks below.

## Canonical Glyphs

| Glyph | Meaning | Text alt |
| ----- | ------- | -------- |
| ✓ | Success, passed, approved | `[OK]` |
| ✗ | Failure, error, rejected | `[FAIL]` |
| ⚠ | Warning, caution, attention needed | `[WARN]` |
| ℹ | Information, note, guidance | `[INFO]` |
| ● | Active, running, current focus | `[...]` |
| ○ | Pending, queued, not started | `[ ]` |

## Formatting Patterns

### Status Summary

Use short, color-coded summary lines when reporting overall results.

```powershell
Write-Host "✓ PASS — Asset validation" -ForegroundColor Green
Write-Host "⚠ WARN — Lint completed with warnings" -ForegroundColor Yellow
Write-Host "✗ FAIL — Smoke tests failed" -ForegroundColor Red
Write-Host "ℹ INFO — See verbose log for details" -ForegroundColor Cyan
```

### File Operations tree

Use tree-style output to show created, updated, deleted, or validated files in sequence.

```powershell
Write-Host "┌─ Validation run"
Write-Host "├── ✓ Updated instructions/global/terminal-formatting.instructions.md"
Write-Host "├── ✓ Added .github/skills/validation-scripts/references/script-catalog.md"
Write-Host "└── ● Validating live assets"
```

### Test Results

Use aligned labels so pass/fail counts remain readable in narrow terminals and copied logs.

```powershell
Write-Host "`n═══ Test Results ═══"
Write-Host "✓ Unit tests:      42/42 passed"
Write-Host "⚠ Integration:    12/12 passed, 2 warnings"
Write-Host "✗ Smoke tests:     1/3 failed"
```

### Progress Updates

Use deterministic progress indicators for multi-step operations and phase work.

```powershell
$bar = ("█" * $completed) + ("░" * ($total - $completed))
Write-Host "● Progress — [$bar] $completed/$total stages complete" -ForegroundColor Cyan
Write-Host "○ Remaining — $($total - $completed) stages pending" -ForegroundColor DarkGray
```

### Git Operations

Keep branch and diff output compact; show only the status a human needs to act on.

```powershell
Write-Host "✓ GIT — main → feature/terminal-formatting" -ForegroundColor Green
Write-Host "ℹ DIFF — 5 files changed, 184 insertions(+), 37 deletions(-)" -ForegroundColor Cyan
Write-Host "⚠ REVIEW — Re-run validation before requesting review" -ForegroundColor Yellow
```

### Validation Results

Use a boxed summary when combining multiple validation scripts into one checkpoint.

```powershell
Write-Host "`n┌─ Validation Summary ───────────────┐"
Write-Host "│ Asset validation    ✓ PASS        │"
Write-Host "│ Lint check          ⚠ WARN        │"
Write-Host "│ Smoke tests         ✗ FAIL        │"
Write-Host "└───────────────────────────────────┘"
```

## Accessibility

- Always pair a glyph with a text label such as `PASS`, `FAIL`, `WARN`, or `INFO`.
- Use `-ForegroundColor` or ANSI escape sequences as a secondary cue, never the only cue.
- Keep stage names explicit so copied logs remain understandable without color.
- Prefer stable wording over clever shorthand; scripts are read by humans and parsers.
- Avoid animated output unless it degrades cleanly to static text in transcripts.
- Keep summary lines short and move verbose details below the summary.
- Ensure tree and table layouts still make sense when pasted into plain text.
- Preserve ASCII fallbacks for environments with weak Unicode rendering.
- Treat screen readers, transcript logs, and CI captures as first-class consumers.

## Fallback Strategy

Use these ASCII alternatives when Unicode glyphs or colors are not reliable.

| Glyph | ASCII fallback |
| ----- | -------------- |
| ✓ | `[OK]` |
| ✗ | `[FAIL]` |
| ⚠ | `[WARN]` |
| ℹ | `[INFO]` |
| ● | `[*]` |
| ○ | `[ ]` |

Detect console capability once near script startup and format consistently for the whole run.

```powershell
$useUnicode = $Host.UI.SupportsVirtualTerminal -or ([Console]::OutputEncoding.WebName -match 'utf')
$glyph = if ($useUnicode) {
    @{ Pass = '✓'; Fail = '✗'; Warn = '⚠'; Info = 'ℹ'; Active = '●'; Pending = '○' }
} else {
    @{ Pass = '[OK]'; Fail = '[FAIL]'; Warn = '[WARN]'; Info = '[INFO]'; Active = '[*]'; Pending = '[ ]' }
}
```

## Agent-Specific Guidelines

### Conductor

- Use tree or boxed summaries to show lifecycle state at a glance.
- Keep phase labels explicit: `Phase 3 of 5`, `Waiting for approval`, `Review blocked`.
- Reserve warnings for real attention items; avoid visual noise in orchestration summaries.

### Implementer

- Show targeted test outcomes before broader validation results.
- Use progress indicators for multi-step validation or fix loops, not for every minor action.
- Keep diff-adjacent terminal output factual and compact.

### Reviewer

- Pair severity with text labels: `✗ BLOCKER`, `⚠ MAJOR`, `ℹ MINOR`, `● NIT`.
- Summarize findings counts before detailed evidence.
- Prefer stable, grep-friendly wording so findings can be copied into artifacts.

### Validation Scripts

- Emit one-line status before verbose detail for each script stage.
- End with a final summary that matches the script exit behavior.
- Use deterministic labels so automation and humans read the same outcome.

## References

- [docs/guides/terminal-formatting-guide.md](../../docs/guides/terminal-formatting-guide.md) — full user-facing guide and richer examples.
