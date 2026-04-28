# Model Tier Strategy & Rationale

Status: Active | Last Updated: 2026-04-29

## Overview

The Copilot Orchestrator uses a three-tier model allocation across 16 specialized agents (11 core + 5 translation). Each agent declares a `model:` fallback array AND a `defaultEffort:` hint. This guide explains both dials and the per-agent rationale.

## Usage-Based Billing (June 1, 2026)

Copilot usage is billed in GitHub AI Credits based on token consumption (input, output, cached). 1 AI credit = $0.01 USD. Code completions and next edit suggestions are not billed.

Model prices are per 1M tokens. See [Models and pricing for GitHub Copilot](https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing) for current rates.

Annual Pro and Pro+ subscribers on existing annual plans remain on model multipliers until their annual plan ends. Multipliers **increase** on June 1, 2026 (see [annual plan multipliers](https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing#model-multipliers-for-annual-copilot-pro-and-copilot-pro-subscribers)).

**Annual plan multiplier mode (cost override):**
- Treat Opus as **27x** and Sonnet as **6x** for budget weighting when you are still on annual-plan multipliers. These are the values **effective June 1, 2026** — pre-June-1 multipliers are lower.
- Revert to per-token pricing once the subscription moves to usage-based billing.

**Promotional included credits (June–August 2026):**
- Copilot Business subscribers receive **$30/month** (vs. standard $19) for the three-month transition period.
- Copilot Enterprise subscribers receive **$70/month** (vs. standard $39) for the three-month transition period.
- Adjust budget-gatekeeper soft/hard limits accordingly if you are on Business or Enterprise during this period.

**Copilot code review and GitHub Actions minutes:**
- GitHub's automated PR code review (the "Request Copilot review" feature) now consumes **both** AI Credits and GitHub Actions minutes. Agent-driven review via the Reviewer agent in chat sessions consumes only AI Credits.

**GitHub-native budget controls:**
- Business and Enterprise plans now include platform-level budget controls at the enterprise, cost center, and user levels — configurable in GitHub org settings. These are the authoritative billing-authority layer. The budget-gatekeeper skill is a complementary session-level safeguard, not a replacement.
- Admins can choose to allow additional usage at published rates (overage billing) or cap spending when included credits are exhausted. Configure this in org Copilot settings before June 1.

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

### Security-Only Premium Tier - GPT-5.3-Codex/4.6 (premium pricing)

Premium pricing is reserved for security reviews only. No agents default to Opus; the reviewer-security prompt pins Opus at the prompt level (`.github/prompts/support/security-review.prompt.md`).

| Invocation | defaultEffort | Rationale |
|------------|---------------|-----------|
| **Reviewer (security mode)** | high | Threat modeling, STRIDE analysis, and vulnerability detection warrant the premium rate. |

### Execution Tier - GPT-5.3-Codex (mid-tier pricing)

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
| **Translation Conductor** | medium | Orchestrates 6-phase translation lifecycle across 4 sub-agents. Routing and coordination — same reasoning profile as the main Conductor. |
| **Translator** | medium | File-level code translation. |
| **Translation Analyzer** | medium | Dependency graph analysis, complexity assessment. Structured analysis; Sonnet at medium catches the same issues as high. |
| **Translation Validator** | medium | 6-layer validation stack with equivalence checking. Primarily tool execution and result interpretation. |

**Execution tier agents:** 12 (~75% of invocations).

### Fast Tier - Claude Haiku 4.5 (lower-cost pricing)

For tasks where pattern-matching suffices and deep reasoning is unnecessary.

| Agent | defaultEffort | Rationale |
|-------|---------------|-----------|
| **GUI Tester** | low | Browser automation, visual regression. Heavy tool usage; model coordinates tool calls rather than reasoning. Moved from Execution tier — Haiku handles tool coordination cleanly at a ~3× lower cost. |
| **Docs** | low | Documentation generation with template-driven patterns. No open-ended reasoning needed. |
| **UX** | low | Visualizer + accessibility. Mermaid diagram generation, UX feedback, WCAG compliance review. |
| **Translation Styler** | low | Target-language idiom application. Small, structured pattern-matching transformation. |

**Fast tier agents:** 4 (~25% of invocations).

## Fallback Chains

When a primary model is unavailable (plan tier, capacity, deprecation), agents fall back to the next entry in the array:

| Tier | Primary | Fallback 1 | Fallback 2 |
|------|---------|------------|------------|
| Security (prompt override) | GPT-5.3-Codex | GPT-5.3-Codex | GPT-5.3-Codex |
| Execution | GPT-5.3-Codex | GPT-5.4 mini | GPT-5.3-Codex |
| Fast | Claude Haiku 4.5 | GPT-5.4 mini | — |

VS Code picks the first model from the array that the current plan can access. Plan-aligned branches (`pro-plus`, `pro`) additionally rewrite the strings at sync time so the array content always matches the target plan.

## Security-Mode Override

The reviewer-security prompt (`.github/prompts/support/security-review.prompt.md`) declares its own `model: GPT-5.3-Codex (copilot)` line. This overrides the agent-level array only for that prompt, so:

- Routine reviews run on Sonnet (execution tier).
- Security reviews run on Opus (premium tier).

Threat modeling, STRIDE analysis, and adversarial pattern recognition warrant the premium rate. Missing a vulnerability costs more than any model savings.

## Summary

| Tier | Model(s) | Agent Count | Cost profile | Use Case |
|------|----------|-------------|--------------|----------|
| Security (prompt override) | GPT-5.3-Codex/4.6 | 0 default | Highest per-token rate | Security review only |
| Execution | GPT-5.3-Codex | 12 (~75%) | Mid-tier rate | Orchestration, planning, review, implementation, research, ops, translation |
| Fast | Claude Haiku 4.5 | 4 (~25%) | Lower-cost rate | Browser automation, documentation, UX, translation styling |

**Total:** 16 agents (11 core + 5 translation). Net effect: no agents use premium pricing by default; Opus is consumed only for explicit security reviews.

