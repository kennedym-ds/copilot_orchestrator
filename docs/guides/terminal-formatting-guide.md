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

✅ **No Font Configuration Required** - Works out of the box in VS Code 1.109+

✅ **Perfect Scaling** - Glyphs scale with line height and letter spacing

✅ **Consistent Rendering** - GPU-accelerated for smooth display

✅ **Cross-Platform** - Same output on Windows, macOS, and Linux

✅ **Accessible** - Agents pair glyphs with text labels for screen readers

## Common Glyphs You'll See

### Status Indicators

| Glyph | Meaning | Example Usage |
|-------|---------|---------------|
| ✓ | Success | ✓ Phase 1 Complete [OK] |
| ✗ | Failure | ✗ Build failed [FAIL] |
| ⚠ | Warning | ⚠ 3 lint warnings [WARN] |
| ℹ | Information | ℹ Tip: Use --verbose for details [INFO] |
| ● | In Progress | ● Installing dependencies [...] |
| ○ | Pending | ○ Tests not started [ ] |

### Progress Bars

**Block-Based Progress:**
```
[████████░░] 80% Complete
[▰▰▰▰▰▰▰▱▱▱] 70% Building
```

**Vertical Bars (increasing height):**
```
Performance: ▁▂▃▄▅▆▇█
```

### Tree Structures

**File Trees:**
```
project/
├── src/
│   ├── app.ts
│   └── utils.ts
└── tests/
    └── app.test.ts
```

**Status Trees:**
```
Implementation Plan:
├── ✓ Phase 1: Complete [OK]
├── ● Phase 2: In Progress [...]
└── ○ Phase 3: Pending [ ]
```

### Section Dividers

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
─── Phase 3: Terminal Glyphs ───
```

## Real-World Examples

### Agent Status Updates

When the Conductor agent runs a multi-phase plan, you'll see:

```
Multi-Phase Implementation:
├── ✓ Phase 1: Settings Update [Complete]
├── ✓ Phase 2: Worktrees Documentation [Complete]
├── ● Phase 3: Terminal Glyphs [In Progress]
├── ○ Phase 4: Auto-Approve [Not Started]
└── ○ Phase 5: Sessions [Not Started]

Current Progress: ▰▰▰▰▰▰▱▱▱▱ 60%
```

### Test Results

When the Test agent runs your test suite:

```
Test Suite: Authentication Module
  ✓ User login with valid credentials [OK]
  ✓ Password hashing verification [OK]
  ✗ Rate limiting enforcement [FAIL]
    └── Expected 429, got 200
  ⚠ Token expiration test (slow: 5.2s) [WARN]

Summary: 2 passed, 1 failed, 1 warning
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Code Review Findings

When the Reviewer agent audits changes:

```
Review Findings:
├── ✗ BLOCKER: Missing input validation [FAIL]
│   ├── File: auth.ts:45
│   └── Fix: Add null checks for user input
├── ⚠ MAJOR: Unhandled error case [WARN]
│   ├── File: api.ts:123
│   └── Recommendation: Add try-catch block
└── ℹ NIT: Consider using const [INFO]
    └── File: utils.ts:67

Severity Distribution: █ 1 Blocker, █ 1 Major, ░ 1 Nit
```

### Git Operations

When agents perform Git operations:

```
Git Status:
├── branch: vscode-1.108-integration
├── ✓ No uncommitted changes [OK]
└── ℹ 3 commits ahead of origin/main [INFO]

Recent Commits:
├── abc1234 - feat: Add terminal glyphs (2 hours ago)
├── def5678 - docs: Update VS Code settings (4 hours ago)
└── ghi9012 - fix: Remove deprecated orientation (6 hours ago)
```

### Build Progress

When the Implementer agent builds your project:

```
Building Application...
▰▰▰▰▰▰▰▰▱▱ 80%
  ├── ✓ TypeScript compilation [OK]
  ├── ✓ CSS processing [OK]
  ├── ● Image optimization [...]
  │   └── Progress: 45/67 files
  └── ○ Service worker generation [Pending]

Estimated Time Remaining: 2m 15s
```

