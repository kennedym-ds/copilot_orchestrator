---
title: "Operations & Continuous Improvement Plan"
version: "0.2.0"
lastUpdated: "2025-11-08"
status: draft
---

# Operations Playbook

## Monitoring

- **Weekly** – review Conductor transcripts for adherence to pause points and instruction compliance.
- **Monthly** – run validation scripts, prune unused prompts/chat modes, refresh AGENTS/md overlays.
- **Quarterly** – host retrospectives to assess model allocations, cost usage, and workflow effectiveness.

## Metrics

### Workflow Effectiveness

- **Adoption rate** — Percentage of work executed via Conductor workflow vs. ad-hoc development.
- **Validation pass rate** — CI workflow success vs. failures.
- **Average phase duration** — Planning, implementation, review durations vs. baseline.
- **Incident count** — Policy/security issues per sprint.

### Multi-Tier Model Effectiveness

**Cost Efficiency Metrics:**
- **Premium vs. execution tier ratio** — Target: 20% premium / 80% execution. Track actual ratio weekly.
- **Cost per completed phase** — Total model costs divided by phases completed successfully.
- **Cost per agent type** — Break down costs by Conductor, Planner, Implementer, Reviewer, Researcher, Security, Performance, Docs.
- **Budget variance** — Actual spend vs. projected spend; alert when >10% over budget.

**Quality & Escalation Metrics:**
- **Review rejection rate** — Percentage of phases rejected by Reviewer, broken down by:
  - Implementer using execution tier (baseline)
  - Implementer after escalation to premium tier (should be lower)
  - Trend over time (should decrease as patterns mature)
- **Escalation frequency** — Track escalations per phase by trigger type:
  - Tier 1 (automatic): Test failures, ambiguity, security, performance
  - Tier 2 (recommended): Architecture changes, API integration, context overflow, cross-cutting concerns
  - Tier 3 (optional): Refactoring opportunities, test coverage gaps, documentation updates
- **Escalation resolution time** — Mean time from escalation to unblock.
- **False escalation rate** — Escalations where execution tier could have succeeded (indicates need for better prompting).

**Model Availability & Resilience:**
- **Primary model uptime** — Availability percentage by model type (GPT-5, Claude Sonnet 4.5, GPT-4.1, etc.).
- **Fallback invocation frequency** — How often fallback models used vs. primary.
- **Fallback success rate** — Percentage of successful completions when using 1st, 2nd, 3rd fallback.
- **Mean time to recovery** — When primary model unavailable, how long until restored.

**Model-Task Fit:**
- **Success rate by model-task pairs** — Track which models perform best for:
  - Code generation vs. refactoring vs. test writing
  - Security analysis vs. performance analysis
  - Research vs. planning vs. review
- **Context window utilization** — Average and peak token usage by agent, identify opportunities for optimization.
- **Response quality scores** — Manual or automated scoring of output quality (1-5 scale) by model and task type.

### Data-Driven Model Allocation

**Weekly Review:**
- Check premium/execution tier ratio; adjust agent defaults if consistently off-target.
- Review top 5 escalation triggers; document patterns and update escalation guidance if needed.
- Identify models with high failure or fallback rates; investigate root causes.

**Monthly Review:**
- Analyze cost per phase trends; optimize prompts or model selection if costs rising.
- Review false escalation patterns; improve Implementer prompts to reduce unnecessary premium usage.
- Compare review rejection rates before vs. after introducing escalation patterns; validate quality improvement.

**Quarterly Review:**
- Assess model-task fit data; update default model assignments in agent definitions.
- Evaluate new model releases (GPT-5.1, Claude Sonnet 5, etc.) for potential inclusion.
- Fine-tune cost-efficient models on successful patterns if data available.
- Adjust fallback chains based on empirical reliability and performance data.

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
| Document escalation patterns for multi-tier model usage | Prompt Guild | Complete |
| Define model fallback matrix and resilience strategies | Platform Guild | Complete |
| Add multi-tier effectiveness metrics to operations playbook | Operations | Complete |
| Create prompt engineering by tier guidelines | Enablement | Complete |
| Implement escalation metrics tracking dashboard | Tooling | Planned |
| Pilot dynamic escalation in low-risk workflows | Platform Guild | Planned |
| Evaluate model re-evaluation cadence for new releases | Operations | Planned |

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
