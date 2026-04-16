# Model Tier Strategy & Rationale

Status: Active | Last Updated: 2026-04-16

## Overview

The Copilot Orchestrator uses a three-tier model allocation across 16 specialized agents (11 core + 5 translation). This guide explains the rationale behind each model assignment and the design of the tier system.

## Cost Multipliers

GitHub Copilot charges premium requests based on model multiplier:

| Multiplier | Models |
|------------|--------|
| **3×** | Claude Sonnet 4.6 |
| **1×** | Claude Haiku 4.5, Claude Haiku 4.5 |
| **0.33×** | Claude Haiku 4.5, Gemini 3 Flash |
| **0×** | GPT-5 mini, GPT-4.1, GPT-4o, Raptor mini |

Source: [GitHub Copilot premium request documentation](https://docs.github.com/en/copilot/managing-copilot/monitoring-usage-and-entitlements/about-premium-requests)

## Three-Tier Model Allocation

The orchestrator optimizes for capability per dollar. Each agent gets the cheapest model that handles its workload without quality degradation.

### Premium Tier — Claude Sonnet 4.6 (3×)

Reserved for agents where reasoning depth directly determines output quality.

| Agent | Rationale |
|-------|-----------|  
| **Conductor** | Orchestrates multi-phase workflows with 16 agents. Needs to assess complexity tiers, route to specialists, manage state, enforce pause points, and synthesize escalation reports. Routing errors compound across phases. |
| **Planner** | Produces multi-phase plans with risk analysis, scope decomposition, and dependency ordering. Plan quality determines the entire workflow trajectory. Weak plans waste more in rework than the 3× cost. |
| **Reviewer** | Multi-mode review (standard, security, adversarial, performance). Threat modeling, STRIDE analysis, and deep pattern recognition require premium reasoning. Missing vulnerabilities in security review costs more than any model savings. |

**Premium tier agents:** 3 (~19% of invocations)

### Execution Tier — Claude Haiku 4.5 (1×)

The workhorse tier for implementation, analysis, and specialized tasks.

| Agent | Rationale |
|-------|-----------|  
| **Implementer** | TDD execution, code generation, multi-file edits. Strong coding capability with large context for multi-file changes. |
| **Researcher** | Evidence gathering and synthesis. Benefits from large context to process documentation corpora. |
| **Ops** | Merged maintainer + github-ops + deployment + observability. Issue triage, changelog generation, CI/CD review, telemetry analysis. Tool-heavy agent where MCP tool access matters more than deep reasoning. |
| **Test** | TDD test writing, coverage gap analysis. Needs strong code understanding for correct test assertions. |
| **IaC** | Merged terraform + bicep. Infrastructure-as-code planning, drift detection. Domain-specific but structured work. |
| **GUI Tester** | Browser automation, visual regression. Heavy tool usage (Playwright); model coordinates tools more than reasons. |
| **Translation Conductor** | Orchestrates 6-phase translation lifecycle across 4 sub-agents. |  
| **Translator** | File-level code translation. Needs strong multilingual code understanding. |
| **Translation Analyzer** | Dependency graph analysis, complexity assessment. |
| **Translation Validator** | 6-layer validation stack with equivalence checking. |
| **Translation Styler** | Target-language idiom application with code generation. |

**Execution tier agents:** 11 (~75% of invocations)

### Fast Tier — Claude Haiku 4.5 (0.33×)

For tasks where pattern-matching suffices and deep reasoning is unnecessary.

| Agent | Rationale |
|-------|-----------|  
| **Docs** | Documentation generation with template-driven patterns. Pattern-matching and structure work. |
| **UX** | Merged visualizer + accessibility. Mermaid diagram generation, UX feedback, WCAG compliance review. Template-driven and pattern-matching work. |

**Fast tier agents:** 2 (~6% of invocations)

## Deleted and Merged Agents

The orchestrator was streamlined from 29 agents to 16 to reduce complexity and improve maintainability:

**Deleted agents:** security, performance, accessibility, lint, rubber-duck, beast-mode, observability, visualizer, deployment, red-team, spec, maintainer, github-ops, terraform, bicep, design

**Merged into existing agents:**
- **ops** = maintainer + github-ops + deployment + observability
- **ux** = visualizer + accessibility  
- **iac** = terraform + bicep
- **reviewer** now has `--security`, `--adversarial`, and `--performance` modes instead of separate agents

## Fallback Chains

When a primary model is unavailable, agents fall back to the next available model:

| Tier | Primary | Fallback 1 | Fallback 2 |
|------|---------|------------|------------|
| Premium | Claude Sonnet 4.6 | Claude Haiku 4.5 | GPT-4.1 |
| Execution | Claude Haiku 4.5 | Claude Haiku 4.5 | GPT-4.1 |
| Fast | Claude Haiku 4.5 | GPT-5 mini | Claude Haiku 4.5 |

All agents use fallback arrays in their frontmatter `model:` field. VS Code picks the first available model from the array.

## Summary

| Tier | Model(s) | Agent Count | Cost | Use Case |
|------|----------|-------------|------|----------|
| Premium | Claude Sonnet 4.6 | 3 (~19%) | 3× | Orchestration, planning, multi-mode review |
| Execution | Claude Haiku 4.5 | 11 (~69%) | 1× | Implementation, research, ops, translation, specialized tasks |
| Fast | Claude Haiku 4.5 | 2 (~12%) | 0.33× | Documentation, UX review, diagrams, accessibility patterns |

**Total:** 16 agents (11 core + 5 translation)
