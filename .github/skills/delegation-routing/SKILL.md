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
| **planner** | "plan", "scope", "phases", "strategy", "breakdown", "estimate" | Need structured multi-phase plan, risk analysis, option evaluation | Claude Opus 4.6 |
| **implementer** | "implement", "build", "code", "fix", "apply", "execute", "create" | Execute approved changes, apply fixes, generate code | Codex 5.2 |
| **reviewer** | "review", "audit", "quality", "check", "verify", "validate" | After implementation, quality gates, diff review, compliance checks | Claude Opus 4.6 |
| **researcher** | "research", "investigate", "evidence", "compare", "explore", "context" | Gather background info, evaluate alternatives, find documentation | Claude Opus 4.6 |
| **maintainer** | "triage", "release", "changelog", "version", "PR", "issue management" | Issue triage, release preparation, PR logistics, changelog updates | Claude Sonnet 4.5 |

#### Support Persona Agents

| Agent | Keyword Triggers | When to Delegate | Model Preference | Restriction |
|-------|-----------------|------------------|------------------|-------------|
| **security** | "threat", "vulnerability", "compliance", "STRIDE", "credentials", "auth" | Security review, threat modeling, compliance checkpoint | Claude Opus 4.6 | `user-invokable: false` — subagent-only |
| **performance** | "latency", "memory", "profiling", "scalability", "Big O", "cost" | Runtime analysis, memory profiling, cost modeling | Claude Sonnet 4.5 | `user-invokable: false` — subagent-only |
| **accessibility** | "WCAG", "ARIA", "a11y", "screen reader", "keyboard navigation", "contrast" | Accessibility audit, WCAG compliance, ARIA review | Claude Sonnet 4.5 | — |
| **docs** | "documentation", "onboarding", "guide", "README", "tutorial", "knowledge" | Documentation drafts, onboarding materials, template creation | Claude Haiku 4.5 | — |
| **observability** | "metrics", "logging", "tracing", "telemetry", "monitoring", "dashboard" | Instrumentation review, platform integration, metrics analysis | Claude Sonnet 4.5 | `user-invokable: false` — subagent-only |
| **visualizer** | "UX", "diagram", "wireframe", "user flow", "visual", "Mermaid" | UX review, diagram creation, visual hierarchy feedback | Claude Sonnet 4.5 | — |
| **data-analytics** | "analyze data", "correlation", "churn", "predict", "forecast", "DS-Star" | Data analysis, statistical testing, ML model evaluation | Claude Sonnet 4.5 | — |
| **deployment** | "CI/CD", "pipeline", "deploy", "release readiness", "environment", "infrastructure" | Deployment review, pipeline validation, release runbooks | Claude Sonnet 4.5 | — |
| **red-team** | "adversarial", "exploit", "edge case", "stress test", "loophole", "bad actor" | Adversarial testing, assumption challenging, attack surface analysis | Claude Opus 4.6 | `user-invokable: false` — subagent-only |

#### Translation Workflow Agents

| Agent | Keyword Triggers | When to Delegate | Model Preference | Restriction |
|-------|-----------------|------------------|------------------|-------------|
| **translation-conductor** | "translate repo", "full translation", "codebase translation", "language migration" | Full-repo translation orchestration (6-phase lifecycle) | Claude Opus 4.6 | Only invoked by conductor |
| **translator** | "translate file", "convert code", "port module" | Single-file code translation with pattern mapping | Claude Opus 4.6 | `disable-model-invocation: true` |
| **translation-analyzer** | "dependency graph", "manifest", "translation analysis", "source discovery" | Source repo analysis, dependency DAG, complexity assessment | Claude Sonnet 4.5 | `disable-model-invocation: true` |
| **translation-validator** | "validate translation", "confidence score", "equivalence check" | 6-layer validation stack, confidence scoring | Codex 5.2 | `disable-model-invocation: true` |
| **translation-styler** | "idioms", "conventions", "target style", "idiomatic code" | Target language idiom application, convention enforcement | Claude Sonnet 4.5 | `disable-model-invocation: true` |

#### Specialist Agents

| Agent | Keyword Triggers | When to Delegate | Model Preference |
|-------|-----------------|------------------|------------------|
| **test** | "unit test", "integration test", "coverage", "TDD", "Pester", "test suite" | Test creation, coverage analysis, Red-Green-Refactor cycles | Codex 5.2 |
| **lint** | "format", "style fix", "lint", "whitespace", "naming convention" | Code formatting, style enforcement, auto-fixes | Gemini 3 Flash |
| **github-ops** | "issue", "pull request", "workflow", "GitHub Actions", "branch", "repository" | GitHub operations, PR management, workflow automation | Claude Sonnet 4.5 |
| **terraform** | "Terraform", "multi-cloud", "IaC", "drift detection", "HCL" | Infrastructure-as-code planning, drift detection | Claude Sonnet 4.5 |
| **bicep** | "Azure", "Bicep", "ARM template", "Azure IaC" | Azure infrastructure implementation, ARM compatibility | Claude Sonnet 4.5 |
| **design** | "design system", "brand colors", "components", "design tokens" | Design system queries, component search, contrast validation | Claude Sonnet 4.5 |
| **beast-mode** | "deep analysis", "complex reasoning", "step-by-step", "thorough investigation" | Extended reasoning with visible thinking, complex problem solving | Claude Opus 4.6 |

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

### Escalation Rules

**Escalate to conductor** (do NOT delegate directly) when:
- The task requires coordination across 3+ agents
- Scope is expanding beyond the approved plan
- A compliance checkpoint is reached (privacy review, deployment approval)
- Routing is ambiguous — multiple agents could handle the task
- A BLOCKER-severity finding requires workflow changes
- The current agent's `agents:` allowlist doesn't include the target

**Delegate directly** when:
- Clear single-agent handoff with matching keyword pattern
- The target agent is in your `agents:` allowlist (or no allowlist is defined)
- The work is scoped to one phase or one deliverable
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
- **conductor** — can invoke 21 agents (all except translation sub-agents directly)
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
| docs | Claude Haiku 4.5 | Documentation tasks are routine-tier |
| lint | Gemini 3 Flash | Formatting is routine-tier |
| translation-validator | Codex 5.2 | Code validation benefits from code-specialized model |
| translation-styler | Claude Sonnet 4.5 | Style application needs execution-tier reasoning |

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

## References

- **Conductor Agent**: `.github/agents/conductor.agent.md` — retains handoff buttons as user entry point
- **Conductor Lifecycle Skill**: `.github/skills/conductor-lifecycle/SKILL.md` — phase orchestration patterns
- **Agent Roster**: `AGENTS.md` — full agent list with capabilities and model allocations
- **Model Selection**: `instructions/global/03_model-selection.instructions.md` — tier definitions and fallback chains
- **Validation Scripts**: `scripts/validate-copilot-assets.ps1`, `scripts/run-lint.ps1`

````
