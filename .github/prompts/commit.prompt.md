---
name: commit
description: "Generate a conventional commit message from staged changes."
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
- Identify the scope from the affected area (e.g., agents, instructions, scripts, docs).
- Write a concise description in imperative mood, lowercase, no period, max 72 chars.
- Add a body explaining *what* and *why* (not *how*) if the change is non-trivial.
- Reference issues with `Closes #N` or `Refs #N` in footer if applicable.
- If changes span multiple concerns, suggest separate commits.

## Output Format
A commit message in Conventional Commits format:
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Examples:
- `feat(agents): add disable-model-invocation to translation sub-agents`
- `docs(guides): add Claude Agent session interop documentation`
- `fix(scripts): handle empty artifact directories in validation`
