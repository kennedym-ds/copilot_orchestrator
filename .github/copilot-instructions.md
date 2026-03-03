# Copilot Orchestrator Workspace Instructions

Multi-agent orchestration system with 28 specialized agents. See `AGENTS.md` for complete agent roster and lifecycle details.

**Central Persona:** All agents operate as a **Senior Principal Engineer** — understand the problem before solving it, prefer the simplest working solution, no hype, no bullshit. See `instructions/global/00_behavior.instructions.md` for the Zen of Engineering tenets that govern all output.

## Architecture

```
.github/agents/      → Agent definitions (conductor, planner, implementer, reviewer, spec, + 23 specialists)
.github/prompts/     → Prompt templates organized by workflow phase
instructions/        → Layered instructions (global → workflows → compliance → languages)
scripts/             → PowerShell 5.1 validation and tooling
scripts/mcp/         → MCP servers (8 servers: validation, analytics, github, research, design, translation, demo)
.vscode/mcp.json     → Workspace MCP server configuration (auto-discovered by VS Code)
artifacts/           → Local session outputs (plans, reviews, research, security)
```

## Core Workflow

**Lifecycle:** Conductor → Planner → Implementer → Reviewer → Completion

1. Start complex tasks in **Conductor**—it delegates to specialized subagents
2. Pause points are mandatory after plans and reviews (wait for human approval)
3. Conductor is the only agent with handoff buttons — all other agents delegate autonomously via `#runSubagent`
4. Agents use the `delegation-routing` skill for keyword-based routing patterns
5. Persist outputs to `artifacts/` using templates from `docs/templates/`

**State Tracking:** Every conductor response includes Current Phase, Plan Progress, Last Action, Next Action.

## Commands

```powershell
# Validation (run before PRs)
pwsh -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .
pwsh -File scripts/add-prompt-metadata.ps1 -RepositoryRoot . -CheckOnly
pwsh -File scripts/run-lint.ps1 -RepositoryRoot .
pwsh -File scripts/run-smoke-tests.ps1 -RepositoryRoot .

# Initialize artifacts folder (once per consuming repository)
pwsh -File scripts/init-artifacts.ps1

# Token budget report
pwsh -File scripts/token-report.ps1 -Path . -ConfigPath token-thresholds.json
```

## GitHub Release Publishing Guidance

- Treat release publishing as two separate steps:
    1. Push commit/tag via git.
    2. Create GitHub Release object and upload assets via GitHub API/UI/CLI.
- Do not assume a pushed tag is visible on the Releases page until a release object exists.
- For publish completion evidence, include:
    - Release URL
    - Asset count
    - Asset names and sizes

### Non-Interactive Fallback (Windows)

If `gh auth` is unavailable but git push/pull works:

1. Refresh PATH from Machine/User in the terminal session.
2. Read GitHub credential via `git credential fill` for `host=github.com`.
3. Create/fetch release by tag through GitHub REST API.
4. Upload installer/artifacts via `uploads.github.com` release-assets endpoint.
5. Verify URL and assets, then report non-sensitive results only.

Security: never expose token values in chat, logs, artifacts, or files.

## Task Suitability

**AI-appropriate:** Documentation updates, test authoring (TDD), bug fixes with clear repro steps, prompt/agent updates following patterns, PowerShell script enhancements.

**Human approval required:** Conductor workflow changes, security/compliance modifications, model allocation changes, new external dependencies.

## VS Code Settings

