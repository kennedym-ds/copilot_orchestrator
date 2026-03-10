?---
name: orchestrator-terminal-style
description: "Terminal formatting patterns using VS Code 1.109 GPU-accelerated glyphs for conductor workflows, validation scripts, and agent output. Use for status indicators, progress bars, and formatted terminal displays."
---

# Orchestrator Terminal Style

Provides terminal formatting patterns using VS Code 1.109's enhanced glyph support for conductor workflows, validation scripts, and agent output.

## Description

This skill teaches agents how to format terminal output with the ~800 GPU-accelerated glyphs available in VS Code 1.109, including status indicators, box drawing, progress bars, and Git symbols. It covers the canonical glyph set, formatting patterns, accessibility requirements, and fallback strategies for conductor workflows.

## When to Use

This skill is relevant when:
- Formatting terminal output from PowerShell validation scripts
- Displaying status summaries in conductor workflows
- Creating progress indicators for multi-phase tasks
- Formatting Git operation results
- Displaying test results with visual indicators
- Creating tables or structured output in terminals

## Entry Points

### Trigger Phrases
- "format terminal output"
- "show validation results"
- "display progress"
- "create status summary"
- "format test results"
- "use glyphs in output"

### Context Patterns
- Running validation scripts (validate-copilot-assets.ps1, run-lint.ps1, run-smoke-tests.ps1)
- Displaying conductor phase progress
- Formatting implementer test results
- Showing reviewer findings summary
- Displaying deployment status

## Core Knowledge

### Canonical Glyph Set

#### Status Indicators
- `✓` (U+2713) — Success, passed, approved
- `✗` (U+2717) — Failure, error, rejected
- `⚠` (U+26A0) — Warning, caution, attention needed
- `ℹ` (U+2139) — Information, note, guidance
- `●` (U+25CF) — Active state, in-progress
- `○` (U+25CB) — Inactive state, pending

#### Box Drawing (U+2500-U+257F)
```
┌─┬─┐  ╔═╦═╗  ╭─┬─╮
├─┼─┤  ╠═╬═╣  ├─┼─┤
└─┴─┘  ╚═╩═╝  ╰─┴─╯
│ ─    ║ ═    │ ─
```

#### Block Elements (U+2580-U+259F)
- `▁▂▃▄▅▆▇█` — Progress bars (8 levels)
- `░▒▓█` — Density indicators

#### Progress Indicators (U+EE00-U+EE0B)
- ` ` — Spinner frames for loading
- Combine with timer for animated progress

#### Git Symbols (U+F5D0-U+F60D)
- `` (U+E0A0) — Branch indicator
- `` (U+E0B0) — Powerline separator

### Formatting Patterns

#### 1. Status Summary
```powershell
Write-Host "✓ All Copilot assets passed validation." -ForegroundColor Green
Write-Host "⚠ 2 warnings found in documentation." -ForegroundColor Yellow
Write-Host "✗ Build failed with 3 errors." -ForegroundColor Red
Write-Host "ℹ Use -Verbose flag for detailed output." -ForegroundColor Cyan
```

#### 2. File Operations
```powershell
Write-Host "┌─ Phase 3: Terminal Glyphs Style Guide"
Write-Host "├── ✓ Created instructions/global/terminal-formatting.instructions.md"
Write-Host "├── ✓ Created docs/guides/terminal-formatting-guide.md"
Write-Host "└── ● Validating changes..."
```

#### 3. Test Results
```powershell
Write-Host "`n═══ Test Results ═══"
Write-Host "✓ Unit Tests:     42/42 passed"
Write-Host "✓ Integration:    15/15 passed"
Write-Host "⚠ E2E Tests:      8/10 passed (2 skipped)"
Write-Host "═══════════════════════"
```

#### 4. Progress Updates
```powershell
$progress = [math]::Floor($completed / $total * 8)
$bar = "█" * $progress + "░" * (8 - $progress)
Write-Host "Progress: [$bar] $completed/$total phases"
```

#### 5. Git Operations
```powershell
Write-Host " main → feature-branch" -ForegroundColor Green
Write-Host "  7 files changed, 234 insertions(+), 12 deletions(-)"
```

#### 6. Validation Results
```powershell
Write-Host "`n┌─ Validation Summary ───────────────┐"
Write-Host "│ Asset Validation      ✓ PASS       │"
Write-Host "│ Lint Check           ✓ PASS       │"
Write-Host "│ Smoke Tests          ✓ PASS       │"
Write-Host "│ Token Budget         ℹ REVIEW     │"
Write-Host "└────────────────────────────────────┘"
```

### Accessibility Requirements

**Always pair glyphs with text labels:**
```powershell
# ✓ GOOD — Accessible
Write-Host "✓ PASS — All assets validated"

# ✗ BAD — Screen reader only sees glyph
Write-Host "✓"
```

**Use ANSI colors for additional context:**
```powershell
Write-Host "✓ Success" -ForegroundColor Green
Write-Host "✗ Error" -ForegroundColor Red
Write-Host "⚠ Warning" -ForegroundColor Yellow
Write-Host "ℹ Info" -ForegroundColor Cyan
```

### ANSI Color Codes

```powershell
# PowerShell -ForegroundColor values
Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, DarkYellow, Gray
DarkGray, Blue, Green, Cyan, Red, Magenta, Yellow, White

