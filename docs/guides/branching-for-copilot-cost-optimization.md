---
title: "Branching for Copilot Cost Optimization"
version: "2.3.0"
lastUpdated: "2026-04-29"
status: stable
---

# Branching for Copilot Cost Optimization

GitHub Copilot plans ship different model sets. Starting June 1, 2026, Copilot usage is billed in GitHub AI Credits based on per-token pricing, so model choice and thinking effort drive cost. Annual Pro and Pro+ subscribers remain on model multipliers until their annual plan ends (see [Models and pricing for GitHub Copilot](https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing)). Opus 4.6 is Enterprise-only; Opus 4.7 is Pro+/Business/Enterprise; Sonnet 4.6 and GPT-5.4 require Pro+ or above; GPT-5.3-Codex and GPT-5.4 mini reach down to Pro/Student.

Rather than forcing every user onto a lowest-common-denominator model set, we ship **three branches aligned to the plan matrix**. Develop on `enterprise`, push once, and GitHub Actions rewrites the model strings on the other two branches.

## The Branches

```
enterprise -> Enterprise plan  (Sonnet 4.6 execution, Haiku 4.5 fast, Opus 4.6 security-only)
pro-plus   -> Pro+/Business (Sonnet 4.6 execution, Haiku 4.5 fast, Opus 4.7 security-only)
pro        -> Pro/Student  (GPT-5.3-Codex, GPT-5.4 mini, Haiku 4.5)
```

`enterprise` is the source of truth. The other two are force-regenerated from `enterprise` by CI on every push.

## Usage-based billing notes

