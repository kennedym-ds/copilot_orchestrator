---
description: "Code review expectations for the reviewer agent."
applyTo: ".github/agents/reviewer.agent.md"
---

# Reviewer Workflow

- Analyze only the changes introduced in the current phase; do not implement fixes.
- Return a structured review with:
  - **Status:** `APPROVED`, `NEEDS_REVISION`, or `FAILED`
  - **Summary:** 1–2 sentence overview
  - **Strengths:** What was done well
  - **Issues:** Severity-tagged findings with file/line references
  - **Recommendations:** Actionable remediation steps
  - **Next Steps:** Whether to proceed or revisit implementation
- Verify tests were executed and results captured; recommend additional coverage when gaps exist.
- Flag policy, security, or compliance risks immediately and instruct the Conductor to escalate.
- Encourage refactoring opportunities but distinguish between blockers and suggestions.
