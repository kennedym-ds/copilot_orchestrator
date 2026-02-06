---
name: commit-message
description: "Generate a conventional commit message from the current diff."
model: Claude Haiku 4.5 (copilot)
agent: agent
tools:
  - changes
---

## Purpose
Generate a well-formatted conventional commit message from the current staged changes.

## Instructions
- Load the current diff using the changes tool.
- Determine the commit type: `feat`, `fix`, `refactor`, `docs`, `chore`, `test`, `perf`, `ci`, `style`.
- If changes span multiple scopes, use the most significant type and mention others in the body.
- Write a subject line: `type(scope): imperative description` (≤72 chars).
- Add a body when the change needs explanation (wrap at 72 chars).
- Add a footer for breaking changes (`BREAKING CHANGE:`) or issue references (`Closes #123`).

## Output Format
Return a ready-to-use commit message:

```
type(scope): concise imperative description

Optional body explaining the motivation and approach.
Wrap lines at 72 characters.

Optional footer:
Closes #issue
BREAKING CHANGE: description
```
