---
title: "Agent Skills Pilot Evaluation Guide"
version: "1.0.0"
date: "2026-01-09"
status: experimental
---

# Agent Skills Pilot Evaluation Guide

This guide provides a structured approach to evaluating the Agent Skills experimental feature in VS Code 1.109, comparing on-demand loading versus always-on agents and instructions.

> **Retirement note (2026-03-11):** `orchestrator-terminal-style` is retired. Terminal formatting guidance now lives in `instructions/global/terminal-formatting.instructions.md`, with user-facing examples in `docs/guides/terminal-formatting-guide.md`.

## Executive Summary

**Objective:** Evaluate whether Agent Skills (on-demand loading) provides benefits over always-on agents/instructions for the Copilot Orchestrator multi-agent system.

**Pilot Skills:**
1. ~~**orchestrator-terminal-style**~~ — *Retired. Migrated to `instructions/global/terminal-formatting.instructions.md`*
2. **worktrees-ops** — Git worktrees operations
3. **validation-scripts** — PowerShell validation script usage

**Evaluation Period:** 2-4 weeks
**Participants:** Conductor workflow users, agent developers
**Success Criteria:** Token usage reduction ≥20%, relevance accuracy ≥90%, no negative performance impact

## Background

### Agent Skills vs. Always-On Instructions

| Aspect | Always-On Instructions | Agent Skills (On-Demand) |
|--------|------------------------|--------------------------|
| **Loading** | All instructions loaded in every chat session | Skills loaded only when relevant context detected |
| **Token Usage** | Full instruction set counts against context window | Only relevant skills consume tokens |
| **Relevance** | May include irrelevant instructions for current task | Only loads instructions matching task context |
| **Maintenance** | Single instruction file per domain | SKILL.md + entry point definitions |
| **Discoverability** | Implicit via instruction layering | Explicit via trigger phrases and patterns |

### Why Evaluate?

**Potential Benefits:**
- **Token Efficiency:** Reduce context window pressure by loading only relevant knowledge
- **Better Context:** More room for task-specific context when not loading all instructions
- **Faster Iteration:** Update skills without affecting unrelated tasks
- **Clearer Scope:** Explicit entry points make skill boundaries transparent

**Potential Drawbacks:**
- **Loading Accuracy:** Risk of missing relevant skills or loading irrelevant ones
- **Complexity:** Maintaining both SKILL.md and entry point definitions
- **Performance:** Overhead of context detection and dynamic loading
- **Compatibility:** Not all teams using VS Code 1.109+

## Pilot Skills

### 1. orchestrator-terminal-style (Retired)

**Status:** Retired — migrated to `instructions/global/terminal-formatting.instructions.md` and `docs/guides/terminal-formatting-guide.md`.

Terminal formatting is now an instruction-layer concern, not a skill. The instruction file applies to `scripts/**/*.ps1` and the user-facing guide lives in `docs/guides/terminal-formatting-guide.md`.

### 2. worktrees-ops

**Domain:** Git worktrees for parallel conductor workflows
**File:** [.github/skills/worktrees-ops/SKILL.md](../.github/skills/worktrees-ops/SKILL.md)

**Always-On Equivalent:** [docs/guides/background-agents-worktrees.md](../../docs/guides/background-agents-worktrees.md) (user guide, not instruction)

**Entry Points:**
- "create worktree"
- "parallel conductor workflows"
- "switch to different branch"
- "clean up worktrees"

**Evaluation Questions:**
1. Does the skill load when user mentions parallel workflows?
2. Does it avoid loading during single-branch work?
3. Are worktree operations explained clearly enough?
4. Does it integrate well with conductor pause points?

### 3. validation-scripts

**Domain:** PowerShell 5.1 validation script usage
**File:** [.github/skills/validation-scripts/SKILL.md](../.github/skills/validation-scripts/SKILL.md)

**Always-On Equivalent:** [scripts/AGENTS.md](../../scripts/AGENTS.md) + inline script documentation

**Entry Points:**
- "validate changes"
- "run lint check"
- "check asset validation"
- "run smoke tests"

