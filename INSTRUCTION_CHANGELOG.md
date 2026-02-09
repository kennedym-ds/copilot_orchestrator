# Instruction Change Log

This document tracks changes to instruction files (`.instructions.md`) to enable safe evolution, rollback capability, and performance tracking.

## Change Format

Each entry should include:
- **Version:** Semantic version (MAJOR.MINOR.PATCH)
- **Date:** Date of change
- **File:** Path to instruction file
- **Change Type:** Added | Modified | Deprecated | Removed
- **Description:** What changed and why
- **Expected Impact:** Quality/Cost/Speed implications
- **Rollback Plan:** How to revert if issues occur
- **Metrics:** Key metrics to track post-change

---

## Changes

### 2026-02-09 - 2026 Best Practices Alignment (5-Phase Plan)

#### v2.2.0 - Frontmatter, Handoffs, Prompts, Skills, MCP Integration
**File:** `.github/agents/*.agent.md` (27), `.github/prompts/**/*.prompt.md` (22), `.github/skills/*/SKILL.md` (6), `instructions/global/*.instructions.md` (3), `instructions/compliance/security.instructions.md`, `scripts/mcp/github_server.py` (new), `docs/guides/mcp-integration.md` (new)
**Type:** Modified (60+ files), Added (12 reference files, 1 MCP server, 1 guide)
**Description:** Five-phase plan to close 10 gaps identified in 2026 best-practices audit against awesome-copilot community standards:
- Phase 1: Removed deprecated `infer` field from all 27 agents; fixed `applyTo` to glob format in 2 instruction files
- Phase 2: Added handoffs to planner (3), implementer (3), reviewer (2), researcher (2); added artifact storage to lint agent
- Phase 3: Added `argument-hint` to all 22 prompts; added `${selection}` to 4 prompts; added Good/Bad examples to 3 global instructions; expanded compliance/security instruction with SOC 2, GDPR, HIPAA, STRIDE, escalation checklist
- Phase 4: Created `references/` folders with 10 bundled assets across 6 skills (tdd, security-review, accessibility-wcag, validation-scripts, git-operations, code-translation); added Bundled References sections to 6 SKILL.md files
- Phase 5: Created GitHub MCP server (14 tools) and integrated with github-ops agent; created MCP integration guide; updated changelogs
**Expected Impact:**
- Quality: +++ (matches 2026 community standards, complete prompt metadata, comprehensive security instructions)
- Cost: Neutral (no model tier changes)
- Speed: + (argument-hint enables faster prompt discovery, handoffs reduce manual routing)
**Rollback:** Revert commits b69f982, e83b439, da7f707, c1fe320, and the Phase 5 commit. Restore `infer` field, remove handoffs, remove reference files, remove MCP server.
**Metrics:** Track prompt invocation rates (argument-hint adoption), skill reference usage, MCP tool call volume, validation pass rates

### 2026-02-08 - Autonomous Agent Delegation

#### v2.1.0 - Remove Handoff Buttons, Add Autonomous Delegation
**File:** `.github/agents/*.agent.md` (26 agents), `.github/skills/delegation-routing/SKILL.md` (new), `AGENTS.md`
**Type:** Modified (26 files), Added (1 file)
**Description:** Replaced UI-based handoff buttons with autonomous `#runSubagent` delegation across all 26 non-conductor agents:
- Removed `handoffs:` frontmatter blocks from 26 agents (70 button definitions eliminated)
- Added `## Delegation` body section to each agent with `#runSubagent` routing patterns
- Created `delegation-routing` skill with comprehensive routing table, keyword triggers, model preferences, escalation rules, and invocation guardrails
- Conductor retains its 11 handoff buttons as the sole user-facing entry point
- Preserved all `agents:` allowlists, `disable-model-invocation`, `user-invokable` flags, and `mcp-servers` blocks
- Updated `AGENTS.md` with new Delegation Model section
**Expected Impact:**
- Quality: ++ (agents delegate autonomously without user clicking buttons; reduced UI clutter)
- Cost: Neutral (same delegation volume, different mechanism)
- Speed: ++ (no user intervention needed for agent-to-agent routing)
**Rollback:** Restore `handoffs:` blocks from git history. Remove `## Delegation` sections and `delegation-routing` skill.
**Metrics:** Track autonomous delegation success rate, conductor handoff button usage, session completion time.

