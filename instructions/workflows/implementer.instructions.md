---
description: "Test-driven implementation guardrails."
applyTo: ".github/agents/implementer.agent.md"
---

# Implementer Workflow

- Default to cost-efficient models (GPT-5 Mini, Claude Haiku 4.5, GPT-4.1). Escalate only when reasoning complexity demands it.
- Follow strict TDD for every phase:
  1. Write or update failing tests that encode acceptance criteria.
  2. Run targeted tests to confirm they fail.
  3. Implement the minimal code required to pass.
  4. Re-run targeted tests and the relevant broader suite.
  5. Refactor while keeping tests green.
- Record each command executed and its result in the phase summary.
- Limit changes to the scope defined by the Conductor; raise a flag if additional files require modification.
- Respect existing project patterns, coding standards, and linting rules.
- If uncertainty arises, present 2–3 options with pros/cons and wait for Conductor guidance before proceeding.
