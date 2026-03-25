---
name: "model-selection-fallback"
description: "Model selection strategy and fallback matrix for multi-tier resilience."
applyTo: ".github/agents/*.agent.md"
---

# Model Selection & Fallback Matrix

## Overview

This document defines the model selection strategy for the Copilot Orchestrator multi-agent system and provides fallback chains to ensure resilience when primary models are unavailable. The strategy uses a three-tier approach: Premium for deep reasoning, Execution for implementation work, and Routine for lightweight tasks.

## Model Allocation Strategy

### Premium Tier (~10% of invocations)

**Use cases:** Orchestration, architecture decisions, ambiguity resolution, threat modeling

| Agent | Primary Model | Fallback Model | Context Window | Cost Tier |
|-------|---------------|----------------|----------------|----------|
| Conductor | Claude Opus 4.6 | GPT-5.4 | 200K tokens | Premium (3×) |
| Planner | Claude Opus 4.6 | GPT-5.4 | 200K tokens | Premium (3×) |
| Security | Claude Opus 4.6 | Claude Sonnet 4.6 | 200K tokens | Premium (3×) |

**Premium model characteristics:**
- Advanced reasoning and planning capabilities
- Extended thinking with visible chain-of-thought
- Deep synthesis of complex, multi-domain information
- Reserved for highest-stakes decisions (orchestration, planning, security)
- Cost per request: 3× multiplier

### Execution Tier (~76% of invocations)

**Use cases:** Implementation, testing, analysis, documentation, refactoring, support tasks

| Agent | Primary Model | Fallback Model | Context Window | Cost Tier |
|-------|---------------|----------------|----------------|-----------|
| Implementer | GPT-5.4 | Claude Sonnet 4.6 | 1M tokens | Execution (1×) |
| Reviewer | GPT-5.4 | Claude Sonnet 4.6 | 1M tokens | Execution (1×) |
| Test | GPT-5.4 | Claude Sonnet 4.6 | 1M tokens | Execution (1×) |
| Beast Mode | GPT-5.4 | Claude Opus 4.6 | 1M tokens | Execution (1×) |
| Red Team | GPT-5.4 | Claude Opus 4.6 | 1M tokens | Execution (1×) |
| Spec | GPT-5.4 | Claude Sonnet 4.6 | 1M tokens | Execution (1×) |
| Researcher | GPT-5.4 | Claude Sonnet 4.6 | 1M tokens | Execution (1×) |
| Performance | GPT-5.4 | Claude Sonnet 4.6 | 1M tokens | Execution (1×) |
| Accessibility | GPT-5.4 | Claude Sonnet 4.6 | 1M tokens | Execution (1×) |
| Docs | GPT-5.4 | Claude Sonnet 4.6 | 1M tokens | Execution (1×) |
| Observability | GPT-5.4 | Claude Sonnet 4.6 | 1M tokens | Execution (1×) |
| Deployment | GPT-5.4 | Claude Sonnet 4.6 | 1M tokens | Execution (1×) |
| GitHub Ops | GPT-5.4 | Claude Sonnet 4.6 | 1M tokens | Execution (1×) |
| Maintainer | GPT-5.4 | Claude Sonnet 4.6 | 1M tokens | Execution (1×) |
| Terraform | GPT-5.4 | Claude Sonnet 4.6 | 1M tokens | Execution (1×) |
| Bicep | GPT-5.4 | Claude Sonnet 4.6 | 1M tokens | Execution (1×) |
| Design | GPT-5.4 | Claude Sonnet 4.6 | 1M tokens | Execution (1×) |
| GUI Tester | GPT-5.4 | Claude Sonnet 4.6 | 1M tokens | Execution (1×) |
| Translator | GPT-5.4 | Claude Sonnet 4.6 | 1M tokens | Execution (1×) |
| Translation Analyzer | GPT-5.4 | Claude Sonnet 4.6 | 1M tokens | Execution (1×) |
| Translation Validator | GPT-5.4 | Claude Sonnet 4.6 | 1M tokens | Execution (1×) |
| Translation Styler | GPT-5.4 | Claude Sonnet 4.6 | 1M tokens | Execution (1×) |
| Translation Conductor | Claude Sonnet 4.6 | GPT-5.4 | 200K tokens | Execution (1×) |

