Repository agent memory patterns
===============================

Purpose
-------
Store durable, repo-scoped knowledge that should survive session compaction and be reusable across projects. This folder contains small templates and guidance only. Do not store ephemeral session notes, draft plans, or breadcrumbs here.

Policy (improved)
-----------------
- Durable facts only: store only stable facts that are likely to be useful across tasks (decisions, error patterns, integration contracts, required global config).
- Small and verifiable: each entry should be short, include a `reason` and `citations`, and follow the `project_decisions.md` template.
- Automated writes go through `scripts/add-agent-decision.ps1` to ensure consistent metadata and avoid accidental pollution.
- Session-only material lives in `vscode/memory` or `artifacts/sessions/` — do not commit session data to `.agent-memory`.

Files
-----
- `project_decisions.md` — ADR-like durable decisions and rationale (template included).
- `error_patterns.md` — common error patterns and remediation guidance.

How to add a durable memory entry (recommended)
----------------------------------------------
Use the helper script to create an entry with consistent metadata and a clear reason:

```powershell
pwsh -File scripts/add-agent-decision.ps1 -Subject "Decision: Use X pattern" -Fact "Use X because..." -Citations "fileA.md,fileB.md" -Reason "Avoid repeated refactor" -Category "architecture"
```

The script creates a timestamped markdown file in this folder and prints the created path.

Audit and review
----------------
Treat `.agent-memory` entries as code: review them in PRs, require a short justification, and prefer small, frequently-reviewed facts over long single-entry documents.
