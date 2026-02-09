---
title: "Terminal Formatting Instructions"
description: "Standard formatting patterns for agent terminal output using VS Code 1.109's GPU-accelerated custom glyphs. Defines canonical symbol sets, accessibility requirements, and formatting patterns for all agents."
version: "1.0.0"
created: "2026-01-09"
status: stable
applyTo: "**"
priority: medium
---

# Terminal Formatting Instructions for Agents

## Purpose

This instruction file defines standard formatting patterns for agent terminal output using VS Code 1.109's ~800 GPU-accelerated custom glyphs. These glyphs render perfectly without custom fonts and scale with line height and letter spacing.

## When to Apply

Apply these formatting guidelines when agents produce:
- Status messages and progress updates
- Phase completion summaries
- Validation results
- Git operation summaries
- Test execution reports
- Error and warning messages

## Core Principles

1. **Accessibility First**: Always pair glyphs with text labels for screen readers
2. **ASCII Fallback**: Provide plain-text alternatives for environments without glyph support
3. **Semantic Clarity**: Use glyphs to enhance meaning, not replace it
4. **Consistency**: Use the same glyph for the same semantic meaning across all agents
5. **Restraint**: Don't overuse glyphs; use them for key information points

## Canonical Glyph Set

### Status Indicators

| Symbol | Unicode | Meaning | Text Alternative | Usage |
|--------|---------|---------|------------------|-------|
| ✓ | U+2713 | Success | `[OK]` | Test passed, validation succeeded, operation complete |
| ✗ | U+2717 | Failure | `[FAIL]` | Test failed, validation error, operation failed |
| ⚠ | U+26A0 | Warning | `[WARN]` | Non-blocking issue, deprecation notice |
| ℹ | U+2139 | Information | `[INFO]` | General information, tips |
| ● | U+25CF | In Progress | `[...]` | Currently running, active state |
| ○ | U+25CB | Pending | `[ ]` | Not started, queued |

**Example Output:**
```
✓ Phase 1: Settings Update [OK]
✓ Phase 2: Worktrees Documentation [OK]
● Phase 3: Terminal Glyphs [...]
○ Phase 4: Auto-Approve Documentation [ ]
```

### Progress Indicators

VS Code 1.109 includes Private Use Area glyphs (U+EE00-U+EE0B) for progress visualization.

**ASCII Fallback Pattern:**
```
[████████░░] 80% - Implementing authentication
[##########..........] 50% - Running tests
```

**Glyph Pattern (when available):**
```
▰▰▰▰▰▰▰▰▱▱ 80% - Implementing authentication
```

**Block Elements (U+2580-U+259F):**
- ▁ ▂ ▃ ▄ ▅ ▆ ▇ █ (vertical bars, increasing height)
- ░ ▒ ▓ █ (shading patterns)

### Box Drawing (U+2500-U+257F)

Use for hierarchical structure, file trees, and nested information.

**Basic Set:**
```
├── Item 1
│   ├── Sub-item 1.1
│   └── Sub-item 1.2
└── Item 2
```

**Full Set:**
- `─` Horizontal line
- `│` Vertical line
- `┌` Top-left corner
- `┐` Top-right corner
- `└` Bottom-left corner
- `┘` Bottom-right corner
- `├` Left T-junction
- `┤` Right T-junction
- `┬` Top T-junction
- `┴` Bottom T-junction
- `┼` Cross junction

**Example: Phase Status Tree:**
```
Implementation Plan
├── ✓ Phase 1: Settings [OK]
├── ✓ Phase 2: Worktrees [OK]
├── ● Phase 3: Terminal Glyphs [In Progress]
├── ○ Phase 4: Auto-Approve [Pending]
└── ○ Phase 5: Sessions [Pending]
```

### Git Branch Symbols (U+F5D0-U+F60D, Private Use Area)

These glyphs are specifically designed for Git operations. Use with text labels.

**Fallback Pattern:**
```
branch: main → feature-branch
commit: abc1234
tag: v1.0.0
```

**With Glyphs (when available):**
Use standard Git terminology with optional glyph prefixes.

### Braille Patterns (U+2800-U+28FF)