## Using Glyphs in Your Own Scripts

### PowerShell Example

```powershell
# Status indicators
Write-Host "✓ Validation passed" -ForegroundColor Green
Write-Host "⚠ 3 warnings found" -ForegroundColor Yellow
Write-Host "✗ Build failed" -ForegroundColor Red

# Progress bar
$percent = 75
$filled = [Math]::Floor($percent / 10)
$empty = 10 - $filled
$bar = ("▰" * $filled) + ("▱" * $empty)
Write-Host "$bar $percent%"

# Tree structure
Write-Host "Results:"
Write-Host "├── ✓ Phase 1 [OK]"
Write-Host "├── ✓ Phase 2 [OK]"
Write-Host "└── ● Phase 3 [...]"
```

### Python Example

```python
# Status indicators
print("✓ Tests passed [OK]")
print("⚠ Deprecation warning [WARN]")
print("✗ Build failed [FAIL]")

# Progress bar
def progress_bar(percent):
    filled = int(percent / 10)
    empty = 10 - filled
    bar = "▰" * filled + "▱" * empty
    return f"{bar} {percent}%"

print(progress_bar(80))

# Tree structure
print("File Changes:")
print("├── src/")
print("│   ├── app.ts [Modified]")
print("│   └── utils.ts [New]")
print("└── tests/")
print("    └── app.test.ts [Modified]")
```

### Bash Example

```bash
#!/bin/bash

# Status indicators
echo "✓ Deployment successful [OK]"
echo "⚠ Rate limit approaching [WARN]"
echo "✗ Connection failed [FAIL]"

# Progress bar
progress_bar() {
    local percent=$1
    local filled=$((percent / 10))
    local empty=$((10 - filled))
    printf "["
    printf "▰%.0s" $(seq 1 $filled)
    printf "▱%.0s" $(seq 1 $empty)
    printf "] %d%%\n" $percent
}

progress_bar 70

# Tree structure
echo "Server Status:"
echo "├── ✓ API Server [Running]"
echo "├── ✓ Database [Connected]"
echo "└── ⚠ Cache [Warning]"
```

## Accessibility Considerations

All agent output follows accessibility best practices:

### ✅ Glyphs Always Paired with Text

```
✓ Test passed [OK]
✗ Test failed [FAIL]
● In progress [...]
```

### ✅ Semantic Structure for Screen Readers

```
Phase 3 Status: Success
  - Created formatting instructions: Success
  - Created user guide: Success
  - All validations: Passed
```

### ✅ Color + Symbol + Text

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
| ─ | U+2500 | Horizontal | Dividers, underlines |
| │ | U+2502 | Vertical | Trees, borders |
| ┌ | U+250C | Top-left | Box corners |
| ┐ | U+2510 | Top-right | Box corners |
| └ | U+2514 | Bottom-left | Box corners, tree ends |
| ┘ | U+2518 | Bottom-right | Box corners |
| ├ | U+251C | Left T | Tree branches |
| ┤ | U+2524 | Right T | Borders |
| ┬ | U+252C | Top T | Headers |
| ┴ | U+2534 | Bottom T | Footers |
| ┼ | U+253C | Cross | Grid intersections |
| ═ | U+2550 | Double horizontal | Emphasis |
| ║ | U+2551 | Double vertical | Strong borders |

### Block Elements

| Glyph | Unicode | Name | Usage |
|-------|---------|------|-------|
| ▁ | U+2581 | Lower 1/8 | Sparklines, progress |
| ▂ | U+2582 | Lower 1/4 | Sparklines, progress |
| ▃ | U+2583 | Lower 3/8 | Sparklines, progress |
| ▄ | U+2584 | Lower 1/2 | Sparklines, progress |
| ▅ | U+2585 | Lower 5/8 | Sparklines, progress |
| ▆ | U+2586 | Lower 3/4 | Sparklines, progress |
| ▇ | U+2587 | Lower 7/8 | Sparklines, progress |
| █ | U+2588 | Full block | Progress bars, solid fills |
| ▰ | U+25B0 | Filled rectangle | Progress bars |
| ▱ | U+25B1 | Empty rectangle | Progress bars |
| ░ | U+2591 | Light shade | Light fills |
| ▒ | U+2592 | Medium shade | Medium fills |
| ▓ | U+2593 | Dark shade | Dark fills |