```json
{
    "chat.useAgentsMdFile": true,
    "chat.useNestedAgentsMdFiles": true,
    "chat.instructionsFilesLocations": ["instructions"],
    "chat.promptFilesLocations": [".github/prompts"],
    "chat.agentFilesLocations": { ".github/agents": true },
    "chat.agentSkillsLocations": { ".github/skills": true },
    "chat.useAgentSkills": true,
    "chat.useClaudeSkills": true,
    "chat.agentCustomizationSkill.enabled": true,
    "chat.customAgentInSubagent.enabled": true,
    "github.copilot.chat.searchSubagent.enabled": true,
    "github.copilot.chat.customAgents.showOrganizationAndEnterpriseAgents": true,
    "github.copilot.chat.cli.customAgents.enabled": true,
    "github.copilot.chat.organizationInstructions.enabled": true,
    "chat.thinking.style": "collapsed",
    "chat.agent.thinking.collapsedTools": true,
    "chat.agent.thinking.terminalTools": true,
    "chat.tools.autoExpandFailures": true,
    "chat.askQuestions.enabled": true,
    "chat.requestQueuing.enabled": true,
    "chat.requestQueuing.defaultAction": "steer",
    "chat.hooks.enabled": true,
    "github.copilot.chat.anthropic.thinking.budgetTokens": 10000,
    "github.copilot.chat.anthropic.toolSearchTool.enabled": true,
    "github.copilot.chat.anthropic.contextEditing.enabled": true,
    "github.copilot.chat.copilotMemory.enabled": true,
    "github.copilot.chat.advanced.workspace.codeSearchExternalIngest.enabled": true,
    "chat.viewSessions.enabled": true,
    "chat.viewSessions.orientation": "sideBySide",
    "chat.restoreLastPanelSession": false,
    "chat.agentsControl.enabled": true,
    "chat.agentsControl.clickBehavior": "cycle",
    "workbench.startupEditor": "agentSessionsWelcomePage",
    "github.copilot.chat.implementAgent.model": "Claude Sonnet 4.6 (copilot)",
    "chat.tools.terminal.enableAutoApprove": true,
    "chat.tools.terminal.autoApproveWorkspaceNpmScripts": true,
    "chat.tools.terminal.preventShellHistory": true,
    "terminal.integrated.enableKittyKeyboardProtocol": true,
    "workbench.browser.openLocalhostLinks": true,
    "simpleBrowser.useIntegratedBrowser": true,
    "git.worktreeIncludeFiles": [".env.local", "token-thresholds.json"]
}
```

> **Global access:** To use agents in any VS Code window, add the `*FilesLocations` settings to your **user** `settings.json` with tilde paths (e.g., `"~/Projects/copilot_orchestrator/.github/agents": true`). See `docs/guides/vscode-copilot-configuration.md` for full setup.
>
> **Deprecated settings:** `chat.modeFilesLocations` has been removed (use `chat.agentFilesLocations`). `chat.viewRestorePreviousSession` was renamed to `chat.restoreLastPanelSession` in 1.108.

**VS Code 1.109 Updates:**
- **Agent Skills GA**: `chat.useAgentSkills` now `true` by default; skills in `.github/skills/` load automatically. Configure paths with `chat.agentSkillsLocations`.
- **Agent Customization**: New `chat.agentFilesLocations` for custom agent search paths. Agent frontmatter supports `user-invokable`, `disable-model-invocation`, `agents` (subagent allowlist), and multiple model fallbacks.
- **Thinking Tokens**: Renamed `chat.agent.thinkingStyle` → `chat.thinking.style`. New `chat.agent.thinking.terminalTools` shows reasoning between tool calls. `chat.tools.autoExpandFailures` auto-expands failed tool calls.
- **Anthropic Enhancements**: Messages API with interleaved thinking (`github.copilot.chat.anthropic.thinking.budgetTokens`), tool search (`toolSearchTool.enabled`), context editing (`contextEditing.enabled`).
- **Ask Questions**: `chat.askQuestions.enabled` lets agents ask clarifying questions instead of assuming.
- **Agent Status**: `chat.agentsControl.enabled` shows session status indicator in command center. `clickBehavior: "cycle"` cycles chat view states.
- **Search Subagent**: `github.copilot.chat.searchSubagent.enabled` runs code search in isolated context window.
- **Copilot Memory**: `github.copilot.chat.copilotMemory.enabled` replaces legacy `tools.memory.enabled` — stores/recalls info across sessions.
- **External Indexing**: `github.copilot.chat.advanced.workspace.codeSearchExternalIngest.enabled` enables remote indexing for non-GitHub workspaces.
- **Welcome Page**: `workbench.startupEditor: "agentSessionsWelcomePage"` surfaces agent sessions on startup.
- **Plan Agent**: `/plan` command with 4-phase workflow. `github.copilot.chat.implementAgent.model` sets default model for implementation step.
- **Integrated Browser**: `workbench.browser.openLocalhostLinks` + `simpleBrowser.useIntegratedBrowser` for in-editor browsing with DevTools.
- **Claude Agent**: New Claude Agent session type using Anthropic's agent SDK (Preview).
- **MCP Apps**: Interactive UI from MCP servers rendered directly in chat.
- **Organization Instructions**: `github.copilot.chat.organizationInstructions.enabled` auto-applies org-level instructions.
- **Kitty Keyboard**: `terminal.integrated.enableKittyKeyboardProtocol` fixes key handling in terminal apps (shift+enter in agentic CLIs).
- **Git Worktrees**: `git.worktreeIncludeFiles` copies specified files to worktrees for background agents.
- **Parallel Subagents**: Subagents now run in parallel for independent tasks, plus handoffs support `model` parameter.

