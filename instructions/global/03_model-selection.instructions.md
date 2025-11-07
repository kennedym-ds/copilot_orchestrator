---
name: "model-selection-fallback"
description: "Model selection strategy and fallback matrix for multi-tier resilience."
applyTo: "**/*.{md,agent.md,chatmode.md}"
---

# Model Selection & Fallback Matrix

## Overview

This document defines the model selection strategy for the Copilot Orchestrator multi-agent system and provides fallback chains to ensure resilience when primary models are unavailable. The strategy balances cost efficiency (execution tier) with reasoning capability (planning/review tier) while maintaining quality through process design.

## Model Allocation Strategy

### Planning/Review Tier (Premium Models)

**Target allocation:** 20% of total invocations  
**Use cases:** Research, architecture decisions, ambiguity resolution, code review, threat modeling

| Agent | Primary Model | Reasoning Capability | Context Window | Cost Tier |
|-------|---------------|---------------------|----------------|-----------|
| Conductor | Claude Sonnet 4.5 | Advanced reasoning, orchestration | 200K tokens | Premium |
| Planner | GPT-5 | Strategic planning, option analysis | 128K tokens | Premium |
| Researcher | Gemini 2.5 Pro | Research synthesis, web integration | 2M tokens | Premium |
| Reviewer | Claude Sonnet 4.5 | Code review, pattern recognition | 200K tokens | Premium |
| Security | Claude Opus | Threat modeling, compliance | 200K tokens | Premium |
| Performance | GPT-5 | Profiling analysis, optimization | 128K tokens | Premium |

**Premium model characteristics:**
- Advanced reasoning and planning capabilities
- Larger context windows (128K - 2M tokens)
- Better synthesis of complex information
- Higher cost per request (baseline = 1.0x)

### Execution Tier (Cost-Efficient Models)

**Target allocation:** 80% of total invocations  
**Use cases:** Structured implementation, test execution, routine refactoring

| Agent | Primary Model | Execution Capability | Context Window | Cost Tier |
|-------|---------------|---------------------|----------------|-----------|
| Implementer | GPT-4.1 | Code generation, TDD workflows | 128K tokens | Efficient |
| Docs | Claude Haiku 4.5 | Documentation writing | 200K tokens | Efficient |

**Cost-efficient model characteristics:**
- Optimized for structured, well-defined tasks
- Strong code generation and test execution
- Adequate context windows (128K - 200K tokens)
- Significantly lower cost per request (~0.15x - 0.30x premium models)

**Expected cost reduction:** 60-75% vs. all-premium approach

## Fallback Matrix

### Primary Model Unavailable Scenarios

1. **Service outage** — API returns 503, 429, or connection timeout
2. **Rate limiting** — Quota exceeded for organization or user
3. **Model deprecation** — Primary model sunset by provider
4. **Context overflow** — Input exceeds model's context window
5. **Performance degradation** — Response time exceeds acceptable threshold

### Fallback Chains by Agent

#### Implementer (Execution Tier)

**Primary:** GPT-4.1  
**Fallback sequence:**
1. Claude Haiku 4.5 (similar cost, different architecture)
2. GPT-5 Mini (lower cost, still capable for structured tasks)
3. **Escalate to Conductor** (may invoke premium model if complexity requires)

**Decision logic:**
- Try Fallback 1 immediately on primary failure
- If Fallback 1 unavailable, try Fallback 2
- If both fallbacks unavailable OR task fails twice, escalate to Conductor
- Conductor determines if premium model needed or if phase should be deferred

#### Conductor (Premium Tier)

**Primary:** Claude Sonnet 4.5  
**Fallback sequence:**
1. GPT-5 (comparable reasoning, different architecture)
2. Gemini 2.5 Pro (massive context window, strong synthesis)
3. Claude Opus (highest capability, highest cost — reserve for critical decisions)

**Decision logic:**
- Fallback 1 for most orchestration tasks
- Fallback 2 when context size is critical (>128K tokens)
- Fallback 3 only for critical security, compliance, or architectural decisions
- If all unavailable, pause workflow and notify user