**Evaluation Questions:**
1. Does the skill load after phase implementation?
2. Does it avoid loading during planning or research phases?
3. Are auto-approve behaviors explained clearly?
4. Does it guide correct script usage at pause points?

## Evaluation Metrics

### 1. Token Usage

**Hypothesis:** Agent Skills reduce token usage by 20-30% by loading only relevant knowledge.

**Measurement:**
```powershell
# Before (Always-On Instructions)
# Measure average session token usage
.\scripts\analyze-sessions.ps1 -StartDate (Get-Date).AddDays(-14) |
    Select-Object -ExpandProperty AverageTokensPerSession

# After (Agent Skills Enabled)
# Measure average session token usage
.\scripts\analyze-sessions.ps1 -StartDate (Get-Date).AddDays(-14) |
    Select-Object -ExpandProperty AverageTokensPerSession
```

**Data Collection:**
- Baseline: 2 weeks with always-on instructions (current state)
- Pilot: 2 weeks with `chat.useAgentSkills: true`
- Compare: Average tokens per session, peak session tokens, token budget headroom

**Success Criterion:** ≥20% reduction in average tokens per session

### 2. Loading Accuracy

**Hypothesis:** Skills load when relevant and avoid loading when irrelevant.

**Measurement:**
- **True Positive:** Skill loaded when needed (good)
- **True Negative:** Skill NOT loaded when not needed (good)
- **False Positive:** Skill loaded when not relevant (bad - wastes tokens)
- **False Negative:** Skill NOT loaded when needed (bad - missing context)

**Data Collection:**
Create test scenarios for each skill:

#### ~~orchestrator-terminal-style~~ (retired)

Retired during DEC-004. Terminal formatting is no longer evaluated as a skill-loading candidate; prompts in this domain should rely on `instructions/global/terminal-formatting.instructions.md` instead.

#### worktrees-ops
| Scenario | Expected Loading | Test Prompt |
|----------|------------------|-------------|
| Parallel features | ✓ Should load | "Work on feature-b while continuing feature-a" |
| Single branch work | ✗ Should NOT load | "Implement OAuth2 authentication" |
| Review PR during dev | ✓ Should load | "Review PR #247 without interrupting current work" |
| Commit changes | ✗ Should NOT load | "Commit Phase 4 completion" |

#### validation-scripts
| Scenario | Expected Loading | Test Prompt |
|----------|------------------|-------------|
| After implementation | ✓ Should load | "Validate changes after Phase 5" |
| During planning | ✗ Should NOT load | "Plan VS Code 1.108 integration" |
| Check frontmatter | ✓ Should load | "Run asset validation" |
| Research new feature | ✗ Should NOT load | "Research Agent Skills feature" |

**Success Criterion:** ≥90% accuracy (TP + TN) / (TP + TN + FP + FN)

### 3. User Experience

**Hypothesis:** Agent Skills improve workflow clarity without adding friction.

**Measurement:** User feedback survey

**Questions:**
1. Did you notice skills loading during your conductor workflows? (Yes/No)
2. Were the loaded skills relevant to your current task? (Always/Usually/Sometimes/Rarely/Never)
3. Did skills provide helpful information not available before? (Yes/No)
4. Did you experience any delays or performance issues? (Yes/No)
5. Would you prefer Agent Skills or always-on instructions? (Skills/Always-On/No Preference)
6. Additional feedback: [Open text]

**Success Criterion:** ≥80% prefer Agent Skills or have No Preference, ≤10% report performance issues

### 4. Performance Impact

**Hypothesis:** Agent Skills have negligible performance impact on conductor workflows.

**Measurement:**
- Time to first response after sending prompt
- Time to complete conductor phase (Planning → Implementation → Review)
- VS Code responsiveness during chat sessions

**Data Collection:**
```powershell
# Measure conductor phase durations
.\scripts\analyze-sessions.ps1 -Metric PhaseDuration -StartDate (Get-Date).AddDays(-14)
```

**Success Criterion:** ≤5% increase in phase duration, no user-reported slowdowns

### 5. Maintenance Burden

**Hypothesis:** Agent Skills add minimal maintenance overhead.

**Measurement:**
- Time to update SKILL.md vs. instruction file (minutes)
- Number of entry point false positives/negatives requiring tuning
- Developer feedback on SKILL.md structure clarity

