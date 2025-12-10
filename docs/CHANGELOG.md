---
title: "Copilot Orchestrator Changelog"
version: "0.4.1"
lastUpdated: "2025-12-10"
status: stable
---

# Changelog

All notable changes are documented here following [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) conventions.

## [0.4.1] - 2025-12-10

### Changed
- **VS Code 1.107 Compatibility Update**:
  - Updated minimum VS Code version requirement from 1.101 to 1.107 in `docs/guides/vscode-copilot-configuration.md`
  - Added VS Code 1.107 compatibility note documenting verified features (unified Agent Sessions, context-isolated subagents, enhanced MCP server support)
  - Updated README.md with version requirement and link to detailed configuration guide
  - Document version incremented to 0.4.1 with stable status

### Added
- **Research Artifact**: Created `artifacts/research/vscode-1-107-copilot-features.md` documenting VS Code 1.107 GitHub Copilot features and compatibility analysis
- **Implementation Plan**: Created `artifacts/plans/vscode-1-107-updates/plan.md` tracking update phases and validation steps

## [0.4.0] - 2025-12-08

### Added
- **Local Artifact Storage**: All 15 artifact-producing agents now persist outputs to local `artifacts/` folder
  - New script: `scripts/init-artifacts.ps1` creates standardized folder structure
  - 14 artifact folders: plans, reviews, research, security, sessions, performance, docs, releases, telemetry, deployments, red-team, accessibility, tests, ux
  - Each agent includes artifact template in its definition
- **Central Deployment Guide**: `docs/guides/central-deployment.md` documents org-level deployment with local artifacts
- **New Agents**:
  - `test.agent.md`: TDD test writing, coverage analysis, Pester framework
  - `lint.agent.md`: Code style enforcement, formatting fixes
  - `github-ops.agent.md`: Issue/PR/workflow management via GitHub CLI
- **Agent Enhancements**:
  - All 22 agents updated with "Commands You Can Use" sections
  - All agents include three-tier boundaries (Always do / Ask first / Never do)
  - Conductor includes "Project Knowledge" section with tech stack and file structure
- **GitHub CLI Integration**: `docs/guides/copilot-cli-usage.md` documents CLI/chat integration patterns

### Changed
- Updated all agent handoffs to use `#runSubagent` syntax
- Standardized agent tool lists to include `runSubagent`, `edit`, `runCommands`
- Revised README.md with cleaner structure and accurate agent roster
- Updated AGENTS.md with complete agent roster table and artifact storage documentation
- Refreshed docs/README.md as documentation index

### Fixed
- Corrected `init-artifacts.ps1` Join-Path syntax for PowerShell 5.1 compatibility
- Removed duplicate Security entry from central-deployment.md artifact table

## [0.3.0] - 2025-12-04

### Added
- **SOTA Architecture Gaps Closure** (2025-12-04):
  - IaC agent coverage: Added `terraform.agent.md` and `bicep.agent.md` with plan/implement split patterns for drift detection, compliance, and modularization.
  - Language coverage expansion: Added `powershell.instructions.md`, `typescript.instructions.md`, `terraform.instructions.md`, and `bicep.instructions.md`.
  - MCP server patterns: Added `python-mcp-server.instructions.md` with comprehensive tool, resource, and prompt implementation guidance.
  - Accessibility agent: Added `accessibility.agent.md` covering WCAG 2.2, ARIA implementation, and a11y best practices.
  - Beast Mode pattern: Added `beast-mode.agent.md` for transparent extended reasoning with visible thinking and systematic task management.
  - Observability integrations: Enhanced `observability.agent.md` with Dynatrace, PagerDuty, Elasticsearch, Prometheus, and Azure Monitor integration patterns.
  - Enhanced session analytics: Expanded `analyze-sessions.ps1` with agent action telemetry (by agent/tool), security findings tracking, and detailed model usage breakdown (per StepSecurity recommendations).
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
- Frontmatter standardization across all 12 agent definitions (added `argument-hint`, removed deprecated `target` field).
- Integrated MCP servers (design_server, research_server) with stdio definitions in design, researcher, data-analytics agents.
- Introduced collections system (`orchestrator-core`, `data-science`, `support-personas`) grouping agents and workflow instructions.
- Documentation enhancements for conductor, planner, implementer agents (Core Capabilities, Response Style, Example Interaction Patterns sections).
- Ultra-premium tier governance for Claude Opus 4.5 (usage thresholds, justification rules) added to model selection instructions.
- Enhanced validation script (`validate-copilot-assets.ps1`) with awesome-copilot pattern checks (argument-hint presence, mcp-servers format, model allowlist, deprecated field warnings).

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
- Updated model fallback chains to explicitly include Claude Opus 4.5 with governance constraints (<5% invocation target, justification logging).
- Strengthened validation to enforce allowed model list and warn on missing discoverability metadata.
- Added `runSubagent` tool to all agent definitions to enable autonomous delegation.
- Added `observability`, `deployment`, and `red-team` support personas to `.github/agents/` and registered them in `AGENTS.md` and `support-personas.collection.yaml`.

### Removed
- Retired the Billy Butcher reviewer persona and associated legacy chat mode assets to maintain a professional review posture.

### Next
- Add scheduled validation runs leveraging the new lint and smoke test scripts.
- Explore additional support personas (observability, deployment) as orchestration coverage grows.
