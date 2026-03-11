---
title: "Agent handoff schemas"
version: "1.0.0"
lastUpdated: "2026-03-10"
status: "active"
reviewOwners:
  - "Copilot Orchestrator maintainers"
aiAssistance: "Drafted with GitHub Copilot and intended for review with Pester plus validate-copilot-assets.ps1."
---

# Agent handoff schemas

Typed delegation contracts make handoffs inspectable, auditable, and routable. This catalog defines the minimum schema set for Phase 1 so agents can reference stable schema IDs instead of relying on loose prose alone.

## Schema fields

| Field | Purpose |
|-------|---------|
| `schema_id` | Stable handoff identifier used in agent docs and reviews |
| `sender` | Agent or agent set allowed to originate the handoff |
| `receiver` | Target agent responsible for the work |
| `objective` | Concise statement of the task to complete |
| `inputs` | Required context, files, decisions, or constraints provided by the sender |
| `constraints` | Limits on scope, tools, approvals, timing, or compliance posture |
| `expected_outputs` | Exact artifacts or results the receiver must return |
| `evidence_required` | Validation or citation evidence the receiver must include |
| `escalation_rule` | What happens when the receiver is blocked or the scope expands |

## Initial schema set

| Schema ID | Sender | Receiver | Purpose |
|-----------|--------|----------|---------|
| `HS-PLAN` | `conductor` | `planner` | Request multi-phase planning |
| `HS-IMPL` | `conductor` / `planner` | `implementer` | Execute an approved plan phase |
| `HS-REVIEW` | `conductor` / `implementer` | `reviewer` | Review implementation changes |
| `HS-RESEARCH` | `conductor` | `researcher` | Gather evidence on a topic |
| `HS-QUALITY` | `conductor` | `security` / `performance` / `accessibility` | Specialist quality checkpoint |
| `HS-RETURN` | `any` | `conductor` | Return control with results |

## Usage note

Agents should reference the applicable schema ID in `## Delegation` and in any handoff definitions that map to these contracts. If a workflow does not fit one of these six schemas, document the exception instead of improvising silently.

## HS-PLAN — request multi-phase planning

- **Required inputs:** objective, constraints, success criteria, known artifacts, open questions
- **Expected outputs:** phased plan, risks, validation steps, recommended next handoff
- **Escalation rule:** if planning requires new scope or missing evidence, return to conductor with questions or request `HS-RESEARCH`

```json
{
  "schema_id": "HS-PLAN",
  "sender": "conductor",
  "receiver": "planner",
  "objective": "Draft a multi-phase plan for the approved request.",
  "inputs": [
    "problem statement",
    "constraints",
    "success criteria",
    "existing spec or research artifacts"
  ],
  "constraints": [
    "preserve current workflow behavior",
    "prefer simplest viable execution sequence"
  ],
  "expected_outputs": [
    "plan artifact path",
    "phase breakdown",
    "risk summary",
    "handoff recommendation"
  ],
  "evidence_required": [
    "file citations",
    "validation steps"
  ],
  "escalation_rule": "Return to conductor if the request is ambiguous, blocked, or requires research before planning can complete."
}
```

## HS-IMPL — execute an approved phase

- **Required inputs:** approved phase objective, files in scope, acceptance criteria, validation commands, constraints
- **Expected outputs:** scoped file changes, test results, residual risks, reviewer-ready summary
- **Escalation rule:** if implementation scope expands or required context is missing, return to conductor or planner before editing outside scope

```json
{
  "schema_id": "HS-IMPL",
  "sender": ["conductor", "planner"],
  "receiver": "implementer",
  "objective": "Execute the approved plan phase with minimal, validated changes.",
  "inputs": [
    "phase objective",
    "target files",
    "acceptance criteria",
    "test and validation commands"
  ],
  "constraints": [
    "touch only approved scope",
    "record validation evidence"
  ],
  "expected_outputs": [
    "changed files",
    "test matrix",
    "handoff package for reviewer"
  ],
  "evidence_required": [
    "targeted test results",
    "broader validation results"
  ],
  "escalation_rule": "Escalate before modifying out-of-scope files, adding dependencies, or bypassing required validation."
}
```

## HS-REVIEW — review implementation changes

