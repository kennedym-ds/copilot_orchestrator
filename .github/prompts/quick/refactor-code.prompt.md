---
name: refactor-code
description: "Refactor selected code for clarity, maintainability, and adherence to language idioms."
argument-hint: "Select or describe the code to refactor"
model: Claude Haiku 4.5 (copilot)
agent: agent
tools: [search, edit, execute, changes]
---

## Purpose
Refactor code to improve readability, reduce complexity, and follow language-specific best practices — without changing external behavior.

## Context
If code is selected in the editor, refactor the selection:
```
${selection}
```

## Instructions
- Read the target code and its surrounding context (callers, tests, types).
- Identify specific refactoring opportunities: extract method, rename, simplify conditionals, reduce nesting, remove duplication.
- Preserve all existing behavior — this is a refactor, not a feature change.
- Run existing tests before and after to confirm nothing breaks.
- Keep changes atomic: one logical refactoring per edit when possible.
- Follow the language instruction file conventions (e.g., PEP 8 for Python, ESLint for JS/TS).

## Output Format
Return:
1. **Before/After** — brief description of what changed and why.
2. **Complexity Reduction** — measurable improvement (fewer branches, shorter methods, etc.).
3. **Tests** — confirmation that existing tests still pass.
4. **Follow-ups** — any additional refactoring deferred for a separate pass.
