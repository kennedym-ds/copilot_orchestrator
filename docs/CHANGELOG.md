---
title: "Copilot Orchestrator Changelog"
version: "0.1.0"
lastUpdated: "2025-11-10"
status: draft
---

# Changelog

All notable changes will be documented here following [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) conventions.

## [Unreleased]

### Added
- Initial repository scaffold, planning documents (`orchestration-rebuild-plan`, `new-workspace-blueprint`, `new-workspace-setup-checklist`).
- Base directory structure for chat modes, prompts, instructions, docs, scripts, and plans.
- Conductor, Planner, Implementer, Researcher, and Reviewer agent definitions with workflow overlays.
- PowerShell validation toolkit (`validate-copilot-assets.ps1`, `add-prompt-metadata.ps1`, `token-report.ps1`) with maintainer guidance under `scripts/`.
- CI workflow (`.github/workflows/ci/validate.yml`) executing validation suite and publishing token report artifacts.
- Orchestrated workflow prompt library (`.github/prompts/**/*`) with nested `AGENTS.md` guidance.
- Onboarding documentation (`docs/guides/onboarding.md`, `docs/guides/sample-agent-session.md`) and sample plan artifacts under `plans/samples/`.
- Compliance overlay for documentation (`instructions/compliance/documentation.instructions.md`).
- Support personas for security, performance, and documentation (`.github/agents/**`) with companion prompts and conductor handoffs.
- Support personas for security, performance, visual design, data analytics, and documentation (`.github/agents/**`) with companion prompts and conductor handoffs.
- Expanded onboarding guide covering VS Code Insiders configuration, Agent Sessions, and support-persona coordination.
- Maintainer, visualizer, and data analytics personas documented with workflow overlays and VS Code setup guidance updates.
- Promotional launch post (`docs/posts/orchestrator-launch-promo.md`) highlighting the multi-agent workflow and dataflow diagram.
- Documentation refresh covering subagent invocation best practices and the `github.copilot.chat.tools.memory.enabled` requirement across README and setup guides.
- Agent personas and workflow instructions now direct responses to embed explicit `#runSubagent {persona}` commands for every handoff.
- Comprehensive reviewer playbook (`.copilot-review-instructions.md`) for the VS Code review selection feature.
- Pester-based regression suite for validation scripts and CI step to run `Invoke-Pester -Path tests`.
- Configurable token thresholds in `token-report.ps1` with category-aware warnings and JSON output metadata.
- Markdown lint check automation (`scripts/run-lint.ps1`) and repository smoke test harness (`scripts/run-smoke-tests.ps1`).
- Scoped global behavior, security, and compliance instructions to targeted file globs to minimize unnecessary context loading.
- Python language guardrails (`instructions/languages/python.instructions.md`) grounded in the Zen of Python and modern tooling expectations.
- VS Code Copilot configuration guide documenting required settings for custom modes, prompts, and instruction meshes.
- Dedicated `plan-ds-star-step` planner prompt for sequential DS-Star routing, plus metadata hooks for telemetry-aware step generation.
- DS-Star regression fixture (`tests/powershell/fixtures/ds-star-session/`) with pipeline state, step metadata, and verdict logs so analytics/tests can run without touching production artifacts.
- Pester coverage invoking `scripts/analyze-sessions.ps1` against the fixture to ensure dashboards render DS-Star metrics, resume readiness, and verdict mix text end-to-end.

### Changed
- Conductor workflow instructions and agent definition now enforce DS-Star telemetry payloads, guardrail escalation thresholds, and resume procedures, ensuring routing decisions are documented and auditable.
- DS-Star workflow guide includes a conductor-facing decision matrix, troubleshooting tips, and onboarding cross-links so contributors can quickly reference routing expectations.
- Operations playbook adds DS-Star monitoring policies (round cap audits, runtime SLA tracking, resume integrity checks).
- Planner workflow instructions and agent definition now document DS-Star sequential mode (single-step output, truncation handling, `pipeline_state.json` context), and a dedicated DS-Star planner prompt plus guidance in `prompt-engineering-by-tier.md` illustrates the new pattern.
- DS-Star artifact governance updates: refreshed data analytics workflow instructions + agent, reviewer verdict rubric alignment, and the new `plans/data-analysis/README.md` to anchor artifact metadata.
- README and onboarding guide highlight DS-Star detection heuristics, telemetry guardrails, and resume steps while pointing contributors to `plans/data-analysis/README.md` and the new planner prompt.
- DS-Star verdict chain + severity alignment (2025-11-18): expanded
  `plans/data-analysis/README.md` metadata schema, updated
  `.github/agents/data-analytics.agent.md`, `.github/agents/reviewer.agent.md`,
  and the reviewer/data-analytics workflow instructions to enforce
  `verdict.md` / `verdict.json` / `verdict_log.ndjson` mirrors plus
  `[severity:high|medium|low]` TODO fences, with entries captured in
  `docs/CHANGELOG.md` and `INSTRUCTION_CHANGELOG.md`.
- `scripts/analyze-sessions.ps1` now accepts `-DSStarPath`, produces a console+markdown DS-Star telemetry section (completion rate, average rounds/steps/duration, verdict mix, resume readiness), and powers the regenerated `docs/dashboards/workflow-metrics.md`.
- `docs/guides/sample-agent-session.md` and `docs/workflows/ds-star-integration.md` describe the new DS-Star fixture, analytics workflow, and test coverage so contributors can replay the sequential loop end-to-end.

### Removed
- Retired the Billy Butcher reviewer persona and associated legacy chat mode assets to maintain a professional review posture.

### Next
- Add scheduled validation runs leveraging the new lint and smoke test scripts.
- Explore additional support personas (observability, deployment) as orchestration coverage grows.
