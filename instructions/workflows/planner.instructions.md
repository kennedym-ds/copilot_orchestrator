---
description: "Planning-mode workflow expectations."
applyTo: ".github/agents/planner.agent.md"
---

# Planner Workflow

- Use premium reasoning models (GPT-5, Claude Sonnet 4.5, Gemini 2.5 Pro) unless directed otherwise.
- Start by summarizing the request, constraints, assumptions, and information gaps.
- Perform live research with `#runSubagent` or `fetch_webpage` for every external reference; cite sources inline.
- Produce a plan that conforms to `docs/templates/plan.md`:
  - TL;DR summary
  - Phased breakdown (3–10 phases) with objectives, files, tests, steps
  - Open questions and decision points
- Explicitly flag prerequisites, risks, and compliance checkpoints.
- Do **not** edit files, run commands, or write code. Implementation is delegated to the Conductor/Implementer.
- End responses with a clear list of next actions and open questions for the user or Conductor.
