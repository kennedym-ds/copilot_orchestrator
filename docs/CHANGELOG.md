---
title: "Copilot Orchestrator Changelog"
version: "0.6.1"
lastUpdated: "2026-02-06"
status: stable
---

# Changelog

All notable changes are documented here following [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) conventions.

## [0.6.1] - 2026-02-06

### Changed
- **Deprecated Settings Cleanup**:
  - Removed `chat.modeFilesLocations` from all documentation (deprecated; superseded by `chat.agentFilesLocations` since VS Code 1.106)
  - Renamed `chat.viewRestorePreviousSession` → `chat.restoreLastPanelSession` across all docs (renamed in VS Code 1.108)
  - Converted absolute Windows paths to tilde (`~`) notation in user-level settings examples for cross-machine portability
  - Updated files: `.github/copilot-instructions.md`, `README.md`, `AGENTS.md`, `docs/guides/vscode-copilot-configuration.md`, `docs/guides/onboarding.md`, `docs/quick-reference.md`, `docs/repository-analysis.md`

## [0.6.0] - 2026-01-09

### Added
- **VS Code 1.108 Feature Integration**:
  - Terminal custom glyphs (~800 GPU-accelerated): Box drawing (U+2500-U+257F), block elements (U+2580-U+259F), Braille patterns (U+2800-U+28FF), Powerline symbols (U+E0A0-U+E0D4), progress indicators (U+EE00-U+EE0B), Git branch symbols (U+F5D0-U+F60D)
  - Terminal auto-approve settings: `chat.tools.terminal.enableAutoApprove`, `autoApproveWorkspaceNpmScripts`, `preventShellHistory`
  - Enhanced Agent Sessions UI: Keyboard navigation (↑↓ arrows, Enter, Delete, Space), session grouping (by state/age), multi-session archiving (Shift+Click, Ctrl+Click), changed files and PR display, Quick Open integration (`agent <name>`), session persistence control (`chat.viewRestorePreviousSession: false`)
  - Enhanced Worktrees UI: Source Control Repositories view, Worktrees node, settings (`scm.repositories.explorer`, `scm.repositories.selectionMode`), keyboard navigation, inline actions
  - Agent Skills (experimental): On-demand loading via `.github/skills/` directory structure with `SKILL.md` files
- **New Documentation**:
  - `instructions/global/terminal-formatting.instructions.md`: Canonical glyph set, 6 formatting patterns, agent-specific guidelines, accessibility requirements (800+ lines)
  - `docs/guides/terminal-formatting-guide.md`: User-facing guide with examples, reference tables, troubleshooting (900+ lines)
  - `docs/guides/agent-skills-pilot.md`: Comprehensive evaluation guide with 5 metrics, 3 phases, 5 test scenarios, decision criteria (680+ lines)
  - `.github/skills/orchestrator-terminal-style/SKILL.md`: Terminal formatting skill for on-demand loading (500+ lines)
  - `.github/skills/worktrees-ops/SKILL.md`: Git worktrees operations skill (450+ lines)
  - `.github/skills/validation-scripts/SKILL.md`: PowerShell validation script usage skill (530+ lines)
- **Enhanced Documentation**:
  - `docs/guides/vscode-copilot-configuration.md`: Added Terminal Auto-Approve section (200+ lines), Agent Sessions UI section (300+ lines), updated to v0.6.0
  - `docs/guides/background-agents-worktrees.md`: Added VS Code 1.108 Worktrees UI section (150+ lines), updated to v1.1.0
  - `.github/copilot-instructions.md`: Updated VS Code Settings section with all 1.108 features, expanded VS Code 1.108 Updates notes
  - `AGENTS.md`: Added Agent Sessions Integration section with workflow best practices
- **Configuration Updates**:
  - Replaced deprecated `chat.viewSessions.orientation: "auto"` with `"sideBySide"`
  - Added `chat.useAgentSkills: false` (experimental, disabled by default)
  - Added terminal auto-approve settings: `enableAutoApprove`, `autoApproveWorkspaceNpmScripts`, `preventShellHistory`
  - Added `chat.viewRestorePreviousSession: false` to prevent context leakage between projects
  - Added worktrees settings: `scm.repositories.explorer`, `scm.repositories.selectionMode`

