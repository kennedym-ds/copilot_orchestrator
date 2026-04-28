---
name: review
description: "Quick code review of the current file or selection with severity-tagged findings."
argument-hint: "Provide code or changes to review for quality and correctness"
model: GPT-5.4 mini mini (copilot)
agent: agent
tools: [changes, search, read, problems]
---

## Purpose
Perform a quick code review on the current file or selection without launching the full conductor workflow.

## Context
If code is selected in the editor, review the selection:
```
${selection}
```

## Instructions
- Load the current diff or file using changes/read tools.
- Review for correctness, security, performance, and style.
- Tag each finding as **BLOCKER**, **MAJOR**, **MINOR**, or **NIT**.
- Check for logic errors, edge cases, off-by-one errors.
- Check for input validation, injection risks, secrets exposure.
- Check for unnecessary allocations, O(n²) patterns, missing caching.
- Check for naming, formatting, consistency with repo conventions.

## Output Format
A structured review with:
1. **Findings** — each tagged with severity level
2. **Verdict** — one of: APPROVED, CHANGES_REQUIRED, or NEEDS_DISCUSSION
3. **Summary** — one-sentence overall assessment
