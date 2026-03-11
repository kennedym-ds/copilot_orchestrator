title: "Copilot Orchestrator Changelog"
version: "0.17.0"
lastUpdated: "2026-03-11"
status: stable
---

# Changelog

All notable changes are documented here following [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) conventions.

## [0.17.0] - 2026-03-11

### Added
- **Agent & Skill Quality Review**: 7-phase structural normalization across 29 agents and 16 skills
  - Canonical agent template (`docs/templates/agent-standard.md`) and skill template (`docs/templates/skill-standard.md`)
  - All 29 agents normalized to canonical section order: frontmatter → H1 → instruction refs → Core Capabilities → Response Style → Workflow → Output Contract → Boundaries → Delegation
  - All 16 skills normalized with `### When NOT to Use`, `## References`, and canonical section order

### Changed
- **`orchestrator-terminal-style` skill retired**: Terminal formatting guidance migrated to `instructions/global/terminal-formatting.instructions.md` (v2.0.0) and `docs/guides/terminal-formatting-guide.md`
- **`validation-scripts` skill decomposed**: Slimmed to thin entry point with bundled references (`references/script-catalog.md`, `references/workflow-patterns.md`)
- **Agent normalization** (Phases 2-4): Response Style, Output Contract, Boundaries, and Delegation sections standardized across all agents
- **Skill normalization** (Phase 6): `### When NOT to Use` added to all 16 skills; section ordering aligned to canonical template

### Fixed
- Stale agent count references updated from "22" or "28" to "29" across documentation
- Stale skill count references updated from "17" to "16" after `orchestrator-terminal-style` retirement

## [0.16.0] - 2026-03-10

### Added
- **VS Code 1.111 Integration**: Agent autonomy levels, agent-scoped hooks, and debug events snapshot
  - Agent Permissions Picker (Preview): Default Approvals, Bypass Approvals, Autopilot modes
  - Agent-Scoped Hooks (Preview): `hooks` in `.agent.md` frontmatter for per-agent lifecycle logic
  - Debug Events Snapshot: `#debugEventsSnapshot` for agent self-diagnosis
  - `task_complete` tool: Required completion signal for Autopilot mode
  - AI Terminal Profile Grouping (Experimental)
- **askQuestions Tool Expansion**: Added to 10 user-facing agents (security, deployment, github-ops, terraform, bicep, design, performance, observability, visualizer, lint) — 82% adoption (23/28)
- **Autopilot Guardrails**: Conductor instructions updated to warn about pause-point bypass in Autopilot mode
- **VS Code 1.111 Features Section**: Added to `docs/guides/vscode-copilot-configuration.md` (v0.9.0)

### Changed
- Updated `.vscode/settings.json` with 3 new 1.111 settings
- Updated `.github/copilot-instructions.md` version reference to 1.108–1.111
- Updated `AGENTS.md` with 1.111 Agent Autonomy section, version range to 1.108–1.111
- Updated `docs/guides/vscode-copilot-configuration.md` prerequisites to VS Code 1.111
- Updated `INSTRUCTION_CHANGELOG.md` with v3.4.0 entry

## [0.15.0] - 2026-03-07

### Changed
- **Agent↔Skill Deduplication**: Removed ~215 lines of duplicated content across 8 agents by replacing inline reference material with skill cross-references
  - `translation-conductor.agent.md`: Confidence Rating System replaced with `code-translation` skill reference
  - `translation-validator.agent.md`: 6-Layer Validation Stack condensed from ~90 to ~30 lines with skill reference
  - `translator.agent.md`: Translation Rules condensed, Confidence Factors table and verbose output format replaced with compact summary + skill reference
  - `translation-analyzer.agent.md`: Added `code-translation` skill cross-reference to dependency analysis step
  - `translation-styler.agent.md`: Idiomatic transformation examples (~58 lines of 4-language before/after) replaced with skill reference + key principles (~6 lines)
