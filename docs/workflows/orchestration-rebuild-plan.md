---
title: "Copilot Orchestrator Rebuild Plan"
status: draft
version: "0.1.0"
lastUpdated: "2025-11-07"
owner: "Copilot Guild"
---

# Executive Summary

Reimagine the Copilot configuration around a conductor-led, multi-agent system that mirrors the GitHub Copilot Orchestra pattern and the latest VS Code agent platform. The goal is to orchestrate planning, implementation, review, and documentation flows with explicit handoffs, high-fidelity context management, and model-aware cost controls. This initiative consolidates instructions, prompts, and chat modes into an extensible architecture that maximizes productivity while preserving compliance, quality, and security guardrails.

## Vision & Objectives

- **Single Source of Truth:** Introduce an `AGENTS.md`-centered instruction mesh with layered `.instructions.md` overrides so every agent shares consistent context.
- **Lifecycle Orchestration:** Deploy a `Conductor` agent that sequences plan → implement → review → commit cycles, persists artifacts, and enforces pause points.
- **Model Utilization Strategy:** Align personas with high-reasoning models (GPT-5, Claude Sonnet 4.5, Gemini 2.5 Pro, Claude Opus) for planning/analysis and cost-efficient models (GPT-5 Mini, Claude Haiku 4.5, GPT-4.1) for execution.
- **Async Subagent Execution:** Leverage `#runSubagent` to invoke planning, research, implementation, and review agents in parallel, reducing wall-clock time for complex work.
- **Guided Handoffs:** Adopt VS Code handoffs to make every phase transition explicit and auditable inside the Agent Sessions view.

# Research Highlights

## Multi-Agent Orchestration (ShepAlderson/copilot-orchestra)

- Conductor agent orchestrates planning, implementation, review, and commit, persisting plan/phase artifacts to the workspace.
- Specialized planning, implementation, and review subagents operate autonomously with strict TDD and structured outputs.
- Mandatory pause points ensure human-in-the-loop approvals between phases.

## VS Code Unified Agent Experience (Nov 2025)

- Agent Sessions dashboard surfaces all local and remote agent runs, enabling real-time monitoring and delegation.
- Handoffs defined in chat mode frontmatter provide guided workflow progression with optional auto-submission of follow-up prompts.
- Context-isolated subagents prevent context bloat by running in separate windows and returning only final results.
- Built-in Plan agent demonstrates a question-first, TODO-tracked planning flow adaptable to custom personas.

## Instructions & Prompt Guidance (VS Code Docs)

- `AGENTS.md`, `.github/copilot-instructions.md`, and `*.instructions.md` can be layered; nearest file wins when nested support is enabled.
- Prompt files (`*.prompt.md`) can override mode, model, and tool sets, and respect the priority: prompt tools → mode tools → default tools.
- Instruction updates should be validated via `scripts/validate-copilot-assets.ps1`, keeping directives concise and linking out to source documents.

## AGENTS.md Ecosystem (openai/agents.md)

- Standardized instruction format adopted by 20k+ repositories, compatible across Copilot, Codex, Cursor, Warp, Gemini CLI, and more.
- Encourages nested files, explicit testing commands, and alignment with CI/CD expectations.

# Current State Assessment

| Asset | Observation | Improvement Opportunity |
| --- | --- | --- |
| Agent definitions (`.github/agents/*.agent.md`) | Legacy personas in prior repo lack a unified conductor. | Consolidate into flow controllers, execution subagents, and utility agents with clear scopes. |
| Prompts (`.github/prompts/**/*.prompt.md`) | Rich library but varied formats and missing references to latest instruction stack. | Standardize front matter, link to AGENTS.md, and align output formats with orchestrated lifecycle. |
| Instructions (`instructions/**`, `.github`) | Multiple layered files exist but no AGENTS.md yet; repo instructions emphasize Beast Mode patterns. | Introduce root and nested AGENTS.md files, map existing instructions to new hierarchy, and remove duplication. |
| Scripts (`scripts/*.ps1`) | Validation and metadata helpers exist but not enforced in CI. | Integrate into workflow to ensure every agent change passes validation and token budgets. |
| Documentation (`docs/*.md`) | Strong governance docs but no unified orchestration blueprint. | Publish this plan, add diagrams, and ensure migration checklist references new workflow. |

# Target Architecture

## Conductor Agent

- **Role:** Owns the lifecycle state machine: Planning → Implementation → Review → Commit → Completion.
- **Responsibilities:**
  - Invoke specialized subagents via `#runSubagent` with bounded prompts and toolsets.
  - Persist plan files to `plans/<task>.md`, phase summaries to `plans/<task>-phase-<n>.md`, and completion reports.
  - Maintain status telemetry (Current Phase, Plan Progress, Last Action, Next Action) for display in responses and Agent Sessions.
  - Enforce mandatory stop points after plan presentation, post-review/pre-commit, and after final summary.
- **Model:** Default to Claude Sonnet 4.5 or GPT-5 for reasoning; allow overrides via front matter.
- **Tools:** `runSubagent`, `todos`, `fetch`, `search`, `githubRepo`, `edit` (restricted), `changes`, `runCommands` when necessary.

## Specialized Subagents

