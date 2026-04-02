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

VS Code 1.114 builds on 1.113, streamlining the chat experience with simplified workspace search, video carousel support, cross-session troubleshooting, and a Copy Final Response command.

### Key Features (1.108–1.114)
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

### VS Code 1.110 Agent Controls
- **Agent Debug Panel**: `Developer: Open Agent Debug Panel` replaces old Chat Diagnostics action — shows loaded agents, instructions, skills, prompts, and MCP servers
- **Slash Commands for Auto-Approve**: `/autoApprove` and `/disableAutoApprove` (aliases: `/yolo`, `/disableYolo`) toggle tool auto-approval from chat
- **Ask Questions Core**: Ask questions tool moved into VS Code core (from Anthropic-specific), with steering/queuing support
- **Anti-Suspend**: VS Code prevents OS from suspending the machine while a chat response is in progress
- **Edit Mode Deprecated**: `chat.editMode.hidden` (default `true`) hides Edit mode from mode picker; will be removed in 1.125. Agent mode replaces Edit mode.

### VS Code 1.110 Agent Extensibility
- **Agent Plugins (Experimental)**: `chat.plugins.enabled` enables installable bundles of skills, tools, and hooks from Extensions view. Configure with `chat.plugins.marketplaces` and `chat.plugins.paths`.
- **Agentic Browser Tools (Experimental)**: `workbench.browser.enableChatTools` gives agents full browser control (`openBrowserPage`, `navigatePage`, `readPage`, `screenshotPage`, `clickElement`, `hoverElement`, `dragElement`, `typeInPage`, `handleDialog`, `runPlaywrightCode`)
- **Create Agent Customizations**: `/create-prompt`, `/create-instruction`, `/create-skill`, `/create-agent`, `/create-hook` slash commands for scaffolding customization files
- **Usages & Rename Tools**: `usages` tool updated, `rename` tool added — LSP-aware refactoring now available to agents

### VS Code 1.110 Smarter Sessions
- **Session Memory for Plans**: Plans persist to session memory across turns, surviving context compaction
- **Context Compaction**: `/compact` command with optional custom instructions for manual context window control. Background/Claude agents also support compaction.
- **Explore Subagent**: Plan agent delegates codebase research to Explore subagent (read-only, fast model). `chat.exploreAgent.defaultModel` sets the model.
- **Inline Chat Session Sync**: Inline chat queues into active agent sessions instead of running independently
- **Session Forking**: `/fork` creates an independent session branch with inherited history — explore alternatives without losing context

### VS Code 1.110 Chat Experience
- **Collapsible Terminal**: `chat.tools.terminal.simpleCollapsible` collapses terminal tool calls for reduced visual noise
- **Terminal Sandboxing (Preview)**: `chat.tools.terminal.sandbox.enabled` restricts agent terminal access (filesystem, network)
- **OS Notifications**: `chat.notifyWindowOnResponseReceived` and `chat.notifyWindowOnConfirmation` — set to `"always"` for long-running agent tasks
- **Inline Chat Modes**: `inlineChat.affordance` changed from boolean to enum (`"off"`, `"editor"`, `"gutter"`). `inlineChat.renderMode` adds hover-based UI.
- **Kitty Graphics Protocol**: `terminal.integrated.enableImages` enables GPU-accelerated image rendering in the integrated terminal
- **AI Co-Author**: `git.addAICoAuthor` adds Copilot as co-author in commit messages (`"off"`, `"chatAndAgent"`, `"all"`)
- **Contextual Tips**: `chat.tips.enabled` shows contextual tips for agent features and workflows
- **Notification Position**: `workbench.notifications.position` — set to `"bottom-left"` to avoid overlapping Chat view

### VS Code 1.111 Agent Autonomy
- **Agent Permissions Picker** (Preview): Three autonomy levels per session via new permissions picker in Chat view:
  - *Default Approvals:* Standard configured approval settings (prompts for authorization)
  - *Bypass Approvals:* Auto-approves all tool calls without confirmation dialogs, auto-retries errors
  - *Autopilot (Preview):* Agent works autonomously until `task_complete` — auto-approves tools, auto-retries errors, auto-responds to `askQuestions`. Setting: `chat.autopilot.enabled`
