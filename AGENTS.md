# Copilot Orchestrator — Agent Playbook

This repository implements a multi-agent orchestration pattern for GitHub Copilot. It provides the source of truth for agent definitions, prompts, instructions, and validation tooling.

> **Status:** Stable. Follow the guardrails below and log issues in `docs/operations.md`.

---

## Mission & Architecture

- Progress tasks through a structured lifecycle: **Planning → Implementation → Review → Completion**
- Persist artifacts locally in the `artifacts/` folder of each consuming repository
- Maintain pause points after plan creation and after each review for human approval
- Use context-isolated subagents via `#runSubagent` for specialized work

### Supporting Documentation

| Document | Purpose |
|----------|---------|
| `docs/workflows/orchestration-rebuild-plan.md` | Strategy, success metrics, roadmap |
| `docs/workflows/new-workspace-blueprint.md` | Repository layout, model allocation |
| `docs/guides/central-deployment.md` | Org-level deployment with local artifacts |
| `docs/operations.md` | Monitoring, backlog, incident process |
| `docs/templates/` | Plan, phase, and completion templates |

---

## Development Environment

| Task | Command |
|------|---------|
| Validate assets | `pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .` |
| Check prompt metadata | `pwsh -File scripts/add-prompt-metadata.ps1 -RepositoryRoot . -CheckOnly` |
| Token budget report | `pwsh -File scripts/token-report.ps1 -Path .` |
| Run linting | `pwsh -File scripts/run-lint.ps1 -RepositoryRoot .` |
| Run smoke tests | `pwsh -File scripts/run-smoke-tests.ps1 -RepositoryRoot .` |
| Initialize artifacts | `pwsh -File scripts/init-artifacts.ps1` |
| Session analytics | `pwsh -File scripts/analyze-sessions.ps1` |
| Pester tests | `Invoke-Pester -Path tests -Output Detailed` |

**Shell**: Windows PowerShell 5.1. Use `;` when chaining commands. Prefer cmdlets over aliases.

---

## Agent Roster (22 Agents)

### Core Workflow

| Agent | File | Purpose |
|-------|------|---------|
| Conductor | `conductor.agent.md` | Lifecycle orchestration, pause points, delegation |
| Planner | `planner.agent.md` | Multi-phase planning, research, risk analysis |
| Implementer | `implementer.agent.md` | TDD execution, validation logging |
| Reviewer | `reviewer.agent.md` | Severity-tagged findings, quality gates |
| Researcher | `researcher.agent.md` | Context gathering, source citation |
| Maintainer | `maintainer.agent.md` | Issue triage, release coordination |

### Support Personas

| Agent | File | Purpose |
|-------|------|---------|
| Security | `security.agent.md` | Threat modeling, compliance review |
| Performance | `performance.agent.md` | Runtime, memory, cost analysis |
| Accessibility | `accessibility.agent.md` | WCAG compliance, ARIA review |
| Docs | `docs.agent.md` | Documentation, onboarding materials |
| Observability | `observability.agent.md` | Telemetry, platform integrations |
| Visualizer | `visualizer.agent.md` | UX review, diagrams |
| Data Analytics | `data-analytics.agent.md` | DS-Star workflow, data quality |
| Deployment | `deployment.agent.md` | CI/CD review, release readiness |
| Red Team | `red-team.agent.md` | Adversarial testing, edge cases |

### Specialists

| Agent | File | Purpose |
|-------|------|---------|
| Test | `test.agent.md` | TDD test writing, coverage analysis |
| Lint | `lint.agent.md` | Code style enforcement |
| GitHub Ops | `github-ops.agent.md` | Issue/PR/workflow management |
| Terraform | `terraform.agent.md` | Multi-cloud IaC planning |
| Bicep | `bicep.agent.md` | Azure IaC implementation |
| Design | `design.agent.md` | Architecture design |
| Beast Mode | `beast-mode.agent.md` | Extended reasoning, visible thinking |

---

## Local Artifact Storage

Agents persist session outputs to a local `artifacts/` folder in each consuming repository:

```
artifacts/
├── plans/          # Planner, Implementer, Conductor
├── reviews/        # Reviewer
├── research/       # Researcher
├── security/       # Security
├── sessions/       # Session state (JSON)
├── performance/    # Performance
├── docs/           # Docs
├── releases/       # Maintainer
├── telemetry/      # Observability
├── deployments/    # Deployment
├── red-team/       # Red Team
├── accessibility/  # Accessibility
├── tests/          # Test
└── ux/             # Visualizer
```

Initialize with: `pwsh -File scripts/init-artifacts.ps1`

See `docs/guides/central-deployment.md` for org-level deployment patterns.

---

## Safety & Compliance

- Follow security baseline in `instructions/global/02_security.instructions.md` and any overlays under `instructions/compliance/`.
- Never include secrets or tokens in transcripts. Use placeholder values and describe secure storage expectations.
- Flag compliance checkpoints (privacy review, deployment approval) in plans and phase summaries.

---

## Validation Requirements

- Run validation scripts after modifying prompts, chat modes, or instruction files.
- Record command output in PR descriptions and update `docs/CHANGELOG.md` for notable changes.
- If validation tooling is missing, add a task to `docs/operations.md` backlog before merging.

---

## Contribution Protocol

1. Update or add documentation in `docs/` alongside code/instruction changes.
2. Ensure new assets follow schemas under `schemas/` (to be ported).
3. Capture rollout notes and approvals in `docs/CHANGELOG.md` and `docs/operations.md`.
4. For major changes, attach sample Agent Sessions exports demonstrating the conductor workflow.

If any guideline conflicts with immediate customer needs, escalate via the Conductor plan's open questions rather than bypassing the guardrails.

---

## Community Resources

Leverage proven patterns from the GitHub Copilot community:

- **[Awesome Copilot](https://github.com/github/awesome-copilot)** - Curated collection of custom agents, prompts, and instructions
  - [Custom Agents](https://github.com/github/awesome-copilot/tree/main/agents) - Reference implementations for specialized personas
  - [Reusable Prompts](https://github.com/github/awesome-copilot/tree/main/prompts) - Battle-tested prompt templates
  - [Instructions](https://github.com/github/awesome-copilot/tree/main/instructions) - Framework-specific and language-specific guidelines
- **Pattern Libraries**:
  - [instructions.instructions.md](https://github.com/github/awesome-copilot/blob/main/instructions/instructions.instructions.md) - Meta-guidelines for creating instruction files
  - [prompt.instructions.md](https://github.com/github/awesome-copilot/blob/main/instructions/prompt.instructions.md) - Best practices for prompt file structure
  - [agent.instructions.md](https://github.com/github/awesome-copilot/blob/main/instructions/agent.instructions.md) - Custom agent development patterns

**Integration Guidelines**:
- Review awesome-copilot patterns before creating new agents or prompts
- Adapt community patterns to match our conductor workflow and TDD requirements
- Contribute successful patterns back to the community when appropriate
- Reference specific awesome-copilot examples in conductor handoffs when suggesting tools

---

## Observability & Continuous Improvement

**Session Analytics** (see `docs/guides/session-analytics.md`):
- Track workflow metrics with `scripts/analyze-sessions.ps1`
- Monitor: escalation patterns, model usage/cost, quality metrics, phase durations
- View dashboard: `docs/dashboards/workflow-metrics.md`
- Targets: ≤20% premium model usage, ≥90% review approval rate

**Instruction Evolution** (see `INSTRUCTION_CHANGELOG.md`):
- All instruction files include version metadata
- Changes tracked with before/after metrics
- Rollback procedures documented
- A/B testing framework for instruction variants

**Quality Enhancement**:
- Multi-perspective review (standard + adversarial)
- Severity-tagged findings (BLOCKER, MAJOR, MINOR, NIT)
- Automated validation scripts and tests

**Process Metrics**:
- Run analytics weekly/monthly: `pwsh -File scripts/analyze-sessions.ps1 -StartDate (Get-Date).AddMonths(-1)`
- Compare metrics before/after instruction changes
- Document patterns in `docs/operations.md`
- Update escalation triggers based on data

**Contribution Updates**:
- Track instruction changes in `INSTRUCTION_CHANGELOG.md` with expected impact and metrics
- Update session metadata in `plans/sessions/` to enable analytics
- Include Mermaid diagrams in plans for complex architectures
