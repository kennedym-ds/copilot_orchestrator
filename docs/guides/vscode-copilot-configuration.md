---
title: "VS Code Copilot Configuration"
version: "0.7.0"
lastUpdated: "2026-02-06"
status: stable
---

## Purpose
This guide shows how to configure VS Code so the Copilot Orchestrator agents, skills, instructions, and prompts are available in your workspace — and optionally in **every VS Code window** you open.

## Prerequisites
- VS Code 1.109 or later (stable channel supports all features including Agent Skills GA, parallel subagents, agent status indicator, and Claude Agent sessions).
- Local clone of the `copilot_orchestrator` repository.
- GitHub Copilot subscription (Individual, Business, or Enterprise).

## Understanding Settings Scope

VS Code settings exist at two levels, and choosing the right one determines where your agents are available:

| Scope | File Location | When to Use |
|-------|--------------|-------------|
| **User (global)** | `Ctrl+Shift+P` → "Open User Settings (JSON)" | Agents available in **every** VS Code window |
| **Workspace** | `.vscode/settings.json` in the repo | Agents available only when **this repo is open** |

**Key insight:** Agents defined via workspace-relative paths (e.g., `.github/agents`) only load when that workspace is open. To make agents available globally (in any window, even without this repo open), use **user-level settings with tilde paths**.

### Tilde Path Notation

User-level settings require paths that resolve regardless of workspace. Use `~` (tilde) notation instead of absolute Windows paths:

| Pattern | Example |
|---------|---------|
| **Tilde (recommended)** | `~/OneDrive/Documents/Projects/copilot_orchestrator/.github/agents` |
| **Absolute (avoid)** | `C:\\Users\\Micha\\OneDrive\\Documents\\Projects\\copilot_orchestrator\\.github\\agents` |

VS Code expands `~` to your user home directory (`%USERPROFILE%` on Windows, `$HOME` on macOS/Linux). Tilde paths are portable across machines and avoid issues with backslash escaping.

> **OneDrive users:** If your files are cloud-only (on-demand), agents may fail to load. Right-click the `.github` folder in File Explorer → **Always keep on this device**.

## Setup: User-Level Settings (Global Agents)

Use this configuration to make all 22 orchestrator agents available in **any VS Code window**, even when the copilot_orchestrator repo is not open.

1. Open **User Settings (JSON)**: `Ctrl+Shift+P` → "Preferences: Open User Settings (JSON)"
2. Add the following settings (adjust the tilde path to match your repo location):

   ```json
   {
     "chat.useAgentsMdFile": true,
     "chat.useNestedAgentsMdFiles": true,

     "chat.agentFilesLocations": {
       "~/OneDrive/Documents/Projects/copilot_orchestrator/.github/agents": true
     },
     "chat.agentSkillsLocations": {
       "~/OneDrive/Documents/Projects/copilot_orchestrator/.github/skills": true
     },
     "chat.instructionsFilesLocations": {
       "~/OneDrive/Documents/Projects/copilot_orchestrator/instructions": true
     },
     "chat.promptFilesLocations": {
       "~/OneDrive/Documents/Projects/copilot_orchestrator/.github/prompts": true
     },

     "chat.useAgentSkills": true,
     "chat.agentCustomizationSkill.enabled": true,
     "chat.customAgentInSubagent.enabled": true,
     "chat.askQuestions.enabled": true,
     "github.copilot.chat.copilotMemory.enabled": true,
     "github.copilot.chat.searchSubagent.enabled": true,
     "github.copilot.chat.organizationInstructions.enabled": true,
     "github.copilot.chat.customAgents.showOrganizationAndEnterpriseAgents": true,
     "github.copilot.chat.cli.customAgents.enabled": true,
     "github.copilot.chat.implementAgent.model": "Claude Sonnet 4.6 (copilot)",
     "github.copilot.chat.advanced.workspace.codeSearchExternalIngest.enabled": true,

     "chat.thinking.style": "collapsed",
     "chat.agent.thinking.collapsedTools": true,
     "chat.agent.thinking.terminalTools": true,
     "chat.tools.autoExpandFailures": true,
     "github.copilot.chat.anthropic.thinking.budgetTokens": 10000,
     "github.copilot.chat.anthropic.toolSearchTool.enabled": true,
     "github.copilot.chat.anthropic.contextEditing.enabled": true,

     "chat.viewSessions.enabled": true,
     "chat.viewSessions.orientation": "sideBySide",
     "chat.restoreLastPanelSession": false,
     "chat.agentsControl.enabled": true,
     "chat.agentsControl.clickBehavior": "cycle",
     "workbench.startupEditor": "agentSessionsWelcomePage",

     "chat.tools.terminal.enableAutoApprove": true,
     "chat.tools.terminal.autoApproveWorkspaceNpmScripts": true,
     "chat.tools.terminal.preventShellHistory": true,
     "terminal.integrated.enableKittyKeyboardProtocol": true,
     "workbench.browser.openLocalhostLinks": true,
     "simpleBrowser.useIntegratedBrowser": true,
     "git.worktreeIncludeFiles": [".env.local", "token-thresholds.json"]
   }
   ```

