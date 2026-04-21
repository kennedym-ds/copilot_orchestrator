# Model Tier Strategy & Rationale

Status: Active | Last Updated: 2026-04-21

## Overview

The Copilot Orchestrator uses a three-tier model allocation across 16 specialized agents (11 core + 5 translation). Each agent declares a `model:` fallback array AND a `defaultEffort:` hint. This guide explains both dials and the per-agent rationale.

## Cost Multipliers (GitHub Copilot, April 2026)

| Multiplier | Models | Plan availability |
|------------|--------|-------------------|
| **7.5x** | Claude Opus 4.7 | Pro+, Business, Enterprise |
| **3x** | Claude Opus 4.6 | Enterprise only |
| **1x** | GPT-5.4, Claude Sonnet 4.6 | Pro+ and above |
| **1x** | GPT-5.3-Codex | Pro and above (incl. Student) |
| **0.33x** | Claude Haiku 4.5, GPT-5.4 mini, Gemini 3 Flash | Pro and above |
| **0x** | GPT-5 mini, GPT-4.1, GPT-4o, Raptor mini | All plans, including Free |

Source: [GitHub Copilot premium request documentation](https://docs.github.com/en/copilot/managing-copilot/monitoring-usage-and-entitlements/about-premium-requests)

## Two Dials: Model + Effort

Reasoning spend is a product of two factors:

1. **Model** - the ceiling on capability and per-request multiplier. Set by the fallback array in frontmatter.
2. **Effort** - how much reasoning the agent actually does per call (`low` / `medium` / `high`). Set by `defaultEffort:` in frontmatter. Individual prompts can override with an `effort:` key.

A `low` effort Sonnet call costs a fraction of a `high` effort Sonnet call. Right-sizing effort matters as much as right-sizing the model.

## Three-Tier Model Allocation (main branch)

### Premium Tier - Claude Opus 4.6 (3x)

Reserved for agents where reasoning depth directly determines output quality.

| Agent | defaultEffort | Rationale |
|-------|---------------|-----------|
| **Planner** | high | Produces multi-phase plans with risk analysis, scope decomposition, and dependency ordering. Plan quality determines the entire workflow trajectory. Weak plans waste more in rework than the 3x cost. |

**Premium tier agents:** 1 (~6% of invocations).

The Reviewer previously sat in this tier but has been demoted to the execution chain. Standard-mode review benefits less from premium reasoning than planning does, and security-mode review is now pinned to Opus via a prompt-level override (`.github/prompts/support/security-review.prompt.md`). This means premium cost is paid only when a security review is actually requested, not on every review.

### Execution Tier - Claude Sonnet 4.6 (1x)

The workhorse tier for orchestration, implementation, analysis, and specialized tasks.

| Agent | defaultEffort | Rationale |
|-------|---------------|-----------|
| **Conductor** | medium | Lifecycle orchestration, delegation, pause points. Sonnet handles routing decisions cleanly; escalation to Planner/Reviewer happens at branch points regardless. |
| **Reviewer** | high | Standard-mode review, code quality, multi-mode switching. Security mode pins Opus separately. |
| **Implementer** | medium | TDD execution, code generation, multi-file edits. Strong coding capability with large context. |
| **Researcher** | high | Evidence gathering and synthesis. Benefits from large context to process documentation corpora. |
| **Ops** | low | Issues, PRs, CI/CD, releases, telemetry. Tool-heavy agent where MCP tool access matters more than reasoning depth. |
| **Test** | medium | TDD test authoring and coverage gap analysis. |
| **IaC** | medium | Terraform / Bicep / Pulumi. Infrastructure-as-code planning, drift detection. |
| **GUI Tester** | low | Browser automation, visual regression. Heavy tool usage; model coordinates more than it reasons. |
| **Translation Conductor** | high | Orchestrates 6-phase translation lifecycle across 4 sub-agents. |
| **Translator** | medium | File-level code translation. |
| **Translation Analyzer** | high | Dependency graph analysis, complexity assessment. |
| **Translation Validator** | high | 6-layer validation stack with equivalence checking. |

**Execution tier agents:** 12 (~75% of invocations).

### Fast Tier - Claude Haiku 4.5 (0.33x)

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
| Premium | Claude Opus 4.6 | Claude Opus 4.7 | Claude Sonnet 4.6 |
| Execution | Claude Sonnet 4.6 | GPT-5.4 | GPT-5.3-Codex |
| Fast | Claude Haiku 4.5 | GPT-5.4 mini | GPT-5 mini |

VS Code picks the first model from the array that the current plan can access. Plan-aligned branches (`pro-plus`, `pro`, `free`) additionally rewrite the strings at sync time so the array content always matches the target plan.

## Security-Mode Override

The reviewer-security prompt (`.github/prompts/support/security-review.prompt.md`) declares its own `model: Claude Opus 4.6 (copilot)` line. This overrides the agent-level array only for that prompt, so:

- Routine reviews run on Sonnet (execution tier, ~1x).
- Security reviews run on Opus (premium, 3x).

Threat modeling, STRIDE analysis, and adversarial pattern recognition warrant the premium rate. Missing a vulnerability costs more than any model savings.

## Summary

| Tier | Model(s) | Agent Count | Cost | Use Case |
|------|----------|-------------|------|----------|
| Premium | Claude Opus 4.6 | 1 (~6%) | 3x | Multi-phase planning |
| Execution | Claude Sonnet 4.6 | 12 (~75%) | 1x | Orchestration, review, implementation, research, ops, translation |
| Fast | Claude Haiku 4.5 | 3 (~19%) | 0.33x | Documentation, UX, translation styling |

**Total:** 16 agents (11 core + 5 translation). Net effect: only 1 agent pays the 3x Opus rate on default calls; the reviewer bumps to Opus only when invoked in security mode.

