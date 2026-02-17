---
name: pr-description
description: "Generate a structured pull request description from the current diff."
argument-hint: "Describe the PR scope or provide the branch name"
model: Claude Sonnet 4.6 (copilot)
agent: agent
tools:
  - changes
  - search
---

## Purpose
Generate a clear, well-structured pull request description from the current staged or unstaged changes.

## Instructions
- Load the current diff using the changes tool.
- Categorize changes by type: feature, fix, refactor, docs, chore, test.
- Write a concise title following conventional commit format (e.g., `feat: add OAuth2 token refresh`).
- Summarize the motivation (why), approach (how), and impact (what changes).
- List all files modified, grouped by category.
- Note any breaking changes, migration steps, or deployment considerations.
- Include a testing section describing how the changes were verified.

## Output Format
Return a ready-to-paste PR description in markdown:

```markdown
## Summary
{One-paragraph description of what this PR does and why}

## Changes
- {Bulleted list of key changes}

## Testing
- {How changes were verified}

## Notes
- {Breaking changes, deployment steps, or follow-ups}
```