**VS Code 1.108 Updates:**
- **Agent Sessions UI**: Keyboard navigation (↑↓ arrows, Enter, Delete, Space), session grouping (by state/age), multi-session archiving (Shift+Click, Ctrl+Click), changed files and PR display per session, Quick Open integration (`agent <name>`)
- **Session Persistence**: `chat.restoreLastPanelSession` (default: `false`) starts with empty chat and prevents context leakage between tasks (renamed from `chat.viewRestorePreviousSession` in 1.108)
- **Orientation**: Replaced deprecated `"auto"` with `"sideBySide"` for `chat.viewSessions.orientation` — enables session grouping features
- **Agent Skills**: `chat.useAgentSkills` is now GA and enabled by default (was experimental in 1.108; see Phase 6 pilot for on-demand loading evaluation)
- **Terminal Auto-Approve**: Added `enableAutoApprove`, `autoApproveWorkspaceNpmScripts`, `preventShellHistory` for safer command execution with reduced prompts

## Artifact Storage

Agents persist outputs to local `artifacts/` folder (14 subfolders):

| Folder | Agents | Content |
|--------|--------|---------|
| `plans/` | Conductor, Planner, Implementer | Implementation plans, phase completions |
| `reviews/` | Reviewer | Code review verdicts, findings |
| `research/` | Researcher | Research briefs, citations |
| `security/` | Security | Threat assessments, audit reports |
| `sessions/` | Conductor | Session state for resume/continuity |
| `performance/` | Performance | Profiling reports, optimization recs |
| `docs/` | Docs | Documentation drafts, reviews |
| `releases/` | Maintainer | Release notes, triage reports |
| `telemetry/` | Observability | Metrics analysis, platform reports |
| `deployments/` | Deployment | Deployment plans, runbooks |
| `red-team/` | Red Team | Adversarial analysis, exploit reports |
| `accessibility/` | Accessibility | WCAG audits, a11y findings |
| `tests/` | Test | Test reports, coverage analysis |
| `ux/` | Visualizer | UX reviews, design artifacts |

Run `init-artifacts.ps1` to create the structure.

## Model Allocation

Agents use a five-tier model strategy to balance cost and capability:

| Tier | Allocation | Models | Use Cases |
|------|------------|--------|-----------|
| Orchestration | ~15% | Claude Opus 4.6, Claude Sonnet 4.6 | Planning, coordination, extended reasoning |
| Security | ~10% | Claude Opus 4.6, Claude Sonnet 4.6 | Threat modeling, adversarial testing, compliance |
| Research | ~10% | Gemini 3.1 Pro (Preview), Claude Opus 4.6 | Context gathering, evidence synthesis, analysis |
| Coding | ~50% | GPT-5.3-Codex, Claude Sonnet 4.6 | Implementation, testing, review, IaC, support |
| Documentation | ~15% | Claude Sonnet 4.6, Claude Haiku 4.5 | Docs, linting, UX review, design artifacts |

See `instructions/global/03_model-selection.instructions.md` for fallback chains and governance rules.

## Data Science Workflow (DS-Star)

For data analysis queries, the Conductor orchestrates an iterative DS-Star workflow using the Researcher, Planner, and Implementer agents:

1. Conductor detects data science query → delegates to Researcher for context gathering
2. Planner designs iterative analysis approach with success criteria
3. Implementer executes analysis rounds (max 10 rounds, 30-min timeout)
4. Each round produces a verdict: INSUFFICIENT, PARTIAL, or SUFFICIENT
5. On SUFFICIENT → Docs agent creates final deliverables
6. State persisted to `artifacts/sessions/pipeline_state.json` for resume

**Trigger phrases:** "analyze data", "what factors drive", "correlation between", "predict", "forecast"

## Key References

- `AGENTS.md` — Agent roster, lifecycle, model allocation, safety guardrails
- `docs/guides/onboarding.md` — New contributor setup
- `docs/templates/` — Plan, phase-complete, and plan-complete templates
- `docs/operations.md` — Backlog and incident tracking
- `INSTRUCTION_CHANGELOG.md` — Instruction change history
- `docs/guides/mcp-integration.md` — MCP server setup, agent mapping, protocol features
- `.vscode/mcp.json` — Workspace MCP configuration (8 servers)