### 2026-02-08 - VS Code Best Practices Gap Analysis Implementation

#### v2.0.1 - Remove Deprecated VS Code Settings
**File:** `.github/copilot-instructions.md`, `README.md`, `AGENTS.md`, `docs/guides/vscode-copilot-configuration.md`, `docs/guides/onboarding.md`, `docs/quick-reference.md`, `docs/repository-analysis.md`
**Type:** Modified
**Description:** Removed deprecated VS Code settings and converted paths to tilde notation across all documentation:
- Removed `chat.modeFilesLocations` (deprecated; superseded by `chat.agentFilesLocations` since VS Code 1.106)
- Renamed `chat.viewRestorePreviousSession` â†’ `chat.restoreLastPanelSession` (renamed in VS Code 1.108)
- Converted absolute Windows paths (`C:\\Users\\...`) to tilde notation (`~/...`) in user-level settings examples for portability
**Expected Impact:**
- Quality: + (no more deprecation warnings in VS Code, settings resolve correctly across machines)
- Cost: Neutral
- Speed: Neutral
**Rollback:** Restore previous setting names from git history. Tilde paths can be reverted to absolute paths if needed.
**Metrics:** Verify agents load in new VS Code windows via Chat â†’ Diagnostics.

### 2026-02-06 - VS Code 1.109 Integration

#### v2.0.0 - Model Tier Overhaul
**File:** `.github/agents/*.agent.md` (all 22 agents)
**Type:** Modified
**Description:** Replaced all single-model assignments with model fallback arrays (1.109 feature). Updated model tiers:
- Premium (~20%): Claude Opus 4.6, Codex 5.2 â†’ conductor, planner, reviewer, security, beast-mode, researcher
- Execution (~70%): Claude Sonnet 4.5, Gemini 3 Pro, Codex 5.2 â†’ implementer, test, red-team, performance, data-analytics, accessibility, observability, visualizer, deployment, github-ops, maintainer, terraform, bicep, design
- Routine (~10%): Claude Haiku 4.5, Gemini 3 Flash â†’ docs, lint

Added `agent` tool to all 22 agents for 1.109 subagent discovery. Added `askQuestions` tool to conductor, planner, and beast-mode agents.
**Expected Impact:**
- Quality: ++ (model fallbacks prevent service interruptions, premium models for critical tasks)
- Cost: Neutral (same volume, better allocation)
- Speed: + (automatic failover avoids manual retry)
**Rollback:** Revert all agent files to commit prior to this change. Replace model arrays with single model strings.
**Metrics:** Track model fallback frequency, cost per agent tier, session completion rate.

#### v2.0.0 - Agent Frontmatter Enhancements (1.109)
**File:** `.github/agents/conductor.agent.md`
**Type:** Modified
**Description:** Added `agents` allowlist to conductor for controlled subagent delegation (all 21 other agents). This restricts which agents the conductor can invoke via `#runSubagent`.
**Expected Impact:**
- Quality: + (prevents accidental delegation to wrong agents)
- Cost: Neutral
- Speed: Neutral
**Rollback:** Remove `agents:` line from conductor frontmatter.
**Metrics:** Track delegation accuracy.

#### v2.0.0 - Settings Configuration (1.109)
**File:** `.vscode/settings.json`
**Type:** Modified (full rewrite from 1.108 format)
**Description:** Comprehensive update to workspace settings for VS Code 1.109:
- Replaced `github.copilot.chat.tools.memory.enabled` â†’ `github.copilot.chat.copilotMemory.enabled`
- Renamed `chat.agent.thinkingStyle` â†’ `chat.thinking.style`
- Added: `chat.agentFilesLocations`, `chat.agentSkillsLocations`, `chat.useAgentSkills` (GA), `chat.agentCustomizationSkill.enabled`
- Added: `chat.agent.thinking.terminalTools`, `chat.tools.autoExpandFailures`, `chat.askQuestions.enabled`
- Added: Anthropic enhancements (thinking budget, tool search, context editing)
- Added: `chat.agentsControl.enabled`, `chat.agentsControl.clickBehavior`, `workbench.startupEditor: "agentSessionsWelcomePage"`
- Added: `github.copilot.chat.searchSubagent.enabled`, `github.copilot.chat.organizationInstructions.enabled`
- Added: `github.copilot.chat.implementAgent.model: "Codex 5.2 (copilot)"`
- Added: `workbench.browser.openLocalhostLinks`, `simpleBrowser.useIntegratedBrowser`
- Added: `terminal.integrated.enableKittyKeyboardProtocol`, `git.worktreeIncludeFiles`
**Expected Impact:**
- Quality: ++ (unlocks all 1.109 features)
- Cost: Neutral
- Speed: ++ (parallel subagents, search subagent, auto-expand failures)
**Rollback:** Restore `.vscode/settings.json` from commit prior to this change.
**Metrics:** Track feature adoption, session metrics, model usage distribution.