| Persona | Primary Models | Scope | Tooling | Notes |
| --- | --- | --- | --- | --- |
| Planning Researcher | Gemini 2.5 Pro, GPT-5, Claude Sonnet 4.5 | Deep code/document research, summarization, option analysis | `search`, `fetch`, `githubRepo`, `readFile`, `usages`, `problems` | Must stop at findings; no plans or edits. |
| Planner (Plan Drafting) | GPT-5 | Drafts plan artifacts using plan template, asks clarification, tracks TODO list | `todos`, `readFile`, `fetch`, `search` (read-only) | Returns plan markdown without executing work. |
| Implementer (TDD) | GPT-5 Mini, Claude Haiku 4.5, GPT-4.1 | Executes per-phase work using strict TDD, minimal commits per step | `edit`, `runCommands`, `search`, `todos`, `problems`, `changes` | Auto-runs targeted tests → full suite; escalates critical decisions. |
| Reviewer | Claude Sonnet 4.5, GPT-5 | Reviews diffs, ensures tests, flags issues with severity tags | `changes`, `search`, `usages`, `problems` | Returns structured review (`APPROVED/NEEDS_REVISION/FAILED`). |
| Support Agents | Model varies | Accessibility, security, performance, docs | Tools tailored per specialty | Integrate as optional subagents triggered by Conductor or handoffs. |

## Handoffs & Agent Sessions

- Configure chat mode front matter `handoffs` so that Planner offers “Kick off Implementation”, Implementer offers “Send to Review”, Reviewer offers “Prepare Commit Summary”.
- Include optional “Open in Agent Sessions” prompts to launch remote agents (Copilot coding agent, Codex) for long-running tasks.
- For parallelizable sub-work, instruct Conductor to spawn multiple `#runSubagent` calls and aggregate results before proceeding.

# Instructions & Context Strategy

1. **Root `AGENTS.md`:** Provide repository overview, build/test matrix, security/compliance requirements, and links to specialized instruction files.
2. **Nested AGENTS.md:** Place domain-specific variants under `.github/agents/`, `.github/prompts/`, and `scripts/` to give localized guidance.
3. **Instruction Files Alignment:**
   - Map existing `instructions/global/*.instructions.md` to the new conductor/subagent expectations.
   - Create `instructions/workflows/conductor.instructions.md` for orchestration policies (pause points, artifact storage).
   - Ensure `.github/copilot-instructions.md` references AGENTS.md and enumerates validation commands.
4. **Validation Automation:** Update CI to run `scripts/validate-copilot-assets.ps1`, `scripts/add-prompt-metadata.ps1`, and `scripts/token-report.ps1` on each PR.

# Prompt Library Modernization

- Update template files (e.g., `prompts/templates/new-prompt.prompt.md`) to reference AGENTS.md, insist on recursive `fetch_webpage`, 2,000-line reads, TODO lists, and explicit validation steps.
- Categorize prompts into planning, implementation, review, research, and support libraries, each referencing the corresponding subagent mode via `mode` front matter.
- Use shared partials for validation checklists and output schemas to avoid divergence.
- Document slash-command usage and parameterization for quick handoffs (e.g., `/plan-new-feature`, `/implement-phase --phase=2`).

# Documentation & Knowledge Base

- Publish diagrams illustrating the conductor/subagent workflow (Mermaid or textual description).
- Update operations backlog to include validation task outputs and incident recording for agent misbehavior.
- Extend `docs/migration-checklist.md` with steps for adopting AGENTS.md, migrating prompts, and verifying handoffs in VS Code Insiders.
- Capture lessons learned in process logs during rollout.

# Implementation Roadmap

| Phase | Focus | Key Deliverables | Owners | Target |
| --- | --- | --- | --- | --- |
| 0 | Foundations | Root `AGENTS.md`, enable nested support, align `.github/copilot-instructions.md` | Docs & Platform | Week 1 |
| 1 | Conductor Skeleton | `conductor.agent.md`, plan/phase templates, updated planner subagents | Prompt Guild | Week 2 |
| 2 | Execution Agents | `implement-subagent`, `review-subagent`, update TDD modes, add handoffs | Dev Experience | Week 3 |
| 3 | Prompt & Template Refresh | Standardize prompt metadata, integrate partials, update templates | Prompt Guild | Week 4 |
| 4 | Automation & CI | Wire validation scripts, add token budget gating, create dashboards | Dev Tools | Week 5 |
| 5 | Adoption & Training | Create demos, record screencasts, gather feedback loops | Enablement | Week 6 |

# Risk & Mitigation

- **Instruction Drift:** Establish change review checklist + automated validation to prevent stale directives.
- **Model Availability Changes:** Centralize model selection in `_shared/models.yml` and allow environment-driven overrides.
- **Parallel Agent Conflicts:** Conductor aggregates subagent outputs sequentially and reconciles conflicting edits before applying patches.
- **User Onboarding Overhead:** Provide quick-start guides, sample Agent Sessions exports, and fallback “classic” prompts for simple tasks.

# Success Metrics

- ≥90% of new tasks executed through conductor pipeline with artifact trail.
- Prompt/agent validation scripts run in CI on every PR with zero warnings.
- Reduction in average implementation cycle time by ≥25% due to subagent parallelism.
- Positive qualitative feedback from trial teams (survey rating ≥4/5 on clarity and productivity).

# Next Steps Checklist

1. Approve this plan and capture feedback in the operations backlog.
2. Stand up `AGENTS.md` scaffolding and enable nested support in workspace settings.
3. Draft Conductor agent front matter + body using Orchestra workflow as reference.
4. Refactor planning and TDD chat modes into new subagent taxonomy.
5. Socialize the plan and schedule enablement sessions.