**Data Collection:**
- Log time spent updating `instructions/global/terminal-formatting.instructions.md` instead of maintaining a separate terminal-formatting skill
- Track entry point tuning iterations during pilot
- Survey agent developers on maintenance experience

**Success Criterion:** ≤20% additional maintenance time, ≤3 entry point tuning iterations per skill

## Evaluation Phases

### Phase A: Baseline (Week 1-2)

**Objective:** Establish baseline metrics with always-on instructions.

**Actions:**
1. Ensure `chat.useAgentSkills: false` (current state)
2. Run normal conductor workflows (VS Code 1.108 integration Phases 4-7)
3. Collect session analytics:
   ```powershell
   .\scripts\analyze-sessions.ps1 -StartDate (Get-Date).AddDays(-14) -ExportPath artifacts/sessions/baseline.json
   ```
4. Record token usage, phase durations, user feedback

**Deliverables:**
- `artifacts/sessions/baseline.json` — Session analytics
- `artifacts/evaluation/baseline-metrics.md` — Summary report

### Phase B: Pilot (Week 3-4)

**Objective:** Enable Agent Skills and measure impact.

**Actions:**
1. Verify Agent Skills enabled (default in VS Code 1.109):
   ```json
   {
     "chat.useAgentSkills": true
   }
   ```
2. Run normal conductor workflows (continue VS Code integration or new tasks)
3. Execute test scenarios (see Loading Accuracy section)
4. Collect session analytics:
   ```powershell
   .\scripts\analyze-sessions.ps1 -StartDate (Get-Date).AddDays(-14) -ExportPath artifacts/sessions/pilot.json
   ```
5. Administer user feedback survey
6. Log entry point tuning iterations

**Deliverables:**
- `artifacts/sessions/pilot.json` — Session analytics
- `artifacts/evaluation/pilot-metrics.md` — Summary report
- `artifacts/evaluation/loading-accuracy-results.csv` — Test scenario results
- `artifacts/evaluation/user-feedback.md` — Survey responses

### Phase C: Analysis (Week 5)

**Objective:** Compare baseline and pilot metrics, make recommendation.

**Actions:**
1. Compare token usage (baseline vs. pilot)
2. Calculate loading accuracy from test scenarios
3. Analyze user feedback survey results
4. Evaluate performance impact
5. Assess maintenance burden
6. Create recommendation report

**Deliverables:**
- `artifacts/evaluation/comparison-report.md` — Detailed analysis
- `artifacts/evaluation/recommendation.md` — Go/No-Go decision

## Test Scenarios

### Scenario 1: Phase Completion Validation

**Context:** Conductor workflow, just completed Phase 5 implementation

**Test Prompt:**
```
Phase 5 implementation complete. Validate changes before creating phase-complete.md.
```

**Expected Behavior:**
- ✓ validation-scripts skill should load
- ✓ Terminal formatting guidance should come from `instructions/global/terminal-formatting.instructions.md` if output is formatted
- ✗ worktrees-ops skill should NOT load

**Validation:**
1. Check chat response mentions validation scripts (validate-copilot-assets.ps1, run-lint.ps1)
2. Check response includes auto-approve information
3. Check response guides correct validation workflow

### Scenario 2: Parallel Feature Development

**Context:** Working on Feature A, need to start Feature B without interrupting

**Test Prompt:**
```
I'm working on Feature A in main branch. Need to start Feature B simultaneously without switching branches. What's the best approach?
```

**Expected Behavior:**
- ✓ worktrees-ops skill should load
- ✗ validation-scripts skill should NOT load
- ✗ `orchestrator-terminal-style` should NOT load because the skill is retired; terminal formatting guidance is instruction-layer only

**Validation:**
1. Check chat response recommends Git worktrees
2. Check response includes creation commands (git worktree add)
3. Check response explains VS Code 1.108 Worktrees UI integration

### Scenario 3: Format Validation Output

**Context:** Validation script ran, want to improve terminal output formatting

**Test Prompt:**
```
The validation script output is plain text. Can you format it with glyphs and colors for better readability?
```