#### v2.0.0 - copilot-instructions.md (1.109)
**File:** `.github/copilot-instructions.md`
**Type:** Modified
**Description:** Updated VS Code Settings block with all 1.109 settings. Added VS Code 1.109 Updates section documenting 18 new features. Updated Model Allocation table (3 tiers: Premium/Execution/Routine replacing Premium/Execution/Ultra-Premium).
**Expected Impact:**
- Quality: + (agents see correct settings documentation)
- Cost: Neutral
- Speed: Neutral
**Rollback:** Revert to previous settings block and remove 1.109 Updates section.
**Metrics:** Track agent behavior consistency.

#### v2.0.0 - AGENTS.md (1.109)
**File:** `AGENTS.md`
**Type:** Modified
**Description:** Updated Agent Sessions Integration section for VS Code 1.109 (was 1.108-only). Added subsections: VS Code 1.109 Agent Customization, VS Code 1.109 Agent Extensibility. Documents parallel subagents, session type picker, agent status indicator, Claude Agent preview, MCP Apps.
**Expected Impact:**
- Quality: + (comprehensive developer documentation)
- Cost: Neutral
- Speed: Neutral
**Rollback:** Revert AGENTS.md to previous version.
**Metrics:** Track onboarding time for new contributors.

#### v2.0.0 - vscode-copilot-configuration.md (1.109)
**File:** `docs/guides/vscode-copilot-configuration.md`
**Type:** Modified
**Description:** Bumped version 0.6.0 â†’ 0.7.0. Updated prerequisites to VS Code 1.109. Added comprehensive VS Code 1.109 Features section (17 subsections). Updated user settings.json examples with all new settings. Updated workspace-local settings example.
**Expected Impact:**
- Quality: ++ (complete configuration guide for 1.109)
- Cost: Neutral
- Speed: + (faster setup for new environments)
**Rollback:** Revert to version 0.6.0.
**Metrics:** Track setup success rate, configuration issue tickets.

### 2025-11-25 - Awesome-Copilot Pattern Adoption

#### v1.0.0 - Agent Frontmatter Standardization
**File:** `.github/agents/*.agent.md` (all 12 agents)
**Type:** Modified
**Description:** Adopted awesome-copilot patterns across all agent definitions:
- Added `argument-hint` field for improved discoverability
- Removed deprecated `target` field (was `target: vscode` or `target: github-copilot`)
- Standardized model names to allowlist format (e.g., `GPT-5 (copilot)`)
- Added Core Capabilities, Response Style, and Example Interaction Patterns sections to conductor, planner, and implementer agents
**Expected Impact:**
- Quality: + (better agent discoverability and documentation)
- Cost: Neutral
- Speed: + (users find correct agent faster via argument-hint)
**Rollback:** Revert all agent files to commit prior to this change.
**Metrics:** Track agent invocation accuracy (correct agent selected first try).

#### v1.0.0 - MCP Server Integration
**File:** `.github/agents/{researcher,design,data-analytics}.agent.md`
**Type:** Modified
**Description:** Added proper `mcp-servers` blocks with stdio type configuration for design_server.py and research_server.py integration.
**Expected Impact:**
- Quality: + (enables MCP tool access for research and design workflows)
- Cost: Neutral
- Speed: + (automated research via DuckDuckGo, design token lookup)
**Rollback:** Remove mcp-servers blocks from affected agents.
**Metrics:** Track MCP tool invocation success rate.

