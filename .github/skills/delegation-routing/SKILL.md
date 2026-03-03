````skill
---
name: delegation-routing
description: "Agent-to-agent routing patterns for autonomous delegation via #runSubagent. Defines keyword matching, context templates, model preferences, escalation rules, and invocation guardrails. Use for routing decisions, subagent dispatch, delegation context preparation, and handoff target selection."
---

# Delegation Routing

Provides keyword-based routing patterns so any agent can autonomously delegate work to the right specialist via `#runSubagent`, without relying on handoff buttons.

## Description

This skill replaces UI-based handoff buttons with autonomous `#runSubagent` delegation. It teaches agents how to:
1. Detect when a specialist is needed by matching keyword patterns in the task
2. Select the correct target agent from the 27-agent roster
3. Compose an effective delegation prompt with required context
4. Respect invocation restrictions (model preferences, allowlists, invocation controls)
5. Decide whether to delegate directly or escalate to the conductor

The conductor agent retains its handoff buttons as the single user-facing entry point. All other agents delegate autonomously using the patterns defined here.

## When to Use

This skill is relevant when:
- An agent needs to hand work to another specialist
- A task requires cross-agent collaboration (e.g., implementer needs security review)
- An agent has completed its work and must return results to the conductor
- Routing ambiguity needs resolution (which agent handles this task?)
- An agent encounters work outside its specialization

## Entry Points

### Trigger Phrases
- "delegate to", "hand off to", "route to"
- "needs review", "needs testing", "needs security check"
- "return to conductor", "escalate", "report findings"
- "who handles", "which agent", "specialist for"

### Context Patterns
- Agent completes its primary task and needs next-step routing
- Task requires a capability the current agent doesn't have
- Multi-step workflow needs coordination across agents
- Quality gate requires a different perspective (review, security, a11y)

## Core Knowledge

### Delegation Mechanism

All inter-agent delegation uses `#runSubagent`:

```
#runSubagent {agent-name} "{detailed context prompt}"
```

**Rules:**
- Always include objective, files in scope, and acceptance criteria in the prompt
- Reference prior decisions: "As planned in Phase 1..." or "Following the findings above..."
- Carry forward constraints: timeline, budget, compliance requirements
- Never call `#runSubagent` for agents not in your `agents:` allowlist (if one is defined)

### Routing Table

#### Core Workflow Agents

| Agent | Keyword Triggers | When to Delegate | Model Preference |
|-------|-----------------|------------------|------------------|
| **conductor** | "orchestrate", "coordinate", "multi-phase", "lifecycle" | Escalate scope changes, ambiguous routing, multi-agent coordination | Claude Opus 4.6 |
| **planner** | "plan", "scope", "phases", "strategy", "breakdown", "estimate", "impact analysis", "blast radius" | Need structured multi-phase plan, risk analysis, option evaluation, impact assessment | Claude Opus 4.6 |
| **implementer** | "implement", "build", "code", "fix", "apply", "execute", "create" | Execute approved changes, apply fixes, generate code | Claude Sonnet 4.6 |
| **reviewer** | "review", "audit", "quality", "check", "verify", "validate" | After implementation, quality gates, diff review, compliance checks | Claude Opus 4.6 |
| **researcher** | "research", "investigate", "evidence", "compare", "explore", "context", "code topology", "codebase overview", "architecture map" | Gather background info, evaluate alternatives, find documentation, structural codebase analysis | Claude Opus 4.6 |
| **maintainer** | "triage", "release", "changelog", "version", "PR", "issue management" | Issue triage, release preparation, PR logistics, changelog updates | GPT-5.3-Codex |

#### Support Persona Agents

| Agent | Keyword Triggers | When to Delegate | Model Preference | Restriction |
|-------|-----------------|------------------|------------------|-------------|
| **security** | "threat", "vulnerability", "compliance", "STRIDE", "credentials", "auth" | Security review, threat modeling, compliance checkpoint | Claude Opus 4.6 | `user-invokable: false` — subagent-only |
| **performance** | "latency", "memory", "profiling", "scalability", "Big O", "cost" | Runtime analysis, memory profiling, cost modeling | GPT-5.3-Codex | `user-invokable: false` — subagent-only |
| **accessibility** | "WCAG", "ARIA", "a11y", "screen reader", "keyboard navigation", "contrast" | Accessibility audit, WCAG compliance, ARIA review | GPT-5.3-Codex | — |
| **docs** | "documentation", "onboarding", "guide", "README", "tutorial", "knowledge" | Documentation drafts, onboarding materials, template creation | Claude Sonnet 4.6 | — |
| **observability** | "metrics", "logging", "tracing", "telemetry", "monitoring", "dashboard" | Instrumentation review, platform integration, metrics analysis | GPT-5.3-Codex | `user-invokable: false` — subagent-only |
| **visualizer** | "UX", "diagram", "wireframe", "user flow", "visual", "Mermaid" | UX review, diagram creation, visual hierarchy feedback | GPT-5.3-Codex | — |
| **deployment** | "CI/CD", "pipeline", "deploy", "release readiness", "environment", "infrastructure" | Deployment review, pipeline validation, release runbooks | GPT-5.3-Codex | — |
| **red-team** | "adversarial", "exploit", "edge case", "stress test", "loophole", "bad actor" | Adversarial testing, assumption challenging, attack surface analysis | Claude Opus 4.6 | `user-invokable: false` — subagent-only |

