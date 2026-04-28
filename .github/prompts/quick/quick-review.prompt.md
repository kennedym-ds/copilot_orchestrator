---
name: quick-review
description: "Fast code review with severity-tagged findings — no conductor workflow needed."
argument-hint: "Paste code or describe the file to review quickly"
model: GPT-5.4 mini mini (copilot)
agent: agent
tools: [changes, search]
---

## Purpose
Perform a fast code review on the current diff without launching the full conductor → reviewer workflow. Ideal for small changes, self-review, or pre-commit checks.

## Context
If code is selected in the editor, focus the review on the selection:
```
${selection}
```

## Instructions
- Load the current diff using the changes tool.
- For each changed file, review for:
  - **Correctness** — logic errors, off-by-one, null handling.
  - **Security** — injection, secrets, unsafe operations.
  - **Performance** — unnecessary allocations, N+1 queries, missing caching.
  - **Style** — naming, formatting, language idioms.
  - **Tests** — are changes covered by tests? Should new tests be added?
- Tag each finding with severity: `BLOCKER`, `MAJOR`, `MINOR`, or `NIT`.
- Provide concrete fix suggestions, not just problem descriptions.

## Output Format
Return:
1. **Summary** — overall assessment (LGTM, minor issues, needs work).
2. **Findings table**:

| Severity | File | Line | Issue | Suggestion |
|----------|------|------|-------|------------|
| ... | ... | ... | ... | ... |

3. **Verdict** — `LGTM` / `MINOR_ISSUES` / `NEEDS_REVISION`
