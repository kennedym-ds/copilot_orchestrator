---
description: "Code review expectations for the reviewer agent."
applyTo: ".github/agents/reviewer.agent.md"
version: "1.2.0"
date: "2025-11-18"
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
- When delegating follow-up work, include the exact `#runSubagent {persona}` command (for example `#runSubagent implementer`) so handoffs preserve context.
- Encourage refactoring opportunities but distinguish between blockers and suggestions.

## DS-Star Verification Rubric

- **Verdict formatting:** Every decision line must begin with `SUFFICIENT`,
  `INSUFFICIENT`, or `BLOCKED`, immediately followed by a single-sentence
  justification that cites either a `steps/00X_*` artifact (for example
  `steps/004_reviewer/verdict.md`) or telemetry inside `pipeline_state.json`
  (`plan_history`, `round_counter`, `active_verdict`, `dataset_inventory`, etc.).
  Mirror the same verdict keyword (uppercase) across `verdict.md`,
  `verdict.json`, `verdict_log.ndjson`, the `TODO-reviewer` fence, and
  `pipeline_state.json.verification_history` during the same review loop.
- **Severity format:** Inside every ```TODO-reviewer``` fence, prefix
  remediation bullets with `[severity:high]`, `[severity:medium]`, or
  `[severity:low]` and cite the authoritative artifact path (`steps/00X_*`,
  `verdict.md`, `pipeline_state.json`, datasets) plus the affected scoring
  dimension. Apply the same severity tag language when listing
  Issues/Recommendations in the final review summary to keep routing automation
  aligned.
- **Scoring dimensions:** Evaluate Completeness, Correctness, Statistical
  Rigor, and Documentation/Clarity. For each deficiency, tie the severity tag to
  the impacted dimension and describe why the evidence is insufficient.
- **Artifact inspection:** Review DS-Star TODO fences, metadata sidecars,
  `verdict.md` / `verdict.json` / `verdict_log.ndjson`, and `pipeline_state.json`
  to understand recent `plan_history`, the current `round_counter`,
  `active_verdict`, `dataset_inventory`, and whether attachments cited in
  `gap_summary` actually exist. Confirm that reviewer notes align with the
  mirrored artifacts before issuing a verdict.
- **Follow-up expectations:**
  - `SUFFICIENT`: document the passing verdict, reference the validated
    artifacts, synchronise `verdict.*`, and hand off to the Docs persona for
    publication or archival (`#runSubagent docs`).
  - `INSUFFICIENT`: request a new planner step or implementation revision that
    targets the cited deficiencies, name the artifact (e.g.,
    `steps/007_implementer/metadata.json`) needing updates, and ensure the
    severity tags line up with remediation urgency.
  - `BLOCKED`: immediately escalate to the Conductor, outline the blocking
    dependency or missing artifact, include the files you inspected
    (`steps/005_reviewer/verdict.json`, `pipeline_state.json`), and note any
    required cross-team coordination plus the precise `#runSubagent {persona}`
    command before further review can proceed.