3. Reload VS Code: `Ctrl+Shift+P` → "Developer: Reload Window"
4. Verify agents loaded: Right-click in Chat → **Diagnostics** — all 27 agents should appear

> VS Code silently skips any tilde paths that don't resolve to existing directories, making it safe to reuse this block across machines.

## Setup: Workspace-Level Settings (Repo-Scoped)

Use this when you only need agents available while the copilot_orchestrator repo is open. Create `.vscode/settings.json` in the repo root:

   ```json
   {
     "chat.instructionsFilesLocations": {
       "instructions": true
     },
     "chat.promptFilesLocations": {
       ".github/prompts": true
     },
     "chat.agentFilesLocations": {
       ".github/agents": true
     },
     "chat.agentSkillsLocations": {
       ".github/skills": true
     },
     "chat.useAgentSkills": true,
     "chat.agentCustomizationSkill.enabled": true,
     "github.copilot.chat.copilotMemory.enabled": true
   }
   ```

Workspace settings layer on top of user settings. If you have user-level global paths, workspace-level relative paths will also be merged in.

## Troubleshooting Agent Availability

| Symptom | Cause | Fix |
|---------|-------|-----|
| Agents missing in new window | Paths are workspace-relative only | Add user-level settings with tilde paths (see above) |
| Agents missing despite user settings | OneDrive files are cloud-only | Right-click folder → "Always keep on this device" |
| Agents missing after VS Code update | Settings renamed | Check for deprecated settings (see below) |
| Some agents load, others don't | Workspace trust not granted | Accept trust prompt for the external path |
| `chat.modeFilesLocations` warning | Setting is deprecated | Remove it; use `chat.agentFilesLocations` instead |
| `chat.viewRestorePreviousSession` warning | Setting renamed in 1.108 | Replace with `chat.restoreLastPanelSession` |

**Diagnostics:** Right-click in Chat panel → **Diagnostics** to see all loaded agents, prompts, instructions, and skills with their resolved paths.

## VS Code 1.109 Features

### Agent Skills (GA)
**Setting:** `chat.useAgentSkills` (default: `true` — now GA)

Agent Skills are now generally available in VS Code 1.109. Skills in `.github/skills/` load automatically when relevant. Configure search paths with `chat.agentSkillsLocations`. The built-in Agent Customization Skill (`chat.agentCustomizationSkill.enabled`) teaches the AI about creating agents, instructions, prompts, and skills.

### Multiple Model Fallbacks
Agent frontmatter now accepts `model` as an array. The first available model is used, providing automatic fallback:

```yaml
model: ['Claude Opus 4.6 (copilot)', 'Claude Sonnet 4.6 (copilot)']
```

All 27 agents in this repo now use model fallback arrays for resilience.

### Agent Invocation Control
New frontmatter attributes for fine-grained control:

- **`user-invokable: false`** — Prevents direct user invocation (internal-only agents)
- **`disable-model-invocation: true`** — Prevents AI-initiated invocation
- **`agents: [list]`** — Subagent allowlist restricting which agents can be delegated to

### Handoff Model Parameters
Handoffs can now specify a `model` parameter for per-handoff model selection:

```yaml
handoffs:
  - label: Deep Analysis
    agent: beast-mode
    model: Claude Opus 4.6 (copilot)
    prompt: Perform extended reasoning analysis.
```

### Thinking & Reasoning Enhancements

