---
title: "Three Branches, One Codebase: Optimizing GitHub Copilot Costs"
version: "1.0.0"
lastUpdated: "2026-03-11"
status: stable
---

# Three Branches, One Codebase: Optimizing GitHub Copilot Costs with Model Tier Branches

GitHub Copilot's premium request system charges differently per model — from 3× for Claude Opus 4.6 down to 0× for GPT-5 mini. If you're running a multi-agent system with 29 specialized agents, those multipliers add up fast.

Here's how we solved it: **three branches, automatically synced, each targeting a different cost profile.**

## The Problem

Not every task needs the most expensive model. A lint check doesn't need Claude Opus 4.6. A rubber duck debugging session doesn't need GPT-5.4. But maintaining separate agent configurations per cost tier by hand is a maintenance nightmare — every change to an agent's prompt, workflow, or tooling would need to be applied three times.

## The Setup

We maintain one source of truth (`main`) and two derived branches that sync automatically on every push:

```
main          → Premium tier (full capability)
low-cost      → Budget tier (~64% savings)
free-cost     → Zero tier (0× models only)
```

### Main Branch — Optimized Per Role

Each agent gets the cheapest model that handles its workload without quality loss:

| Tier | Model | Cost | Agents | Why |
|------|-------|------|--------|-----|
| Premium | Claude Opus 4.6 | 3× | 3 (conductor, planner, security) | Orchestration errors compound. Security is ruin-risk. Plan quality drives everything downstream. |
| Execution | GPT-5.4 | 1× | 22 (implementer, reviewer, test, etc.) | Strong coding benchmarks, 1M context window. The workhorse. |
| Execution | Claude Sonnet 4.6 | 1× | 1 (translation-conductor) | Leverages Anthropic-specific tool-use patterns. |
| Routine | Claude Haiku 4.5 | 0.33× | 3 (lint, rubber-duck, visualizer) | Pattern-matching and template-driven output. Smallest capable model. |

### Low-Cost Branch — ~64% Savings

Collapses the tier structure:

- Opus → Sonnet 4.5 (3× → 1×)
- GPT-5.4 / Sonnet 4.6 → Haiku 4.5 (1× → 0.33×)
- Haiku stays Haiku

**Result:** 3 agents on Sonnet 4.5, 26 on Haiku 4.5. Good enough for learning, experimentation, and lighter workloads.

### Free-Cost Branch — Zero Premium Requests

Uses only 0× multiplier models:

- **GPT-5 mini** (24 agents) — strongest free model, 71% on SWE-bench
- **GPT-4.1** (5 agents) — speed-first tasks (docs, lint, rubber-duck, visualizer, gui-tester)

Zero premium requests consumed. Ideal for teams hitting quota limits or evaluating the system before committing budget.

## How the Sync Works

Two GitHub Actions workflows fire on every push to `main`:

1. **`sync-low-cost-branch.yml`** — resets `low-cost` from `main`, applies sed substitutions for model strings
2. **`sync-free-cost-branch.yml`** — resets `free-cost` from `main`, applies targeted agent-level substitutions + blanket doc replacements

The key design choice: **reset-then-substitute**, not merge. The derived branches are always a clean transformation of `main`. No merge conflicts, no drift, no manual maintenance.

```yaml
# Simplified — the actual workflow handles edge cases
- name: Reset low-cost to main
  run: git checkout -B low-cost origin/main

- name: Apply model downgrades
  run: |
    # GPT-5.4 → Claude Haiku 4.5
    sed -i 's/GPT-5\.4/Claude Haiku 4.5/g' "$file"
    # Claude Opus 4.6 → Claude Sonnet 4.5
    sed -i 's/Claude Opus 4\.6/Claude Sonnet 4.5/g' "$file"
```

The substitution order matters — Sonnet before Opus on the low-cost branch prevents double-substitution (Opus → Sonnet → Haiku). Both workflows were verified via simulation to produce correct output.

## Switching Tiers

```bash
git checkout free-cost   # Zero-cost — evaluating or quota-limited
git checkout low-cost    # Budget — light workloads
git checkout main        # Premium — production work
```

That's it. Same agents, same prompts, same workflows. Different models.

## What We Learned

1. **Three models cover the full spectrum.** Premium (3×), execution (1×), and routine (0.33×) tiers map cleanly to agent roles. You don't need per-agent optimization — you need per-role optimization.

2. **Reset-then-substitute beats merge.** Any merge-based approach would accumulate conflicts from model string changes on every sync. Force-resetting the derived branch and reapplying substitutions is simpler and conflict-free.

3. **The free tier is surprisingly capable.** GPT-5 mini scores 71% on SWE-bench at 0× cost. For many workflows — especially with well-structured prompts — it's good enough.

4. **Cost optimization is a branching problem, not a configuration problem.** We tried environment variables, config files, and conditional model loading. Branches turned out to be the simplest solution because VS Code loads agent files directly from the filesystem — no runtime configuration layer needed.

## Getting Started

If you're running the Copilot Orchestrator:

1. Clone the repo and check out the branch matching your budget
2. The sync workflows handle everything — just develop on `main`
3. See [Model Tier Strategy & Rationale](model-tiers.md) for the full rationale behind each model assignment
4. See the [README](../../README.md#model-tiers) for the complete agent-to-model mapping across all three branches
