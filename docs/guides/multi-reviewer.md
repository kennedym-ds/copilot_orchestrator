# Multi-Reviewer Guide

This guide shows expected consolidated artifact structure from `multi-reviewer` and example Conductor handling patterns.

Consolidated artifact (example fields):

- `verdict`: APPROVED | NEEDS_REVISION | BLOCKED
- `action`: `approve` | `request-changes` | `escalate` (HS-QUALITY contract)
- `findings`: array of {
  - `severity`: BLOCKER | MAJOR | MINOR | NIT
  - `consensus_level`: `unanimous` | `majority` | `single`
  - `file`: path
  - `line`: integer or range
  - `issue`: short description
  - `recommendation`: remediation text
  - `provenance`: [ { agent: name, confidence: 0-1, timestamp } ]
  }
- `subagent_outputs`: links to raw subagent artifacts under `artifacts/reviews/{slug}/subagents/`

Conductor handling (example):

1. Inspect `action`:
   - `approve` → continue to next phase
   - `request-changes` → gather `findings` where `severity==BLOCKER` and call Implementer
   - `escalate` → surface to human and route to `conductor` review (include `subagent_outputs`)

2. Example prompt to auto-create implementer task (Conductor -> Implementer):

```
#runSubagent implementer "Fix BLOCKER findings: [file1:line,file2:line]. Priority: BLOCKER first. Re-run multi-reviewer after fixes. Acceptance criteria: all BLOCKER findings cleared and multi-reviewer consensus shows no BLOCKERs."
```

3. When re-running reviews, include `previous_artifact` in the multi-reviewer request so reviewers can compare deltas and confirm remediation.

Notes
- Limit parallel reviewer count to control cost (default 3). The Conductor enforces budget gates.
- Use git worktrees or `/delegate` when reviewers perform long-running rechecks that need filesystem isolation.
- Store raw subagent outputs for auditability and attach them to the consolidated artifact.

Helper script

Use the included helper to convert a consolidated HS-QUALITY JSON artifact into an implementer handoff command. Example:

```powershell
pwsh -File scripts/multi-review-helper.ps1 -JsonPath artifacts/reviews/2026-03-11-feature-multi.json
# prints: #runSubagent implementer "Fix BLOCKER findings: [file1:line,file2:line]; Priority: BLOCKER first..."
```

The script also accepts JSON on stdin.