| Setting | Value | Description |
|---------|-------|-------------|
| `chat.thinking.style` | `"collapsed"` | Renamed from `chat.agent.thinkingStyle` |
| `chat.agent.thinking.terminalTools` | `true` | Shows reasoning interleaved with terminal tool calls |
| `chat.tools.autoExpandFailures` | `true` | Auto-expands failed tool calls for diagnosis |

### Anthropic Model Enhancements
Three new settings optimize Claude model performance:

- **`github.copilot.chat.anthropic.thinking.budgetTokens`** (`10000`) — Budget for interleaved thinking via Messages API
- **`github.copilot.chat.anthropic.toolSearchTool.enabled`** (`true`) — Helps Claude discover relevant tools from larger pools
- **`github.copilot.chat.anthropic.contextEditing.enabled`** (`true`) — Clears old tool results/thinking to maintain more useful context

### Ask Questions Tool
**Setting:** `chat.askQuestions.enabled` (default: `true`)

Agents can now ask clarifying questions instead of making assumptions. This is especially useful for the Planner and Conductor agents during the discovery phase. The `askQuestions` tool has been added to conductor, planner, and beast-mode agents.

### Agent Sessions Enhancements

| Setting | Value | Description |
|---------|-------|-------------|
| `chat.agentsControl.enabled` | `true` | Agent status indicator in command center |
| `chat.agentsControl.clickBehavior` | `"cycle"` | Cycle chat view states on click |
| `workbench.startupEditor` | `"agentSessionsWelcomePage"` | Surfaces recent sessions on startup |

**New Features:**
- **Session Type Picker**: Switch between local, background, cloud, and Claude Agent sessions
- **Agent Status Indicator**: Command center badge showing in-progress, unread, and attention-needed sessions
- **Parallel Subagents**: Independent subtasks run in parallel across multiple subagents

### Search Subagent
**Setting:** `github.copilot.chat.searchSubagent.enabled` (`true`)

Iterative code search runs in an isolated context window, preventing search operations from consuming the main conversation context.

### Copilot Memory (Preview)
**Setting:** `github.copilot.chat.copilotMemory.enabled` (`true`)

Replaces the legacy `github.copilot.chat.tools.memory.enabled`. Stores and recalls information across sessions for persistent agent context.

### Organization Instructions
**Setting:** `github.copilot.chat.organizationInstructions.enabled` (`true`)

Auto-applies org-level custom instructions, enabling consistent behavior across all repositories in your GitHub organization.

### External Indexing
**Setting:** `github.copilot.chat.advanced.workspace.codeSearchExternalIngest.enabled` (`true`)

Enables remote indexing for non-GitHub workspaces, making code search fast even for local-only repositories.

### Integrated Browser (Preview)

| Setting | Value | Description |
|---------|-------|-------------|
| `workbench.browser.openLocalhostLinks` | `true` | Opens localhost URLs in integrated browser |
| `simpleBrowser.useIntegratedBrowser` | `true` | Uses new integrated browser with DevTools |

### Plan Agent
**Setting:** `github.copilot.chat.implementAgent.model` (`"Claude Sonnet 4.6 (copilot)"`)

The `/plan` command provides a 4-phase workflow (Discovery → Alignment → Design → Refinement) with integrated `askQuestions`. The `implementAgent.model` setting controls which model is used for the implementation step.

### Claude Agent (Preview)
New session type using Anthropic's agent SDK. Available from the session type picker alongside local, background, and cloud agent sessions.

### MCP Apps
Interactive UI from MCP servers rendered directly in chat, enabling rich tool interactions.

### Chat Diagnostics
Right-click in Chat → Diagnostics to see all loaded agents, prompts, instructions, and skills. Useful for debugging configuration issues.

### `/init` Command
Auto-generates workspace instruction files based on codebase analysis — accelerates onboarding for new repositories.

### Other New Settings

| Setting | Value | Description |
|---------|-------|-------------|
| `terminal.integrated.enableKittyKeyboardProtocol` | `true` | Better key handling (shift+enter in agentic CLIs) |
| `git.worktreeIncludeFiles` | array | Copies specified files to worktrees for background agents |
| `inlineChat.affordance` | `true` | Inline chat affordance in editor |

## VS Code 1.108 Features