Use for lightweight sparklines and mini-visualizations.

**Example: Test Coverage Trend:**
```
Test Coverage (last 7 days): ⠀⠁⠃⠇⠏⠟⠿ 87%
```

**Example: Performance Metrics:**
```
Response Time: ⡀⡄⡆⡇⣇⣧⣷⣿ [Peak]
```

### Section Dividers

Use sparingly for major section breaks:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Or with text:
```
─── Phase 3: Terminal Glyphs ───
```

## Formatting Patterns

### Pattern 1: Status Summary

```
Phase 3 Results:
  ✓ Created terminal-formatting.instructions.md [OK]
  ✓ Created terminal-formatting-guide.md [OK]
  ✓ All validations passed [OK]
  ⚠ 3 pre-existing lint warnings [WARN]
```

### Pattern 2: File Operations

```
Modified Files:
├── instructions/global/
│   └── terminal-formatting.instructions.md [NEW]
└── docs/guides/
    └── terminal-formatting-guide.md [NEW]
```

### Pattern 3: Test Results

```
Test Suite: Authentication Module
  ✓ User login with valid credentials [OK]
  ✓ Password hashing verification [OK]
  ✗ Rate limiting enforcement [FAIL]
    └── Expected 429, got 200
  ⚠ Token expiration test (slow: 5.2s) [WARN]

Summary: 2 passed, 1 failed, 1 warning
```

### Pattern 4: Progress Updates

```
Building Application...
▰▰▰▰▰▰▰▰▱▱ 80% - Bundling assets
  ├── ✓ JavaScript compiled [OK]
  ├── ✓ CSS processed [OK]
  ├── ● Images optimized [...]
  └── ○ Service worker [Pending]
```

### Pattern 5: Git Operations

```
Git Status:
├── branch: main
├── ✓ No uncommitted changes [OK]
└── ✓ Up to date with origin/main [OK]

Recent Commits:
├── abc1234 - feat: Add terminal glyphs (2 hours ago)
└── def5678 - docs: Update VS Code settings (4 hours ago)
```

### Pattern 6: Validation Results

```
Validation Summary:
┌─────────────────────────────────────┐
│ Lint Check:        ✓ Passed [OK]    │
│ Asset Validation:  ✓ Passed [OK]    │
│ Tests:             ✓ Passed [OK]    │
│ Coverage:          87% ⠀⠁⠃⠇⠏⠟⠿      │
└─────────────────────────────────────┘
```

## Accessibility Requirements

### Rule 1: Always Include Text Labels

❌ **Bad:**
```
✓
✗
●
```

✅ **Good:**
```
✓ [OK]
✗ [FAIL]
● [In Progress]
```

### Rule 2: Use Semantic Structure

❌ **Bad:**
```
Result: ✓
```

✅ **Good:**
```
✓ Validation Result: Passed [OK]
```

### Rule 3: Screen Reader Compatibility

Structure output so screen readers can interpret meaning without glyphs:
```
Phase 3 Status: Success [OK]
  - Created formatting instructions: Success [OK]
  - Created user guide: Success [OK]
  - All validations: Passed [OK]
```

## Color Usage (ANSI Escape Codes)

While glyphs provide visual structure, color can enhance semantic meaning:

- **Green (\x1b[32m)**: Success states, passed tests
- **Red (\x1b[31m)**: Errors, failed tests
- **Yellow (\x1b[33m)**: Warnings, pending states
- **Blue (\x1b[34m)**: Informational messages
- **Gray (\x1b[90m)**: Secondary information, comments
- **Reset (\x1b[0m)**: Always reset after coloring

**Example with Color:**
```powershell
Write-Host "✓ Phase 1 Complete" -ForegroundColor Green
Write-Host "⚠ 3 warnings found" -ForegroundColor Yellow
Write-Host "✗ Build failed" -ForegroundColor Red
```

## Agent-Specific Guidelines

### Implementer Agent

Use progress bars and status trees when executing phases:
```
Implementing Phase 3...
▰▰▰▰▰▰▰▱▱▱ 70%
├── ✓ Created instruction file [OK]
├── ● Creating user guide [...]
└── ○ Update agent definitions [Pending]
```

### Reviewer Agent

Use structured findings format:
```
Review Findings:
├── ✗ BLOCKER: Missing input validation [FAIL]
│   └── File: auth.ts:45
├── ⚠ MAJOR: Unhandled error case [WARN]
│   └── File: api.ts:123
└── ℹ NIT: Consider using const [INFO]
    └── File: utils.ts:67
```

### Test Agent

Use test result summaries:
```
Test Execution Summary:
┌────────────────────────────┐
│ Total:    42 tests         │
│ ✓ Passed: 40 [OK]          │
│ ✗ Failed: 2 [FAIL]         │
│ ⚠ Skipped: 0 [WARN]        │
│ Duration: 12.4s            │
└────────────────────────────┘
```

### Conductor Agent

Use phase tracking trees:
```
Multi-Phase Implementation:
├── ✓ Phase 1: Settings & Documentation [Complete]
├── ✓ Phase 2: Worktrees UI Documentation [Complete]
├── ● Phase 3: Terminal Glyphs Style Guide [In Progress]
├── ○ Phase 4: Auto-Approve Validation [Not Started]
└── ○ Phase 5: Session Management [Not Started]

Next Action: Complete Phase 3 formatting guides
```

## Environment Detection

Agents should detect terminal capabilities and adjust output accordingly:

```powershell
# PowerShell example
$supportsGlyphs = $true  # Assume VS Code 1.109+ integrated terminal
if ($env:TERM -eq "dumb") {
    $supportsGlyphs = $false  # Fallback to ASCII
}
```

## Testing Your Output

Before finalizing formatting:

1. **Visual Test**: Run in VS Code integrated terminal
2. **Screen Reader Test**: Verify with Accessible View (Alt+H)
3. **ASCII Test**: Confirm fallback text is meaningful
4. **Color Blind Test**: Ensure glyphs + text labels convey meaning without color

## Examples from Other Agents

### Planner Agent Output

```
Implementation Plan: VS Code 1.109 Integration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Phase Breakdown:
├── Phase 1: Settings & Documentation
│   ├── Objective: Update settings for VS Code 1.109
│   ├── Status: ✓ Complete [OK]
│   └── Duration: 2 hours
├── Phase 2: Worktrees UI Documentation
│   ├── Objective: Document new Worktrees node
│   ├── Status: ✓ Complete [OK]
│   └── Duration: 1.5 hours
└── Phase 3: Terminal Glyphs Style Guide
    ├── Objective: Create formatting standards
    ├── Status: ● In Progress [...]
    └── Estimated: 2 hours

Success Criteria:
  ✓ All validations pass [OK]
  ✓ Documentation is comprehensive [OK]
  ○ Team review approval [Pending]
```

### Researcher Agent Output

```
Research Findings: Terminal Glyphs in VS Code 1.109
─────────────────────────────────────────────────

Key Discoveries:
├── ✓ ~800 custom glyphs now supported [OK]
│   ├── Box Drawing (U+2500-U+257F)
│   ├── Block Elements (U+2580-U+259F)
│   ├── Braille Patterns (U+2800-U+28FF)
│   └── Powerline Symbols (PUA)
├── ✓ GPU-accelerated rendering [OK]
│   └── No custom fonts required
└── ℹ Accessibility considerations documented [INFO]

Sources:
  1. VS Code 1.109 Release Notes
  2. Terminal Glyph Rendering Documentation
```

## Version History

- **1.0.0** (2026-01-09): Initial terminal formatting instructions for VS Code 1.109 integration

## Related Instructions

- `instructions/global/02_security.instructions.md` - Security baseline
- `instructions/workflows/conductor.instructions.md` - Conductor workflow
- `instructions/workflows/tdd-workflow.instructions.md` - TDD process

## References

- VS Code 1.109 Release Notes: https://code.visualstudio.com/updates/v1_109
- Unicode Box Drawing: https://en.wikipedia.org/wiki/Box-drawing_character
- Unicode Block Elements: https://en.wikipedia.org/wiki/Block_Elements
- ANSI Escape Codes: https://en.wikipedia.org/wiki/ANSI_escape_code
