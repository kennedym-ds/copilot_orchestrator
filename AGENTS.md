# Copilot Orchestrator — Agent Playbook

This repository implements a multi-agent orchestration pattern for GitHub Copilot. It provides the source of truth for agent definitions, prompts, instructions, and validation tooling.

> **Status:** Stable. Follow the guardrails below and log issues in `docs/operations.md`.

---

## Mission & Architecture

**Central Persona:** Every agent in this system operates as a **Senior Principal Engineer** — pragmatic, no-hype, no-bullshit. Understand the problem before solving it. Simple is maintainable, extendable, and understandable. Complexity must justify itself. See `instructions/global/00_behavior.instructions.md` for the full Zen of Engineering tenets.

- Progress tasks through a structured lifecycle: **Planning → Implementation → Review → Completion**
- Persist artifacts locally in the `artifacts/` folder of each consuming repository
- Maintain pause points after plan creation and after each review for human approval
- Use context-isolated subagents via `#runSubagent` for specialized work

### Delegation Model

Agents delegate work autonomously using `#runSubagent` with keyword-based routing patterns defined in the `delegation-routing` skill (`.github/skills/delegation-routing/SKILL.md`).

- **Conductor** is the only agent with UI handoff buttons — it serves as the single user-facing entry point
- All other agents delegate via `#runSubagent` instructions in their `## Delegation` body section
- Routing decisions are guided by keyword patterns, model preferences, and invocation guardrails
- Agents with `user-invokable: false` (security, performance, observability, red-team) are reachable only via `#runSubagent`
- Translation sub-agents with `disable-model-invocation: true` are invoked only by their designated parent

### Supporting Documentation

| Document | Purpose |
|----------|---------|
| `docs/workflows/orchestration-rebuild-plan.md` | Strategy, success metrics, roadmap |
| `docs/workflows/new-workspace-blueprint.md` | Repository layout, model allocation |
| `docs/guides/central-deployment.md` | Org-level deployment with local artifacts || `docs/guides/background-agents-worktrees.md` | Parallel execution with Git worktrees |
| `docs/guides/claude-skills-migration.md` | Converting prompts to Claude skills || `docs/operations.md` | Monitoring, backlog, incident process |
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
| Setup Claude Code | `pwsh -File scripts/setup-claude-code.ps1 -Mode Project -TargetPath .` |
| Setup VS / CLI | `pwsh -File scripts/setup-vs-cli.ps1 -Strategy Symlink -TargetPath .` |
| Setup Antigravity | `pwsh -File scripts/setup-antigravity.ps1 -Mode Project -TargetPath .` |

**Shell**: Windows PowerShell 5.1. Use `;` when chaining commands. Prefer cmdlets over aliases.

**Cross-Platform**: For macOS/Linux, use the `.sh` equivalents: `setup-claude-code.sh`, `setup-vs-cli.sh`, `setup-antigravity.sh`. See `docs/guides/multi-platform-setup.md`.

---

## Agent Sessions Integration

VS Code 1.109 builds on the Agent Sessions UI introduced in 1.108, adding multi-environment delegation, parallel subagents, and agent status indicators.

### Key Features (1.108–1.109)
- **Keyboard Navigation**: Navigate sessions with arrow keys, archive with Delete, toggle read state with Space
- **Session Grouping**: Organize by state (Active, Unread, Read, Archived) or age (Today, Yesterday, This Week, etc.)
- **Multi-Session Operations**: Shift+Click/Ctrl+Click for batch archiving and state changes
- **Changed Files Display**: See all files modified during each conductor workflow
- **PR Integration**: View linked pull requests and their status directly in session list
- **Quick Open**: Access sessions via `agent <name>` in Quick Open (Ctrl+P)
- **Session Type Picker** (1.109): Switch between local, background, cloud, and Claude Agent sessions from a unified picker
- **Agent Status Indicator** (1.109): Command center badge showing in-progress, unread, and attention-needed sessions (`chat.agentsControl.enabled`)
- **Agent Sessions Welcome Page** (1.109): Startup editor surfacing recent sessions (`workbench.startupEditor: "agentSessionsWelcomePage"`)
- **Parallel Subagents** (1.109): Independent subtasks run in parallel across multiple subagents with full visibility