### Agent Skills (Experimental)
**Setting:** `chat.useAgentSkills` (default: `false` in 1.108, now `true` in 1.109)

Agent Skills enable on-demand loading of domain-specific knowledge from `.github/skills/` folders. Each skill is a directory containing a `SKILL.md` file that defines behavior, scripts, and resources. VS Code loads skills progressively when relevant to your request.

**Status:** Experimental. See Phase 6 of our integration plan for pilot program details.

### Enhanced Terminal Features
**Settings:**
- `chat.tools.terminal.enableAutoApprove` — Auto-approve safe commands like `git ls-files`, `rg`, `sed`, `Out-String`
- `chat.tools.terminal.autoApproveWorkspaceNpmScripts` — Auto-approve npm/pnpm/yarn scripts from `package.json`
- `chat.tools.terminal.preventShellHistory` — Exclude agent commands from shell history (default: `true`)

**Custom Glyphs:** VS Code 1.108 adds ~800 GPU-accelerated terminal glyphs including powerline symbols, progress indicators, git branch symbols, and braille patterns. No custom fonts required.

### Agent Sessions Improvements
**Settings:**
- `chat.viewSessions.orientation` — Use `"sideBySide"` (the `"auto"` option has been deprecated)
- `chat.restoreLastPanelSession` — Controls whether previous chat is restored on startup (default: `false` for empty chat)

**New Features:**
- Keyboard access for archive, read state, and open actions
- Session grouping by state and age when viewing side-by-side
- Changed files and associated PRs displayed per session
- Multi-session archiving support
- Quick access via "agent " in Quick Open (Ctrl+P)

### Terminal IntelliSense
Now requires **Ctrl+Space** to trigger by default (previously showed automatically while typing). This reduces interruptions for terminal power users while keeping the feature accessible.

## Terminal Auto-Approve (VS Code 1.108)

### Overview

VS Code 1.108 introduces intelligent auto-approval of safe terminal commands, reducing prompts while maintaining security. When agents or users run known-safe commands, VS Code executes them immediately rather than requesting approval.

### Auto-Approved Commands

When `chat.tools.terminal.enableAutoApprove` is enabled (default: `true`), these commands execute without prompts:

#### Git Commands
- `git ls-files` — List tracked files
- `git --no-pager <safe_subcommand>` — Read-only Git operations (status, log, diff, show, branch, tag)
- `git -C <dir> <safe_subcommand>` — Git operations in specific directory

#### Search and Text Tools
- `rg` (ripgrep) — Excludes dangerous flags like `--pre` and `--hostname-bin`
- `sed` — Text stream editing (with safety restrictions on dangerous patterns)

#### PowerShell Output
- `Out-String` — Convert objects to strings for display

### NPM Scripts Auto-Approve

**Setting:** `chat.tools.terminal.autoApproveWorkspaceNpmScripts` (default: `true`)

Scripts defined in `package.json` are auto-approved when run through npm, pnpm, or yarn:

```json
{
  "scripts": {
    "build": "tsc",           // ✓ Auto-approved
    "test": "jest",           // ✓ Auto-approved
    "lint": "eslint ."        // ✓ Auto-approved
  }
}
```

**Rationale:** Workspace Trust is already required for agents. Since agents cannot edit `package.json` (protected file), scripts are trusted.

**To disable:** Set `chat.tools.terminal.autoApproveWorkspaceNpmScripts: false`

### Shell History Exclusion

**Setting:** `chat.tools.terminal.preventShellHistory` (default: `true`)

Agent-run commands are excluded from your shell history by default. This keeps your history clean and focused on your manual commands.

**How it works:**
- **Bash/Zsh:** Sets `HISTCONTROL=ignorespace` and prefixes commands with a space
- **PowerShell:** Uses `-NoProfile` execution where appropriate
- **Fish:** Uses Fish-specific history control

**To include in history:** Set `chat.tools.terminal.preventShellHistory: false`

### Denial Transparency

When a command is denied by auto-approve rules, VS Code displays a clear informational message explaining why:

```
❌ Command denied by auto-approve rules
Command: rm -rf /
Reason: Dangerous file deletion detected
Action: Review command and run manually if needed
```

This transparency helps you understand security decisions and adjust your workflow.

### Validation Scripts and Auto-Approve

Our PowerShell validation scripts work seamlessly with auto-approve:

#### Auto-Approved Scripts
These scripts use only safe, read-only operations:

```powershell
# ✓ Auto-approved - read-only operations
.\scripts\validate-copilot-assets.ps1 -RepositoryRoot .
.\scripts\run-lint.ps1 -RepositoryRoot .
.\scripts\run-smoke-tests.ps1 -RepositoryRoot .
.\scripts\token-report.ps1 -Path .

# ✓ Auto-approved - Git read operations
git ls-files
git status
git diff
```

#### Requires Approval
Scripts that modify files or system state require explicit approval:

```powershell
# ⚠ Requires approval - modifies files
.\scripts\add-prompt-metadata.ps1 -RepositoryRoot .

# ⚠ Requires approval - creates artifacts
.\scripts\init-artifacts.ps1
```

### Security Best Practices

#### ✅ DO:
- Leave `enableAutoApprove` enabled for better workflow
- Review denial messages to understand security boundaries
- Use validation scripts frequently (they're auto-approved)
- Trust workspace npm scripts in your `package.json`

#### ⚠️ CONSIDER:
- Disable auto-approve in highly restricted environments
- Set `autoApproveWorkspaceNpmScripts: false` for untrusted repositories
- Review auto-approve logs periodically

#### ❌ DON'T:
- Override denial decisions without understanding the risk
- Disable `preventShellHistory` unless you need command history
- Assume all commands are auto-approved (check denial messages)

### Example Workflow

**Scenario:** Running conductor workflow validation

```powershell
# Agent runs validation (auto-approved ✓)
.\scripts\validate-copilot-assets.ps1 -RepositoryRoot .
# ✓ Executed immediately - no prompt

# Agent checks Git status (auto-approved ✓)
git status
# ✓ Executed immediately - no prompt

# Agent wants to modify metadata (requires approval ⚠)
.\scripts\add-prompt-metadata.ps1 -RepositoryRoot .
# ⚠ Prompt shown: "Allow this script to modify files?"
```

### Troubleshooting

**Issue:** Commands still prompting despite auto-approve enabled

**Solutions:**
1. Verify setting: `"chat.tools.terminal.enableAutoApprove": true`
2. Restart VS Code after changing settings
3. Check command matches safe patterns (see list above)
4. Review denial message for specific reason

**Issue:** NPM scripts not auto-approved

**Solutions:**
1. Verify setting: `"chat.tools.terminal.autoApproveWorkspaceNpmScripts": true`
2. Ensure scripts are in `package.json` (not run via `npx` or global packages)
3. Check Workspace Trust is enabled

**Issue:** Commands appearing in shell history

**Solutions:**
1. Verify setting: `"chat.tools.terminal.preventShellHistory": true`
2. Ensure shell integration is enabled and working
3. Check terminal type supports history control (bash, zsh, pwsh, fish)

### Related Settings

```json
{
  "chat.tools.terminal.enableAutoApprove": true,
  "chat.tools.terminal.autoApproveWorkspaceNpmScripts": true,
  "chat.tools.terminal.preventShellHistory": true,
  "terminal.integrated.shellIntegration.enabled": true
}
```

## Agent Sessions UI (VS Code 1.108)

### Overview

VS Code 1.108 introduces powerful Agent Sessions management features that make it easier to track, organize, and archive conductor workflows. The enhanced UI provides keyboard navigation, intelligent grouping, and multi-session operations.

### Keyboard Navigation

Navigate and manage sessions entirely from the keyboard:

#### Navigation Keys
- **↑/↓ (Arrow Keys)** — Move between sessions in the list
- **Enter** — Open selected session in editor
- **Delete** — Archive selected session
- **Space** — Toggle read/unread state

#### Multi-Selection
- **Shift+Click** — Select range of sessions
- **Ctrl+Click (Cmd+Click on Mac)** — Add/remove individual sessions from selection

#### Batch Operations
Once multiple sessions are selected:
- **Delete** — Archive all selected sessions at once
- **Space** — Mark all selected sessions as read/unread

**Example Workflow:**
```
1. Click first completed session
2. Shift+Click last completed session
3. Press Delete → All selected sessions archived
```

### Session Grouping

When `chat.viewSessions.orientation` is set to `"sideBySide"`, sessions are automatically grouped for better organization:

#### Group by State
- **Active** — Currently in-progress conductor workflows
- **Unread** — Completed sessions not yet reviewed
- **Read** — Reviewed sessions ready for archiving
- **Archived** — Historical sessions for reference

#### Group by Age
- **Today** — Sessions from the current day
- **Yesterday** — Sessions from the previous day
- **This Week** — Sessions from the current week
- **This Month** — Sessions from the current month
- **Older** — Historical sessions beyond current month

**Toggle Grouping:**
Use the grouping dropdown in the Agent Sessions view header to switch between State, Age, or None.

### Changed Files and PRs

Each session now displays associated context:

#### Changed Files Indicator
- Sessions show the number of files modified during the workflow
- Click the files indicator to expand and see the full list
- Each file is clickable to open in the editor

**Example:**
```
🎯 conductor — VS Code 1.108 Integration
   📁 7 files changed
      ├── vscode-copilot-configuration.md
      ├── copilot-instructions.md
      ├── terminal-formatting.instructions.md
      └── ...
```

#### Pull Request Links
- Sessions that resulted in commits show linked PRs
- Click PR number to open in default browser
- Status badge shows PR state (Open, Merged, Closed)

**Example:**
```
🎯 conductor — OAuth2 Implementation
   📁 12 files changed
   🔀 PR #247 (Merged)
```

### Quick Open Integration

Access Agent Sessions directly from Quick Open (Ctrl+P / Cmd+P):

**Syntax:** `agent <session_name>`

**Examples:**
```
agent oauth          → Find sessions about OAuth
agent Phase 3        → Find Phase 3 sessions
agent conductor      → Filter conductor workflows
```

**Workflow:**
1. Press Ctrl+P (Cmd+P on Mac)
2. Type `agent ` (with space)
3. Type search terms
4. Press Enter to open selected session

### Session Persistence

**Setting:** `chat.restoreLastPanelSession` (default: `false`)

Controls whether VS Code restores the last active session on startup.

#### Recommended: `false` (Default)
- **Start Fresh:** Each VS Code launch begins with an empty chat
- **Prevents Context Leakage:** Avoids accidental continuation of previous work
- **Clean State:** Ensures conductor starts with clear phase tracking

**Use Case:** Multi-project environments where sessions should not cross boundaries

#### Optional: `true`
- **Continue Where You Left Off:** Restores the last active session
- **Useful for:** Single long-running tasks interrupted by restarts
- **Caution:** May lead to context confusion if switching between projects

**Configuration:**
```json
{
  "chat.restoreLastPanelSession": false  // Recommended for conductor workflows
}
```

### Session Organization Best Practices

#### During Planning
- Start each conductor task in a new session
- Use descriptive initial prompts ("Implement OAuth2 authentication")
- VS Code uses this as the session title

#### During Implementation
- Mark sessions as unread when needing follow-up
- Use changed files indicator to verify phase scope
- Group by State to see active vs completed workflows

#### After Completion
- Review phase-complete.md artifacts
- Mark session as read (Space key)
- Archive when work is committed (Delete key)
- Link PR in session notes for traceability

#### Batch Cleanup
- Weekly: Shift+Click range of old sessions → Delete
- Monthly: Archive all Read sessions from previous month
- Before major release: Archive all completed feature sessions

### Workflow Integration

#### Conductor Lifecycle
Agent Sessions integrate seamlessly with conductor pause points:

```mermaid
flowchart LR
    A[New Session] --> B[Planning Phase]
    B --> C[Session: Unread]
    C --> D[Implementation]
    D --> E[Review]
    E --> F[Session: Read]
    F --> G[Archive]
```

**At Each Phase:**
1. **Planning** — Session starts, conductor delegates to Planner
2. **Pause** — User reviews plan, session marked Unread
3. **Implementation** — User approves, session continues with Implementer
4. **Review** — Reviewer validates changes, session marked Read
5. **Completion** — Phase-complete.md created, session ready to archive

#### Multi-Phase Projects
For projects with 5-7 phases (like VS Code integrations):

- **Keep session active** through all phases
- Use phase-complete.md artifacts as checkpoints
- Changed files indicator shows cumulative scope
- Archive only after plan-complete.md and final validation

#### Parallel Workflows
When running multiple conductor tasks simultaneously:

- Group by State to see all Active sessions
- Use session titles to differentiate ("Feature A", "Bug Fix B")
- Archive completed sessions to reduce clutter
- Link related PRs in session notes

### Troubleshooting

**Issue:** Sessions not grouping by state or age

**Solutions:**
1. Verify setting: `"chat.viewSessions.orientation": "sideBySide"`
2. Restart VS Code after changing orientation
3. Check Agent Sessions view is in Panel (not Sidebar)
4. Use grouping dropdown to select desired grouping mode

**Issue:** Changed files not showing for session

**Solutions:**
1. Ensure session includes tool calls that modified files
2. Check files were saved during the session
3. Verify workspace is a Git repository (changed files tracked via Git)
4. Refresh Agent Sessions view (reload icon)

**Issue:** Keyboard shortcuts not working

**Solutions:**
1. Ensure Agent Sessions view has focus (click in the view)
2. Check for keybinding conflicts (File → Preferences → Keyboard Shortcuts)
3. Verify VS Code version is 1.108 or later
4. Try restarting VS Code

**Issue:** Previous session restoring on startup

**Solutions:**
1. Set `"chat.restoreLastPanelSession": false`
2. Restart VS Code after changing setting
3. Manually archive unwanted session
4. Start new session with clear prompt

### Related Settings

```json
{
  "chat.viewSessions.enabled": true,
  "chat.viewSessions.orientation": "sideBySide",
  "chat.restoreLastPanelSession": false
}
```

## Claude Agent Sessions (Preview)

VS Code 1.109 introduces Claude Agent as a new session type, powered by Anthropic's agent SDK. This complements the existing conductor workflow by providing a native Anthropic-hosted agent experience.

### When to Use Each Session Type

| Session Type | Best For | Context | Model |
|---|---|---|---|
| **Local (Conductor)** | Multi-phase orchestrated work | Full workspace access, 22 custom agents | Your choice via model picker |
| **Background** | Long-running implementation | Git worktree isolation, auto-commit | Configured model |
| **Cloud** | Quick tasks, PR-focused work | GitHub-hosted, repo access | Cloud model selection |
| **Claude Agent** | Deep reasoning, complex analysis | Anthropic SDK, native Claude tools | Claude models only |

### Configuration

Claude Agent sessions appear automatically in the session type picker when using Anthropic models with your Copilot subscription. No additional configuration is needed beyond having Claude models available.

### Interop with Conductor Workflow

- **Plan locally, implement with Claude Agent**: Use the conductor to create an implementation plan, then hand off to Claude Agent for deep implementation work
- **Research with Claude Agent, orchestrate locally**: Use Claude Agent for complex research requiring extended thinking, then bring findings back to the conductor
- **Session type picker**: Switch between session types mid-workflow using the picker in the chat input area

### Limitations (Preview)

- Claude Agent sessions do not load custom agents or instructions from `.github/agents/`
- Handoffs from conductor to Claude Agent require manual session switching
- Memory is shared across session types when `copilotMemory` is enabled

## MCP Server Integration

This workspace includes MCP servers configured in `.vscode/mcp.json`:

| Server | Purpose | Used By |
|---|---|---|
| `github` | GitHub API operations (issues, PRs, repos) | github-ops agent |
| `filesystem` | Workspace file operations | All agents |
| `design-server` | Brand colors, components, contrast checking | design agent |
| `research-server` | Research and context gathering | researcher agent |

MCP Apps (GA in VS Code 1.109) render interactive UI directly in chat responses. Servers can return rich visualizations like flame graphs, dashboards, and forms.

### Adding New MCP Servers

Add entries to `.vscode/mcp.json` following the existing pattern. For private registries, use the `registryBaseUrl` property (new in 1.109).

## Terminal Lifecycle Tools

VS Code 1.109 introduced new terminal lifecycle tools for better background process management:

| Tool | Purpose | When to Use |
|---|---|---|
| `timeout` | Set max execution time for terminal commands | Always — prevents runaway processes |
| `awaitTerminal` | Wait for a background terminal to complete | When a build/test must finish before next step |
| `killTerminal` | Terminate a background terminal | Clean up servers, stop stale processes |

### Best Practices

- Always specify a `timeout` value when running terminal commands (0 = no timeout)
- Use `awaitTerminal` instead of `sleep` or `echo "done"` patterns to wait for background work
- Use `killTerminal` to stop old server processes before starting new ones
- Background terminals always start in the workspace directory; non-background terminals persist their working directory

### Terminal Sandboxing

Terminal sandboxing restricts file system and network access for agent-executed commands. **Available on macOS and Linux only** — on Windows, sandbox settings have no effect.

When enabled (`chat.tools.terminal.sandbox.enabled: true`):
- Commands can only read/write within the workspace folder
- Network access is blocked by default (configurable per domain)
- No confirmation dialog since commands run in a controlled environment

## Optional Enhancements
- Define tool set collections via `chat.tools.sets` when you create shared tool groups in `.github/toolsets.jsonc`.
- Control terminal approvals with `chat.tools.terminal.autoApprove` to match your security posture.
- Sync prompt and instruction files across machines by enabling Settings Sync for “Prompts and Instructions.”
- Review the **Chat History & Memory** panel to curate notes that custom agents should inherit; with memory enabled, the conductor and `#runSubagent` calls can re-use decisions from prior sessions.

## Custom Agent Delegation in Practice
- Launch complex work in the Conductor — it is the only agent with handoff buttons. All other agents delegate autonomously via `#runSubagent` using the `delegation-routing` skill.
- **Cross-agent custom agents**: With `chat.customAgentInSubagent.enabled`, you can invoke different agent personas from within a custom agent:
  ```
  Run the researcher agent as a custom agent to investigate authentication patterns.
  Use the security agent in a custom agent to threat-model the API design.
  ```
- **Monitor all sessions**: Open the Agent Sessions view (Panel → Agent Sessions) to see conductor workflows, delegated cloud agents, and CLI sessions in one place.
- When delegating manually, include scope, files, and expectations so memory captures the context for follow-up personas.
- Encourage specialists (Security, Performance, Visualizer, Data Analytics, Docs) to append memory notes summarizing their findings for downstream agents.
- Clear or update memory entries before starting a new initiative to avoid cross-talk between projects.

## Saving Successful Sessions
When a conductor session produces a valuable workflow, capture it for reuse:

1. After completing the workflow, type `/savePrompt` in the chat input.
2. VS Code generates a `.prompt.md` file with placeholders for variable inputs.
3. Review the generated prompt and save it to `.github/prompts/` for team use.
4. Document the new prompt in `docs/CHANGELOG.md` and add metadata with `scripts/add-prompt-metadata.ps1`.

Example use cases:
- Complex refactoring patterns that worked well
- Multi-phase implementation workflows
- Effective research + planning + implementation sequences

## Verification Checklist
1. Restart VS Code Insiders after saving the settings.
2. Open the Chat view and confirm custom modes (Conductor, Planner, Implementer, Reviewer, Researcher, Maintainer, Security, Performance, Visualizer, Data Analytics, Docs) appear in the mode picker.
3. Type `/` in chat and ensure prompt files from `.github/prompts` are listed.
4. Select the Conductor and verify handoff buttons appear. Other agents should delegate autonomously via `#runSubagent`.
5. Confirm the memory indicator shows as enabled (gear icon → “Chat > Tools > Memory”) and pin any critical context for the next session.
6. Run the following commands to confirm instructions and prompts remain valid:
   - `./scripts/run-lint.ps1`
   - `./scripts/run-smoke-tests.ps1`
   - `Invoke-Pester -Path tests`

## Troubleshooting
- If modes or prompts are missing, ensure the settings paths match the workspace layout and that `chat.promptFiles` is enabled.
- Handoffs only appear in VS Code Insiders; update to the latest build if buttons are absent.
- If tool approvals appear too often, adjust the per-tool approval settings or consolidate tool sets.
- Regenerate the token budget report (`./scripts/token-report.ps1`) after adding new instructions or prompts to keep CI thresholds current.

## References
- [Custom chat modes in VS Code](https://code.visualstudio.com/docs/copilot/customization/custom-chat-modes)
- [Use custom instructions](https://code.visualstudio.com/docs/copilot/customization/custom-instructions)
- [Use prompt files](https://code.visualstudio.com/docs/copilot/customization/prompt-files)
- [Use tools in chat](https://code.visualstudio.com/docs/copilot/chat/chat-tools)
