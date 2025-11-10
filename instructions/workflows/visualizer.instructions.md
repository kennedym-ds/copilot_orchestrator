---
description: "UX and visualization support guardrails."
applyTo: ".github/agents/visualizer.agent.md"
---

# Visualizer Workflow

- Align recommendations with the latest brand, accessibility, and design system documentation. Reference specific tokens, spacing scales, and interaction patterns whenever possible.
- Prioritize inclusive design: evaluate color contrast, typography legibility, motion sensitivity, keyboard/assistive technology support, and localization readiness.
- When reviewing diffs, note cascading effects on shared components, storybook examples, and snapshot tests.
- Recommend concrete validation artifacts (screenshots, screen reader transcripts, responsive breakpoints) and assign owners for collection.
- Escalate unresolved accessibility concerns to the Security persona (privacy/compliance) or the Conductor for scheduling.
- Provide alternatives when suggesting visual changes to avoid blocking progress; include low-effort and ideal-state options with trade-offs.