# Model Tier Strategy & Rationale

Status: Active | Last Updated: 2026-02-17

## Overview

The Copilot Orchestrator uses a three-tier model allocation across 29 specialized agents, with three deployment branches targeting different cost profiles. This guide explains the rationale behind each model assignment and the design of the tier system.

## Cost Multipliers

GitHub Copilot charges premium requests based on model multiplier:

| Multiplier | Models |
|------------|--------|
| **3×** | Claude Opus 4.6 |
| **1×** | GPT-5.4, Claude Sonnet 4.6 |
| **0.33×** | Claude Haiku 4.5, Gemini 3 Flash, GPT-5.1-Codex-Mini |
| **0×** | GPT-5 mini, GPT-4.1, GPT-4o, Raptor mini |

Source: [GitHub Copilot premium request documentation](https://docs.github.com/en/copilot/managing-copilot/monitoring-usage-and-entitlements/about-premium-requests)

## Main Branch (Premium Tier)

The main branch optimizes for capability per dollar. Each agent gets the cheapest model that handles its workload without quality degradation.

### Premium — Claude Opus 4.6 (3×)

Reserved for agents where reasoning depth directly determines output quality.

| Agent | Rationale |
|-------|-----------|
| **Conductor** | Orchestrates multi-phase workflows with 29 agents. Needs to assess complexity tiers, route to specialists, manage state, enforce pause points, and synthesize escalation reports. Routing errors compound across phases. |
| **Planner** | Produces multi-phase plans with risk analysis, scope decomposition, and dependency ordering. Plan quality determines the entire workflow trajectory. Weak plans waste more in rework than the 3× cost. |
| **Security** | Threat modeling, STRIDE analysis, compliance review. Security is a ruin-risk domain — a missed vulnerability costs more than any model savings. Requires deep pattern recognition across attack surfaces. |

### Execution — GPT-5.4 (1×)

The workhorse tier. GPT-5.4 was selected over GPT-5.3-Codex because it scores higher on every benchmark at the same 1× cost, with a 1M token context window:

| Benchmark | GPT-5.4 | GPT-5.3-Codex |
|-----------|---------|---------------|
| SWE-Bench Pro | 57.7% | 55.6% |
| GDPval | 83.0% | 80.0% |
| GPQA Diamond | 92.8% | 74.1% |
| OSWorld | 75.0% | 52.4% |
| Context window | 1M tokens | 200K tokens |

22 agents use GPT-5.4:

| Agent | Rationale |
|-------|-----------|
| **Implementer** | TDD execution, code generation, multi-file edits. Needs strong coding benchmarks (SWE-Bench Pro 57.7%) and large context for multi-file changes. |
| **Reviewer** | Diff review with severity-tagged findings. Needs to hold full change context and apply quality criteria. 1M context window handles large PRs. |
| **Researcher** | Evidence gathering and synthesis. Benefits from 1M context to process large documentation corpora. |
| **Maintainer** | Issue triage, changelog generation, release coordination. Needs competent code understanding but not deep reasoning. |
| **Spec** | Requirements elicitation, scope definition, acceptance criteria. Structured output generation with moderate reasoning needs. |
| **Test** | TDD test writing, coverage gap analysis. Strong coding model needed for correct test assertions. |
| **Beast Mode** | Extended reasoning with visible thinking. GPT-5.4 provides sufficient depth at 1× vs Opus at 3×. |
| **Red Team** | Adversarial testing and edge case discovery. Benefits from large context to analyze full attack surface. |
| **Performance** | Runtime complexity analysis, memory profiling, cost modeling. Analytical work within 1× tier capability. |
| **Accessibility** | WCAG compliance review, ARIA implementation. Pattern-matching against known standards. |
| **Docs** | Documentation generation needs 1M context window to process entire documentation trees. Previously Haiku; upgraded to GPT-5.4 specifically for the 5× larger context window. |
| **Observability** | Telemetry analysis, metrics review. Data-oriented work within 1× tier capability. |
| **Deployment** | CI/CD review, pipeline validation. Configuration analysis doesn't require premium reasoning. |
| **GitHub Ops** | Issue/PR management, workflow automation. Tool-heavy agent where model capability matters less than MCP tool access. |
| **Terraform** | IaC planning, drift detection. Domain-specific but structured work. |
| **Bicep** | Azure IaC implementation. Similar profile to Terraform. |
| **Design** | Design system queries, contrast validation. MCP-driven agent; model primarily formats tool results. |
| **GUI Tester** | Browser automation, visual regression. Heavy tool usage (Playwright); model coordinates tools more than reasons. |
| **Translator** | File-level code translation. Needs strong multilingual code understanding. |
| **Translation Analyzer** | Dependency graph analysis, complexity assessment. Structural analysis work. |
| **Translation Validator** | 6-layer validation stack. Needs solid code understanding for equivalence checking. |
| **Translation Styler** | Target-language idiom application. Needs code generation capability for idiomatic output. |

### Execution — Claude Sonnet 4.6 (1×)

| Agent | Rationale |
|-------|-----------|
| **Translation Conductor** | Orchestrates the 6-phase translation lifecycle across 4 sub-agents. Uses Claude Sonnet 4.6 (not GPT-5.4) because it leverages Anthropic-specific tool-use patterns and `agents:` allowlist features that work best within the Claude model family. |

### Routine — Claude Haiku 4.5 (0.33×)

For tasks where pattern-matching suffices and deep reasoning is unnecessary.

| Agent | Rationale |
|-------|-----------|
| **Lint** | Code formatting and style enforcement. Rule-based pattern matching — the smallest capable model handles this well. |
| **Rubber Duck** | Socratic questioning to help users think through problems. Asks questions, doesn't generate complex analysis. |
| **Visualizer** | Mermaid diagram generation and UX feedback. Template-driven output that doesn't benefit from larger models. |

## Low-Cost Branch (Budget Tier)

The `low-cost` branch provides ~64% savings by collapsing the tier structure:

| Main Model | Low-Cost Replacement | Savings |
|------------|---------------------|---------|
| Claude Opus 4.6 (3×) | Claude Sonnet 4.6 (1×) | 67% per request |
| GPT-5.4 (1×) | Claude Haiku 4.5 (0.33×) | 67% per request |
| Claude Sonnet 4.6 (1×) | Claude Haiku 4.5 (0.33×) | 67% per request |
| Claude Haiku 4.5 (0.33×) | Claude Haiku 4.5 (0.33×) | 0% (already cheapest) |

**Design rationale:** The three Opus agents (conductor, planner, security) handle orchestration and risk — they degrade the most from weaker models. Sonnet 4.6 matches Sonnet 4.5 at 1× cost with stronger capabilities. Everything else drops to Haiku 4.5 (0.33×), accepting reduced capability for maximum savings.

**Result:** 3 agents on Claude Sonnet 4.6, 26 on Claude Haiku 4.5.

## Free-Cost Branch (Zero Tier)

The `free-cost` branch uses only 0× multiplier models — zero premium requests consumed.

| Model | Count | Agents | Rationale |
|-------|-------|--------|-----------|
| **GPT-5 mini** | 24 | conductor, planner, implementer, reviewer, researcher, security, performance, red-team, spec, maintainer, accessibility, observability, deployment, github-ops, terraform, bicep, design, beast-mode, test, translator, translation-conductor, translation-analyzer, translation-validator, translation-styler | Strongest 0× model — SWE-bench 71%, COLLIE 98.5% instruction following. Handles complex reasoning acceptably for zero cost. |
| **GPT-4.1** | 5 | docs, lint, rubber-duck, visualizer, gui-tester | Speed-first agents where deep reasoning is unnecessary. GPT-4.1 is fast with a 1M context window, well-suited for docs (large contexts) and lightweight pattern-matching tasks (lint, rubber-duck, visualizer, gui-tester). |

**Design rationale:** Split the 0× tier by task profile rather than giving everyone the same model. Agents that need reasoning get GPT-5 mini (71% SWE-bench). Agents that need speed or large context without deep reasoning get GPT-4.1 (1M window, faster inference).

See [artifacts/research/0x-model-benchmark-report.md](../../artifacts/research/0x-model-benchmark-report.md) for the full benchmark analysis.

## Branch Sync Mechanism

Both tier branches are maintained automatically via GitHub Actions:

1. **Develop on `main`** — all agents use premium models.
2. **Push to `main`** — two workflows trigger:
   - [`sync-low-cost-branch.yml`](../../.github/workflows/sync-low-cost-branch.yml) — resets `low-cost` from `main`, applies sed substitutions.
   - [`sync-free-cost-branch.yml`](../../.github/workflows/sync-free-cost-branch.yml) — resets `free-cost` from `main`, applies targeted + blanket substitutions.
3. **Switch tiers** — `git checkout <branch>` to use a different cost profile.

The sync workflows were verified via simulation: both produce correct output with no double-substitution issues.

## Fallback Chains

When a primary model is unavailable, agents fall back to the next available model:

| Tier | Primary | Fallback 1 | Fallback 2 |
|------|---------|------------|------------|
| Premium | Claude Opus 4.6 | GPT-5.4 | Claude Sonnet 4.6 |
| Execution (GPT) | GPT-5.4 | Claude Sonnet 4.6 | Claude Haiku 4.5 |
| Execution (Claude) | Claude Sonnet 4.6 | GPT-5.4 | Claude Haiku 4.5 |
| Routine | Claude Haiku 4.5 | GPT-5.1-Codex-Mini | Gemini 3 Flash |

See [instructions/global/03_model-selection.instructions.md](../../instructions/global/03_model-selection.instructions.md) for the full fallback matrix and decision criteria.

## Summary

| Tier | Model(s) | Agent Count | Cost | Use Case |
|------|----------|-------------|------|----------|
| Premium | Claude Opus 4.6 | 3 (~10%) | 3× | Orchestration, planning, security |
| Execution | GPT-5.4, Claude Sonnet 4.6 | 23 (~80%) | 1× | Implementation, review, analysis, translation |
| Routine | Claude Haiku 4.5 | 3 (~10%) | 0.33× | Formatting, questions, diagrams |
| Low-cost | Sonnet 4.6 + Haiku 4.5 | 29 | ~0.44× avg | Budget deployment (~64% savings) |
| Free-cost | GPT-5 mini + GPT-4.1 | 29 | 0× | Zero premium requests |
