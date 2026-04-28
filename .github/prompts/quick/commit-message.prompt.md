---
name: commit-message
description: "Alias for /commit — generate a conventional commit message from staged changes."
argument-hint: "Describe the staged changes for a commit message"
model: GPT-5.3-Codex (copilot)
agent: agent
tools: [changes]
---

> **Note:** This prompt is an alias. The canonical version is [`/commit`](../commit.prompt.md).

## Instructions

Use the `/commit` prompt for full conventional commit message generation. This file is retained for backward compatibility with `quick/` shortcuts.

## Output Format

See the `/commit` prompt for the expected output format (conventional commit with type, scope, subject, and body).