**Expected Behavior:**
- ✗ `orchestrator-terminal-style` should NOT load because the skill is retired
- ✓ Terminal formatting guidance should come from `instructions/global/terminal-formatting.instructions.md`
- ✗ validation-scripts skill might load (output interpretation)
- ✗ worktrees-ops skill should NOT load

**Validation:**
1. Check chat response includes glyph examples (✓✗⚠ℹ)
2. Check response includes PowerShell Write-Host with colors
3. Check response mentions accessibility (glyph + text labels)

### Scenario 4: Planning New Feature (Control)

**Context:** Starting new conductor workflow, planning phase

**Test Prompt:**
```
Plan implementation for adding MFA (multi-factor authentication) to our API.
```

**Expected Behavior:**
- ✗ All pilot skills should NOT load (not relevant to planning)

**Validation:**
1. Check chat response focuses on planning (phases, risks, dependencies)
2. Check no terminal formatting references
3. Check no worktrees or validation script references

### Scenario 5: Documentation Update (Control)

**Context:** Updating user documentation

**Test Prompt:**
```
Update the README.md to include VS Code 1.108 features.
```

**Expected Behavior:**
- ✗ All pilot skills should NOT load (documentation task)

**Validation:**
1. Check chat response focuses on documentation structure
2. Check no validation script execution mentioned
3. Check no terminal formatting or worktrees context

## Data Collection Templates

### Loading Accuracy Tracking Sheet

```csv
Scenario,Skill,Expected,Actual,Result,Notes
Phase Validation,validation-scripts,Load,Load,TP,"Correctly loaded, mentioned validate-copilot-assets.ps1"
Phase Validation,terminal-formatting.instructions,Apply,Apply,TP,"Instruction-layer formatting guidance used; retired skill not loaded"
Phase Validation,worktrees-ops,NOT Load,NOT Load,TN,"Correctly avoided, not relevant"
Parallel Features,worktrees-ops,Load,Load,TP,"Correctly loaded, recommended git worktree add"
Parallel Features,validation-scripts,NOT Load,NOT Load,TN,"Correctly avoided, not relevant"
...
```

### Token Usage Comparison

```markdown
## Token Usage: Baseline vs. Pilot

| Metric | Baseline (Always-On) | Pilot (Agent Skills) | Change |
|--------|----------------------|----------------------|--------|
| Average tokens/session | 45,200 | 32,150 | -28.9% ✅ |
| Peak session tokens | 78,900 | 54,300 | -31.2% ✅ |
| Median tokens/session | 42,100 | 30,900 | -26.6% ✅ |
| 95th percentile | 67,800 | 48,200 | -28.9% ✅ |
```

### User Feedback Summary

```markdown
## User Feedback (n=12 participants)

**Q1: Did you notice skills loading?**
- Yes: 9 (75%)
- No: 3 (25%)

**Q2: Were loaded skills relevant?**
- Always: 7 (58%)
- Usually: 4 (33%)
- Sometimes: 1 (8%)
- Rarely: 0 (0%)
- Never: 0 (0%)

**Q3: Helpful information not available before?**
- Yes: 10 (83%)
- No: 2 (17%)

**Q4: Performance issues?**
- Yes: 1 (8%)
- No: 11 (92%)

**Q5: Preference?**
- Agent Skills: 8 (67%)
- Always-On: 1 (8%)
- No Preference: 3 (25%)
```

## Decision Criteria

### Go Decision (Recommend Agent Skills)

All of the following must be true:
1. ✅ Token usage reduced by ≥20%
2. ✅ Loading accuracy ≥90%
3. ✅ ≥80% user preference for Skills or No Preference
4. ✅ Performance impact ≤5%
5. ✅ Maintenance burden ≤20% additional time

**Action:** Expand Agent Skills to additional domains (Phase C expansion)

### No-Go Decision (Keep Always-On Instructions)

Any of the following is true:
1. ❌ Token usage reduced by <20%
2. ❌ Loading accuracy <90%
3. ❌ >20% user preference for Always-On
4. ❌ Performance impact >5%
5. ❌ Maintenance burden >20% additional time

**Action:** Disable `chat.useAgentSkills`, keep pilot skills as reference documentation

