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
