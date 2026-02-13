# Copilot Orchestrator Workspace Instructions

Multi-agent orchestration system with 26 specialized agents. See `AGENTS.md` for complete agent roster and lifecycle details.

## Architecture

```
.github/agents/      → Agent definitions (conductor, planner, implementer, reviewer, + 23 specialists)
.github/prompts/     → Prompt templates organized by workflow phase
instructions/        → Layered instructions (global → workflows → compliance → languages)
scripts/             → PowerShell 5.1 validation and tooling
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
    "github.copilot.chat.implementAgent.model": "Codex 5.2 (copilot)",
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

Agents use a tiered model strategy to balance cost and capability:

| Tier | Allocation | Models | Use Cases |
|------|------------|--------|-----------|
| Premium | ~20% | Claude Opus 4.6, Codex 5.2 | Planning, review, research, security, orchestration |
| Execution | ~70% | GPT-5.3-Codex, Gemini 3 Pro, Codex 5.2 | Implementation, testing, analysis, support |
| Routine | ~10% | Claude Haiku 4.5, Gemini 3 Flash | Documentation, linting, routine tasks |

See `instructions/global/03_model-selection.instructions.md` for fallback chains and governance rules.

## Data Science Workflow (DS-Star)

For data analysis queries, the Conductor routes to the **Data Analytics** agent using the DS-Star iterative workflow:

1. Conductor detects data science query → delegates to `data-analytics` agent
2. Data Analytics executes iterative rounds (max 10, 30-min timeout)
3. Each round produces a verdict: INSUFFICIENT, PARTIAL, or SUFFICIENT
4. On SUFFICIENT → Documentation handoff for final deliverables
5. State persisted to `artifacts/sessions/pipeline_state.json` for resume

**Trigger phrases:** "analyze data", "what factors drive", "correlation between", "predict", "forecast"

## Key References

- `AGENTS.md` — Agent roster, lifecycle, model allocation, safety guardrails
- `docs/guides/onboarding.md` — New contributor setup
- `docs/templates/` — Plan, phase-complete, and plan-complete templates
- `docs/operations.md` — Backlog and incident tracking
- `INSTRUCTION_CHANGELOG.md` — Instruction change history