# Direct ANSI (for cross-platform scripts)
$ESC = [char]27
Write-Host "$ESC[32m✓ Success$ESC[0m"  # Green
Write-Host "$ESC[31m✗ Error$ESC[0m"    # Red
Write-Host "$ESC[33m⚠ Warning$ESC[0m"  # Yellow
```

## Agent-Specific Guidelines

### Conductor
- Use tree structure for phase progress
- Status summary with emoji + text
- Box drawing for plan/review boundaries

### Implementer
- Progress bars for test execution
- File operation trees (├─┼─)
- Success/failure indicators per test

### Reviewer
- Severity indicators: ✗ BLOCKER, ⚠ MAJOR, ℹ MINOR, ● NIT
- Finding summaries with counts
- Box-drawn verdict sections

### Validation Scripts
- Status summary format: `✓ PASS`, `✗ FAIL`, `⚠ WARN`, `ℹ INFO`
- Tree structure for multi-file validation
- Total counts in box-drawn table

## Examples

### Example 1: Conductor Phase Progress
```powershell
Write-Host "`n┌─ VS Code 1.109 Integration ─────────┐"
Write-Host "│ ✓ Phase 1: Settings & Docs Update  │"
Write-Host "│ ✓ Phase 2: Worktrees Docs Refresh  │"
Write-Host "│ ✓ Phase 3: Terminal Glyphs Style   │"
Write-Host "│ ✓ Phase 4: Terminal Auto-Approve   │"
Write-Host "│ ● Phase 5: Agent Sessions Updates  │"
Write-Host "│ ○ Phase 6: Agent Skills Pilot      │"
Write-Host "│ ○ Phase 7: Rollout & Validation    │"
Write-Host "└──────────────────────────────────────┘"
Write-Host "Progress: [█████░░░] 5/7 phases (71%)"
```

### Example 2: Validation Script Output
```powershell
function Format-ValidationResult {
    param([bool]$Success, [string]$Name, [int]$Warnings = 0)

    if ($Success -and $Warnings -eq 0) {
        Write-Host "✓ PASS" -ForegroundColor Green -NoNewline
        Write-Host " — $Name"
    } elseif ($Success -and $Warnings -gt 0) {
        Write-Host "⚠ WARN" -ForegroundColor Yellow -NoNewline
        Write-Host " — $Name ($Warnings warnings)"
    } else {
        Write-Host "✗ FAIL" -ForegroundColor Red -NoNewline
        Write-Host " — $Name"
    }
}

# Usage
Format-ValidationResult -Success $true -Name "Asset validation"
Format-ValidationResult -Success $true -Name "Lint check" -Warnings 2
Format-ValidationResult -Success $false -Name "Smoke tests"
```

### Example 3: Test Results Summary
```powershell
Write-Host "`n╔═══════════════════════════════════╗"
Write-Host "║   Test Execution Complete        ║"
Write-Host "╠═══════════════════════════════════╣"
Write-Host "║ ✓ Unit Tests        127/127     ║"
Write-Host "║ ✓ Integration       45/45       ║"
Write-Host "║ ⚠ E2E Tests         23/25       ║"
Write-Host "║ ─────────────────────────────── ║"
Write-Host "║ Total:              195/197     ║"
Write-Host "║ Success Rate:       99.0%       ║"
Write-Host "╚═══════════════════════════════════╝"
```

## Fallback Strategies

### When Glyphs Don't Render
If terminal doesn't support Unicode:
```powershell
# Detect console capability
$useUnicode = $Host.UI.SupportsVirtualTerminal -or ($env:TERM -match "xterm|vt100")

if ($useUnicode) {
    Write-Host "✓ Success"
} else {
    Write-Host "[PASS] Success"
}
```

### ASCII Fallback Set
```
✓ → [PASS] or [OK]
✗ → [FAIL] or [X]
⚠ → [WARN] or [!]
ℹ → [INFO] or [i]
● → [*]
○ → [ ]
```

## Testing

Test glyph rendering in your terminal:
```powershell
# Test basic glyphs
Write-Host "Status: ✓ ✗ ⚠ ℹ ● ○"

# Test box drawing
Write-Host "┌─┬─┐"
Write-Host "├─┼─┤"
Write-Host "└─┴─┘"

# Test blocks
Write-Host "Progress: ▁▂▃▄▅▆▇█"

# Test colors
Write-Host "✓ Green" -ForegroundColor Green
Write-Host "✗ Red" -ForegroundColor Red
Write-Host "⚠ Yellow" -ForegroundColor Yellow
```

## References

- Full glyph reference: [docs/guides/terminal-formatting-guide.md](../../../docs/guides/terminal-formatting-guide.md)
- Agent instructions: [instructions/global/terminal-formatting.instructions.md](../../../instructions/global/terminal-formatting.instructions.md)
- VS Code 1.109 terminal features: [docs/guides/vscode-copilot-configuration.md](../../../docs/guides/vscode-copilot-configuration.md)
