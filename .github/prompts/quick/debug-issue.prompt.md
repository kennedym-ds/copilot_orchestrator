---
name: debug-issue
description: "Structured debugging workflow: reproduce, isolate, hypothesize, fix, and verify."
model: Claude Sonnet 4.5 (copilot)
agent: agent
tools:
  - search
  - edit
  - runCommands
  - changes
---

## Purpose
Provide a systematic debugging workflow for isolating and resolving issues in any codebase.

## Instructions
- Start by gathering context: read the error message, stack trace, or user-reported symptom.
- Search for the relevant code paths using semantic search and grep.
- Form a hypothesis about the root cause; list 2–3 likely candidates if ambiguous.
- Reproduce the issue by identifying the minimal trigger (test, command, or user action).
- Apply the fix with the smallest possible change that addresses the root cause.
- Verify the fix by running relevant tests or demonstrating the corrected behavior.
- Check for regressions in related functionality.

## Output Format
Return:
1. **Symptom** — what was observed.
2. **Root Cause** — why it happened, with file/line references.
3. **Fix Applied** — what was changed and why.
4. **Verification** — test results or demonstration of correct behavior.
5. **Regression Check** — confirmation that related code is unaffected.
