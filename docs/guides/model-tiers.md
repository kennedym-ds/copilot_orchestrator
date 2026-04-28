# Model Tier Strategy & Rationale

Status: Active | Last Updated: 2026-04-29

## Overview

The Copilot Orchestrator uses a three-tier model allocation across 16 specialized agents (11 core + 5 translation). Each agent declares a `model:` fallback array AND a `defaultEffort:` hint. This guide explains both dials and the per-agent rationale.

## Usage-Based Billing (June 1, 2026)

Copilot usage is billed in GitHub AI Credits based on token consumption (input, output, cached). 1 AI credit = $0.01 USD. Code completions and next edit suggestions are not billed.

Model prices are per 1M tokens. See [Models and pricing for GitHub Copilot](https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing) for current rates.

Annual Pro and Pro+ subscribers on existing annual plans remain on model multipliers until their annual plan ends. Multipliers change on June 1, 2026 (see [annual plan multipliers](https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing#model-multipliers-for-annual-copilot-pro-and-copilot-pro-subscribers)).

**Annual plan multiplier mode (cost override):**
- Treat Opus as **27x** and Sonnet as **6x** for budget weighting when you are still on annual-plan multipliers.
- Revert to per-token pricing once the subscription moves to usage-based billing.

## Cost-Aware Usage (Default)

Starting June 1, AI credits are the primary pricing model and per-token API rates apply. The tier labels remain useful for *relative* cost guidance, but budget decisions should be driven by actual token spend.

**Cost-aware defaults:**
1. Use the lowest tier that meets quality for the task.
2. Reserve premium models for security reviews only.
3. Prefer lower thinking effort before switching tiers.
4. Keep contexts tight; avoid loading large files unless necessary.

## Two Dials: Model + Effort

Reasoning spend is a product of two factors:

1. **Model** - the ceiling on capability and per-token pricing. Set by the fallback array in frontmatter.
2. **Effort** - how much reasoning the agent actually does per call (`low` / `medium` / `high`). Set by `defaultEffort:` in frontmatter. Individual prompts can override with an `effort:` key.

A `low` effort Sonnet call costs a fraction of a `high` effort Sonnet call. Right-sizing effort matters as much as right-sizing the model.

## Three-Tier Model Allocation (enterprise branch)

### Security-Only Premium Tier - Claude Opus 4.7/4.6 (premium pricing)

Premium pricing is reserved for security reviews only. No agents default to Opus; the reviewer-security prompt pins Opus at the prompt level (`.github/prompts/support/security-review.prompt.md`).

| Invocation | defaultEffort | Rationale |
|------------|---------------|-----------|
| **Reviewer (security mode)** | high | Threat modeling, STRIDE analysis, and vulnerability detection warrant the premium rate. |

### Execution Tier - Claude Sonnet 4.6 (mid-tier pricing)

The workhorse tier for orchestration, implementation, analysis, and specialized tasks.

| Agent | defaultEffort | Rationale |
|-------|---------------|-----------|
| **Conductor** | medium | Lifecycle orchestration, delegation, pause points. Sonnet handles routing decisions cleanly; escalation to Planner/Reviewer happens at branch points regardless. |
| **Reviewer** | high | Standard-mode review, code quality, multi-mode switching. Security mode pins Opus separately. |
| **Implementer** | medium | TDD execution, code generation, multi-file edits. Strong coding capability with large context. |
| **Planner** | high | Multi-phase planning with risk analysis, scope decomposition, and dependency ordering. |
| **Researcher** | high | Evidence gathering and synthesis. Benefits from large context to process documentation corpora. |
| **Ops** | low | Issues, PRs, CI/CD, releases, telemetry. Tool-heavy agent where MCP tool access matters more than reasoning depth. |
| **Test** | medium | TDD test authoring and coverage gap analysis. |
| **IaC** | medium | Terraform / Bicep / Pulumi. Infrastructure-as-code planning, drift detection. |
| **GUI Tester** | low | Browser automation, visual regression. Heavy tool usage; model coordinates more than it reasons. |
| **Translation Conductor** | high | Orchestrates 6-phase translation lifecycle across 4 sub-agents. |
| **Translator** | medium | File-level code translation. |
| **Translation Analyzer** | high | Dependency graph analysis, complexity assessment. |
| **Translation Validator** | high | 6-layer validation stack with equivalence checking. |

**Execution tier agents:** 13 (~81% of invocations).

### Fast Tier - Claude Haiku 4.5 (lower-cost pricing)

For tasks where pattern-matching suffices and deep reasoning is unnecessary.

| Agent | defaultEffort | Rationale |
|-------|---------------|-----------|
| **Docs** | medium | Documentation generation with template-driven patterns. |
| **UX** | low | Visualizer + accessibility. Mermaid diagram generation, UX feedback, WCAG compliance review. |
| **Translation Styler** | medium | Target-language idiom application. Small, structured transformation. |

**Fast tier agents:** 3 (~19% of invocations).

## Fallback Chains

When a primary model is unavailable (plan tier, capacity, deprecation), agents fall back to the next entry in the array:

| Tier | Primary | Fallback 1 | Fallback 2 |
|------|---------|------------|------------|
| Security (prompt override) | Claude Opus 4.6 | Claude Opus 4.7 | Claude Sonnet 4.6 |
| Execution | Claude Sonnet 4.6 | GPT-5.4 | GPT-5.3-Codex |
| Fast | Claude Haiku 4.5 | GPT-5.4 mini | — |

VS Code picks the first model from the array that the current plan can access. Plan-aligned branches (`pro-plus`, `pro`) additionally rewrite the strings at sync time so the array content always matches the target plan.

## Security-Mode Override

The reviewer-security prompt (`.github/prompts/support/security-review.prompt.md`) declares its own `model: Claude Opus 4.6 (copilot)` line. This overrides the agent-level array only for that prompt, so:

- Routine reviews run on Sonnet (execution tier).
- Security reviews run on Opus (premium tier).

Threat modeling, STRIDE analysis, and adversarial pattern recognition warrant the premium rate. Missing a vulnerability costs more than any model savings.

## Summary

| Tier | Model(s) | Agent Count | Cost profile | Use Case |
|------|----------|-------------|--------------|----------|
| Security (prompt override) | Claude Opus 4.6/4.7 | 0 default | Highest per-token rate | Security review only |
| Execution | Claude Sonnet 4.6 | 13 (~81%) | Mid-tier rate | Orchestration, planning, review, implementation, research, ops, translation |
| Fast | Claude Haiku 4.5 | 3 (~19%) | Lower-cost rate | Documentation, UX, translation styling |

**Total:** 16 agents (11 core + 5 translation). Net effect: no agents use premium pricing by default; Opus is consumed only for explicit security reviews.

