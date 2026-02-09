---
title: "Terminal Formatting Guide"
version: "1.0.0"
created: "2026-01-09"
status: stable
audience: ["developers", "users"]
---

# Terminal Formatting Guide

> **Feature:** VS Code 1.109+ GPU-Accelerated Terminal Glyphs

## Overview

VS Code 1.108 introduced support for ~800 custom glyphs that render perfectly in the integrated terminal using GPU acceleration. These glyphs require no custom fonts and provide beautiful, accessible formatting for agent output, scripts, and terminal applications.

This guide shows you how to use these glyphs effectively in your terminal output and understand the formatting you see from Copilot agents.

## What Are Terminal Glyphs?

Terminal glyphs are special Unicode characters that VS Code 1.109+ renders directly using its GPU-accelerated renderer. They include:

- **Box Drawing** - Lines, corners, and junctions for structure
- **Block Elements** - Solid and shaded blocks for progress bars
- **Braille Patterns** - Lightweight dots for sparklines and mini-charts
- **Powerline Symbols** - Status bar icons and separators
- **Progress Indicators** - Dedicated symbols for loading states
- **Git Branch Symbols** - Icons for version control operations

## Benefits

âœ… **No Font Configuration Required** - Works out of the box in VS Code 1.109+

âœ… **Perfect Scaling** - Glyphs scale with line height and letter spacing

âœ… **Consistent Rendering** - GPU-accelerated for smooth display

âœ… **Cross-Platform** - Same output on Windows, macOS, and Linux

âœ… **Accessible** - Agents pair glyphs with text labels for screen readers

## Common Glyphs You'll See

### Status Indicators

| Glyph | Meaning | Example Usage |
|-------|---------|---------------|
| âœ“ | Success | âœ“ Phase 1 Complete [OK] |
| âœ— | Failure | âœ— Build failed [FAIL] |
| âš  | Warning | âš  3 lint warnings [WARN] |
| â„¹ | Information | â„¹ Tip: Use --verbose for details [INFO] |
| â— | In Progress | â— Installing dependencies [...] |
| â—‹ | Pending | â—‹ Tests not started [ ] |

### Progress Bars

**Block-Based Progress:**
```
[â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–‘â–‘] 80% Complete
[â–°â–°â–°â–°â–°â–°â–°â–±â–±â–±] 70% Building
```

**Vertical Bars (increasing height):**
```
Performance: â–â–‚â–ƒâ–„â–…â–†â–‡â–ˆ
```

### Tree Structures

**File Trees:**
```
project/
â”œâ”€â”€ src/
â”‚   â”œâ”€â”€ app.ts
â”‚   â””â”€â”€ utils.ts
â””â”€â”€ tests/
    â””â”€â”€ app.test.ts
```

**Status Trees:**
```
Implementation Plan:
â”œâ”€â”€ âœ“ Phase 1: Complete [OK]
â”œâ”€â”€ â— Phase 2: In Progress [...]
â””â”€â”€ â—‹ Phase 3: Pending [ ]
```

### Section Dividers

```
â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
â”€â”€â”€ Phase 3: Terminal Glyphs â”€â”€â”€
```

## Real-World Examples

### Agent Status Updates

When the Conductor agent runs a multi-phase plan, you'll see:

```
Multi-Phase Implementation:
â”œâ”€â”€ âœ“ Phase 1: Settings Update [Complete]
â”œâ”€â”€ âœ“ Phase 2: Worktrees Documentation [Complete]
â”œâ”€â”€ â— Phase 3: Terminal Glyphs [In Progress]
â”œâ”€â”€ â—‹ Phase 4: Auto-Approve [Not Started]
â””â”€â”€ â—‹ Phase 5: Sessions [Not Started]

Current Progress: â–°â–°â–°â–°â–°â–°â–±â–±â–±â–± 60%
```

### Test Results

When the Test agent runs your test suite:

```
Test Suite: Authentication Module
  âœ“ User login with valid credentials [OK]
  âœ“ Password hashing verification [OK]
  âœ— Rate limiting enforcement [FAIL]
    â””â”€â”€ Expected 429, got 200
  âš  Token expiration test (slow: 5.2s) [WARN]

Summary: 2 passed, 1 failed, 1 warning
â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
```

### Code Review Findings

When the Reviewer agent audits changes:

```
Review Findings:
â”œâ”€â”€ âœ— BLOCKER: Missing input validation [FAIL]
â”‚   â”œâ”€â”€ File: auth.ts:45
â”‚   â””â”€â”€ Fix: Add null checks for user input
â”œâ”€â”€ âš  MAJOR: Unhandled error case [WARN]
â”‚   â”œâ”€â”€ File: api.ts:123
â”‚   â””â”€â”€ Recommendation: Add try-catch block
â””â”€â”€ â„¹ NIT: Consider using const [INFO]
    â””â”€â”€ File: utils.ts:67

Severity Distribution: â–ˆ 1 Blocker, â–ˆ 1 Major, â–‘ 1 Nit
```

### Git Operations

When agents perform Git operations:

```
Git Status:
â”œâ”€â”€ branch: vscode-1.108-integration
â”œâ”€â”€ âœ“ No uncommitted changes [OK]
â””â”€â”€ â„¹ 3 commits ahead of origin/main [INFO]

Recent Commits:
â”œâ”€â”€ abc1234 - feat: Add terminal glyphs (2 hours ago)
â”œâ”€â”€ def5678 - docs: Update VS Code settings (4 hours ago)
â””â”€â”€ ghi9012 - fix: Remove deprecated orientation (6 hours ago)
```

### Build Progress

When the Implementer agent builds your project:

```
Building Application...
â–°â–°â–°â–°â–°â–°â–°â–°â–±â–± 80%
  â”œâ”€â”€ âœ“ TypeScript compilation [OK]
  â”œâ”€â”€ âœ“ CSS processing [OK]
  â”œâ”€â”€ â— Image optimization [...]
  â”‚   â””â”€â”€ Progress: 45/67 files
  â””â”€â”€ â—‹ Service worker generation [Pending]

Estimated Time Remaining: 2m 15s
```

## Using Glyphs in Your Own Scripts

### PowerShell Example

```powershell
# Status indicators
Write-Host "âœ“ Validation passed" -ForegroundColor Green
Write-Host "âš  3 warnings found" -ForegroundColor Yellow
Write-Host "âœ— Build failed" -ForegroundColor Red

# Progress bar
$percent = 75
$filled = [Math]::Floor($percent / 10)
$empty = 10 - $filled
$bar = ("â–°" * $filled) + ("â–±" * $empty)
Write-Host "$bar $percent%"

# Tree structure
Write-Host "Results:"
Write-Host "â”œâ”€â”€ âœ“ Phase 1 [OK]"
Write-Host "â”œâ”€â”€ âœ“ Phase 2 [OK]"
Write-Host "â””â”€â”€ â— Phase 3 [...]"
```

### Python Example

```python
# Status indicators
print("âœ“ Tests passed [OK]")
print("âš  Deprecation warning [WARN]")
print("âœ— Build failed [FAIL]")

# Progress bar
def progress_bar(percent):
    filled = int(percent / 10)
    empty = 10 - filled
    bar = "â–°" * filled + "â–±" * empty
    return f"{bar} {percent}%"

print(progress_bar(80))

# Tree structure
print("File Changes:")
print("â”œâ”€â”€ src/")
print("â”‚   â”œâ”€â”€ app.ts [Modified]")
print("â”‚   â””â”€â”€ utils.ts [New]")
print("â””â”€â”€ tests/")
print("    â””â”€â”€ app.test.ts [Modified]")
```

### Bash Example

```bash
#!/bin/bash

# Status indicators
echo "âœ“ Deployment successful [OK]"
echo "âš  Rate limit approaching [WARN]"
echo "âœ— Connection failed [FAIL]"

# Progress bar
progress_bar() {
    local percent=$1
    local filled=$((percent / 10))
    local empty=$((10 - filled))
    printf "["
    printf "â–°%.0s" $(seq 1 $filled)
    printf "â–±%.0s" $(seq 1 $empty)
    printf "] %d%%\n" $percent
}

progress_bar 70

# Tree structure
echo "Server Status:"
echo "â”œâ”€â”€ âœ“ API Server [Running]"
echo "â”œâ”€â”€ âœ“ Database [Connected]"
echo "â””â”€â”€ âš  Cache [Warning]"
```

## Accessibility Considerations

All agent output follows accessibility best practices:

### âœ… Glyphs Always Paired with Text

```
âœ“ Test passed [OK]
âœ— Test failed [FAIL]
â— In progress [...]
```

### âœ… Semantic Structure for Screen Readers

```
Phase 3 Status: Success
  - Created formatting instructions: Success
  - Created user guide: Success
  - All validations: Passed
```

### âœ… Color + Symbol + Text