#### Translation Workflow Agents

| Agent | Keyword Triggers | When to Delegate | Model Preference | Restriction |
|-------|-----------------|------------------|------------------|-------------|
| **translation-conductor** | "translate repo", "full translation", "codebase translation", "language migration" | Full-repo translation orchestration (6-phase lifecycle) | Claude Opus 4.6 | Only invoked by conductor |
| **translator** | "translate file", "convert code", "port module" | Single-file code translation with pattern mapping | Claude Opus 4.6 | `disable-model-invocation: true` |
| **translation-analyzer** | "dependency graph", "manifest", "translation analysis", "source discovery" | Source repo analysis, dependency DAG, complexity assessment | GPT-5.3-Codex | `disable-model-invocation: true` |
| **translation-validator** | "validate translation", "confidence score", "equivalence check" | 6-layer validation stack, confidence scoring | Claude Sonnet 4.6 | `disable-model-invocation: true` |
| **translation-styler** | "idioms", "conventions", "target style", "idiomatic code" | Target language idiom application, convention enforcement | GPT-5.3-Codex | `disable-model-invocation: true` |

#### Specialist Agents

| Agent | Keyword Triggers | When to Delegate | Model Preference |
|-------|-----------------|------------------|------------------|
| **test** | "unit test", "integration test", "coverage", "TDD", "Pester", "test suite" | Test creation, coverage analysis, Red-Green-Refactor cycles | Claude Sonnet 4.6 |
| **lint** | "format", "style fix", "lint", "whitespace", "naming convention" | Code formatting, style enforcement, auto-fixes | Claude Sonnet 4.6 |
| **github-ops** | "issue", "pull request", "workflow", "GitHub Actions", "branch", "repository" | GitHub operations, PR management, workflow automation | GPT-5.3-Codex |
| **terraform** | "Terraform", "multi-cloud", "IaC", "drift detection", "HCL" | Infrastructure-as-code planning, drift detection | GPT-5.3-Codex |
| **bicep** | "Azure", "Bicep", "ARM template", "Azure IaC" | Azure infrastructure implementation, ARM compatibility | GPT-5.3-Codex |
| **design** | "design system", "brand colors", "components", "design tokens" | Design system queries, component search, contrast validation | GPT-5.3-Codex |
| **beast-mode** | "deep analysis", "complex reasoning", "step-by-step", "thorough investigation" | Extended reasoning with visible thinking, complex problem solving | Claude Opus 4.6 |
| **rubber-duck** | "stuck", "confused", "think through", "debug thinking", "rubber duck", "talk it out", "help me understand" | Socratic problem-solving, guided debugging via probing questions | Claude Sonnet 4.6 |

### Delegation Templates

#### Standard Delegation
```
#runSubagent {agent} "
Objective: {what needs to be done}
Context: {relevant findings, decisions, constraints from current work}
Files in scope: {file paths}
Acceptance criteria: {how to verify success}
"
```

#### Return to Conductor
```
#runSubagent conductor "
Completed: {summary of work done}
Findings: {key results, severity-tagged if applicable}
Artifacts: {files created or modified}
Next steps: {recommended follow-up actions}
"
```

#### Implementation Handoff
```
#runSubagent implementer "
Implement: {specific objective from approved plan}
Phase: {N of M}
Files: {target file paths}
TDD: Write failing test first, then implement, then validate.
Validation: Run `powershell -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .`
"
```

#### Review Handoff
```
#runSubagent reviewer "
Review: {what was changed and why}
Phase objective: {the goal this change serves}
Changed files: {list}
Acceptance criteria: {specific checks}
Tag findings: BLOCKER, MAJOR, MINOR, NIT
"
```

#### Quality Specialist Handoff
```
#runSubagent {security|performance|accessibility} "
Scope: {files, features, or changes to evaluate}
Context: {what prompted this review}
Prior findings: {any related issues from earlier phases}
Deliver: Severity-tagged findings with actionable remediation.
"
```

