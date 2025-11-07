---
description: "Dynamic escalation framework for transitioning from cost-efficient to premium models."
applyTo: ".github/agents/implementer.agent.md,.github/agents/conductor.agent.md"
---

# Escalation Patterns — Cost-Efficient to Premium Model Assistance

## Overview

This document defines triggers and patterns for escalating from cost-efficient models (GPT-5 Mini, Claude Haiku 4.5, GPT-4.1) to premium reasoning models (GPT-5, Claude Sonnet 4.5, Claude Opus, Gemini 2.5 Pro) during implementation phases. Escalation preserves cost efficiency while ensuring quality recovery when complexity exceeds the capabilities of execution-tier models.

## Cost-Tier Architecture

**Execution Tier (80% of invocations):**
- Default models: GPT-5 Mini, Claude Haiku 4.5, GPT-4.1
- Optimized for: Structured implementation, test execution, routine refactoring
- Tool access: `edit`, `runCommands`, `search`, `todos`, `changes`, `problems`
- No access to: `fetch`, `githubRepo` (prevents context bloat)

**Planning/Review Tier (20% of invocations):**
- Premium models: GPT-5, Claude Sonnet 4.5, Claude Opus, Gemini 2.5 Pro
- Optimized for: Research, architecture decisions, ambiguity resolution, code review
- Full tool access including `fetch`, `search`, `githubRepo`, `usages`

**Expected cost reduction:** 60-75% vs. all-premium approach

## Escalation Triggers

### Tier 1: Automatic Escalation (Implementer Must Escalate)

Escalate immediately to Conductor (which may invoke premium models) when:

1. **Repeated test failures after 2+ fix attempts**
   - Pattern: Same test fails despite code changes
   - Action: Flag to Conductor with failure logs and attempted fixes
   - Rationale: Requires deeper reasoning about test design or hidden dependencies

2. **Ambiguous or conflicting requirements**
   - Pattern: Phase instructions contain contradictions or unclear acceptance criteria
   - Action: Request Conductor clarification before proceeding
   - Rationale: Cost-efficient models should not guess intent on critical decisions

3. **Security vulnerability detected in changed code**
   - Pattern: CodeQL alerts, dependency warnings, or manual security concerns
   - Action: Escalate to Security agent via Conductor
   - Rationale: Security reviews require threat modeling beyond execution-tier scope

4. **Performance regression exceeding 20% threshold**
   - Pattern: Benchmark results show significant slowdown or memory increase
   - Action: Escalate to Performance agent via Conductor
   - Rationale: Performance optimization requires profiling and architectural analysis

### Tier 2: Recommended Escalation (Implementer Should Consider)

Consider escalating to Conductor when:

1. **Implementation requires significant architectural changes**
   - Pattern: Minimal fix requires modifying 5+ files or introducing new abstractions
   - Action: Present options to Conductor with trade-offs before proceeding
   - Rationale: Architecture decisions benefit from premium model reasoning

2. **External API integration with unclear documentation**
   - Pattern: Third-party API behavior unclear from docs alone
   - Action: Request Researcher investigation via Conductor
   - Rationale: Research tasks benefit from `fetch` tool and premium model synthesis

3. **Context window approaching 75% capacity**
   - Pattern: Token usage warnings or truncated responses
   - Action: Request phase split or context compression from Conductor
   - Rationale: Premium models have larger context windows and better summarization

4. **Cross-cutting concerns affecting multiple modules**
   - Pattern: Change impacts logging, error handling, or shared utilities
   - Action: Validate scope with Conductor before expanding implementation
   - Rationale: Reduces risk of unintended side effects in broader codebase

### Tier 3: Optional Escalation (Implementer May Escalate)

Optionally escalate when:

1. **Refactoring opportunity identified during implementation**
   - Pattern: Code duplication or design smell discovered
   - Action: Log in phase summary; Conductor decides if in-scope
   - Rationale: Keeps implementation focused; defers optimization decisions

2. **Test coverage gaps observed**
   - Pattern: Edge cases not covered by existing tests
   - Action: Note in phase summary with suggested test additions
   - Rationale: Test design improvements can be batched in review phase

3. **Documentation inconsistencies with implementation**
   - Pattern: Comments or README contradict actual behavior
   - Action: Fix obvious errors; flag major rewrites for Docs agent
   - Rationale: Minor doc fixes are in-scope; major rewrites need dedicated effort