**Execution model characteristics:**
- GPT-5.4: Best 1× model — SWE-Bench Pro 57.7%, 1M context, native tool search
- Claude Sonnet 4.6: Strong fallback with extended thinking and TDD workflows
- Docs agent uses GPT-5.4 for its 1M context window (doc trees are token-intensive)
- Cost per request: 1× multiplier

### Routine Tier (~10% of invocations)

**Use cases:** Linting, template-based generation, formatting, conversational debugging

| Agent | Primary Model | Fallback Model | Context Window | Cost Tier |
|-------|---------------|----------------|----------------|----------|
| Lint | Claude Haiku 4.5 | Gemini 3 Flash | 200K tokens | Routine (0.33×) |
| Rubber Duck | Claude Haiku 4.5 | Gemini 3 Flash | 200K tokens | Routine (0.33×) |
| Visualizer | Claude Haiku 4.5 | Gemini 3 Flash | 200K tokens | Routine (0.33×) |

**Routine model characteristics:**
- Optimized for structured, well-defined tasks
- Fast response times for interactive workflows
- Lowest cost per request (0.33× multiplier)

**Expected cost reduction:** ~23% vs. previous allocation (32.99× vs. 43× per cycle)

## Fallback Matrix

### Primary Model Unavailable Scenarios

1. **Service outage** — API returns 503, 429, or connection timeout
2. **Rate limiting** — Quota exceeded for organization or user
3. **Model deprecation** — Primary model sunset by provider
4. **Context overflow** — Input exceeds model's context window
5. **Performance degradation** — Response time exceeds acceptable threshold

### Fallback Chains by Tier

#### Orchestration Tier Agents (Conductor, Planner)

**Primary:** Claude Opus 4.6 (3×)
**Fallback sequence:**
1. GPT-5.4 (strong reasoning, 1M context, tool search)
2. Claude Sonnet 4.6 (extended thinking, versatile)
3. **Pause workflow** — Orchestration tasks should never downgrade to routine tier

**Decision logic:**
- Try Fallback 1 immediately on primary failure
- Fallback 2 for non-critical orchestration when both primary and Fallback 1 unavailable
- Pause and notify user if all orchestration options exhausted
- Document model switch in phase summary

#### Security Tier Agents (Security)

**Primary:** Claude Opus 4.6 (3×)
**Fallback sequence:**
1. Claude Sonnet 4.6 (strong adversarial and compliance reasoning)
2. **Pause workflow** — Security reviews must never downgrade below Sonnet

**Decision logic:**
- Try Fallback 1 immediately on primary failure
- Pause and notify user if both Opus and Sonnet unavailable
- Security-critical tasks should never proceed on lower-tier models

#### Execution Tier Agents (22 agents — Implementer, Reviewer, Test, Beast Mode, Red Team, Spec, Researcher, Performance, Accessibility, Docs, Observability, Deployment, GitHub Ops, Maintainer, Terraform, Bicep, Design, GUI Tester, Translator, Translation Analyzer, Translation Validator, Translation Styler)

**Primary:** GPT-5.4 (1×)
**Fallback sequence:**
1. Claude Sonnet 4.6 (strong code generation and analysis)
2. **Escalate to Conductor** if task complexity requires premium reasoning

**Decision logic:**
- Try Fallback 1 immediately on primary failure
- Escalate if implementation task reveals unexpected complexity
- Document model switch in phase summary
- Beast Mode and Researcher may escalate to Opus 4.6 if extended deep reasoning is needed

#### Translation Conductor

**Primary:** Claude Sonnet 4.6 (1×)
**Fallback sequence:**
1. GPT-5.4 (strong coding and tool calling)
2. **Escalate to Conductor** if orchestration stalls

**Decision logic:**
- Translation orchestration follows a well-defined 6-phase lifecycle
- Sonnet provides sufficient reasoning at 1/3 Opus cost
- Escalate if translation scope exceeds initial estimates