#### v1.0.0 - Collections System
**File:** `.github/collections/*.collection.yaml` (3 new files)
**Type:** Added
**Description:** Created orchestrator-core, data-science, and support-personas collections grouping related agents and instructions per awesome-copilot patterns.
**Expected Impact:**
- Quality: + (logical grouping aids discovery)
- Cost: Neutral
- Speed: + (collections pre-load relevant context)
**Rollback:** Delete `.github/collections/` directory.
**Metrics:** N/A (infrastructure change).

### 2025-11-25 - Model Governance Updates

#### v1.1.0 - Ultra-Premium Tier Governance
**File:** `instructions/global/03_model-selection.instructions.md`
**Type:** Modified
**Description:** Added Claude Opus 4.5 ultra-premium tier with:
- <5% invocation target
- Explicit justification requirements
- Updated fallback chains to reference Claude Opus 4.5 with governance constraints
- Scenario matrix for when Opus is appropriate (architecture, security, compliance)
**Expected Impact:**
- Quality: + (clear guidance prevents Opus misuse)
- Cost: + (prevents budget overruns from casual Opus usage)
- Speed: Neutral
**Rollback:** Revert model-selection instructions to prior version.
**Metrics:** Track Opus invocation percentage and justification quality.

### 2025-11-25 - Validation Enhancements

#### v1.1.0 - Agent Validation Script
**File:** `scripts/validate-copilot-assets.ps1`
**Type:** Modified
**Description:** Extended validation to check:
- `argument-hint` field presence (warning if missing)
- Model names against allowlist (error if invalid)
- `mcp-servers` object format (error if array format used)
- Deprecated `target` field presence (warning)
**Expected Impact:**
- Quality: + (catches configuration errors before commit)
- Cost: Neutral
- Speed: + (faster feedback on agent definition issues)
**Rollback:** Revert script to prior version.
**Metrics:** Track validation error/warning counts over time.

### 2025-11-18 - Instruction Governance & Linting

#### v1.1.0 - Conductor Workflow Instructions
**File:** `instructions/workflows/conductor.instructions.md`
**Type:** Modified
**Description:** Added standard version and date metadata to the frontmatter.
**Expected Impact:**
- Quality: Neutral (standardization)
- Cost: Neutral
- Speed: Neutral
**Rollback:** Revert to previous version.
**Metrics:** N/A

#### v1.0.1 - Copilot Instructions
**File:** `.github/copilot-instructions.md`
**Type:** Modified
**Description:** Fixed tab indentation issues to comply with linting rules.
**Expected Impact:**
- Quality: Neutral (formatting)
- Cost: Neutral
- Speed: Neutral
**Rollback:** Revert to previous version.
**Metrics:** N/A

### 2025-11-18 - DS-Star Routing Guardrails

#### v2.1.0 - Conductor Workflow Instructions
**File:** `instructions/workflows/conductor.instructions.md`
**Type:** Modified
**Description:** Added DS-Star telemetry payload requirements (round counter, verdict log, elapsed time), escalation guardrails (10-round cap, 5 consecutive INSUFFICIENT verdicts, 30-minute runtime limit), resume procedures tied to `pipeline_state.json`, and a troubleshooting matrix. Updated `.github/agents/conductor.agent.md`, `docs/workflows/ds-star-integration.md`, `docs/guides/onboarding.md`, and `docs/operations.md` to reference the new workflow.
**Expected Impact:**
- Quality: + (consistent DS-Star routing + monitoring)
- Cost: Neutral
- Speed: Neutral to slight - (additional telemetry verification adds minimal overhead)
**Rollback:** Revert the instruction file and dependent docs to the previous commit.
**Metrics:** Track DS-Star session completion rate, count of escalations triggered by guardrails, and number of resume events with artifact mismatches.

#### v1.3.0 - Planner Sequential DS-Star Mode
**File:** `instructions/workflows/planner.instructions.md`
**Type:** Modified
**Description:** Added DS-Star sequential planning guidance (single-step outputs, truncation handling, `pipeline_state.json` context requirements) and updated `.github/agents/planner.agent.md` plus a new DS-Star planner prompt to align with the Data Analytics workflow.
**Expected Impact:**
- Quality: + (planner steps align with DS-Star telemetry and artifact structure)
- Cost: Neutral (same premium-tier usage)
- Speed: + (less rework from over-planning)
**Rollback:** Revert planner instruction + agent + prompt files to prior commit.
**Metrics:** Monitor number of DS-Star rounds requiring planner step regeneration and the ratio of SUFFICIENT verdicts post-step submission.

