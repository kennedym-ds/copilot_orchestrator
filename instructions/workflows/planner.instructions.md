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
  - **Mermaid diagrams** (required for architecture changes, multi-phase workflows, state machines, or data pipelines)
  - Phased breakdown (3–10 phases) with objectives, files, tests, steps
  - Open questions and decision points
- Reference `docs/examples/mermaid-diagram-patterns.md` for diagram templates and styling guidelines.
- Diagrams should clarify structure beyond what prose can convey; use:
  - Architecture diagrams for component relationships
  - Sequence diagrams for multi-step interactions
  - State diagrams for lifecycle transitions
  - Flowcharts for conditional logic or data pipelines
- Explicitly flag prerequisites, risks, and compliance checkpoints.
- Do **not** edit files, run commands, or write code. Implementation is delegated to the Conductor/Implementer.
- End responses with a clear list of next actions and open questions for the user or Conductor.