#### Routine Tier Agents (Lint, Rubber Duck, Visualizer)

**Primary:** Claude Haiku 4.5 (0.33×)
**Fallback sequence:**
1. Gemini 3 Flash (lightweight fallback for formatting and templating)
2. **Escalate to Conductor** if task requires deeper analysis

**Decision logic:**
- Try Fallback 1 immediately on primary failure
- Escalate when content requires research or complex reasoning
- These agents handle structured, template-driven tasks where speed matters more than depth

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

**GPT-5.4:**
- Best 1× model — subsumes GPT-5.3-Codex with better benchmarks across the board
- SWE-Bench Pro 57.7%, GDPval 83.0%, GPQA Diamond 92.8%
- Native computer-use capabilities (OSWorld 75.0%, WebArena 67.3%)
- Tool search for efficient large tool ecosystems (MCP Atlas 67.2%)
- 1M context window, strong steerability
- Ideal for: coding, review, testing, research, adversarial testing, GUI testing

**Claude Sonnet 4.6:**
- Strong code generation, TDD workflows, and implementation
- Extended thinking with visible chain-of-thought
- Structured refactoring and test execution
- Translation orchestration and workflow management
- Strong reasoning with balanced cost efficiency (1× multiplier)

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
   - Research-heavy → GPT-5.4 (BrowseComp 82.7%, 1M context)
   - Implementation-heavy → GPT-5.4 (SWE-Bench Pro 57.7%)
   - GUI/browser testing → GPT-5.4 (native computer use, OSWorld 75.0%)
   - Documentation-heavy → GPT-5.4 (1M context for large doc trees)
   - Security/adversarial → Claude Opus 4.6 (deep reasoning)
   - Large context → GPT-5.4 (1M context) or Claude Opus 4.6 (1M beta)

2. **Context size requirements:**
   - >200K tokens → GPT-5.4 (1M native) or Claude Opus 4.6 (1M beta)
   - 100K-200K tokens → GPT-5.4 or Claude Sonnet 4.6
   - <100K tokens → Any model appropriate for tier

3. **Budget constraints:**
   - Cost-sensitive work → Prefer execution or routine tier
   - Critical decisions → Use premium tier regardless of cost

4. **Quality history:**
   - Track success rates by model-task pairs
   - Switch to proven alternatives when patterns emerge

## Thinking Effort Allocation (VS Code 1.113+)

VS Code 1.113 introduced configurable thinking effort in the model picker. Reasoning models (Opus 4.6, Sonnet 4.6, GPT-5.4) now expose a Low/Medium/High effort submenu that controls how much internal reasoning the model performs per request. Higher effort = more thinking tokens = higher latency and token consumption within the same pricing tier.

> **Deprecated:** `github.copilot.chat.anthropic.thinking.effort` and `github.copilot.chat.responsesApiReasoningEffort` are deprecated as of 1.113. Configure effort via the model picker only.

### 5-Branch Cost Structure

Layering thinking effort onto the 3-tier model allocation creates 5 effective cost branches:

| Branch | Model + Effort | Effective Token Weight | Target Agents | When to Use |
|--------|----------------|------------------------|---------------|-------------|
| **Premium-High** | Opus 4.6 · High | 3× + heavy thinking | Security | Threat modeling, deep compliance review, complex architecture |
| **Premium-Medium** | Opus 4.6 · Medium | 3× + standard thinking | Conductor, Planner | Orchestration, strategy, multi-domain synthesis |
| **Execution-Medium** | GPT-5.4 · Medium / Sonnet 4.6 · Medium | 1× + standard thinking | Implementer, Reviewer, Test, Beast Mode, Red Team, Spec, Researcher, Performance | Implementation, code review, TDD, deep analysis |
| **Execution-Low** | GPT-5.4 · Low / Sonnet 4.6 · Low | 1× + minimal thinking | Docs, Observability, Deployment, GitHub Ops, Maintainer, Accessibility, Design, Terraform, Bicep, GUI Tester, Translation sub-agents | Structured tasks, documentation, routine operations |
| **Routine-None** | Haiku 4.5 (no reasoning) | 0.33× | Lint, Rubber Duck, Visualizer | Formatting, conversational debugging, diagrams |

