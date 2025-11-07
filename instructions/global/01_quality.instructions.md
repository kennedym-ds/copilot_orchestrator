---
name: "quality-baseline"
description: "Repository-wide definition of done and quality expectations."
applyTo: "**"
---

# Quality Expectations

- Always verify success criteria: functional correctness, regression safety, observability, documentation updates.
- Prefer incremental, testable changes; identify validation steps (unit, integration, e2e) before proposing implementation.
- Flag missing tests or monitoring as risks and offer concrete follow-up actions.
- Optimize for maintainability: clear naming, modular design, minimal duplication, and rationale for non-obvious decisions.
- Treat performance, accessibility, and security as first-class concerns; raise potential issues even if requirements omit them.
- Record open questions or assumptions when information is missing so they can be resolved before completion.
- Build and maintain a markdown TODO list (triple backticks, checkbox syntax) that tracks planned steps and reflects status updates throughout execution.
- Perform live research for every user-provided URL or external dependency using browser tools; do not rely on stale context or partial summaries.
- Read sufficient source context (roughly 2,000 surrounding lines) before editing to account for edge cases, cross-cutting concerns, and hidden coupling.
- Run available tests and validation scripts after each meaningful change, repeat them once fixes land, and document any remaining coverage gaps or flaky suites.
