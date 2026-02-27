---
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
- `âœ“` (U+2713) â€” Success, passed, approved
- `âœ—` (U+2717) â€” Failure, error, rejected
- `âš ` (U+26A0) â€” Warning, caution, attention needed
- `â„¹` (U+2139) â€” Information, note, guidance
- `â—` (U+25CF) â€” Active state, in-progress
- `â—‹` (U+25CB) â€” Inactive state, pending

#### Box Drawing (U+2500-U+257F)
```
â”Œâ”€â”¬â”€â”  â•”â•â•¦â•â•—  â•­â”€â”¬â”€â•®
â”œâ”€â”¼â”€â”¤  â• â•â•¬â•â•£  â”œâ”€â”¼â”€â”¤
â””â”€â”´â”€â”˜  â•šâ•â•©â•â•  â•°â”€â”´â”€â•¯
â”‚ â”€    â•‘ â•    â”‚ â”€
```

#### Block Elements (U+2580-U+259F)
- `â–â–‚â–ƒâ–„â–…â–†â–‡â–ˆ` â€” Progress bars (8 levels)
- `â–‘â–’â–“â–ˆ` â€” Density indicators

#### Progress Indicators (U+EE00-U+EE0B)
- ` ` â€” Spinner frames for loading
- Combine with timer for animated progress

#### Git Symbols (U+F5D0-U+F60D)
- `` (U+E0A0) â€” Branch indicator
- `` (U+E0B0) â€” Powerline separator

### Formatting Patterns

#### 1. Status Summary
```powershell
Write-Host "âœ“ All Copilot assets passed validation." -ForegroundColor Green
Write-Host "âš  2 warnings found in documentation." -ForegroundColor Yellow
Write-Host "âœ— Build failed with 3 errors." -ForegroundColor Red
Write-Host "â„¹ Use -Verbose flag for detailed output." -ForegroundColor Cyan
```

#### 2. File Operations
```powershell
Write-Host "â”Œâ”€ Phase 3: Terminal Glyphs Style Guide"
Write-Host "â”œâ”€â”€ âœ“ Created instructions/global/terminal-formatting.instructions.md"
Write-Host "â”œâ”€â”€ âœ“ Created docs/guides/terminal-formatting-guide.md"
Write-Host "â””â”€â”€ â— Validating changes..."
```

#### 3. Test Results
```powershell
Write-Host "`nâ•â•â• Test Results â•â•â•"
Write-Host "âœ“ Unit Tests:     42/42 passed"
Write-Host "âœ“ Integration:    15/15 passed"
Write-Host "âš  E2E Tests:      8/10 passed (2 skipped)"
Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•"
```

#### 4. Progress Updates
```powershell
$progress = [math]::Floor($completed / $total * 8)
$bar = "â–ˆ" * $progress + "â–‘" * (8 - $progress)
Write-Host "Progress: [$bar] $completed/$total phases"
```

#### 5. Git Operations
```powershell
Write-Host " main â†’ feature-branch" -ForegroundColor Green
Write-Host "  7 files changed, 234 insertions(+), 12 deletions(-)"
```

#### 6. Validation Results
```powershell
Write-Host "`nâ”Œâ”€ Validation Summary â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”"
Write-Host "â”‚ Asset Validation      âœ“ PASS       â”‚"
Write-Host "â”‚ Lint Check           âœ“ PASS       â”‚"
Write-Host "â”‚ Smoke Tests          âœ“ PASS       â”‚"
Write-Host "â”‚ Token Budget         â„¹ REVIEW     â”‚"
Write-Host "â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜"
```

### Accessibility Requirements

**Always pair glyphs with text labels:**
```powershell
# âœ“ GOOD â€” Accessible
Write-Host "âœ“ PASS â€” All assets validated"

# âœ— BAD â€” Screen reader only sees glyph
Write-Host "âœ“"
```

**Use ANSI colors for additional context:**
```powershell
Write-Host "âœ“ Success" -ForegroundColor Green
Write-Host "âœ— Error" -ForegroundColor Red
Write-Host "âš  Warning" -ForegroundColor Yellow
Write-Host "â„¹ Info" -ForegroundColor Cyan
```

### ANSI Color Codes

```powershell
# PowerShell -ForegroundColor values
Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, DarkYellow, Gray
DarkGray, Blue, Green, Cyan, Red, Magenta, Yellow, White