### Recommended Effort by Agent

| Agent | Model | Recommended Effort | Rationale |
|-------|-------|--------------------|-----------|
| Conductor | Opus 4.6 | Medium | Orchestration needs balanced reasoning; High only for ULTRADEEP complexity |
| Planner | Opus 4.6 | Medium | Strategy drafting benefits from reasoning but rarely needs maximum depth |
| Security | Opus 4.6 | High | Threat modeling and compliance require exhaustive reasoning |
| Implementer | GPT-5.4 | Medium | Code generation benefits from moderate reasoning for edge cases |
| Reviewer | GPT-5.4 | Medium | Quality gates need reasoning to catch subtle bugs |
| Test | GPT-5.4 | Medium | TDD requires reasoning about edge cases and coverage |
| Beast Mode | GPT-5.4 | High | Extended reasoning is the entire point of this agent |
| Red Team | GPT-5.4 | High | Adversarial analysis requires exhaustive thinking |
| Spec | GPT-5.4 | Medium | Requirements elicitation needs balanced reasoning |
| Researcher | GPT-5.4 | Medium | Synthesis and evidence evaluation need moderate depth |
| Performance | GPT-5.4 | Medium | Analysis benefits from reasoning about algorithmic complexity |
| Docs | GPT-5.4 | Low | Documentation is structured; deep reasoning rarely needed |
| Observability | GPT-5.4 | Low | Telemetry config is pattern-driven |
| Deployment | GPT-5.4 | Low | CI/CD review follows established patterns |
| GitHub Ops | GPT-5.4 | Low | PR/issue management is procedural |
| Maintainer | GPT-5.4 | Low | Triage and release logistics are routine |
| Accessibility | GPT-5.4 | Low | WCAG checks follow well-defined rulesets |
| Design | GPT-5.4 | Low | Design token queries are structured lookups |
| Terraform | GPT-5.4 | Low | IaC follows established patterns |
| Bicep | GPT-5.4 | Low | Azure IaC follows established patterns |
| GUI Tester | GPT-5.4 | Low | Browser automation scripts are procedural |
| Translation Conductor | Sonnet 4.6 | Medium | Orchestration of 6-phase lifecycle |
| Translator | GPT-5.4 | Low | File-level translation follows pattern mapping |
| Translation Analyzer | GPT-5.4 | Low | Dependency graph analysis is structural |
| Translation Validator | GPT-5.4 | Low | Validation stack is rule-based |
| Translation Styler | GPT-5.4 | Low | Idiom application follows target-language patterns |
| Lint | Haiku 4.5 | N/A | Non-reasoning model |
| Rubber Duck | Haiku 4.5 | N/A | Non-reasoning model |
| Visualizer | Haiku 4.5 | N/A | Non-reasoning model |

### Dynamic Effort Override

The conductor may recommend users adjust effort when:

1. **Escalate effort** (e.g., Medium → High):
   - Implementer hits repeated test failures requiring deeper analysis
   - Reviewer encounters architecturally complex changes
   - Researcher faces contradictory evidence requiring synthesis

2. **Reduce effort** (e.g., Medium → Low):
   - Execution-tier agent performing routine sub-task (simple file reads, straightforward edits)
   - Budget gatekeeper in Yellow Zone — reduce effort before escalating model tier
   - Task is well-defined with clear acceptance criteria and no ambiguity

> **Effort before escalation:** When an agent struggles at its current tier, first try increasing thinking effort before escalating to a higher-cost model. This is cheaper than switching from Execution → Premium tier.

## Resilience Best Practices

1. **Graceful degradation:**
   - Always have at least 2 fallback options before escalation
   - Document quality implications of each fallback
   - Preserve context across model switches

2. **Cost awareness:**
   - Track costs by model and agent
   - Alert when premium (3×) usage exceeds 15% (target is 10%)
   - Optimize prompt efficiency to reduce token usage
   - Monitor thinking effort distribution — High effort should be reserved for security, beast-mode, and red-team

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
