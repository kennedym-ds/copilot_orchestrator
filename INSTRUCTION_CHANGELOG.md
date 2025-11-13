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

### 2025-11-13 - LLM Format Preferences & Chatmode Deprecation

#### v1.0.0 - LLM-Specific Format Preferences
**File:** `instructions/global/04_llm-format-preferences.instructions.md`
**Type:** Added
**Description:**
- Created comprehensive guide for LLM-specific prompt formatting
- Claude XML preferences with structured examples and use cases
- OpenAI JSON preferences for API design and structured generation
- Gemini conversational format for research and interactive exploration
- Format selection matrix by task type and agent role
- Hybrid approach examples for complex multi-phase tasks
- Performance considerations and token efficiency guidelines
- Migration strategy for existing prompts
**Expected Impact:**
- Quality: +20-30% improvement in model-appropriate task routing
- Cost: -10-15% reduction through optimized format/model pairing
- Speed: +5-10% faster responses due to format alignment with model strengths
**Rollback:** Remove file and revert model selection references
**Metrics to Track:**
- Output quality by format type
- Token usage per format
- Task completion success rate
- Developer satisfaction with format clarity

#### v1.1.0 - Model Selection with Format Integration
**File:** `instructions/global/03_model-selection.instructions.md`
**Type:** Modified
**Description:**
- Removed deprecated chatmode reference from applyTo field
- Added reference to new LLM format preferences guide
- Updated related documentation section
**Expected Impact:**
- Quality: Neutral (documentation improvement)
- Cost: Neutral
- Speed: Neutral
**Rollback:** Revert applyTo field and remove format preferences reference
**Metrics:** N/A - documentation update

#### v1.0.0 - Agent Format Preference Metadata
**Files:** All `.github/agents/*.agent.md` files
**Type:** Modified
**Description:**
- Added preferred_formats metadata to all 11 agent definitions
- Specified primary and secondary format preferences per agent
- Included rationale for format choices based on agent responsibilities
- Aligned with LLM format preferences guide
**Agent Format Assignments:**
- Conductor: Conversational (planning) / XML (state tracking)
- Planner: Conversational (requirements) / JSON (deliverables)
- Implementer: JSON (code gen) / XML (refactoring)
- Reviewer: XML (findings) / JSON (metrics)
- Researcher: Conversational (exploration) / XML (synthesis)
- Security: XML (threats) / JSON (vulnerabilities)
- Performance: JSON (metrics) / Conversational (analysis)
- Maintainer: JSON (tracking) / XML (triage)
- Visualizer: Conversational (UX) / JSON (specs)
- Data Analytics: JSON (schemas) / Conversational (insights)
- Docs: XML (structure) / Conversational (guides)
**Expected Impact:**
- Quality: +15-20% improvement in agent output consistency
- Cost: Neutral (same models, better format selection)
- Speed: +5-10% from reduced format conversion overhead
**Rollback:** Remove preferred_formats sections from agent front matter
**Metrics to Track:**
- Agent output quality scores by format usage
- Format conversion frequency
- Task completion success rate per agent
- User satisfaction with agent responses

#### Chatmode Deprecation
**Files:** Multiple documentation and configuration files
**Type:** Removed/Modified
**Description:**
- Removed `.github/chatmodes/` directory (conductor.chatmode.md, planner.chatmode.md)
- Updated 10 documentation files to remove chatmode references
- Replaced with .agent.md references throughout
- Updated VS Code configuration examples in all guides
- Aligned with VS Code Insiders modern agent architecture
**Files Modified:**
- `.github/copilot-instructions.md`
- `README.md`
- `docs/guides/vscode-copilot-configuration.md`
- `docs/guides/onboarding.md`
- `docs/quick-reference.md`
- `docs/repository-analysis.md`
- `docs/workflows/orchestration-rebuild-plan.md`
- `docs/workflows/new-workspace-blueprint.md`
- `docs/workflows/new-workspace-setup-checklist.md`
**Expected Impact:**
- Quality: +5% from consistency (single agent definition format)
- Cost: Neutral
- Speed: Neutral
- Maintainability: +30% from eliminating duplicate definitions
**Rollback:** Restore .github/chatmodes directory from git history and revert documentation
**Metrics to Track:**
- Documentation accuracy
- User onboarding time
- Configuration error rate
- Agent discovery success rate

---

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