- **Commands Section Extraction**: Removed standard validation commands from 13 agents (documented at workspace level in `AGENTS.md`)
  - Full removal (10 agents): reviewer, lint, beast-mode, deployment, visualizer, red-team, docs, performance, maintainer, implementer
  - Partial trim (3 agents): test (kept Pester), terraform (kept tf CLI), bicep (kept az CLI)
- **Frontmatter Tool Array Fixes**: Corrected tool access for 5 agents based on role-alignment audit
  - `docs.agent.md`: Added `changes`, `runCommands`, `askQuestions` (documentation agent needs to see diffs, run validation, and clarify requirements)
  - `github-ops.agent.md`: Added `edit` (can now modify local workflow YAML and issue templates)
  - `observability.agent.md`: Removed `edit`, `runCommands` (analysis-only agent, delegates writes)
  - `performance.agent.md`: Added `runCommands` (can now run benchmarks and profilers directly)
  - `translation-validator.agent.md`: Removed `edit` (uses MCP `update_module_status` tool instead)

### Improved
- **Token Footprint**: Estimated ~6-7 KB reduction in agent file sizes from deduplication
- **Role Clarity**: Agent tool arrays now consistently match each agent's read/write/execute permissions

## [0.14.0] - 2026-03-05

### Added
- **VS Code 1.110 Integration**: Full baseline update across settings, documentation, and agent instructions
  - Agent Plugins (experimental): installable bundles of skills, tools, and hooks
  - Agentic Browser Tools (experimental): full browser control from agent sessions
  - Explore Subagent: plan agent delegates codebase research to fast read-only model
  - Context Compaction (`/compact`): manual context window control
  - Session Forking (`/fork`): branch conversations to explore alternatives
  - Agent Debug Panel replaces old Chat Diagnostics
  - Edit Mode deprecated (hidden by default, removed in 1.125)
  - Create Agent Customization slash commands (`/create-prompt`, `/create-skill`, etc.)
  - Usages and Rename tools for LSP-aware refactoring
  - Terminal sandboxing, collapsible terminal, Kitty Graphics Protocol
  - OS notifications for long-running agent tasks
  - AI Co-Author attribution in git commits
  - Auto-approve slash commands (`/autoApprove`, `/disableAutoApprove`)
- **VS Code 1.110 Features Section**: Added to `docs/guides/vscode-copilot-configuration.md` (v0.8.0)

### Fixed
- **`inlineChat.affordance` breaking change**: Changed from boolean `true` to enum `"editor"` (1.110 changed the setting type)
- **Test-AgentTooling.Tests.ps1**: Fixed em dash (U+2014) causing ParseException in PowerShell 5.1 due to UTF-8/Windows-1252 encoding mismatch
- **Front matter validation**: Removed legacy `paths:` keys from 9 `.claude/rules/languages/` instruction files; `applyTo` is the canonical key
- **Front matter validation (artifact copies)**: Synced 9 artifact test copies under `artifacts/tests/claude_full_review_out/` to match main files

### Changed
- Updated `.vscode/settings.json` with 14 new 1.110 settings
- Updated `.github/copilot-instructions.md` and `.claude/CLAUDE.md` with 1.110 settings and feature notes
- Updated `AGENTS.md` with 4 new 1.110 subsections (Agent Controls, Extensibility, Smarter Sessions, Chat Experience)
- Updated `INSTRUCTION_CHANGELOG.md` with v3.2.0 entry
- Updated `docs/guides/vscode-copilot-configuration.md` prerequisites to VS Code 1.110

## [0.13.0] - 2026-07-28

### Added
- **Antigravity IDE Setup Scripts**: Cross-platform scripts for exporting orchestrator agents/skills to Google DeepMind's Antigravity IDE
  - `scripts/setup-antigravity.ps1` -- PowerShell script transforming VS Code agents to Antigravity `.agent/` format (2 modes: Project, User)
  - `scripts/setup-antigravity.sh` -- Bash equivalent for macOS/Linux
  - Converts 27 agents, 16 skills, 22 prompts-to-workflows, instructions-to-rules, and MCP configuration
  - Generates slash-command workflows from prompt templates with `$ARGUMENTS` support
  - Maps models (Opus/Sonnet/Haiku/Gemini) and tools (Read/Grep/Glob/Bash/Edit/Write) to Antigravity equivalents