## Escalation Protocol

### For Implementer

When escalation is required:

1. **Document the situation:**
   - Current phase objective
   - Specific blocker or complexity encountered
   - Attempts made and results (logs, error messages, test output)
   - Recommended next action (which agent or model tier needed)

2. **Use structured escalation format:**
   ```markdown
   ## Escalation Required
   
   **Trigger:** [Tier 1/2/3] [Specific trigger from above]
   **Context:** [Brief summary of current work]
   **Blocker:** [Detailed explanation of issue]
   **Attempts:** [What was tried, with results]
   **Recommendation:** [Which agent/tier needed and why]
   **Artifacts:** [Logs, test output, error traces]
   ```

3. **Hand off to Conductor:**
   - Use handoff button to transition context
   - Preserve TODO list and phase summary state
   - Wait for Conductor guidance before resuming

### For Conductor

When receiving escalation:

1. **Assess trigger severity:**
   - Tier 1: Immediate action required
   - Tier 2: Evaluate cost/benefit of escalation
   - Tier 3: Defer to next review unless critical

2. **Route to appropriate agent:**
   - **Ambiguity/Research:** Invoke Researcher with premium model
   - **Architecture decisions:** Invoke Planner for options analysis
   - **Security concerns:** Invoke Security agent for threat assessment
   - **Performance issues:** Invoke Performance agent for profiling
   - **Test design:** Invoke Reviewer for test strategy guidance

3. **Document escalation in phase summary:**
   - Record trigger, routing decision, outcome
   - Update cost metrics (premium vs. execution tier usage)
   - Note any process improvements for future phases

## Context Overflow Prevention

When Implementer approaches context limits:

### Prevention Strategies

1. **Targeted file reads:**
   - Use `view` with line ranges instead of full files
   - Read only relevant modules for current change
   - Avoid loading test suites unless executing them

2. **Progressive disclosure:**
   - Start with high-level structure (`tree`, directory views)
   - Drill down only into files requiring changes
   - Defer reading related modules until necessary

3. **Search over read:**
   - Use `search` to locate specific functions or patterns
   - Read search results context instead of full files
   - Leverage `usages` for cross-reference analysis

### Recovery Patterns

1. **Phase splitting (Conductor action):**
   - Break large implementation into smaller phases
   - Each phase has focused scope and acceptance criteria
   - Reduces context accumulation per phase

2. **Context compression (Conductor action):**
   - Summarize completed work into artifact
   - Start new phase with clean context + artifact reference
   - Preserve continuity without token bloat

3. **Premium model escalation:**
   - Larger context windows (GPT-5: 128K, Claude Opus: 200K, Gemini 2.5 Pro: 2M)
   - Better summarization capabilities
   - Use for complex integrations or refactorings

## Metrics & Monitoring

Track escalation effectiveness in `docs/operations.md`:

1. **Escalation frequency:**
   - Count escalations per week/month
   - Categorize by trigger tier and type
   - Identify patterns requiring process improvements

2. **Cost efficiency:**
   - Premium model invocations / Total invocations
   - Actual vs. target ratio (20% premium)
   - Cost per completed phase

3. **Quality recovery rate:**
   - Successful outcomes after escalation
   - Time to resolution (escalation → unblock)
   - Review rejection rate before vs. after escalation patterns

4. **False escalation rate:**
   - Escalations where cost-efficient model could have succeeded
   - Over-escalation indicates need for better Implementer prompting
   - Under-escalation indicates need for clearer triggers

## Open Questions

- Should escalation triggers auto-update based on success/failure data?
- How to handle model-specific strengths (e.g., Claude for refactoring, GPT for code generation)?
- When to batch multiple Tier 3 escalations vs. handling individually?
- Should Implementer have limited `fetch` access for API documentation only?

## Related Documentation

- `instructions/workflows/implementer.instructions.md` — TDD workflow and execution-tier expectations
- `instructions/global/03_model-selection.instructions.md` — Model fallback matrix and resilience strategies
- `docs/guides/prompt-engineering-by-tier.md` — Tier-specific prompt crafting guidelines
- `docs/operations.md` — Metrics tracking and continuous improvement