### 2025-11-18 - DS-Star Artifact Governance (Phase 3)

#### v2.1.0 - Data Analytics Workflow Instructions
**File:** `instructions/workflows/data-analytics.instructions.md`
**Type:** Modified
**Description:** Introduced DS-Star artifact governance across the data analytics workflow, including required metadata tables, TODO fences for unfinished insights, and explicit `pipeline_state` fields that reviewers must see in every submission. Added a pointer to the new `plans/data-analysis/README.md` so analysts have a canonical artifact checklist, and updated `.github/agents/data-analytics.agent.md` to enforce the governance gates.
**Expected Impact:**
- Quality: + (structured artifacts reduce rework and enable reviewer traceability)
- Cost: Neutral (same model mix, marginally longer prompts only when metadata missing)
- Speed: - (slight) due to added verification steps before delivering DS-Star rounds
**Rollback:** Revert the workflow instruction, agent definition, and README pointer to the prior version.
**Metrics:** Track artifact metadata completeness rate, number of TODO fences that escape to reviewers, and DS-Star `pipeline_state` mismatch incidents per cycle.

#### v1.1.0 - Reviewer Workflow Instructions
**File:** `instructions/workflows/reviewer.instructions.md`
**Type:** Modified
**Description:** Added a DS-Star-specific verdict rubric with severity scoring, explicit artifact inspection guidance (metadata tables, TODO fences, `pipeline_state` diffs), and aligned `.github/agents/reviewer.agent.md` so reviewers apply the same governance language as data analytics.
**Expected Impact:**
- Quality: + (consistent verdicts and severity gradings improve auditability)
- Cost: Neutral (no model tier change)
- Speed: - (slight) because reviewers spend extra cycles validating governance artifacts
**Rollback:** Restore reviewer workflow instructions and agent persona to the previous DS-Star rubric.
**Metrics:** Monitor verdict-to-issue correlation, severity score distribution, and reviewer turnaround time deltas during DS-Star phases.

### 2025-11-18 - DS-Star Verdict Chain Alignment

#### v2.3.0 - Data Analytics Workflow Instructions
**File:** `instructions/workflows/data-analytics.instructions.md`
**Type:** Modified
**Description:** Added explicit cross-references to
`plans/data-analysis/README.md Â§Â§2â€“5`, reinforced the full metadata key set
(`run_id`, `reviewer_model`, `gap_summary`, `router_directive`, `attachments`,
optional `truncation_note`), and mandated `[severity:high|medium|low]` bullets
within `TODO-reviewer` fences so analytics, reviewer, and conductor personas can
trace `verdict.md` / `verdict.json` / `verdict_log.ndjson` updates without
ambiguity.
**Expected Impact:**
- Quality: + (clear pointers close the â€œmissing artifactâ€ loop and reduce reviewer churn)
- Cost: Neutral
- Speed: - (minimal) due to extra verification when cross-checking README sections
**Rollback Plan:** Revert the instruction file to v2.2.0 and remove the new
cross-references/severity language from affected agents.
**Metrics:** Track the count of reviewer escalations citing missing DS-Star
artifacts and the percentage of `metadata.json` files containing all required
keys.

#### v1.2.0 - Reviewer Workflow Instructions
**File:** `instructions/workflows/reviewer.instructions.md`
**Type:** Modified
**Description:** Formalized the `[severity:<level>]` format for
`TODO-reviewer` fences and Issues lists, required verdict synchronization across
`verdict.md`, `verdict.json`, `verdict_log.ndjson`, and `pipeline_state.json`,
and tightened references to `steps/00X_*` artifacts when issuing uppercase
verdict headers.
**Expected Impact:**
- Quality: + (reviewers now cite authoritative evidence and severity levels consistently)
- Cost: Neutral
- Speed: - (slight) due to the extra bookkeeping when mirroring verdict artifacts
**Rollback Plan:** Restore `instructions/workflows/reviewer.instructions.md` to
v1.1.0 and remove the severity/mirror requirements from reviewer prompts.
**Metrics:** Monitor time-to-approval for DS-Star sessions, the ratio of verdict
log mismatches detected during validation, and the count of reviews missing
severity tags.

### 2025-11-18 - Terminology & Configuration Alignment (Phase 1)

