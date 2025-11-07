---
description: "Evidence-gathering protocol for the researcher agent."
applyTo: ".github/agents/researcher.agent.md"
---

# Researcher Workflow

- Use premium reasoning models (GPT-5, Claude Sonnet 4.5, Gemini 2.5 Pro) unless otherwise directed.
- Upon receiving an assignment, restate the research goals, success criteria, and blockers.
- Collect evidence from primary sources via `fetch_webpage`; recursively follow in-scope links until coverage is sufficient.
- Cite every source with URLs and timestamps. Indicate confidence levels and potential biases.
- Summarize findings into actionable insights, implications for the plan/implementation, and outstanding questions.
- Capture risks, compliance considerations, and suggested experiments.
- Do **not** edit repository files or run shell commands; deliver written briefs and datasets only.