Visual indicators use multiple channels:
- **Glyph:** Visual symbol
- **Color:** Red/Green/Yellow
- **Text:** Explicit status label [OK], [FAIL], [WARN]

### How to Test Accessibility

1. **Open Accessible View:** Press `Alt+H` in VS Code
2. **Screen Reader:** Use built-in or third-party screen reader
3. **Verify:** Ensure all information is conveyed through text alone

## Glyph Reference Tables

### Box Drawing Characters

| Glyph | Unicode | Name | Usage |
|-------|---------|------|-------|
| â”€ | U+2500 | Horizontal | Dividers, underlines |
| â”‚ | U+2502 | Vertical | Trees, borders |
| â”Œ | U+250C | Top-left | Box corners |
| â” | U+2510 | Top-right | Box corners |
| â”” | U+2514 | Bottom-left | Box corners, tree ends |
| â”˜ | U+2518 | Bottom-right | Box corners |
| â”œ | U+251C | Left T | Tree branches |
| â”¤ | U+2524 | Right T | Borders |
| â”¬ | U+252C | Top T | Headers |
| â”´ | U+2534 | Bottom T | Footers |
| â”¼ | U+253C | Cross | Grid intersections |
| â• | U+2550 | Double horizontal | Emphasis |
| â•‘ | U+2551 | Double vertical | Strong borders |

### Block Elements

| Glyph | Unicode | Name | Usage |
|-------|---------|------|-------|
| â– | U+2581 | Lower 1/8 | Sparklines, progress |
| â–‚ | U+2582 | Lower 1/4 | Sparklines, progress |
| â–ƒ | U+2583 | Lower 3/8 | Sparklines, progress |
| â–„ | U+2584 | Lower 1/2 | Sparklines, progress |
| â–… | U+2585 | Lower 5/8 | Sparklines, progress |
| â–† | U+2586 | Lower 3/4 | Sparklines, progress |
| â–‡ | U+2587 | Lower 7/8 | Sparklines, progress |
| â–ˆ | U+2588 | Full block | Progress bars, solid fills |
| â–° | U+25B0 | Filled rectangle | Progress bars |
| â–± | U+25B1 | Empty rectangle | Progress bars |
| â–‘ | U+2591 | Light shade | Light fills |
| â–’ | U+2592 | Medium shade | Medium fills |
| â–“ | U+2593 | Dark shade | Dark fills |

### Status Symbols

| Glyph | Unicode | Name | Usage |
|-------|---------|------|-------|
| âœ“ | U+2713 | Check mark | Success, passed |
| âœ— | U+2717 | Ballot X | Failure, failed |
| âœ• | U+2715 | Multiplication X | Error, cancelled |
| âš  | U+26A0 | Warning sign | Warnings, cautions |
| âš¡ | U+26A1 | Lightning | Fast, performance |
| â± | U+23F1 | Stopwatch | Timing, duration |
| â„¹ | U+2139 | Information | Info, tips |
| â— | U+25CF | Black circle | Active, in progress |
| â—‹ | U+25CB | White circle | Inactive, pending |
| â—‰ | U+25C9 | Fisheye | Selected, focused |

### Braille Patterns (Examples)

| Pattern | Unicode | Usage |
|---------|---------|-------|
| â €â â ƒâ ‡â â Ÿâ ¿ | U+2800-28FF | Sparklines, trends |
| â¡€â¡„â¡†â¡‡â£‡â£§â£·â£¿ | U+2800-28FF | Density visualization |

## Terminal Settings

### Recommended VS Code Settings

```json
{
  "terminal.integrated.gpuAcceleration": "on",
  "terminal.integrated.fontFamily": "Cascadia Code, Consolas, monospace",
  "terminal.integrated.fontSize": 14,
  "terminal.integrated.lineHeight": 1.2
}
```

### Font Recommendations

While glyphs work without special fonts, these fonts provide excellent overall terminal experience:

- **Cascadia Code** (Windows, cross-platform)
- **Fira Code** (Cross-platform)
- **JetBrains Mono** (Cross-platform)
- **SF Mono** (macOS)
- **Consolas** (Windows fallback)

## Troubleshooting

### Glyphs Appear as Boxes or Question Marks

**Cause:** Not using VS Code 1.109+ or GPU acceleration disabled

**Solution:**
1. Update to VS Code 1.109 or later
2. Enable GPU acceleration: `"terminal.integrated.gpuAcceleration": "on"`
3. Restart VS Code

### Glyphs Are Misaligned

**Cause:** Font doesn't have proper metrics for Unicode characters

