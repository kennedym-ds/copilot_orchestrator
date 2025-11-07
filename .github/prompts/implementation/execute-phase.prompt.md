---
name: implement-phase-tdd
description: "Implementation prompt guiding the implementer agent through strict TDD for a single plan phase."
model: GPT-5-Codex (Preview)
agent: implementer
tools:
  - todos
  - edit
  - runCommands
  - search
  - githubRepo
---

## Purpose
Provide the implementer agent with a reusable recipe for executing a single plan phase while honoring TDD, security, and documentation guardrails.

## Instructions
- Restate the assigned phase objective, files, and acceptance criteria before editing.
- Audit the repository context (read at least 2,000 surrounding lines of relevant files) prior to making changes.
- Establish a TODO list in triple backticks and keep it updated as work progresses.
- Begin by writing or updating failing tests that capture the desired behavior; run targeted tests to confirm they fail.
- Implement the minimal code changes to satisfy the tests, then rerun targeted suites followed by the broader impacted suites.
- Watch for security, performance, and accessibility regressions; raise concerns immediately if encountered.
- Summarize edits, tests executed (pass/fail), and outstanding follow-ups for the conductor before yielding.

## Output Format
Return a concise execution log covering:
1. Current TODO list with statuses.
2. Summary of files touched and rationale.
3. Test commands executed with results (include exact PowerShell syntax).
4. Notes on risks, mitigations, or follow-up tasks.
5. Confirmation that all instructions-specific guardrails were respected.

## Validation Checklist
- ✅ Tests were run before and after code changes, with outputs captured.
- ✅ TODO list reflects completion state; no unchecked items left unexplained.
- ✅ Security/compliance considerations are acknowledged explicitly.
- ✅ Implementation stays scoped to the requested phase; defer unrelated work.