- **Required inputs:** diff summary, files changed, phase objective, acceptance criteria, known risks
- **Expected outputs:** severity-tagged findings, approval status, remediation guidance, confidence summary
- **Escalation rule:** if the change requires specialist analysis, route back through conductor or request a specialist checkpoint with `HS-QUALITY`

```json
{
  "schema_id": "HS-REVIEW",
  "sender": ["conductor", "implementer"],
  "receiver": "reviewer",
  "objective": "Assess the implementation against the approved phase goal.",
  "inputs": [
    "diff summary",
    "changed files",
    "acceptance criteria",
    "validation evidence"
  ],
  "constraints": [
    "tag findings by severity",
    "stay within review scope"
  ],
  "expected_outputs": [
    "review verdict",
    "findings list",
    "recommended next action"
  ],
  "evidence_required": [
    "file citations",
    "validation coverage assessment"
  ],
  "escalation_rule": "Return to conductor when specialist follow-up or workflow changes are required."
}
```

## HS-RESEARCH — gather evidence on a topic

- **Required inputs:** research question, why the evidence is needed, scope, preferred sources
- **Expected outputs:** cited findings, decision-relevant summary, recommended options or next steps
- **Escalation rule:** if evidence is incomplete or contradictory, return to conductor with gaps and confidence level

```json
{
  "schema_id": "HS-RESEARCH",
  "sender": "conductor",
  "receiver": "researcher",
  "objective": "Gather evidence needed to unblock planning or implementation.",
  "inputs": [
    "research question",
    "delivery deadline or phase context",
    "preferred sources or repositories"
  ],
  "constraints": [
    "cite sources",
    "separate facts from recommendations"
  ],
  "expected_outputs": [
    "research brief",
    "source citations",
    "recommended next step"
  ],
  "evidence_required": [
    "file or URL citations",
    "confidence note"
  ],
  "escalation_rule": "Return to conductor if the question expands beyond the original scope or the available evidence is insufficient."
}
```

## HS-QUALITY — specialist quality checkpoint

- **Required inputs:** scope under review, reason for checkpoint, relevant files or diff, acceptance concerns
- **Expected outputs:** specialist findings, verdict, mitigations, follow-up routing recommendation
- **Escalation rule:** blocker findings return to conductor for workflow control; routine fixes can route to implementer after conductor review

```json
{
  "schema_id": "HS-QUALITY",
  "sender": "conductor",
  "receiver": ["security", "performance", "accessibility"],
  "objective": "Run a specialist checkpoint on the current scope.",
  "inputs": [
    "files or diff under review",
    "reason for checkpoint",
    "known risks or prior findings"
  ],
  "constraints": [
    "stay within the named quality domain",
    "report actionable findings only"
  ],
  "expected_outputs": [
    "domain verdict",
    "severity-tagged findings",
    "recommended remediation"
  ],
  "evidence_required": [
    "cited files or lines",
    "clear pass/fail reasoning"
  ],
  "escalation_rule": "Escalate blocker or scope-changing findings to conductor before implementation continues."
}
```

## HS-RETURN — return control with results

- **Required inputs:** completion summary, artifacts touched, findings, next-step recommendation
- **Expected outputs:** conductor-ready state update and routing recommendation
- **Escalation rule:** if the result contains blockers, make the blocker explicit and recommend the next agent or pause point

```json
{
  "schema_id": "HS-RETURN",
  "sender": "any",
  "receiver": "conductor",
  "objective": "Return control with a complete summary of work performed.",
  "inputs": [
    "completed work summary",
    "artifacts or files touched",
    "findings",
    "recommended next step"
  ],
  "constraints": [
    "be concise and auditable",
    "surface blockers explicitly"
  ],
  "expected_outputs": [
    "updated workflow state",
    "next routing decision"
  ],
  "evidence_required": [
    "artifact paths",
    "validation or review status"
  ],
  "escalation_rule": "If blocked, return with the blocker, why it matters, and the recommended pause point or specialist follow-up."
}
```

## Related references

- [Agent standard template](../templates/agent-standard.md)
- [Delegation routing skill](../../.github/skills/delegation-routing/SKILL.md)
- [Agent & Skill Quality Review spec](../../artifacts/specs/agent-skill-quality-review/spec.md)
- [Action plan Phase 1](../../artifacts/plans/2026-agent-skill-quality-action-plan/plan.md)