- **Multi-Platform Setup Guide v1.1**: Updated guide now covers five platforms (VS Code, Visual Studio, Claude Code, Antigravity, Copilot CLI)

### Changed
- Updated `docs/guides/multi-platform-setup.md` with Antigravity IDE section, format mapping tables, troubleshooting
- Updated `scripts/AGENTS.md` with Antigravity setup script documentation

## [0.12.0] - 2026-07-28

### Added
- **Multi-Platform Setup Scripts**: Cross-platform scripts for using orchestrator agents/skills in Claude Code, Visual Studio, and Copilot CLI
  - `scripts/setup-claude-code.ps1` — PowerShell script transforming VS Code agents to Claude Code format (3 modes: Project, User, Plugin)
  - `scripts/setup-claude-code.sh` — Bash equivalent for macOS/Linux
  - `scripts/setup-vs-cli.ps1` — PowerShell script for Visual Studio and Copilot CLI setup (Symlink, Copy, Reference strategies)
  - `scripts/setup-vs-cli.sh` — Bash equivalent for macOS/Linux
- **Multi-Platform Setup Guide** (`docs/guides/multi-platform-setup.md`): Comprehensive guide covering all four platforms (VS Code, Claude Code, Visual Studio, Copilot CLI) with cross-platform instructions for Windows, macOS, and Linux
- **Claude Code Plugin Support**: Plugin mode creates a distributable `.claude-plugin/` package with manifest, transformed agents, skills, and MCP configuration
- **Agent Format Transformation**: Automated model mapping (VS Code model names → Claude Code aliases), tool mapping (VS Code tools → Claude Code tools), and frontmatter conversion
- **Instruction → Rules Conversion**: Converts `instructions/` hierarchy to `.claude/rules/` with language-specific `paths` frontmatter for scoped rules

### Changed
- Updated `scripts/AGENTS.md` with documentation for new setup scripts

## [0.11.0] - 2026-02-23

### Added
- **Code Topology Skill** (`.github/skills/code-topology/SKILL.md`): 5-phase structural code understanding protocol — landscape survey, dependency mapping, function-level tracing, data-flow analysis, and impact assessment. Teaches agents to reason about codebase architecture using existing tools (`usages`, `search`, `readFile`, directory listing) instead of ad hoc file reading.
- **Code Topology Research** (`artifacts/research/code-topology-agent-understanding-2026.md`): In-depth research brief on code topology concepts (CBFDAE framework, Golden Mesh, call graphs, ASTs, data-flow analysis) and their applicability to agent code understanding.