#### v1.0.0 - Terminology Standardization
**File:** Multiple (`AGENTS.md`, `instructions/workflows/*.md`, `docs/**/*.md`)
**Type:** Modified
**Description:** Standardized terminology from "Subagent" to "Custom Agent" and invocation syntax from `#runSubagent` to `#runCustomAgent` to align with official VS Code documentation and features. Updated configuration guides to reflect `chat.modeFilesLocations` and `chat.promptFilesLocations`.
**Expected Impact:**
- Quality: + (reduces confusion for new users)
- Cost: Neutral
- Speed: Neutral
**Rollback:** Revert to previous commit.
**Metrics:** N/A

### 2025-11-07 - SOTA Enhancement Release

#### v1.0.0 - Global Behavior Instructions
**File:** `instructions/global/00_behavior.instructions.md`
**Type:** Modified (Added versioning)
**Description:** Added version metadata to enable instruction tracking
**Expected Impact:**
- Quality: Neutral
- Cost: Neutral
- Speed: Neutral
**Rollback:** Remove version fields from front matter
**Metrics:** N/A - infrastructure change

#### v1.1.0 - Billy Butcher Adversarial Enhancement
**File:** `.github/agents/billy-butcher.agent.md`
**Type:** Modified
**Description:**
- Enhanced with explicit adversarial mindset
- Added adversarial test case checklist (boundary, concurrent, malicious input, resource exhaustion, state violations, error paths)
- Reframed as "Red Team Edition" for clarity
**Expected Impact:**
- Quality: +15-20% improvement in edge case detection
- Cost: Neutral (same model, potentially longer reviews)
- Speed: -5-10% (more thorough analysis)
**Rollback:** Revert to commit before adversarial enhancement
**Metrics to Track:**
- Number of security issues caught per review
- Number of edge cases identified
- Blocker/Major findings ratio
- Implementation rework rate

#### v1.2.0 - Billy Butcher Persona Retirement
**File:** `.github/agents/billy-butcher.agent.md`
**Type:** Removed
**Description:** Retired the tongue-in-cheek reviewer persona to keep the workspace professional and reduce duplicate review pathways.
**Expected Impact:**
- Quality: Neutral (standard reviewer remains authoritative)
- Cost: Slight reduction (one less premium persona)
- Speed: Neutral
**Rollback:** Restore the previous agent definition and reinstate conductor handoffs.
**Metrics to Track:**
- Review rejection rate (should remain stable)
- Security/performance escalation frequency (monitor for regressions)

#### v1.1.0 - Plan Template Diagram Support
**File:** `docs/templates/plan.md`
**Type:** Modified
**Description:** Added optional Mermaid diagram sections for architecture and workflow visualization
**Expected Impact:**
- Quality: +10% improvement in stakeholder understanding
- Cost: Neutral
- Speed: +5-10% time for diagram creation (offset by clarity gains)
**Rollback:** Remove diagram sections from template
**Metrics to Track:**
- Plan approval rate on first submission
- Stakeholder feedback scores
- Diagram usage rate in plans

### 2025-11-18 - DS-Star Sequential Planning (Phase 2)

#### v1.3.0 - Planner Sequential Mode
**File:** `instructions/workflows/planner.instructions.md`
**Type:** Modified
**Description:** Added "DS-Star Sequential Mode" section detailing single-step output requirements, `pipeline_state.json` context awareness, and truncation handling.
**Expected Impact:**
- Quality: + (aligns planner output with DS-Star architecture)
- Cost: Neutral
- Speed: + (reduces wasted tokens on future steps that might change)
**Rollback:** Revert to v1.2.0.
**Metrics:** Track number of planner steps rejected by Data Analytics agent.

#### v1.1.0 - Planner Agent Definition
**File:** `.github/agents/planner.agent.md`
**Type:** Modified
**Description:** Updated mission to include "DS-Star Mode" responsibility for generating single sequential analysis steps.
**Expected Impact:**
- Quality: + (clarifies agent role in DS-Star loop)
- Cost: Neutral
- Speed: Neutral
**Rollback:** Revert to v1.0.0.
**Metrics:** N/A