### Status Symbols

| Glyph | Unicode | Name | Usage |
|-------|---------|------|-------|
| ✓ | U+2713 | Check mark | Success, passed |
| ✗ | U+2717 | Ballot X | Failure, failed |
| ✕ | U+2715 | Multiplication X | Error, cancelled |
| ⚠ | U+26A0 | Warning sign | Warnings, cautions |
| ⚡ | U+26A1 | Lightning | Fast, performance |
| ⏱ | U+23F1 | Stopwatch | Timing, duration |
| ℹ | U+2139 | Information | Info, tips |
| ● | U+25CF | Black circle | Active, in progress |
| ○ | U+25CB | White circle | Inactive, pending |
| ◉ | U+25C9 | Fisheye | Selected, focused |

### Braille Patterns (Examples)

| Pattern | Unicode | Usage |
|---------|---------|-------|
| ⠀⠁⠃⠇⠏⠟⠿ | U+2800-28FF | Sparklines, trends |
| ⡀⡄⡆⡇⣇⣧⣷⣿ | U+2800-28FF | Density visualization |

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
✓ Test passed [OK]  ← Screen reader: "Test passed OK"
```

### Colors Don't Show in External Terminal

**Cause:** External terminals may not support ANSI color codes

**Solution:**
Use VS Code integrated terminal where agents are designed to run. If using external terminals, focus on glyphs and text labels rather than colors.

## Examples Gallery

### Validation Summary

```
Validation Summary:
┌─────────────────────────────────────┐
│ Lint Check:        ✓ Passed [OK]    │
│ Asset Validation:  ✓ Passed [OK]    │
│ Type Check:        ✓ Passed [OK]    │
│ Tests:             ✓ Passed [OK]    │
│ Coverage:          87% ▇▇▇▇▇▇▇▇▇░    │
└─────────────────────────────────────┘
```

### Deployment Status

```
Deployment Progress:
┌────────────────────────────────────────┐
│ Stage                     Status       │
├────────────────────────────────────────┤
│ Build                     ✓ Complete   │
│ Unit Tests                ✓ Complete   │
│ Integration Tests         ● Running    │
│ Security Scan             ○ Pending    │
│ Deploy to Staging         ○ Pending    │
│ Deploy to Production      ○ Pending    │
└────────────────────────────────────────┘

Overall Progress: ▰▰▰▱▱▱▱▱▱▱ 30%
```

### Performance Metrics

```
Performance Metrics (Last 24 Hours):
├── Response Time:  ▁▂▃▄▅▆▇█ 245ms (p95)
├── Throughput:     ▃▄▅▆▇▇▇▆ 1,234 req/s
├── Error Rate:     ▁▁▁▂▁▁▁▁ 0.02%
└── CPU Usage:      ▃▄▅▄▃▃▄▅ 45% avg

Status: ✓ All systems operational [OK]
```

### Code Review Summary

```
Code Review: Feature Branch (45 files changed)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Findings by Severity:
├── ✗ BLOCKER:  0 [OK]
├── ⚠ MAJOR:    2 [WARN]
├── ℹ MINOR:    5 [INFO]
└── ℹ NIT:      8 [INFO]

Modified Files:
├── src/
│   ├── ⚠ auth.ts (3 findings)
│   ├── ℹ api.ts (1 finding)
│   └── ✓ utils.ts (no issues)
└── tests/
    ├── ✓ auth.test.ts (no issues)
    └── ℹ api.test.ts (2 findings)

Recommendation: ⚠ Address 2 major findings before merge [WARN]
```

## Best Practices

### DO ✓

- Pair glyphs with text labels: `✓ Success [OK]`
- Use consistent glyphs for the same meaning
- Test output in Accessible View
- Provide ASCII fallbacks in scripts
- Use semantic colors (green = success, red = error)

### DON'T ✗

- Use glyphs without text labels: `✓` alone
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