### Conditional-Go Decision (Needs Tuning)

Metrics partially meet criteria:
- Token usage: 15-20% reduction (close to target)
- Loading accuracy: 85-90% (close to target)
- Mixed user feedback

**Action:** Extend pilot 2 more weeks, tune entry points, re-evaluate

## Rollback Plan

If pilot shows negative results:

2. **Disable Agent Skills (if needed for rollback):**
   ```json
   {
     "chat.useAgentSkills": false
   }
   ```

2. **Document Findings:**
   Create `artifacts/evaluation/pilot-failure-report.md` with:
   - Metrics that didn't meet criteria
   - User feedback summary
   - Recommendations for future attempts

3. **Preserve Skills as Documentation:**
   - Keep `.github/skills/` directory
   - Update README to indicate "Reference Documentation (Not Active)"
   - Link from conductor.agent.md as supplemental material

4. **Communicate to Team:**
   - Email summary of pilot results
   - Update `docs/operations.md` with lessons learned
   - Archive pilot in `docs/research/agent-skills-pilot-2026-01.md`

## Expansion Complete (11 Total Skills)

**Status:** ✅ All candidate skills implemented (2026-01-09)

### Core Skills (Implemented)
1. ~~**orchestrator-terminal-style**~~ — *Retired after pilot; migrated to instruction and guide assets*
2. **worktrees-ops** — Git worktrees parallel workflow management
3. **validation-scripts** — PowerShell validation tooling

### Expanded Skills (Implemented)
4. **conductor-lifecycle** — Phase management, pause points, handoffs
5. **security-review** — STRIDE threat modeling, compliance (SOC2/GDPR/HIPAA)
6. **performance-analysis** — Big O complexity, database optimization, cloud cost
7. **tdd** — Test-Driven Development, Red-Green-Refactor, test doubles
8. **accessibility-wcag** — WCAG 2.1 Level AA, ARIA, keyboard navigation
9. **documentation-style** — Markdown conventions, API docs, technical writing
10. **git-operations** — Conventional commits, branching strategies, PR workflows
11. **observability-telemetry** — Metrics/logs/traces, OpenTelemetry, Prometheus/Grafana

### Evaluation for Each Skill
- Token count in current instruction files
- Frequency of usage (how often needed)
- Context specificity (narrow domain vs. broad application)
- Entry point clarity (can we define precise triggers)

## Appendix: SKILL.md Structure

All pilot skills follow this structure for consistency:

```markdown
# Skill Name

Brief one-line description

## Description

2-3 paragraph overview of what the skill teaches

## When to Use

Bullet list of scenarios where skill is relevant

## Entry Points

### Trigger Phrases
- "phrase 1"
- "phrase 2"

### Context Patterns
- Pattern 1
- Pattern 2

## Core Knowledge

Main content: concepts, commands, patterns, examples

## Examples

Real-world usage scenarios with code samples

## References

Links to related documentation
```

## Resources

- **Pilot Skills:**
- [../../instructions/global/terminal-formatting.instructions.md](../../instructions/global/terminal-formatting.instructions.md)
- [terminal-formatting-guide.md](./terminal-formatting-guide.md)
  - [worktrees-ops/SKILL.md](../.github/skills/worktrees-ops/SKILL.md)
  - [validation-scripts/SKILL.md](../.github/skills/validation-scripts/SKILL.md)

- **Always-On Equivalents:**
  - [terminal-formatting.instructions.md](../../instructions/global/terminal-formatting.instructions.md)
  - [background-agents-worktrees.md](../../docs/guides/background-agents-worktrees.md)
  - [scripts/AGENTS.md](../../scripts/AGENTS.md)

- **Analytics:**
  - Session analytics: `.\scripts\analyze-sessions.ps1`
  - Token report: `.\scripts\token-report.ps1 -Path .`

- **VS Code 1.109:**
  - [VS Code Copilot Configuration](../../docs/guides/vscode-copilot-configuration.md)
  - [Agent Sessions Integration](../../AGENTS.md#agent-sessions-integration)

---

**Version:** 1.0.0
**Status:** Experimental
**Last Updated:** 2026-01-09
**Contact:** Conductor agent team
