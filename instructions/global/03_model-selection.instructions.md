---
name: "model-selection-fallback"
description: "Model selection strategy and fallback matrix for multi-tier resilience."
applyTo: "**/*.{md,agent.md,chatmode.md}"
---

# Model Selection & Fallback Matrix

## Overview

This document defines the model selection strategy for the Copilot Orchestrator multi-agent system and provides fallback chains to ensure resilience when primary models are unavailable. The strategy uses a three-tier approach: Premium for deep reasoning, Execution for implementation work, and Routine for lightweight tasks.

## Model Allocation Strategy

### Premium Tier (~20% of invocations)

**Use cases:** Research, architecture decisions, ambiguity resolution, code review, threat modeling, orchestration

| Agent | Primary Model | Fallback Model | Context Window | Cost Tier |
|-------|---------------|----------------|----------------|-----------|
| Conductor | Claude Opus 4.6 | Claude Sonnet 4.6 | 200K tokens | Premium |
| Planner | Claude Opus 4.6 | Claude Sonnet 4.6 | 200K tokens | Premium |
| Security | Claude Opus 4.6 | Claude Sonnet 4.6 | 200K tokens | Premium |
| Beast Mode | Claude Opus 4.6 | Claude Sonnet 4.6 | 200K tokens | Premium |
| Researcher | Claude Opus 4.6 | Claude Sonnet 4.6 | 200K tokens | Premium |

**Premium model characteristics:**
- Advanced reasoning and planning capabilities
- Extended thinking with visible chain-of-thought
- Deep synthesis of complex, multi-domain information
- Higher cost per request (baseline = 1.0x)

### Execution Tier (~70% of invocations)

**Use cases:** Implementation, testing, analysis, routine refactoring, support tasks

| Agent | Primary Model | Fallback Model | Context Window | Cost Tier |
|-------|---------------|----------------|----------------|-----------|
| Reviewer | GPT-5.3-Codex | Claude Sonnet 4.6 | 200K tokens | Execution |
| Implementer | Claude Sonnet 4.6 | GPT-5.3-Codex | 200K tokens | Execution |
| Test | Claude Sonnet 4.6 | GPT-5.3-Codex | 200K tokens | Execution |
| Translator | GPT-5.3-Codex | Claude Sonnet 4.6 | 200K tokens | Execution |
| Red Team | GPT-5.3-Codex | Claude Sonnet 4.6 | 200K tokens | Execution |
| Performance | GPT-5.3-Codex | Claude Sonnet 4.6 | 200K tokens | Execution |
| Rubber Duck | Claude Sonnet 4.6 | Claude Haiku 4.5 | 200K tokens | Routine |
| Accessibility | GPT-5.3-Codex | Claude Sonnet 4.6 | 200K tokens | Execution |
| Observability | GPT-5.3-Codex | Claude Sonnet 4.6 | 200K tokens | Execution |
| Visualizer | GPT-5.3-Codex | Claude Sonnet 4.6 | 200K tokens | Execution |
| Deployment | GPT-5.3-Codex | Claude Sonnet 4.6 | 200K tokens | Execution |
| GitHub Ops | GPT-5.3-Codex | Claude Sonnet 4.6 | 200K tokens | Execution |
| Maintainer | GPT-5.3-Codex | Claude Sonnet 4.6 | 200K tokens | Execution |
| Terraform | GPT-5.3-Codex | Claude Sonnet 4.6 | 200K tokens | Execution |
| Bicep | GPT-5.3-Codex | Claude Sonnet 4.6 | 200K tokens | Execution |
| Design | GPT-5.3-Codex | Claude Sonnet 4.6 | 200K tokens | Execution |

**Execution model characteristics:**
- Strong code generation, testing, and analysis
- Good balance of reasoning capability and cost
- Multiple architecture options for resilience
- Cost per request (~0.3x - 0.5x premium)

### Routine Tier (~10% of invocations)

**Use cases:** Documentation, linting, template-based generation, formatting

| Agent | Primary Model | Fallback Model | Context Window | Cost Tier |
|-------|---------------|----------------|----------------|-----------|
| Docs | Claude Haiku 4.5 | Gemini 3 Flash | 200K tokens | Routine |
| Lint | Claude Haiku 4.5 | Gemini 3 Flash | 200K tokens | Routine |

**Routine model characteristics:**
- Optimized for structured, well-defined tasks
- Fast response times for interactive workflows
- Lowest cost per request (0.33x premium or less)

**Expected cost reduction:** 60-75% vs. all-premium approach

## Fallback Matrix

### Primary Model Unavailable Scenarios

1. **Service outage** — API returns 503, 429, or connection timeout
2. **Rate limiting** — Quota exceeded for organization or user
3. **Model deprecation** — Primary model sunset by provider
4. **Context overflow** — Input exceeds model's context window
5. **Performance degradation** — Response time exceeds acceptable threshold

### Fallback Chains by Tier

#### Orchestration Tier Agents (Conductor, Planner, Beast Mode, Translation Conductor)

**Primary:** Claude Opus 4.6
**Fallback sequence:**
1. Claude Sonnet 4.6 (strong reasoning, versatile architecture)
2. GPT-5.3-Codex (good reasoning at lower cost)
3. **Pause workflow** — Orchestration tasks should never downgrade to routine tier