### Complexity-Based Pre-Routing (Cognitive Router)

Before keyword-matching to a specific agent, assess the request's **complexity tier** to determine the appropriate processing depth. This prevents over-engineering simple tasks and under-resourcing complex ones.

#### Complexity Tiers

| Tier | Signal Patterns | Routing Action |
|------|----------------|----------------|
| **INSTANT** | Simple lookups, greetings, factual questions, "what is X?" | Conductor answers directly — no subagent delegation needed |
| **FAST** | Single-file fixes, typo corrections, config changes, "fix this lint error" | Route to a single specialist (lint, implementer) — skip planning |
| **STANDARD** | Feature implementation, bug investigation, documentation overhaul | Standard lifecycle: Planner → Implementer → Reviewer |
| **DEEP** | Multi-system architecture, cross-cutting refactor, security audit + performance review | Full lifecycle with support personas (security, performance, red-team) |
| **ULTRADEEP** | Full-repo translation, compliance overhaul, production incident RCA | Extended reasoning (beast-mode), parallel subagent tracks, mandatory trilateral review |

#### Complexity Signal Detection

**Escalate to DEEP/ULTRADEEP when any of these signals are present:**
- Request uses synthesis keywords: "synthesize", "compare and contrast", "trace evolution", "root cause"
- Multiple systems or agent domains are affected (e.g., security + performance + deployment)
- Contradictory evidence or failed prior attempts exist in session context
- User explicitly requests deep analysis: "thorough", "comprehensive", "investigate fully"
- Ruin-risk indicators: destructive operations, PII handling, production environment changes

**Keep at FAST/INSTANT when:**
- Request matches a calculator pattern, greeting, or simple factual question
- Single-file scope with clear acceptance criteria
- Task is routine-tier work (formatting, commit messages, PR descriptions)

#### Pre-Routing Decision Flow

```
1. Check complexity tier (INSTANT → ULTRADEEP)
2. If INSTANT → Conductor answers directly, no delegation
3. If FAST → Skip planning, delegate to single specialist
4. If STANDARD → Standard lifecycle (plan → implement → review)
5. If DEEP → Standard lifecycle + engage support personas
6. If ULTRADEEP → Beast-mode reasoning + parallel tracks + trilateral review
```

**Integration with keyword routing:** Complexity tier determines the *workflow depth*; keyword matching determines the *target agent*. Apply complexity assessment first, then use the routing table below to select the specific agent.

### Escalation Rules

**Escalate to conductor** (do NOT delegate directly) when:
- The task requires coordination across 3+ agents
- Scope is expanding beyond the approved plan
- A compliance checkpoint is reached (privacy review, deployment approval)
- Routing is ambiguous — multiple agents could handle the task
- A BLOCKER-severity finding requires workflow changes
- The current agent's `agents:` allowlist doesn't include the target
- Complexity tier is ULTRADEEP and requires parallel subagent coordination

**Delegate directly** when:
- Clear single-agent handoff with matching keyword pattern
- The target agent is in your `agents:` allowlist (or no allowlist is defined)
- The work is scoped to one phase or one deliverable
- Complexity tier is FAST and a single specialist can handle it
- Return-to-conductor after completing your assigned task

### Invocation Guardrails

#### Agents with `user-invokable: false`
These agents cannot be started directly by users. They are only reachable via `#runSubagent`:
- **security** — invoke from conductor, implementer, reviewer, or planner
- **performance** — invoke from conductor, implementer, or reviewer
- **observability** — invoke from conductor only
- **red-team** — invoke from conductor, planner, or reviewer

#### Agents with `disable-model-invocation: true`
These agents cannot be autonomously invoked by another model. They must be explicitly invoked by their designated parent:
- **translator** — invoked only by `translation-conductor`
- **translation-analyzer** — invoked only by `translation-conductor`
- **translation-validator** — invoked only by `translator` or `translation-conductor`
- **translation-styler** — invoked only by `translator` or `translation-conductor`

#### `agents:` Allowlists
Some agents have explicit allowlists restricting which subagents they can invoke:
- **conductor** — can invoke 22 agents (all except translation sub-agents directly)
- **translation-conductor** — can invoke 13 agents (translation workflow + core workflow)
- **translator** — can invoke only `translation-validator` and `translation-styler`

If your `agents:` allowlist doesn't include the target, escalate to the conductor:
```
#runSubagent conductor "
Need delegation to {target-agent} but it's outside my allowlist.
Context: {what needs to happen}
Recommendation: Route to {target-agent} with these parameters: {details}
"
```

### Model Override Guidance

When delegating to these agents, note their preferred models for cost efficiency:

| Target Agent | Preferred Model | Rationale |
|--------------|----------------|-----------|
| docs | Claude Sonnet 4.6 | Documentation tasks are routine-tier |
| lint | Claude Sonnet 4.6 | Formatting is routine-tier |
| translation-validator | Claude Sonnet 4.6 | Code validation benefits from versatile model |
| translation-styler | GPT-5.3-Codex | Style application needs execution-tier reasoning |

These preferences are encoded in the agent's own `model:` frontmatter and will be applied automatically by the platform. Mentioning the model in your delegation prompt is not required — the agent will use its configured model.

## Examples

### Example 1: Implementer Needs Security Review
```
# After finishing Phase 2 implementation:
#runSubagent security "
Scope: Authentication middleware changes in src/auth/ and src/middleware/
Context: Implemented OAuth2 token validation as part of Phase 2.
Prior findings: None — first security review for this plan.
Deliver: STRIDE assessment of the auth flow, severity-tagged findings, remediation guidance.
"
```

### Example 2: Reviewer Routes to Implementer for Fixes
```
# After finding issues during review:
#runSubagent implementer "
Implement: Fix 2 MAJOR findings from code review
Phase: 3 of 5 (iteration)
Files: src/api/users.ts (L45 - null check), src/api/auth.ts (L112 - token expiry)
TDD: Write regression tests for each fix before implementing.
Validation: Run `powershell -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .`
"
```

### Example 3: Planner Escalates Ambiguous Routing
```
# Task seems to need both security and performance review:
#runSubagent conductor "
Completed: Phase 2 plan draft for database migration.
Open question: The migration involves both sensitive data (PII) and large table scans.
Recommendation: Engage both security (PII handling) and performance (query optimization) before implementation.
This requires multi-agent coordination — escalating for conductor routing.
"
```

### Example 4: Docs Agent Returns to Conductor
```
#runSubagent conductor "
Completed: Documentation update for OAuth2 feature.
Artifacts: docs/guides/oauth2-setup.md (new), docs/guides/onboarding.md (updated)
Findings: Gap identified — no runbook for token rotation. Recommend security review.
Next steps: Security agent should review token rotation procedures.
"
```

## Agent → Skill Mapping

When delegating to a sub-agent, load the relevant skills to ensure the agent follows established patterns. This table maps each agent to the skills it should reference.

| Agent | Primary Skills | Load When |
|-------|---------------|-----------|
| conductor | conductor-lifecycle, delegation-routing, memory-management | Always (orchestration core) |
| planner | documentation-style | Plan authoring, Mermaid diagrams |
| implementer | git-operations | Commit workflows, branch operations |
| reviewer | performance-analysis | Performance-relevant reviews |
| researcher | documentation-style | Brief formatting, citation structure |
| maintainer | git-operations, memory-management | Release ops, artifact triage |
| security | — | Standalone threat analysis |
| performance | performance-analysis | Always (core competency) |
| accessibility | — | Standalone WCAG analysis |
| docs | documentation-style | Always (core competency) |
| observability | performance-analysis, orchestrator-terminal-style | Metrics display, terminal output |
| visualizer | orchestrator-terminal-style | Diagram authoring, terminal formatting |
| deployment | git-operations | Release pipelines, tag management |
| red-team | — | Adversarial testing (standalone) |
| test | — | Test authoring (standalone) |
| lint | — | Style enforcement (standalone) |
| github-ops | git-operations | PR/issue management, branch ops |
| terraform | — | IaC planning (standalone) |
| bicep | — | Azure IaC (standalone) |
| design | — | Design system queries (standalone) |
| beast-mode | memory-management | Extended sessions, context management |
| rubber-duck | — | Conversational only (no skills needed) |
| translation-conductor | conductor-lifecycle | Translation orchestration lifecycle |
| translator | — | File-level translation |
| translation-analyzer | — | Dependency graph analysis |
| translation-validator | — | Validation stack execution |
| translation-styler | — | Idiom enforcement |

**Usage pattern**: When routing via `#runSubagent`, the receiving agent should load listed skills before beginning work. Skills marked "—" operate with built-in instructions only.

## References

- **Conductor Agent**: `.github/agents/conductor.agent.md` — retains handoff buttons as user entry point
- **Conductor Lifecycle Skill**: `.github/skills/conductor-lifecycle/SKILL.md` — phase orchestration patterns
- **Code Topology Skill**: `.github/skills/code-topology/SKILL.md` — structural code understanding protocol
- **Agent Roster**: `AGENTS.md` — full agent list with capabilities and model allocations
- **Model Selection**: `instructions/global/03_model-selection.instructions.md` — tier definitions and fallback chains
- **Validation Scripts**: `scripts/validate-copilot-assets.ps1`, `scripts/run-lint.ps1`

````