- GitHub AI Credits are consumed for chat/agent usage based on per-token pricing; code completions remain included.
- When AI credits or budgets are exhausted, usage is blocked or billed. There is no automatic fallback to lower-cost models.
- If you are still on annual-plan multipliers, apply your multiplier weights (e.g., Opus 27x, Sonnet 6x) when sizing budgets. These are the values **effective June 1, 2026** — pre-June-1 multipliers are lower. Multipliers increase on June 1 for annual subscribers before they transition at plan expiry.
- From June 1, AI credits are the default pricing model, so treat tiers as relative cost guidance rather than fixed multipliers.
- **Promotional included credits (June–August 2026):** Business subscribers get $30/month (standard: $19); Enterprise get $70/month (standard: $39). Adjust budget-gatekeeper limits during this window.
- **Copilot code review (GitHub's automated PR review) now consumes GitHub Actions minutes** in addition to AI Credits. Agent chat-driven review via the Reviewer agent uses only AI Credits.
- Admins can configure whether usage is blocked or charged at overage rates when credits are exhausted — set this in org Copilot settings before June 1.

## Per-Branch Mapping

### enterprise (Enterprise plan)

Each agent declares a fallback array in frontmatter and a `defaultEffort:` hint. The first array entry is the default model.

| Agent class | Primary | Fallback 1 | Fallback 2 | Effort range |
|-------------|---------|-----------|-----------|--------------|
| Execution (12 agents) | Claude Sonnet 4.6 | GPT-5.4 | GPT-5.3-Codex | low - high |
| Fast (gui-tester, docs, ux, translation-styler) | Claude Haiku 4.5 | GPT-5.4 mini | — | low |
| Security override (reviewer --security) | Claude Opus 4.7 | Claude Opus 4.6 | Claude Sonnet 4.6 | high |

The Reviewer runs on the execution chain by default. Security-mode review pins `Claude Opus 4.6` via a prompt-level `model:` override so only the security invocation uses a premium model.

### pro-plus (Pro+ / Business)

Opus 4.6 is Enterprise-only. The pro-plus sync replaces every `Claude Opus 4.6` occurrence with `Claude Opus 4.7`. In the security override array `[Opus 4.7, Opus 4.6, Sonnet 4.6]` this produces `[Opus 4.7, Opus 4.7, Sonnet 4.6]` — a harmless duplicate that VS Code's model picker resolves to the first entry. The effective security model on pro-plus is Opus 4.7, which is correct.

All other models (Sonnet 4.6, GPT-5.4, Haiku 4.5, GPT-5.3-Codex, GPT-5.4 mini) are available on Pro+ and pass through unchanged.

### pro (Pro / Student)

Neither Opus 4.6 nor Opus 4.7 is on Pro. Sonnet 4.6 and GPT-5.4 also require Pro+. The pro branch rewrites:

- `Claude Opus 4.7` -> `GPT-5.3-Codex`
- `Claude Opus 4.6` -> `GPT-5.3-Codex`
- `Claude Sonnet 4.6` -> `GPT-5.3-Codex`
- `GPT-5.4` (bare) -> `GPT-5.4 mini` (lower-cost, Pro-available)

GPT-5.3-Codex, GPT-5.4 mini, and Haiku 4.5 all stay on Pro.

## How the Sync Works

Two GitHub Actions workflows fire on every push to `enterprise`:

1. `sync-pro-plus-branch.yml` - resets `pro-plus` from `enterprise`, runs the Opus substitutions.
2. `sync-pro-branch.yml` - resets `pro` from `enterprise`, runs the Pro-plan substitutions.

The key design choice is **reset-then-substitute, not merge**. The derived branches are always a clean transformation of `enterprise`. No merge conflicts, no drift, no manual maintenance.

```yaml
# Simplified - see .github/workflows/sync-pro-branch.yml for the real script
- name: Reset pro to enterprise
  run: git checkout -B pro origin/enterprise

- name: Apply Pro plan substitutions
  run: |
    sed -i 's/Claude Opus 4\.6/GPT-5.3-Codex/g' "$file"
    sed -i 's/Claude Sonnet 4\.6/GPT-5.3-Codex/g' "$file"
    sed -i 's/GPT-5\.4/GPT-5.4 mini/g' "$file"   # with placeholder dance
```

Substitution order matters. The pro workflow protects `GPT-5.4 mini` with a placeholder before rewriting bare `GPT-5.4` to avoid `GPT-5.4 mini mini`.

## Switching Tiers

```bash
git checkout pro-plus   # Pro+ or Business subscriber
git checkout pro        # Pro or Student subscriber
git checkout enterprise       # Enterprise (source of truth)
```

Same agents, same prompts, same workflows - different models.

> **Annual plan expiry:** When an annual Pro or Pro+ plan expires, GitHub converts the account to either Copilot Free or a monthly paid plan. The `free` branch was removed in v3.1.6 — `pro` is the lowest supported tier. Copilot Free provides access to Haiku 4.5 and GPT-5.3-Codex (same models as `pro`) but with tighter rate limits; verify your model access against the [GitHub model matrix](https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing) before relying on the `pro` branch on a Free plan.

## What We Learned

1. **Align branches to plans, not "cost targets".** Earlier versions used opaque names like `low-cost` and `free-cost`. Users had to guess whether their plan supported the target models. `pro-plus` / `pro` are self-explanatory.
2. **Fallback arrays let one branch serve multiple plans.** An Enterprise user on `enterprise` still works if their request happens to fall back to Sonnet 4.6 - the array is ordered by preference, not by exclusivity.
3. **`defaultEffort` is a second dial.** Model choice sets the per-token rate; effort sets the spend per call. A `low` effort Sonnet call costs far less than a `high` effort one, so right-sizing effort per agent matters as much as right-sizing the model.
4. **Security-critical prompts override at the prompt level.** The security-mode review pins Opus regardless of which branch it runs on (subject to plan availability). Agent-level demotions do not compromise the paths where reasoning quality is genuinely load-bearing.

## Getting Started

1. Identify your Copilot plan (Pro / Pro+ / Business / Enterprise / Student).
2. Checkout the matching branch - Students use `pro`, Enterprise users stay on `enterprise`.
3. The sync workflows handle everything else. Develop on `enterprise` if you have write access; otherwise pin to the branch that matches your plan.
4. See [Model Tier Strategy & Rationale](model-tiers.md) for the per-agent reasoning.
5. See the [README](../../README.md#model-tiers) for the summary table.