### Changed
- Terminal formatting: All agents now use GPU-accelerated glyphs with mandatory text pairing for accessibility
- Agent Sessions: Default to side-by-side orientation with grouping enabled
- Session persistence: Default to empty chat on startup (prevents cross-project context leakage)
- Worktrees integration: Enhanced with VS Code 1.108 native UI support
- Documentation versions: Updated from 0.5.0 to 0.6.0 across configuration guide

### Security
- **Terminal Auto-Approve**: Conservative allow-list (Git read-only, ripgrep with restrictions, sed with pattern checks, PowerShell Out-String)
- **NPM Scripts**: Workspace Trust dependency for auto-approval, optional disable for untrusted repos
- **Shell History**: Exclusion enabled by default to prevent credential leakage
- **Agent Skills**: Experimental feature disabled by default, requires explicit opt-in
- **Security Review**: LOW risk assessment with adequate safeguards (Workspace Trust gating, conservative allow-lists, denial transparency)

### Accessibility
- **WCAG 2.1 Level AA Compliance**: Glyph-text pairing mandatory (e.g., `✓ PASS`, `✗ FAIL`, `⚠ WARN`)
- **Screen Reader Support**: ASCII fallback patterns for non-rendering environments
- **Keyboard Navigation**: Complete Agent Sessions keyboard-only operation (arrows, Enter, Delete, Space)
- **Color Contrast**: ANSI colors supplemented with textual indicators
- **Accessibility Review**: Strong foundation with recommendations for color contrast validation and screen reader walkthrough

### Experimental
- **Agent Skills** (`chat.useAgentSkills: false` by default): On-demand loading of domain-specific knowledge
- **Pilot Skills**: orchestrator-terminal-style, worktrees-ops, validation-scripts
- **Evaluation Guide**: 2-4 week pilot framework with 5 metrics, Go/No-Go decision criteria
- **Future Expansion**: 8 candidate skills identified for Phase C (conductor-lifecycle, security-review, performance-analysis, TDD, accessibility-WCAG, documentation-style, git-operations, observability-telemetry)

### Operations
- **Token Budget:** Corrected validation to use per-file limits (10k tokens) instead of misleading total. 1 file over limit: `copilot-subagents-briefing.md` (19,161 tokens, +91.6%).
- **Rationale:** Agents load specific files per-context, not all files simultaneously.
- **Action:** Split large research document into smaller focused docs, establish 8k soft limit for new documentation.

## [0.5.0] - 2025-12-19

### Added
- **VS Code 1.107 Feature Integration**:
  - `infer` metadata added to all 22 agent definitions for automatic agent routing
  - Organization-level agent sharing support (experimental)
  - Background agents with Git worktrees for parallel phase execution
  - Claude Skills compatibility for cross-platform skill reuse
  - Enhanced fetch tool for JavaScript-rendered content
  - Collapsible thinking/tools UI for cleaner sessions
  - CLI custom agents support
- **New Documentation**:
  - `docs/guides/background-agents-worktrees.md`: Comprehensive guide for parallel execution with Git worktrees
  - `docs/guides/claude-skills-migration.md`: Complete migration guide for converting prompts to Claude skills format
  - `instructions/compliance/tool-approval-policy.instructions.md`: Enterprise security policy for tool auto-approval
  - `USER-SETTINGS-GUIDE.md`: Quick reference for personal VS Code settings
- **Enhanced Documentation**:
  - `docs/guides/central-deployment.md`: Added Method 1 (Native Organization Sharing) vs Method 2 comparison, migration paths, rollout strategy
  - `docs/guides/onboarding.md`: Added Language Models editor configuration section
  - `.github/agents/researcher.agent.md`: Enhanced with VS Code 1.107 dynamic fetch and ignored file search capabilities
- **Configuration Updates**:
  - `.vscode/settings.json`: Added 8 new VS Code 1.107 settings plus Git worktree support
  - `.github/copilot-instructions.md`: Updated with all new experimental settings

### Changed
- All 22 agents now include `infer` metadata (false for Conductor to prevent loops, true for 21 specialists)
- Updated all documentation versions from 0.4.0 to 0.5.0
- Standardized VS Code settings blocks across all guides
- Researcher agent instructions updated for enhanced fetch and ignored file search

### Security
- Added comprehensive tool auto-approval policy with risk classification, threat model, and compliance checkpoints
- Documented safe vs risky tools for auto-approval configuration
- Added incident response procedures for malicious tool use detection

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
