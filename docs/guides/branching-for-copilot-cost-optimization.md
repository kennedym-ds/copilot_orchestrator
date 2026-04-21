---
title: "Branching for Copilot Cost Optimization"
version: "2.0.0"
lastUpdated: "2026-04-21"
status: stable
---

# Branching for Copilot Cost Optimization

GitHub Copilot plans ship different models at different multipliers. Opus 4.6 (3x) is Enterprise-only; Opus 4.7 (7.5x) is Pro+/Business/Enterprise; Sonnet 4.6 and GPT-5.4 (1x) need Pro+ or above; GPT-5.3-Codex and GPT-5.4 mini reach down to Pro/Student; only GPT-5 mini and GPT-4.1 (0x) are available on Free.

Rather than forcing every user onto a lowest-common-denominator model set, we ship **four branches aligned to the plan matrix**. Develop on `enterprise`, push once, and GitHub Actions rewrites the model strings on the other three branches.

## The Branches

```
enterprise -> Enterprise plan  (Opus 4.6 flagship, Sonnet 4.6 execution, Haiku 4.5 fast)
pro-plus   -> Pro+/Business (Opus 4.7 flagship, Sonnet 4.6 execution, Haiku 4.5 fast)
pro        -> Pro/Student  (GPT-5.3-Codex, GPT-5.4 mini, Haiku 4.5)
free       -> Free         (GPT-5 mini, GPT-4.1)
```

`enterprise` is the source of truth. The other three are force-regenerated from `enterprise` by CI on every push.

## Per-Branch Mapping

### enterprise (Enterprise plan)

Each agent declares a fallback array in frontmatter and a `defaultEffort:` hint. The first array entry is the default model.

| Agent class | Primary | Fallback 1 | Fallback 2 | Effort range |
|-------------|---------|-----------|-----------|--------------|
| Premium (planner) | Claude Opus 4.6 | Claude Opus 4.7 | Claude Sonnet 4.6 | high |
| Execution (12 agents) | Claude Sonnet 4.6 | GPT-5.4 | GPT-5.3-Codex | low - high |
| Fast (docs, ux, translation-styler) | Claude Haiku 4.5 | GPT-5.4 mini | GPT-5 mini | low - medium |

The Reviewer runs on the execution chain by default. Security-mode review pins `Claude Opus 4.6` via a prompt-level `model:` override so only the security invocation uses a 3x model.

### pro-plus (Pro+ / Business)

Opus 4.6 is Enterprise-only, so the pro-plus branch substitutes the flagship:

- `Claude Opus 4.6` -> `Claude Opus 4.7` (3x -> 7.5x, but available on Pro+)

All other models (Sonnet 4.6, GPT-5.4, Haiku 4.5, GPT-5.3-Codex, GPT-5.4 mini) are available on Pro+ and pass through unchanged.

### pro (Pro / Student)

Neither Opus 4.6 nor Opus 4.7 is on Pro. Sonnet 4.6 and GPT-5.4 also require Pro+. The pro branch rewrites:

- `Claude Opus 4.7` -> `GPT-5.3-Codex` (1x)
- `Claude Opus 4.6` -> `GPT-5.3-Codex` (1x)
- `Claude Sonnet 4.6` -> `GPT-5.3-Codex` (1x)
- `GPT-5.4` (bare) -> `GPT-5.4 mini` (0.33x)

GPT-5.3-Codex, GPT-5.4 mini, and Haiku 4.5 all stay on Pro.

### free (Free plan)

Only `GPT-5 mini` and `GPT-4.1` are truly 0x on Free. Everything else is substituted:

- All Opus / Sonnet / GPT-5.4 / GPT-5.3-Codex / Gemini / GPT-5.4 mini -> `GPT-5 mini` (0x)
- `Claude Haiku 4.5` (0.33x, paid-only) -> `GPT-4.1` (0x)

Five speed-first agents (docs, ux, gui-tester, ops, translation-styler) have their frontmatter array collapsed to `[GPT-4.1]`. The other eleven collapse to `[GPT-5 mini]`.

## How the Sync Works

Three GitHub Actions workflows fire on every push to `enterprise`:

1. `sync-pro-plus-branch.yml` - resets `pro-plus` from `enterprise`, runs the Opus substitutions.
2. `sync-pro-branch.yml` - resets `pro` from `enterprise`, runs the Pro-plan substitutions.
3. `sync-free-branch.yml` - resets `free` from `enterprise`, collapses frontmatter arrays and runs the Free-plan substitutions.

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
git checkout free       # Free tier
git checkout enterprise       # Enterprise (source of truth)
```

Same agents, same prompts, same workflows - different models.

## What We Learned

1. **Align branches to plans, not "cost targets".** Earlier versions used opaque names like `low-cost` and `free-cost`. Users had to guess whether their plan supported the target models. `pro-plus` / `pro` / `free` are self-explanatory.
2. **Fallback arrays let one branch serve multiple plans.** An Enterprise user on `enterprise` still works if their request happens to fall back to Sonnet 4.6 - the array is ordered by preference, not by exclusivity.
3. **`defaultEffort` is a second dial.** Model choice sets the ceiling; effort sets the spend per call. A `low` effort Sonnet call costs far less than a `high` effort one, so right-sizing effort per agent matters as much as right-sizing the model.
4. **Security-critical prompts override at the prompt level.** The security-mode review pins Opus regardless of which branch it runs on (subject to plan availability). Agent-level demotions do not compromise the paths where reasoning quality is genuinely load-bearing.

## Getting Started

1. Identify your Copilot plan (Free / Pro / Pro+ / Business / Enterprise / Student).
2. Checkout the matching branch - Students use `pro`, Enterprise users stay on `enterprise`.
3. The sync workflows handle everything else. Develop on `enterprise` if you have write access; otherwise pin to the branch that matches your plan.
4. See [Model Tier Strategy & Rationale](model-tiers.md) for the per-agent reasoning.
5. See the [README](../../README.md#model-tiers) for the summary table.

