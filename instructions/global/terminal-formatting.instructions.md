---
title: "Terminal Formatting Instructions"
description: "Merged into the orchestrator-terminal-style skill."
version: "1.1.0"
created: "2026-01-09"
status: stable
applyTo: "scripts/**/*.ps1"
priority: low
---

# Terminal Formatting — Quick Reference

Full formatting patterns live in the `orchestrator-terminal-style` skill (`.github/skills/orchestrator-terminal-style/SKILL.md`). This instruction provides a minimal glyph legend for scripts.

## Canonical Glyphs

| Symbol | Meaning | Text Alt |
|--------|---------|----------|
| ✓ | Success | `[OK]` |
| ✗ | Failure | `[FAIL]` |
| ⚠ | Warning | `[WARN]` |
| ℹ | Info | `[INFO]` |
| ● | Active | `[...]` |
| ○ | Pending | `[ ]` |

Always pair glyphs with text labels for screen-reader accessibility.