**Solution:**
1. Try a recommended font (Cascadia Code, Fira Code)
2. Adjust line height: `"terminal.integrated.lineHeight": 1.2`
3. Ensure font size is reasonable (12-16pt)

### Screen Reader Announces Glyphs Incorrectly

**This is expected.** All agent output includes text labels specifically for screen readers:

```
âœ“ Test passed [OK]  â† Screen reader: "Test passed OK"
```

### Colors Don't Show in External Terminal

**Cause:** External terminals may not support ANSI color codes

**Solution:**
Use VS Code integrated terminal where agents are designed to run. If using external terminals, focus on glyphs and text labels rather than colors.

## Examples Gallery

### Validation Summary

```
Validation Summary:
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Lint Check:        âœ“ Passed [OK]    â”‚
â”‚ Asset Validation:  âœ“ Passed [OK]    â”‚
â”‚ Type Check:        âœ“ Passed [OK]    â”‚
â”‚ Tests:             âœ“ Passed [OK]    â”‚
â”‚ Coverage:          87% â–‡â–‡â–‡â–‡â–‡â–‡â–‡â–‡â–‡â–‘    â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### Deployment Status

```
Deployment Progress:
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Stage                     Status       â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ Build                     âœ“ Complete   â”‚
â”‚ Unit Tests                âœ“ Complete   â”‚
â”‚ Integration Tests         â— Running    â”‚
â”‚ Security Scan             â—‹ Pending    â”‚
â”‚ Deploy to Staging         â—‹ Pending    â”‚
â”‚ Deploy to Production      â—‹ Pending    â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

Overall Progress: â–°â–°â–°â–±â–±â–±â–±â–±â–±â–± 30%
```

### Performance Metrics

```
Performance Metrics (Last 24 Hours):
â”œâ”€â”€ Response Time:  â–â–‚â–ƒâ–„â–…â–†â–‡â–ˆ 245ms (p95)
â”œâ”€â”€ Throughput:     â–ƒâ–„â–…â–†â–‡â–‡â–‡â–† 1,234 req/s
â”œâ”€â”€ Error Rate:     â–â–â–â–‚â–â–â–â– 0.02%
â””â”€â”€ CPU Usage:      â–ƒâ–„â–…â–„â–ƒâ–ƒâ–„â–… 45% avg

Status: âœ“ All systems operational [OK]
```

### Code Review Summary

```
Code Review: Feature Branch (45 files changed)
â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”

Findings by Severity:
â”œâ”€â”€ âœ— BLOCKER:  0 [OK]
â”œâ”€â”€ âš  MAJOR:    2 [WARN]
â”œâ”€â”€ â„¹ MINOR:    5 [INFO]
â””â”€â”€ â„¹ NIT:      8 [INFO]

Modified Files:
â”œâ”€â”€ src/
â”‚   â”œâ”€â”€ âš  auth.ts (3 findings)
â”‚   â”œâ”€â”€ â„¹ api.ts (1 finding)
â”‚   â””â”€â”€ âœ“ utils.ts (no issues)
â””â”€â”€ tests/
    â”œâ”€â”€ âœ“ auth.test.ts (no issues)
    â””â”€â”€ â„¹ api.test.ts (2 findings)

Recommendation: âš  Address 2 major findings before merge [WARN]
```

## Best Practices

### DO âœ“

- Pair glyphs with text labels: `âœ“ Success [OK]`
- Use consistent glyphs for the same meaning
- Test output in Accessible View
- Provide ASCII fallbacks in scripts
- Use semantic colors (green = success, red = error)

### DON'T âœ—

- Use glyphs without text labels: `âœ“` alone
- Mix different styles for the same concept
- Overuse dividers and decorative elements
- Assume all terminals support glyphs
- Rely solely on color to convey meaning

## Related Resources

- [VS Code 1.108 Release Notes](https://code.visualstudio.com/updates/v1_108)
- [Terminal Formatting Instructions](../../instructions/global/terminal-formatting.instructions.md) - For agent developers
- [VS Code Terminal Documentation](https://code.visualstudio.com/docs/terminal/basics)
- [Unicode Box Drawing](https://en.wikipedia.org/wiki/Box-drawing_character)
- [Accessible Terminal Output](https://code.visualstudio.com/docs/editor/accessibility)

## Feedback

Have suggestions for improving terminal formatting? Open an issue in the repository or update `docs/operations.md` with your recommendations.

---

**Version:** 1.0.0
**Created:** January 2026 (VS Code 1.109)
**Maintainer:** Copilot Orchestrator Team