#### Planner (Premium Tier)

**Primary:** GPT-5  
**Fallback sequence:**
1. Claude Sonnet 4.5 (strong planning, lower context)
2. Gemini 2.5 Pro (research-heavy planning)
3. Claude Opus (complex multi-phase planning)

**Decision logic:**
- Fallback 1 for standard planning tasks
- Fallback 2 when extensive research required
- Fallback 3 for critical architecture decisions
- Avoid downgrading to execution tier for planning

#### Researcher (Premium Tier)

**Primary:** Gemini 2.5 Pro  
**Fallback sequence:**
1. Claude Opus (excellent synthesis, smaller context)
2. GPT-5 (strong research, good web integration)
3. Claude Sonnet 4.5 (adequate research, most cost-effective premium)

**Decision logic:**
- Fallback 1 when context size <200K tokens
- Fallback 2 for balanced research tasks
- Fallback 3 when budget constraints exist
- Never downgrade to execution tier for research

#### Reviewer (Premium Tier)

**Primary:** Claude Sonnet 4.5  
**Fallback sequence:**
1. GPT-5 (strong code understanding)
2. Claude Opus (highest scrutiny for critical reviews)
3. Gemini 2.5 Pro (when context size is large)

**Decision logic:**
- Fallback 1 for most code reviews
- Fallback 2 for security-critical or compliance reviews
- Fallback 3 for reviews spanning many files
- Document model used in review report for audit trail

#### Docs (Execution Tier)

**Primary:** Claude Haiku 4.5  
**Fallback sequence:**
1. GPT-5 Mini (cost-efficient documentation)
2. GPT-4.1 (structured writing)
3. **Escalate to Conductor** if documentation requires research or architecture decisions

**Decision logic:**
- Try both execution-tier fallbacks before escalating
- Escalate if documentation gap analysis needed
- Escalate if architectural diagrams or complex onboarding required

#### Security (Premium Tier)

**Primary:** Claude Opus  
**Fallback sequence:**
1. Claude Sonnet 4.5 (strong security analysis, lower cost)
2. GPT-5 (good threat modeling)
3. **No further fallback** — security reviews require premium capability

**Decision logic:**
- Fallback 1 for routine security reviews
- Fallback 2 for specific threat scenarios
- If both unavailable, defer security review until primary restored
- Never downgrade security to execution tier

#### Performance (Premium Tier)

**Primary:** GPT-5  
**Fallback sequence:**
1. Gemini 2.5 Pro (good analytical reasoning)
2. Claude Sonnet 4.5 (cost-effective performance review)
3. **No further fallback** — performance analysis requires premium capability

**Decision logic:**
- Fallback 1 for profiling-heavy analysis
- Fallback 2 for routine performance reviews
- If unavailable, defer until primary restored
- Never downgrade performance to execution tier

## Fallback Implementation

### Detection

Agents should detect unavailability through:

1. **API error codes:**
   - 503 Service Unavailable
   - 429 Too Many Requests (rate limiting)
   - 500 Internal Server Error (persistent)

2. **Response quality degradation:**
   - Truncated responses
   - Hallucinations or nonsense output
   - Repeated failures on known-good inputs

3. **Performance thresholds:**
   - Response time > 60 seconds
   - Multiple retries required
   - Timeout errors

### Execution

When primary model fails:

1. **Log the failure:**
   - Model attempted
   - Error type and message
   - Task context (agent, phase, objective)
   - Timestamp and duration

2. **Attempt fallback:**
   - Select next model in fallback chain
   - Preserve all context and prompts
   - Retry with same inputs
   - Document model switch in response

3. **Escalate if needed:**
   - All fallbacks exhausted
   - Task failed on multiple models
   - Quality concerns with fallback output
   - Hand off to Conductor with failure log

### Recovery

After primary model restored:

1. **Return to primary model** for new tasks
2. **Complete in-flight tasks** with current model (avoid mid-task switching)
3. **Review fallback quality** to assess if fallback matrix needs tuning
4. **Update metrics** in `docs/operations.md`

## Model-Specific Strengths

### When to Prefer Specific Models

**Claude Sonnet 4.5 / Claude Opus:**
- Refactoring and code restructuring
- Security and compliance reviews
- Long-form documentation
- Nuanced requirement interpretation

**GPT-5 / GPT-4.1:**
- Code generation and test writing
- API integration and external calls
- Structured data transformation
- Step-by-step execution tasks

**Gemini 2.5 Pro:**
- Research with massive context requirements
- Cross-repository analysis
- Large file/log analysis
- Multi-document synthesis

**Claude Haiku 4.5 / GPT-5 Mini:**
- Routine implementation tasks
- Test execution and validation
- Documentation updates
- Template-based generation

### Dynamic Model Selection

Conductor may override default model assignment when:

1. **Task characteristics favor specific model:**
   - Research-heavy → Gemini 2.5 Pro
   - Refactoring-heavy → Claude Sonnet 4.5
   - Code generation-heavy → GPT-5

2. **Context size requirements:**
   - >128K tokens → Gemini 2.5 Pro or Claude Opus
   - 64K-128K tokens → GPT-5 or Claude Sonnet 4.5
   - <64K tokens → Any model appropriate for tier

3. **Budget constraints:**
   - Cost-sensitive work → Prefer execution tier or cheaper premium models
   - Critical decisions → Use top-tier premium models regardless of cost

4. **Quality history:**
   - Model X consistently underperforms on task type Y → Switch to proven alternative
   - Track success rates by model-task pairs in metrics

## Resilience Best Practices

1. **Graceful degradation:**
   - Always have at least 2 fallback options before escalation
   - Document quality implications of each fallback
   - Preserve context across model switches

2. **Cost awareness:**
   - Track costs by model and agent
   - Alert when premium usage exceeds 25% (target is 20%)
   - Optimize prompt efficiency to reduce token usage

3. **Quality assurance:**
   - Review outputs from fallback models more carefully
   - Compare fallback quality to primary over time
   - Update fallback chains based on empirical performance

4. **Communication:**
   - Log all model switches in phase summaries
   - Notify user if critical task required fallback
   - Document fallback patterns in completion reports

## Metrics & Monitoring

Track in `docs/operations.md`:

1. **Model availability:**
   - Uptime by model (primary and fallbacks)
   - Frequency of fallback invocation
   - Mean time to recovery for primary models

2. **Fallback effectiveness:**
   - Success rate by fallback position (1st, 2nd, 3rd)
   - Quality comparison (primary vs. fallback outputs)
   - Escalation rate after fallback exhaustion

3. **Cost impact:**
   - Actual cost vs. budgeted cost per phase
   - Premium vs. execution tier ratio (target: 20/80)
   - Cost per successful task completion

4. **Model-task fit:**
   - Success rates by model-task pairs
   - Identify optimal model for each common task type
   - Update default assignments based on data

## Future Enhancements

1. **Automated fallback tuning:**
   - Machine learning to predict best fallback for task type
   - Dynamic reordering of fallback chains based on success history

2. **Fine-tuning execution tier:**
   - Train GPT-5 Mini or Claude Haiku on successful implementation patterns
   - Reduce need for premium escalation through better base capability

3. **Hybrid approaches:**
   - Use execution tier for draft, premium for review/refinement
   - Split complex tasks across multiple models strategically

4. **Real-time cost optimization:**
   - Prefer cheaper models when budget threshold approaching
   - Alert before exceeding cost targets

## Related Documentation

- `instructions/workflows/escalation-patterns.instructions.md` — When and how to escalate from execution to premium tier
- `docs/guides/prompt-engineering-by-tier.md` — Tier-specific prompt crafting guidelines
- `docs/operations.md` — Metrics, monitoring, and continuous improvement
- `docs/workflows/new-workspace-blueprint.md` — Overall architecture and model allocation rationale