# Direct ANSI (for cross-platform scripts)
$ESC = [char]27
Write-Host "$ESC[32mâœ“ Success$ESC[0m"  # Green
Write-Host "$ESC[31mâœ— Error$ESC[0m"    # Red
Write-Host "$ESC[33mâš  Warning$ESC[0m"  # Yellow
```

## Agent-Specific Guidelines

### Conductor
- Use tree structure for phase progress
- Status summary with emoji + text
- Box drawing for plan/review boundaries

### Implementer
- Progress bars for test execution
- File operation trees (â”œâ”€â”¼â”€)
- Success/failure indicators per test

### Reviewer
- Severity indicators: âœ— BLOCKER, âš  MAJOR, â„¹ MINOR, â— NIT
- Finding summaries with counts
- Box-drawn verdict sections

### Validation Scripts
- Status summary format: `âœ“ PASS`, `âœ— FAIL`, `âš  WARN`, `â„¹ INFO`
- Tree structure for multi-file validation
- Total counts in box-drawn table

## Examples

### Example 1: Conductor Phase Progress
```powershell
Write-Host "`nâ”Œâ”€ VS Code 1.109 Integration â”€â”€â”€â”€â”€â”€â”€â”€â”€â”"
Write-Host "â”‚ âœ“ Phase 1: Settings & Docs Update  â”‚"
Write-Host "â”‚ âœ“ Phase 2: Worktrees Docs Refresh  â”‚"
Write-Host "â”‚ âœ“ Phase 3: Terminal Glyphs Style   â”‚"
Write-Host "â”‚ âœ“ Phase 4: Terminal Auto-Approve   â”‚"
Write-Host "â”‚ â— Phase 5: Agent Sessions Updates  â”‚"
Write-Host "â”‚ â—‹ Phase 6: Agent Skills Pilot      â”‚"
Write-Host "â”‚ â—‹ Phase 7: Rollout & Validation    â”‚"
Write-Host "â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜"
Write-Host "Progress: [â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–‘â–‘â–‘] 5/7 phases (71%)"
```

### Example 2: Validation Script Output
```powershell
function Format-ValidationResult {
    param([bool]$Success, [string]$Name, [int]$Warnings = 0)

    if ($Success -and $Warnings -eq 0) {
        Write-Host "âœ“ PASS" -ForegroundColor Green -NoNewline
        Write-Host " â€” $Name"
    } elseif ($Success -and $Warnings -gt 0) {
        Write-Host "âš  WARN" -ForegroundColor Yellow -NoNewline
        Write-Host " â€” $Name ($Warnings warnings)"
    } else {
        Write-Host "âœ— FAIL" -ForegroundColor Red -NoNewline
        Write-Host " â€” $Name"
    }
}

# Usage
Format-ValidationResult -Success $true -Name "Asset validation"
Format-ValidationResult -Success $true -Name "Lint check" -Warnings 2
Format-ValidationResult -Success $false -Name "Smoke tests"
```

### Example 3: Test Results Summary
```powershell
Write-Host "`nâ•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—"
Write-Host "â•‘   Test Execution Complete        â•‘"
Write-Host "â• â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•£"
Write-Host "â•‘ âœ“ Unit Tests        127/127     â•‘"
Write-Host "â•‘ âœ“ Integration       45/45       â•‘"
Write-Host "â•‘ âš  E2E Tests         23/25       â•‘"
Write-Host "â•‘ â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ â•‘"
Write-Host "â•‘ Total:              195/197     â•‘"
Write-Host "â•‘ Success Rate:       99.0%       â•‘"
Write-Host "â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•"
```

## Fallback Strategies

### When Glyphs Don't Render
If terminal doesn't support Unicode:
```powershell
# Detect console capability
$useUnicode = $Host.UI.SupportsVirtualTerminal -or ($env:TERM -match "xterm|vt100")

if ($useUnicode) {
    Write-Host "âœ“ Success"
} else {
    Write-Host "[PASS] Success"
}
```

### ASCII Fallback Set
```
âœ“ â†’ [PASS] or [OK]
âœ— â†’ [FAIL] or [X]
âš  â†’ [WARN] or [!]
â„¹ â†’ [INFO] or [i]
â— â†’ [*]
â—‹ â†’ [ ]
```

## Testing

Test glyph rendering in your terminal:
```powershell
# Test basic glyphs
Write-Host "Status: âœ“ âœ— âš  â„¹ â— â—‹"

# Test box drawing
Write-Host "â”Œâ”€â”¬â”€â”"
Write-Host "â”œâ”€â”¼â”€â”¤"
Write-Host "â””â”€â”´â”€â”˜"

# Test blocks
Write-Host "Progress: â–â–‚â–ƒâ–„â–…â–†â–‡â–ˆ"

# Test colors
Write-Host "âœ“ Green" -ForegroundColor Green
Write-Host "âœ— Red" -ForegroundColor Red
Write-Host "âš  Yellow" -ForegroundColor Yellow
```

## References

- Full glyph reference: [docs/guides/terminal-formatting-guide.md](../../../docs/guides/terminal-formatting-guide.md)
- Agent instructions: [instructions/global/terminal-formatting.instructions.md](../../../instructions/global/terminal-formatting.instructions.md)
- VS Code 1.109 terminal features: [docs/guides/vscode-copilot-configuration.md](../../../docs/guides/vscode-copilot-configuration.md)