#### v1.0.0 - DS-Star Step Prompt
**File:** `.github/prompts/planning/ds-star-step.prompt.md`
**Type:** Added
**Description:** New prompt template for generating single analysis steps with context variables (`{{question}}`, `{{session_id}}`, `{{round}}`).
**Expected Impact:**
- Quality: + (standardizes step generation)
- Cost: Neutral
- Speed: + (faster prompt construction)
**Rollback:** Delete file.
**Metrics:** Usage count of this prompt template.

---

## Planned Changes

### Q1 2026 - Session Analytics Integration
- Add structured logging to conductor agent
- Create metrics collection hooks in all agents
- Target: Real-time observability improvements

### Q1 2026 - Instruction A/B Testing Framework
- Enable side-by-side comparison of instruction variants
- Automated quality/cost/speed metrics collection
- Target: Evidence-based instruction optimization

---

## Version Guidelines

### Semantic Versioning for Instructions

**MAJOR (X.0.0):** Breaking changes to instruction behavior
- Complete rewrite of agent persona
- Fundamental change to workflow expectations
- Removal of critical features
- Example: Changing from TDD to non-TDD workflow

**MINOR (0.X.0):** Backward-compatible improvements
- New capabilities or guidelines
- Enhanced checklists or criteria
- Additional tool usage patterns
- Example: Adding adversarial testing checklist

**PATCH (0.0.X):** Bug fixes and clarifications
- Typo corrections
- Clarifying ambiguous language
- Formatting improvements
- Example: Fixing unclear wording

### When to Increment Versions

Increment version when:
- âœ… Changing agent behavior expectations
- âœ… Adding/removing checklist items
- âœ… Modifying quality criteria
- âœ… Changing tool usage patterns
- âœ… Updating persona characteristics

Do NOT increment for:
- âŒ Comment-only changes
- âŒ Whitespace/formatting
- âŒ Metadata updates (except version itself)

---

## Performance Tracking Template

Use this template when analyzing instruction change impact:

```markdown
### Instruction Change Impact Analysis

**Version:** {version}
**Date Range:** {start} to {end}
**Sample Size:** {number of sessions}

**Quality Metrics:**
- Review pass rate: {before}% â†’ {after}%
- Blocker findings: {before} â†’ {after} per review
- Edge case coverage: {before}% â†’ {after}%

**Cost Metrics:**
- Premium model usage: {before}% â†’ {after}%
- Average cost per phase: ${before} â†’ ${after}

**Speed Metrics:**
- Average phase duration: {before}min â†’ {after}min
- Escalation frequency: {before} â†’ {after} per 10 phases

**Qualitative Feedback:**
- {User feedback summary}
- {Agent performance observations}

**Recommendation:** {Keep | Refine | Rollback}
**Next Actions:** {List of follow-up improvements}
```

---

## Rollback Procedures

### Emergency Rollback
If a change causes immediate issues:

1. Identify the problematic instruction file and version
2. Locate the git commit hash from this changelog
3. Revert the specific file: `git checkout <commit-hash>^ -- <file-path>`
4. Test the rollback with a sample session
5. Document the rollback reason in this changelog
6. Create a retrospective issue to prevent recurrence

### Planned Rollback
If metrics show degradation over time:

1. Review the performance tracking analysis
2. Determine if issue is instruction-related or environmental
3. Propose alternative instruction approach
4. A/B test old vs. new vs. alternative
5. Select best-performing variant
6. Update changelog with decision rationale

---

## Best Practices

### Before Making Changes
- [ ] Review current instruction version and changelog
- [ ] Define expected impact on quality/cost/speed
- [ ] Identify metrics to track post-change
- [ ] Document rollback plan
- [ ] Get peer review for MAJOR changes

### After Making Changes
- [ ] Update version in instruction front matter
- [ ] Add entry to this changelog
- [ ] Update relevant agent documentation
- [ ] Run validation scripts
- [ ] Monitor metrics for 1-2 weeks
- [ ] Collect qualitative feedback
- [ ] Document actual vs. expected impact

### Quarterly Review
- [ ] Analyze all instruction changes from quarter
- [ ] Identify patterns in successful/unsuccessful changes
- [ ] Update instruction templates with learnings
- [ ] Share insights in docs/operations.md
- [ ] Plan improvements for next quarter

---

**Changelog Status:** Active
**Next Review:** Q2 2025
**Owner:** Copilot Guild
**Feedback:** Submit via docs/operations.md or create issue