### VS Code 1.109 Agent Customization
- **Agent Skills GA**: Skills in `.github/skills/` load automatically; `chat.useAgentSkills` is now `true` by default
- **Multiple Model Fallbacks**: Agent frontmatter `model` accepts arrays — first available model is used
- **Invocation Control**: New frontmatter attributes `user-invokable`, `disable-model-invocation`, and `agents` (subagent allowlist)
- **Handoff Model Parameter**: Specify `model` in handoff definitions for per-handoff model selection
- **Organization Instructions**: Org-level custom instructions auto-applied (`github.copilot.chat.organizationInstructions.enabled`)
- **Agent Customization Skill**: Built-in skill teaches AI about creating agents/instructions/prompts/skills
- **Custom Agent File Locations**: `chat.agentFilesLocations` setting for additional agent search paths
- **Chat Diagnostics**: Right-click in Chat → Diagnostics to see all loaded agents, prompts, instructions, and skills
- **`/init` Command**: Auto-generates workspace instructions based on codebase analysis
- **`/plan` Command**: 4-phase workflow (Discovery → Alignment → Design → Refinement) with ask-questions integration

### VS Code 1.109 Agent Extensibility
- **Claude Agent (Preview)**: New session type using Anthropic's agent SDK
- **MCP Apps**: Interactive UI from MCP servers rendered directly in chat
- **MCP Resources & Prompts**: Servers expose queryable context (resources) and reusable templates (prompts) via `@mcp.resource()` and `@mcp.prompt()` decorators
- **MCP Tool Annotations**: Tools carry behavioral hints (`readOnlyHint`, `destructiveHint`, `idempotentHint`) for auto-approval and risk display
- **MCP Elicitation**: Servers can pause execution and present forms to the user via `ctx.elicit()`
- **MCP Progress Reporting**: Tools report live progress via `ctx.report_progress()` — VS Code shows a progress bar
- **Remote MCP (HTTP)**: Servers can run as hosted HTTP endpoints with OAuth authentication (e.g., `https://api.githubcopilot.com/mcp/`)
- **Search Subagent**: Iterative code search in isolated context window (`github.copilot.chat.searchSubagent.enabled`)
- **Copilot Memory**: Stores and recalls info across sessions (`github.copilot.chat.copilotMemory.enabled`)
- **External Indexing**: Non-GitHub workspaces remotely indexed for fast code search
- **Anthropic Enhancements**: Messages API with interleaved thinking, tool search tool, context editing

### Workflow Best Practices
- Start each conductor task in a new session with a descriptive prompt
- Keep session active through all phases (Planning → Implementation → Review)
- Mark session as Read after reviewing phase-complete.md artifacts
- Archive session after plan-complete.md and final validation
- Use session grouping (by State) to track multiple parallel workflows
- Set `chat.restoreLastPanelSession: false` to prevent context leakage between projects

### Documentation
See [docs/guides/vscode-copilot-configuration.md](docs/guides/vscode-copilot-configuration.md) for complete Agent Sessions UI guide including keyboard shortcuts, grouping modes, troubleshooting, and conductor integration patterns.

---

## Agent Roster (27 Agents)

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
| Deployment | `deployment.agent.md` | CI/CD review, release readiness |
| Red Team | `red-team.agent.md` | Adversarial testing, edge cases |

### Translation Workflow

| Agent | File | Purpose |
|-------|------|---------|
| Translation Conductor | `translation-conductor.agent.md` | Full-repo translation orchestration, 6-phase lifecycle |
| Translator | `translator.agent.md` | File-level code translation with pattern mapping |
| Translation Analyzer | `translation-analyzer.agent.md` | Dependency graph, manifest, complexity assessment |
| Translation Validator | `translation-validator.agent.md` | 6-layer validation stack, confidence scoring |
| Translation Styler | `translation-styler.agent.md` | Target language idioms and conventions |

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
| Rubber Duck | `rubber-duck.agent.md` | Socratic problem-solving, guided debugging |

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
├── ux/             # Visualizer
├── decisions/      # Architectural Decision Records (ADRs)
├── memory/         # Active context and session memory
├── artifact-index.md  # Auto-generated inventory
└── .archive/       # Rolled-off artifacts past TTL
```

Initialize with: `pwsh -File scripts/init-artifacts.ps1`

### Memory Lifecycle

Artifacts follow a three-tier retention model managed by `scripts/cleanup-artifacts.ps1`:

| Tier | Default TTL | Action at TTL | Examples |
|------|-------------|---------------|----------|
| **Permanent** | Never | Never archived | ADRs, compliance audits |
| **Seasonal** | 90 days | Compact at 75%, archive at 100% | Plans, research, reviews |
| **Ephemeral** | 14 days | Delete at 100% | Session logs, activeContext.md |

Set retention via YAML frontmatter (`retention:`, `ttl-days:`). See the `memory-management` skill for full details.

**Session read-back:** Conductor reads `artifact-index.md` + `memory/activeContext.md` at session start.
**Session write-back:** Conductor updates `memory/activeContext.md` at pause points and session end.
**Cleanup:** `powershell -File scripts/cleanup-artifacts.ps1 -DryRun` to preview, without `-DryRun` to execute.

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
- Targets: ≤25% Opus-tier usage (orchestration + security), ≥90% review approval rate

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
