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

### 2025-12-06 - Copilot Instructions Enhancement

#### v1.1.0 - Enhanced .github/copilot-instructions.md
**File:** `.github/copilot-instructions.md`
**Type:** Modified
**Description:** Enhanced Copilot instructions to align with GitHub best practices for Copilot coding agent:
- Added "Technology Stack" section documenting languages (PowerShell, Python, Markdown), configuration formats (YAML, JSON), testing frameworks (Pester, pytest), and platform support
- Added "Project Conventions" section covering file naming (kebab-case for markdown, PascalCase for PowerShell), documentation requirements, commit message format (conventional commits), line length limits (400 chars), and whitespace rules
- Added consolidated "Build, Test, and Validation" section with clear testing commands and validation requirements
- Added "Common Tasks and Workflows" section with step-by-step guides for: adding custom agents, updating instructions, creating prompts, and troubleshooting validation failures
- Improved overall structure and readability for better Copilot coding agent comprehension
**Expected Impact:**
- Quality: ++ (clearer guidance for Copilot coding agent, better adherence to project conventions)
- Cost: Neutral (improved efficiency may reduce token usage through clearer instructions)
- Speed: + (Copilot can find relevant information faster, reduce clarification questions)
**Rollback:** Revert `.github/copilot-instructions.md` to previous version (103 lines vs 167 lines)
**Metrics:**
- Track Copilot PR quality scores (adherence to conventions, validation pass rate)
- Monitor time-to-completion for common tasks
- Track validation failure frequency

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
`plans/data-analysis/README.md §§2–5`, reinforced the full metadata key set
(`run_id`, `reviewer_model`, `gap_summary`, `router_directive`, `attachments`,
optional `truncation_note`), and mandated `[severity:high|medium|low]` bullets
within `TODO-reviewer` fences so analytics, reviewer, and conductor personas can
trace `verdict.md` / `verdict.json` / `verdict_log.ndjson` updates without
ambiguity.
**Expected Impact:**
- Quality: + (clear pointers close the “missing artifact” loop and reduce reviewer churn)
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
- ✅ Changing agent behavior expectations
- ✅ Adding/removing checklist items
- ✅ Modifying quality criteria
- ✅ Changing tool usage patterns
- ✅ Updating persona characteristics

Do NOT increment for:
- ❌ Comment-only changes
- ❌ Whitespace/formatting
- ❌ Metadata updates (except version itself)

---

## Performance Tracking Template

Use this template when analyzing instruction change impact:

```markdown
### Instruction Change Impact Analysis

**Version:** {version}
**Date Range:** {start} to {end}
**Sample Size:** {number of sessions}

**Quality Metrics:**
- Review pass rate: {before}% → {after}%
- Blocker findings: {before} → {after} per review
- Edge case coverage: {before}% → {after}%

**Cost Metrics:**
- Premium model usage: {before}% → {after}%
- Average cost per phase: ${before} → ${after}

**Speed Metrics:**
- Average phase duration: {before}min → {after}min
- Escalation frequency: {before} → {after} per 10 phases

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