- **Agent-Scoped Hooks** (Preview): `hooks` section in `.agent.md` frontmatter for per-agent pre/post-processing logic. Setting: `chat.useCustomAgentHooks`
- **Debug Events Snapshot**: `#debugEventsSnapshot` context attachment passes token consumption, loaded customizations, and state into chat for agent self-diagnosis
- **`task_complete` Tool**: Required for Autopilot mode — agents must explicitly signal task completion
- **AI Terminal Profile Grouping** (Experimental): `terminal.integrated.experimental.aiProfileGrouping` groups AI CLI profiles at top of terminal dropdown
- **Search Subagent Improvements**: Search results exempted from disk writes; token usage reporting refined to avoid context widget spam
- **Session-Specific Autonomy**: Permissions picker applies per-session; step up or down mid-session
- **Improved Tips**: Overhauled onboarding tips surface foundational features first; `/fork` and `/init` actively promoted

### VS Code 1.112 Agent Diagnostics
- **`/troubleshoot` Skill (Preview)**: Analyzes agent debug logs in-chat to diagnose why tools, subagents, instructions, or skills weren’t applied. Requires `github.copilot.chat.agentDebugLog.enabled` and `github.copilot.chat.agentDebugLog.fileLogging.enabled`
- **Debug Log Export/Import**: Export and import JSONL debug logs for sharing and offline analysis. Import warns for files >50 MB
- **Image & Binary File Support**: Agents can read image files from disk and binary files (hexdump format). Image carousel view (`chat.imageCarousel.enabled`) for agent-generated images
- **Automatic Symbol References**: Pasting copied symbol names in chat auto-converts to `#sym:Name` references for richer context
- **Copilot CLI Permissions**: Autopilot, Bypass Approvals, and Default Permissions now available for Copilot CLI sessions
- **Copilot CLI Message Steering**: Steering and queueing messages extended to Copilot CLI sessions
- **Copilot CLI Pending Changes Preview**: Chat view shows uncommitted changes when delegating to Copilot CLI
- **Copilot CLI File Links**: Terminal link detection for `~/.copilot/session-state/` paths (`github.copilot.chat.cli.terminalLinks.enabled`)

### VS Code 1.112 Agent Extensibility
- **Monorepo Customizations Discovery**: `chat.useCustomizationsInParentRepositories` discovers agents, instructions, skills, and hooks from parent Git repositories when opening a subfolder
- **MCP Server Sandboxing**: `"sandboxEnabled": true` in `mcp.json` restricts file system and network access for stdio MCP servers (macOS/Linux only; not available on Windows)
- **Improved MCP Elicitation UI**: Elicitation forms now use the same UI as the Ask Questions tool for consistency
- **Plugin & MCP Enable/Disable**: Plugins and MCP servers can be enabled/disabled globally and per-workspace without uninstalling
- **Automatic Plugin Updates**: Plugins auto-update via `extensions.autoUpdate` setting; npm/pypi plugins require approval

### VS Code 1.112 Developer Experience
- **Integrated Browser Debugging**: New `editor-browser` debug type for debugging web apps in the integrated browser with Launch/Attach configurations
- **Integrated Browser UX**: Context menus, independent zoom level (`workbench.browser.pageZoom`), per-site zoom memory

### VS Code 1.113 Agent Experience
- **Nested Subagents**: `chat.subagents.allowInvocationsFromSubagents` enables subagents to invoke other subagents (max depth 5). Implementer can directly invoke test/lint; reviewer can directly invoke security/red-team without conductor relay.
- **Configurable Thinking Effort**: Model picker exposes Low/Medium/High effort submenu for reasoning models. Controls thinking token budget per request. Effort level persists per-model across conversations. Replaces deprecated `github.copilot.chat.anthropic.thinking.effort` and `github.copilot.chat.responsesApiReasoningEffort` settings.
- **MCP in Copilot CLI & Claude Agents**: MCP servers configured in VS Code now bridge to Copilot CLI and Claude agent sessions. All 8 workspace MCP servers are available in CLI sessions.
- **Chat Customizations Editor** (Preview): Centralized UI for managing all chat customizations (instructions, prompts, agents, skills). Open via Configure Chat gear icon or `Chat: Open Chat Customizations`.
- **Session Forking in CLI & Claude Agents**: `/fork` now available in Copilot CLI and Claude agent sessions. Setting: `github.copilot.chat.cli.forkSessions.enabled`.
- **Agent Debug Logs for CLI**: Agent Debug Log panel now works for Copilot CLI and Claude agent sessions.
- **Claude Session Listing via SDK**: VS Code adopts official Claude agent SDK APIs for session and message listing, replacing JSONL file parsing.
- **Plugin Marketplace Management**: `Chat: Manage Plugin Marketplaces` command for browsing, opening, and removing plugin sources.
- **Plugin URL Handlers**: Install plugins via `vscode://chat-plugin/install?source=<source>` URLs.
- **Images Preview**: Full image viewer for chat attachments with navigation, zoom, and pan. Settings: `imageCarousel.chat.enabled`, `imageCarousel.explorerContextMenu.enabled`.
- **New Default Themes**: "VS Code Light" and "VS Code Dark" replace the previous Modern themes.

