# Copilot Orchestrator — Agent Playbook

Welcome, agent. This repository is the **greenfield conductor workspace** for GitHub Copilot. It implements the multi-agent orchestration pattern described in `docs/workflows/orchestration-rebuild-plan.md` and should be treated as the source of truth for future personas, prompts, and validation tooling.

> **Status:** Inception phase. Follow the guardrails below and log gaps in `docs/operations.md`.

---

## Mission & Architecture

- Build a conductor-led workflow that progresses every task through **Planning → Implementation → Review → Commit → Completion**.
- Persist artifacts for each stage under `plans/` (plan drafts, phase summaries, completion report).
- Maintain strict pause points after plan creation and after each review to keep the human in control.
- Use **context-isolated subagents** (via `#runSubagent`) for research-heavy or parallelizable work.

Supporting documentation:

| Document | Purpose |
| --- | --- |
| `docs/workflows/orchestration-rebuild-plan.md` | End-to-end strategy, success metrics, roadmap. |
| `docs/workflows/new-workspace-blueprint.md` | Repository layout, model allocation, automation guardrails. |
| `docs/workflows/new-workspace-setup-checklist.md` | Operational checklist for bootstrapping and migration. |
| `docs/operations.md` | Monitoring cadence, backlog, and incident process. |
| `docs/templates/` | Standardized plan/phase/summary templates (populate before first conductor run). |

---

## Development Environment

| Task | Command |
| --- | --- |
| Install dependencies | _None yet — prompt the team before adding packages._ |
| Validation suite | `pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .` |
| Prompt metadata check | `pwsh -File scripts/add-prompt-metadata.ps1 -RepositoryRoot . -CheckOnly` |
| Token budget report | `pwsh -File scripts/token-report.ps1 -Path .` |
| PowerShell regression tests | `Invoke-Pester -Path tests -Output Detailed` |
| **Session analytics** | **`pwsh -File scripts/analyze-sessions.ps1`** |
| **View metrics dashboard** | **`docs/dashboards/workflow-metrics.md`** |

**Shell expectations**

- Default shell: Windows PowerShell 5.1. Prefer `;` when chaining commands.
- Use PowerShell cmdlets (`Get-ChildItem`, `Set-Content`, etc.) over aliases for reproducibility.
- Document any new scripts or tooling requirements in `docs/operations.md` and update this table.

---

## Workflow Guardrails

All agents must honor the global instructions in `instructions/global/*.instructions.md` plus the workflow-specific overlays in `instructions/workflows/`.

### Conductor

- Maintain state (`Current Phase`, `Plan Progress`, `Last Action`, `Next Action`) in responses.
- Invoke specialized subagents with `#runSubagent`; do not implement code directly.
- Enforce mandatory pause points and write artifacts using templates in `docs/templates/`.

### Planner & Researcher

- Use premium reasoning models (GPT-5, Claude Sonnet 4.5, Gemini 2.5 Pro).
- Perform live research for every external reference via `fetch_webpage` and capture findings, options, assumptions, and open questions.
- Produce plans aligned with `docs/templates/plan.md` (including Mermaid diagrams when applicable) and avoid implementation actions.

### Implementer

- Follow strict TDD: failing tests → minimal code → passing tests → refactor.
- Default to cost-optimized models (GPT-5 Mini, Claude Haiku 4.5). Escalate to premium only if necessary.
- Run targeted tests first, then the relevant suites, recording results in the phase summary.

### Reviewer

- Review only, never apply fixes. Return status (`APPROVED`, `NEEDS_REVISION`, `FAILED`) with severity-tagged findings.
- Confirm tests were executed and recommend additional coverage when gaps appear.
- **Billy Butcher variant**: Adversarial "red team" review actively tries to break the implementation with edge cases, security scenarios, and resource exhaustion attacks.

### Support Personas

- Security (`security.agent.md`): threat modeling, privacy, compliance reviews.
- Performance (`performance.agent.md`): runtime, memory, and cost analysis.
- Documentation (`docs.agent.md`): onboarding guides, knowledge base, validation runbooks.
- Keep tool access minimal and scoped to each specialty. Escalate to these agents through conductor handoffs when risks emerge.
- Return actionable recommendations (severity-tagged findings, mitigations, approvals) to the Conductor for follow-up.

---

## Safety & Compliance

- Follow security baseline in `instructions/global/02_security.instructions.md` and any overlays under `instructions/compliance/`.
- Never include secrets or tokens in transcripts. Use placeholder values and describe secure storage expectations.
- Flag compliance checkpoints (privacy review, deployment approval) in plans and phase summaries.

---

## Validation Requirements

- Run validation scripts after modifying prompts, chat modes, or instruction files.
- Record command output in PR descriptions and update `docs/CHANGELOG.md` for notable changes.
- If validation tooling is missing, add a task to `docs/operations.md` backlog before merging.

---

## Contribution Protocol

1. Update or add documentation in `docs/` alongside code/instruction changes.
2. Ensure new assets follow schemas under `schemas/` (to be ported).
3. Capture rollout notes and approvals in `docs/CHANGELOG.md` and `docs/operations.md`.
4. For major changes, attach sample Agent Sessions exports demonstrating the conductor workflow.

If any guideline conflicts with immediate customer needs, escalate via the Conductor plan’s open questions rather than bypassing the guardrails.

---

## Observability & Continuous Improvement

**Session Analytics** (see `docs/guides/session-analytics.md`):
- Track workflow metrics with `scripts/analyze-sessions.ps1`
- Monitor: escalation patterns, model usage/cost, quality metrics, phase durations
- View dashboard: `docs/dashboards/workflow-metrics.md`
- Targets: ≤20% premium model usage, ≥90% review approval rate

**Instruction Evolution** (see `INSTRUCTION_CHANGELOG.md`):
- All instruction files include version metadata
- Changes tracked with before/after metrics
- Rollback procedures documented
- A/B testing framework for instruction variants

**Quality Enhancement**:
- Billy Butcher agent provides adversarial "red team" review
- Multi-perspective review (standard + adversarial)
- Severity-tagged findings (BLOCKER, MAJOR, MINOR, NIT)
- Automated validation scripts and tests

**Process Metrics**:
- Run analytics weekly/monthly: `pwsh -File scripts/analyze-sessions.ps1 -StartDate (Get-Date).AddMonths(-1)`
- Compare metrics before/after instruction changes
- Document patterns in `docs/operations.md`
- Update escalation triggers based on data

**Contribution Updates**:
- Track instruction changes in `INSTRUCTION_CHANGELOG.md` with expected impact and metrics
- Update session metadata in `plans/sessions/` to enable analytics
- Include Mermaid diagrams in plans for complex architectures