### Changed
- **Planner Agent**: Added structural analysis step — runs Phase 1-2 topology survey for multi-file features to ground plans in actual code structure
- **Implementer Agent**: Added impact assessment step (new Execution Rule #2) — runs Phase 3+5 topology before edits to trace callers, classify blast radius, and flag untested paths
- **Reviewer Agent**: Added structural impact check (new Workflow step #4) — verifies blast radius is accounted for in diffs using `usages`-based topology tracing
- **Researcher Agent**: Added codebase analysis pattern — uses Phase 1-2 topology for structured codebase overviews instead of ad hoc browsing
- **Delegation Routing Skill**: Added "code topology", "codebase overview", "architecture map", "impact analysis", "blast radius" to routing keyword triggers; added code-topology skill reference

## [0.10.0] - 2026-02-20

### Added
- **Memory Management System**: Three-tier artifact retention (permanent/seasonal/ephemeral) with rolloff and compaction
- **Cleanup Script** (`scripts/cleanup-artifacts.ps1`): Scans YAML frontmatter, enforces TTL-based archival/deletion, auto-compacts at 75% TTL, regenerates `artifact-index.md`
- **Memory Management Skill** (`.github/skills/memory-management/SKILL.md`): Teaches agents memory hygiene, decision recording, retention tiers, session read-back/write-back
- **Decision (ADR) Template** (`docs/templates/decision.md`): Structured template with YAML frontmatter for architectural decisions
- **Compact Template** (`docs/templates/compact.md`): Summary template for compacted artifacts
- **Active Context** (`artifacts/memory/activeContext.md`): Session write-back file for Conductor
- **Artifact Index** (`artifacts/artifact-index.md`): Auto-generated inventory of all active artifacts
- **Memory Management Guide** (`docs/guides/memory-management.md`): End-to-end guide covering retention, cleanup, ADRs, and Copilot Memory hygiene
- **New artifact folders**: `artifacts/decisions/`, `artifacts/memory/`, `artifacts/.archive/`

### Changed
- **Conductor Agent**: Added session read-back protocol (reads `artifact-index.md` + `activeContext.md` at start), write-back at pause points, decision naming, cleanup command
- **Reviewer Agent**: Added decision extraction step — creates ADRs for architectural decisions after reviews
- **Behavior Instructions** (`00_behavior.instructions.md`): Added Memory Hygiene section with Copilot Memory store/skip/refresh rules
- **Escalation Patterns** (`escalation-patterns.instructions.md`): Added Proactive Memory Management section (memory budget, compaction, decision-first reading)
- **Init Script** (`scripts/init-artifacts.ps1`): Creates `decisions/`, `memory/`, `.archive/` subfolders
- **Artifacts README**: Added retention tiers table, 3 new folders, expanded naming conventions
- **Plan Template**: Added "Decisions Made" section
- **Phase Complete Template**: Added "Decisions Made" section
- **AGENTS.md**: Documented memory lifecycle, retention tiers, cleanup command, folder structure
- **Quick Reference**: Added cleanup command, updated artifact folder listing

## [0.9.0] - 2026-02-17

### Added
- **Validation MCP Server** (`scripts/mcp/validation_server.py`): Wraps 5 PowerShell validation scripts as MCP tools, exposes 6 resources (templates, instructions) and 3 prompts (validate-and-report, tdd-cycle, severity-review)
- **Analytics MCP Server** (`scripts/mcp/analytics_server.py`): 5 tools for session/artifact queries, 4 resources (routing table, agent roster, thresholds, operations), 2 prompts (workflow-analysis, cost-optimization)
- **Bleeding-Edge Demo Server** (`scripts/mcp/demo_bleeding_edge.py`): Showcases 6 MCP protocol features from the 2025-11-25 revision — elicitation, tool annotations, progress reporting, structured output, resource annotations, and logging
- **MCP Unit Tests**: `test_validation_server.py` (14 tests) and `test_analytics_server.py` (10 tests)
- **Remote GitHub MCP**: `github-ops`, `maintainer`, `security`, `deployment` agents now use GitHub's hosted MCP server (`https://api.githubcopilot.com/mcp/`) — OAuth-authenticated, no PAT management

### Changed
- **Workspace MCP Config** (`.vscode/mcp.json`): Replaced old `mcpServers` format with new `servers` format; 8 servers registered (1 HTTP remote, 7 stdio local); all paths use `${workspaceFolder}` for portability; venv interpreter for reliable `mcp` imports
- **MCP Agent Coverage**: 14 of 27 agents now have `mcp-servers:` frontmatter (was 3)
- **github-ops Agent**: Migrated from local `github_server.py` (stdio) to remote GitHub MCP (HTTP)
- **Agent MCP Wiring**: Added scoped tool allowlists to conductor, implementer, reviewer, test, lint, observability, translation-conductor
- **MCP Integration Guide** (`docs/guides/mcp-integration.md`): Rewritten to cover HTTP transport, workspace config, resource annotations, prompts, validation/analytics servers, agent-to-MCP mapping
- **Python MCP Instructions** (`instructions/languages/python-mcp-server.instructions.md`): Updated from low-level `Server` class to `FastMCP` high-level API matching actual server implementations
- **Model Allocation**: Updated model tiers — Premium (Opus 4.6, Sonnet 4.6), Execution (GPT-5.3-Codex, Sonnet 4.6), Routine (Haiku 4.5, Gemini 3 Flash)

## [0.8.0] - 2026-02-09

### Added
- **Bundled Skill References** (Phase 4): Added `references/` folders with actionable assets to 6 skills:
  - `tdd`: test-pyramid.md, coverage-config-examples.md
  - `security-review`: owasp-top-10-checklist.md, stride-threat-model-template.md
  - `accessibility-wcag`: wcag-2.2-success-criteria.md, aria-patterns.md
  - `validation-scripts`: example-outputs.md
  - `git-operations`: conventional-commits.md, pr-template.md
  - `code-translation`: language-equivalence-tables.md
- **GitHub MCP Server** (`scripts/mcp/github_server.py`): 14-tool MCP server for issue, PR, workflow, and release management via `gh` CLI
- **MCP Integration Guide** (`docs/guides/mcp-integration.md`): Architecture, tool catalog, security considerations, setup instructions
- **Good/Bad Examples** in 3 global instructions: behavior (response style), quality (error handling), security (secret management)
- **Expanded Compliance Security** (`instructions/compliance/security.instructions.md`): SOC 2, GDPR, HIPAA frameworks; STRIDE reference; 8-step escalation checklist; audit trail requirements
- **Prompt `argument-hint`**: All 22 prompts now include `argument-hint` for VS Code 1.109 contextual suggestions
- **Prompt `${selection}`**: 4 prompts (review, quick-review, debug-issue, refactor-code) use `${selection}` contextual variable
- **Agent Handoffs** (Phase 2): Added handoffs to planner (3), implementer (3), reviewer (2), researcher (2) for agent-to-agent navigation

### Changed
- **Agent Frontmatter** (Phase 1): Removed deprecated `infer` field from all 27 agents (VS Code 1.109 uses `user-invokable`/`disable-model-invocation`)
- **Instruction `applyTo`** (Phase 1): Fixed `terminal-formatting.instructions.md` and `tool-approval-policy.instructions.md` to use `applyTo: "**"` (glob format)
- **github-ops Agent**: Added `mcp-servers` block pointing to `github_server.py` with 14-tool allowlist
- **Lint Agent**: Added `## Local Artifact Storage` section
- **WCAG Reference**: Updated accessibility-wcag skill from WCAG 2.1 to WCAG 2.2 references

## [0.7.0] - 2026-02-08

### Added
- **Delegation Routing Skill** (`.github/skills/delegation-routing/SKILL.md`): Comprehensive routing table for all 27 agents with keyword triggers, model preferences, escalation rules, context templates, and invocation guardrails
- **Autonomous Agent Delegation**: All 26 non-conductor agents now have `## Delegation` body sections with `#runSubagent` routing patterns

### Changed
- **Agent Frontmatter Cleanup**: Removed `handoffs:` blocks from 26 agents (70 button definitions eliminated). Conductor retains its 11 handoff buttons as the sole user-facing entry point
- **AGENTS.md**: Added Delegation Model section documenting the conductor-only handoff pattern and `#runSubagent` delegation model
- **copilot-instructions.md**: Updated Core Workflow section to reflect delegation-routing skill and conductor-only handoffs
- **conductor-lifecycle skill**: Added cross-reference to delegation-routing skill
- **Documentation Updates**: Updated onboarding guide, vscode-copilot-configuration guide, launch promo, and repository-analysis to reflect autonomous delegation model

### Preserved
- All `agents:` allowlists on conductor (21), translation-conductor (13), translator (2)
- `disable-model-invocation: true` on 4 translation sub-agents
- `user-invokable: false` on security, performance, observability, red-team
- All MCP server configurations

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
