---
title: "Operations & Continuous Improvement Plan"
version: "0.1.0"
lastUpdated: "2025-11-07"
status: draft
---

# Operations Playbook

## Monitoring

- **Weekly** – review Conductor transcripts for adherence to pause points and instruction compliance.
- **Monthly** – run validation scripts, prune unused prompts/chat modes, refresh AGENTS/md overlays.
- **Quarterly** – host retrospectives to assess model allocations, cost usage, and workflow effectiveness.

## Metrics

- Adoption rate (% of work executed via Conductor workflow).
- Validation pass rate (CI workflow success vs. failures).
- Average phase duration (planning, implementation, review) vs. baseline.
- Model cost distribution (premium vs. efficiency models).
- Incident count (policy/security issues per sprint).

## Incident Response

- Classify incidents (operational, policy, security).
- Escalate security breaches and open tracking tickets.
- Disable problematic agents/prompts via repo settings until resolved.
- Document post-incident reviews and remediation steps.

## Backlog

| Item | Owner | Status |
| --- | --- | --- |
| Author root `AGENTS.md` | Docs Guild | Complete |
| Publish conductor + subagent definitions under `.github/agents/` | Platform Guild | Complete |
| Port validation scripts (`validate`, `metadata`, `token-report`) | Tooling | Complete |
| Configure `ci/validate.yml` workflow | Tooling | Complete |
| Develop onboarding walkthrough (Agent Sessions demo) | Enablement | Complete |
| Draft prompt library for orchestrator workflows | Prompt Guild | Complete |
| Add JSON output mode to token report | Tooling | Planned |
| Introduce Pester-based regression tests for scripts | Tooling | Complete |
| Author support persona prompts (security, performance, docs) | Prompt Guild | Complete |
| Create planner/researcher/implementer/reviewer chat modes with handoffs | Prompt Guild | Complete |
| Replace placeholder `.github/copilot-instructions.md` with finalized workspace charter | Docs Guild | Complete |
| Document nested `AGENTS.md` settings and Agent Sessions workflow | Enablement | Complete |
| Align prompt front matter with chat modes and tool priority rules | Prompt Guild | Complete |

## Tooling

- Validation scripts (PowerShell) to be ported from legacy repo.
- Markdown/YAML linting pipeline (to be defined).
- Token budget reporting integrated with CI.

## Instruction Hygiene

- Scope `applyTo` globs narrowly (e.g., `**/*.{md,ps1,yml,json}`) to avoid loading instructions for binary assets while keeping coverage for scripted and documentation artifacts.
- Maintain distinct overlays for behavior, security, and compliance to keep context modular; update the `description` fields when semantics change.
- Review instruction impact quarterly to ensure new file types are explicitly opted-in rather than inheriting global defaults.
- Introduce language-specific guardrails (e.g., `instructions/languages/python.instructions.md`) when languages enter the workspace so contextual guidance stays relevant and lightweight.

Update this document as workflows mature and automation lands.
