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
- Pester-based regression suite for validation scripts and CI step to run `Invoke-Pester -Path tests`.
- Configurable token thresholds in `token-report.ps1` with category-aware warnings and JSON output metadata.
- Markdown lint check automation (`scripts/run-lint.ps1`) and repository smoke test harness (`scripts/run-smoke-tests.ps1`).
- Scoped global behavior, security, and compliance instructions to targeted file globs to minimize unnecessary context loading.
- Python language guardrails (`instructions/languages/python.instructions.md`) grounded in the Zen of Python and modern tooling expectations.
- VS Code Copilot configuration guide documenting required settings for custom modes, prompts, and instruction meshes.

### Removed
- Retired the Billy Butcher reviewer persona and associated legacy chat mode assets to maintain a professional review posture.

### Next
- Add scheduled validation runs leveraging the new lint and smoke test scripts.
- Explore additional support personas (observability, deployment) as orchestration coverage grows.