### VS Code 1.113 Cost Optimization
- **5-Branch Cost Structure**: Thinking effort layered onto the 3-tier model allocation creates 5 effective cost branches: Premium-High, Premium-Medium, Execution-Medium, Execution-Low, Routine-None. See `instructions/global/03_model-selection.instructions.md`.
- **Effort Before Escalation**: New Tier 0.5 escalation pattern — increase thinking effort before switching model tiers. See `instructions/workflows/escalation-patterns.instructions.md`.
- **Effort-Weighted Budget Tracking**: Budget gatekeeper now tracks effort distribution and uses effort-weighted token estimates. See `budget-gatekeeper` skill.

### VS Code 1.114 Chat Streamlining
- **Workspace Search Simplification**: `#codebase` is now purely semantic search — no more fuzzy text fallback. Local/remote index distinction removed; indexing is automatic. Agents get faster, more consistent context.
- **Video Carousel**: Image carousel (`imageCarousel.chat.enabled`, `imageCarousel.explorerContextMenu.enabled`) now supports video playback with controls and thumbnail navigation.
- **Copy Final Response**: New context menu command copies only the final Markdown section of an agent response (excludes thinking/tool calls). Useful for sharing conductor deliverables.
- **Troubleshoot Previous Sessions**: `/troubleshoot` + `#session` can reference any previous chat session for post-hoc diagnosis. Also available via `+` (Add Context) > Sessions.

### VS Code 1.114 Enterprise & Ecosystem
- **Claude Agent Group Policy**: Administrators can disable Claude agent integration via `Claude3PIntegration` group policy key. Setting: `github.copilot.chat.claudeAgent.enabled`.
- **Fine-grained Tool Approval (Proposed API)**: `approveCombination` property on `LanguageModelToolConfirmationMessages` scopes approval to specific argument combinations — e.g., approving `formatDocument` without approving all VS Code commands.
- **TypeScript 6.0**: Built-in TypeScript support upgraded; deprecates older options ahead of TypeScript 7.0 native rewrite.
- **MCP Env Var Resolution Fix**: Environment variables in agent plugin MCP server definitions now resolve correctly.

### Workflow Best Practices
- Start each conductor task in a new session with a descriptive prompt
- Keep session active through all phases (Planning → Implementation → Review)
- Mark session as Read after reviewing phase-complete.md artifacts
- Archive session after plan-complete.md and final validation
- Use session grouping (by State) to track multiple parallel workflows
- Set `chat.restoreLastPanelSession: false` to prevent context leakage between projects
- Use `/compact` to manage context window during long sessions
- Use `/fork` to explore alternative approaches without losing the main thread

### Documentation
See [docs/guides/vscode-copilot-configuration.md](docs/guides/vscode-copilot-configuration.md) for complete Agent Sessions UI guide including keyboard shortcuts, grouping modes, troubleshooting, and conductor integration patterns.

---

## Agent Roster (29 Agents)

### Core Workflow

| Agent | File | Purpose |
|-------|------|---------|
| Conductor | `conductor.agent.md` | Lifecycle orchestration, pause points, delegation |
| Planner | `planner.agent.md` | Multi-phase planning, research, risk analysis |
| Implementer | `implementer.agent.md` | TDD execution, validation logging |
| Reviewer | `reviewer.agent.md` | Severity-tagged findings, quality gates |
| Researcher | `researcher.agent.md` | Context gathering, source citation |
| Maintainer | `maintainer.agent.md` | Issue triage, release coordination |
| Spec | `spec.agent.md` | Project specification, requirements elicitation |

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
| GUI Tester | `gui-tester.agent.md` | Browser automation, visual regression, interaction testing |
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
