# Copilot Orchestrator Workspace Instructions

Multi-agent orchestration system with 22 specialized agents. See `AGENTS.md` for complete agent roster and lifecycle details.

## Architecture

```
.github/agents/      → Agent definitions (conductor, planner, implementer, reviewer, + 18 specialists)
.github/prompts/     → Prompt templates organized by workflow phase
instructions/        → Layered instructions (global → workflows → compliance → languages)
scripts/             → PowerShell 5.1 validation and tooling
artifacts/           → Local session outputs (plans, reviews, research, security)
```

## Core Workflow

**Lifecycle:** Conductor → Planner → Implementer → Reviewer → Completion

1. Start complex tasks in **Conductor**—it delegates to specialized subagents
2. Pause points are mandatory after plans and reviews (wait for human approval)
3. Use handoff buttons to move between agents, not manual switching
4. Persist outputs to `artifacts/` using templates from `docs/templates/`

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
    "chat.instructionsFilesLocations": ["instructions", ".github/instructions"],
    "chat.promptFilesLocations": [".github/prompts"],
    "chat.modeFilesLocations": [".github/agents", ".github/chatmodes"],
    "github.copilot.chat.tools.memory.enabled": true,
    "chat.customAgentInSubagent.enabled": true,
    "github.copilot.chat.customAgents.showOrganizationAndEnterpriseAgents": true,
    "github.copilot.chat.cli.customAgents.enabled": true,
    "chat.useClaudeSkills": true,
    "chat.useAgentSkills": false,
    "chat.agent.thinkingStyle": "collapsed",
    "chat.agent.thinking.collapsedTools": true,
    "chat.viewSessions.enabled": true,
    "chat.viewSessions.orientation": "sideBySide",
    "chat.viewRestorePreviousSession": false,
    "chat.tools.terminal.enableAutoApprove": true,
    "chat.tools.terminal.autoApproveWorkspaceNpmScripts": true,
    "chat.tools.terminal.preventShellHistory": true
}
```

**VS Code 1.108 Updates:**
- **Agent Sessions UI**: Keyboard navigation (↑↓ arrows, Enter, Delete, Space), session grouping (by state/age), multi-session archiving (Shift+Click, Ctrl+Click), changed files and PR display per session, Quick Open integration (`agent <name>`)
- **Session Persistence**: Added `chat.viewRestorePreviousSession` (default: `false`) to start with empty chat and prevent context leakage between tasks
- **Orientation**: Replaced deprecated `"auto"` with `"sideBySide"` for `chat.viewSessions.orientation` — enables session grouping features
- **Agent Skills**: Added `chat.useAgentSkills` (experimental, off by default; see Phase 6 pilot for on-demand loading evaluation)
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
| Premium | ~20% | Claude Sonnet 4.5, GPT-5, Gemini 2.5 Pro | Planning, review, research, security |
| Execution | ~80% | GPT-5 Mini, Claude Sonnet 4 | Implementation, testing, routine tasks |
| Ultra-Premium | <5% | Claude Opus 4.5 | Complex architecture, critical security reviews |

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