**Decision logic:**
- Try Fallback 1 immediately on primary failure
- Fallback 2 for non-critical orchestration tasks when both primary and Fallback 1 unavailable
- Pause and notify user if all orchestration options exhausted
- Document model switch in phase summary

#### Security Tier Agents (Security, Red Team)

**Primary:** Claude Opus 4.6
**Fallback sequence:**
1. Claude Sonnet 4.6 (strong adversarial and compliance reasoning)
2. **Pause workflow** — Security reviews must never downgrade below Sonnet

**Decision logic:**
- Try Fallback 1 immediately on primary failure
- Pause and notify user if both Opus and Sonnet unavailable
- Security-critical tasks should never proceed on lower-tier models

#### Research Tier Agents (Researcher, Translation Analyzer)

**Primary:** Gemini 3.1 Pro (Preview)
**Fallback sequence:**
1. Claude Opus 4.6 (deep research and synthesis)
2. Claude Haiku 4.5 (lightweight research for simple queries)
3. **Escalate to Conductor** if research requires extended analysis

**Decision logic:**
- Try Fallback 1 immediately on primary failure
- Fallback 2 only for simple, well-scoped research tasks
- Escalate for multi-domain synthesis when both primary and Opus unavailable

#### Coding Tier Agents (Implementer, Reviewer, Test, Translator, Translation Validator, Translation Styler, Performance, Accessibility, Observability, Deployment, GitHub Ops, Maintainer, Terraform, Bicep)

**Primary:** GPT-5.3-Codex
**Fallback sequence:**
1. Claude Sonnet 4.6 (strong code generation and analysis)
2. **Escalate to Conductor** if task complexity requires premium reasoning

**Decision logic:**
- Try Fallback 1 immediately on primary failure
- Escalate if implementation task reveals unexpected complexity
- Document model switch in phase summary

#### Documentation Tier Agents (Docs, Lint, Visualizer, Design, Rubber Duck)

**Primary:** Claude Sonnet 4.6
**Fallback sequence:**
1. Claude Haiku 4.5 (fast, cost-effective for structured tasks)
2. Gemini 3 Flash (lightweight fallback for formatting and templating)
3. **Escalate to Conductor** if documentation requires research or complex analysis

**Decision logic:**
- Try Fallback 1 immediately on primary failure
- Fallback 2 for simple formatting and template-based tasks
- Escalate when content requires deep analysis or research capabilities

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

**Claude Opus 4.6:**
- Complex architectural planning and review
- Security and compliance reviews requiring deep reasoning
- Multi-domain synthesis and research
- Extended thinking tasks with visible chain-of-thought

**Claude Sonnet 4.6:**
- Code generation, TDD workflows, and implementation
- Structured refactoring and test execution
- API integration and external calls
- Strong reasoning with balanced cost efficiency

**GPT-5.3-Codex:**
- Analysis, profiling, and support tasks
- Code review and quality auditing
- Nuanced requirement interpretation
- Long-form documentation review
- Balanced reasoning at moderate cost
- Large context analysis and cross-repository analysis

**Claude Haiku 4.5:**
- Fast, reliable answers to lightweight coding questions
- Documentation formatting and template-based generation
- Code style enforcement and linting
- Low-cost routine tasks (0.33x multiplier)

**Gemini 3.1 Pro (Preview):**
- Large context window optimized for document analysis and research
- Strong evidence synthesis and multi-source citation
- Technology evaluation and dependency analysis
- Cost per request (~0.4x premium)

**Gemini 3 Flash:**
- Fast, lightweight coding assistance
- Budget fallback for documentation and formatting tasks (0.1x multiplier)
- Quick syntax and formatting questions

### Dynamic Model Selection

Conductor may override default model assignment when:

1. **Task characteristics favor specific model:**
   - Research-heavy → Gemini 3.1 Pro (Preview) (large context, evidence synthesis)
   - Implementation-heavy → GPT-5.3-Codex (code generation)
   - Documentation-heavy → Claude Sonnet 4.6 (writing quality)
   - Security/adversarial → Claude Opus 4.6 (deep reasoning)
   - Large context → Gemini 3.1 Pro (Preview) or Claude Opus 4.6

2. **Context size requirements:**
   - >200K tokens → Claude Opus 4.6
   - 100K-200K tokens → Claude Opus 4.6 or Claude Sonnet 4.6
   - <100K tokens → Any model appropriate for tier

3. **Budget constraints:**
   - Cost-sensitive work → Prefer execution or routine tier
   - Critical decisions → Use premium tier regardless of cost

4. **Quality history:**
   - Track success rates by model-task pairs
   - Switch to proven alternatives when patterns emerge

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
   - Dynamic reordering of fallback chains based on success history
   - Predict best fallback for task type based on historical data

2. **Hybrid approaches:**
   - Use execution tier for draft, premium for review/refinement
   - Split complex tasks across multiple models strategically

3. **Real-time cost optimization:**
   - Prefer cheaper models when budget threshold approaching
   - Alert before exceeding cost targets

## Related Documentation

- `instructions/workflows/escalation-patterns.instructions.md` — When and how to escalate from execution to premium tier
- `docs/guides/prompt-engineering-by-tier.md` — Tier-specific prompt crafting guidelines
- `docs/operations.md` — Metrics, monitoring, and continuous improvement
- `docs/workflows/new-workspace-blueprint.md` — Overall architecture and model allocation rationale
