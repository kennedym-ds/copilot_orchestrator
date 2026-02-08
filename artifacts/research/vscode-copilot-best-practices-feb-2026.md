# Research: VS Code GitHub Copilot Best Practices & New Features (Dec 2025–Feb 2026)

**Date**: 2026-02-08T12:00:00Z
**Researcher**: researcher-agent
**Confidence**: High
**Tools Used**: fetch (8 URLs), grep_search, read_file
**Period Covered**: December 10, 2025 – February 8, 2026

## Summary

VS Code 1.108 (Dec 2025) and 1.109 (Jan 2026) represent a paradigm shift toward "multi-agent development home." Key themes: Agent Skills GA, parallel subagents, Claude Agent (Preview), MCP Apps, Copilot Memory, organization-wide instructions, model fallback arrays, terminal sandboxing, and the `/plan` command. The awesome-copilot repo has grown to 227+ contributors with plugins, collections, and an MCP server for installing customizations.

---

## Sources

| Source | URL | Accessed | Relevance | Method |
|--------|-----|----------|-----------|--------|
| VS Code 1.109 Release Notes | https://code.visualstudio.com/updates/v1_109 | 2026-02-08 | Critical | fetch |
| VS Code 1.108 Release Notes | https://code.visualstudio.com/updates/v1_108 | 2026-02-08 | Critical | fetch |
| Copilot Customization Docs | https://code.visualstudio.com/docs/copilot/copilot-customization | 2026-02-08 | High | fetch |
| Copilot Overview | https://code.visualstudio.com/docs/copilot/overview | 2026-02-08 | High | fetch |
| Awesome Copilot Repo | https://github.com/github/awesome-copilot | 2026-02-08 | High | fetch |
| GitHub Blog | https://github.blog | 2026-02-08 | Medium | fetch |
| GitHub Copilot Docs | https://docs.github.com/en/copilot | 2026-02-08 | Medium | fetch |
| Maximizing Agentic Capabilities | https://github.blog/ai-and-ml/github-copilot/how-to-maximize-github-copilots-agentic-capabilities/ | 2026-02-08 | High | fetch |
| Workspace: INSTRUCTION_CHANGELOG.md | local | 2026-02-08 | High | read_file |
| Workspace: docs/CHANGELOG.md | local | 2026-02-08 | High | read_file |
| Workspace: artifacts/plans/ | local | 2026-02-08 | Medium | grep_search |

---

## 1. VS Code 1.108 Features (December 2025, released Jan 8, 2026)

### Maturity: **GA (Stable)**

**Key Copilot Features:**

- **Agent Skills (Experimental)**: First introduction of `.github/skills/` directory with `SKILL.md` files. Skills loaded on-demand into chat context. Setting: `chat.useAgentSkills` (experimental in 1.108, GA in 1.109).
- **Agent Sessions View Improvements**: Keyboard navigation (↑↓, Enter, Delete, Space), session grouping by state/age, multi-session archiving (Shift+Click, Ctrl+Click), changed files and PR display per session.
- **Chat Picker Based on Agent Sessions**: Quick Pick now unified with Agent Sessions. Access via `agent <name>` in Quick Open (Ctrl+P).
- **Open Empty Chat on Restart**: `chat.restoreLastPanelSession: false` (new default) prevents context leakage between sessions. Replaces `chat.viewRestorePreviousSession`.
- **Terminal Auto-Approve Default Rules**: Auto-approved commands include `git ls-files`, `rg`, `sed` (restricted), `Out-String`. NPM/yarn/pnpm scripts auto-approved when in `package.json`.
  - Settings: `chat.tools.terminal.enableAutoApprove`, `chat.tools.terminal.autoApproveWorkspaceNpmScripts`, `chat.tools.terminal.preventShellHistory`
- **Session/Workspace Allow Rules**: Allow dropdown for terminal commands with session or workspace scope.
- **Terminal Tool Shell History Prevention**: Commands run by terminal tool excluded from shell history.
- **Terminal Custom Glyphs**: ~800 GPU-accelerated glyphs (box drawing, block elements, Braille, Powerline, progress indicators, Git branch symbols).
- **Worktrees in SCM View (Experimental)**: `scm.repositories.explorer`, `scm.repositories.selectionMode` settings.
- **Orientation Changes**: `chat.viewSessions.orientation` removed `"auto"` option; use `"sideBySide"`.

**Breaking Changes/Deprecations:**
- `chat.viewRestorePreviousSession` renamed to `chat.restoreLastPanelSession`
- `chat.viewSessions.orientation: "auto"` deprecated → use `"sideBySide"`

---

## 2. VS Code 1.109 Features (January 2026, released Feb 4, 2026)

### Maturity: **GA (Stable)** unless noted

This is the flagship "multi-agent development home" release. Major sections:

### 2.1 Chat UX

| Feature | Maturity | Settings | Details |
|---------|----------|----------|---------|
| **Anthropic Thinking Tokens** | GA | `chat.thinking.style`, `chat.agent.thinking.collapsedTools`, `chat.agent.thinking.terminalTools`, `chat.tools.autoExpandFailures` | Choose detailed or compact thinking; model reasoning interleaved with tool calls; failing tool calls auto-expand |
| **Mermaid Diagrams** | GA | — | Interactive Mermaid diagrams via `renderMermaidDiagram` tool; pan/zoom with Alt+wheel, open in editor, copy source |
| **Ask Questions Tool** | Experimental | `chat.askQuestions.enabled` | Agent asks clarifying questions with single/multi-select, free text, recommended answers. Used by Plan agent. |
| **Plan Agent (`/plan`)** | GA | `github.copilot.chat.implementAgent.model` | 4-phase workflow: Discovery → Alignment → Design → Refinement. Invoke with `/plan <task>`. |
| **Context Window Details** | GA | — | Token usage indicator in chat input with hover breakdown by category |
| **Inline Chat Revamp** | Preview | `inlineChat.affordance`, `inlineChat.renderMode` | Lightweight affordance for text selection, contextual rendering |
| **Model Descriptions** | GA | — | Hover on model picker shows model details |
| **Terminal Command Output** | GA | — | Syntax highlighting (Node, Python, Ruby), working directory display, command intent description, output streaming, interactive input, hidden terminal cleanup |
| **New Themes** | Experimental | — | New `VS Code Light` and `VS Code Dark` themes with shadows/transparency |

### 2.2 Agent Session Management

| Feature | Maturity | Settings | Details |
|---------|----------|----------|---------|
| **Session Type Picker** | GA | — | Choose local, background, cloud, or Claude Agent from unified picker; hand off sessions between types |
| **Agent Sessions View** | GA | — | Resizable session list, multi-select bulk operations, improved stacked view, filter support |
| **Agent Status Indicator** | GA | `chat.agentsControl.enabled`, `chat.agentsControl.clickBehavior` | Command center badge showing in-progress/unread/attention-needed counts; click cycles chat view states |
| **Parallel Subagents** | GA | `chat.customAgentInSubagent.enabled` | Subagents run in parallel across independent tasks; dedicated context windows; full visibility into subagent activity |
| **Search Subagent** | Experimental | `github.copilot.chat.searchSubagent.enabled` | Iterative code search in isolated context window; preserves main agent context |
| **Cloud Agents** | GA | — | Model selection, third-party agents (Claude, Codex), custom agents, multi-root workspace support |
| **Background Agents** | GA | `git.worktreeIncludeFiles` | Custom agents, image context, multi-root support, auto-commit at end of each turn |
| **Welcome Page** | Experimental | `workbench.startupEditor: "agentSessionsWelcomePage"` | Agent sessions surfaced on startup |

### 2.3 Agent Customization

| Feature | Maturity | Settings | Details |
|---------|----------|----------|---------|
| **Agent Skills GA** | **GA** | `chat.useAgentSkills`, `chat.agentSkillsLocations` | Skills in `.github/skills/` and `.claude/skills/` loaded automatically. Extension authors can use `chatSkills` contribution point. User home: `~/.copilot/skills/`, `~/.claude/skills/` |
| **`/init` Command** | GA | — | Generates or updates workspace instructions based on codebase analysis |
| **Organization-Wide Instructions** | GA | `github.copilot.chat.organizationInstructions.enabled` | Org-level custom instructions automatically applied to all sessions |
| **Custom Agent File Locations** | GA | `chat.agentFilesLocations` | Search additional directories for `.agent.md` files beyond workspace `.github/agents/` |
| **Agent Invocation Control** | GA | — | `user-invokable: false` (subagent-only), `disable-model-invocation: true` (user-triggered only), `agents: [list]` (subagent allowlist) |
| **Multiple Model Support** | GA | — | Agent frontmatter `model:` accepts arrays; first available used |
| **Chat Diagnostics** | GA | — | Right-click Chat → Diagnostics shows all loaded agents, prompts, instructions, skills with status and errors |
| **Language Models Editor** | GA | — | Multiple configs per provider, Azure model configuration, `chatLanguageModels.json` file |
| **Implement Agent Model** | Experimental | `github.copilot.chat.implementAgent.model` | Default model for Plan agent implementation step (e.g., `"Codex 5.2 (copilot)"`) |
| **Inline Chat Default Model** | GA | `inlineChat.defaultModel` | Set preferred model for inline chat |
| **Handoff Model Parameter** | GA | — | `model` parameter in handoff definitions for per-handoff model selection |
| **Agent Customization Skill** | Experimental | `chat.agentCustomizationSkill.enabled` | Built-in skill teaching AI how to create agents, instructions, prompts, skills |

### 2.4 Agent Extensibility

| Feature | Maturity | Details |
|---------|----------|---------|
| **Agent Orchestration** | GA | Full documentation of conductor patterns; cites community projects Copilot Orchestra and GitHub Copilot Atlas |
| **Claude Agent** | **Preview** | Delegates to Anthropic Claude Agent SDK; same prompts/tools/architecture as other Claude implementations |
| **Anthropic Models** | GA | Messages API with interleaved thinking (`github.copilot.chat.anthropic.thinking.budgetTokens`), tool search tool (`toolSearchTool.enabled`), context editing (`contextEditing.enabled`) |
| **MCP Apps** | GA | Interactive UI from MCP servers rendered in chat; rich visualizations (flame graphs, dashboards, forms) |
| **Custom Registry Base URLs** | GA | `registryBaseUrl` in MCP server manifests for private/alternative package registries |

### 2.5 Agent Optimizations

| Feature | Maturity | Settings | Details |
|---------|----------|----------|---------|
| **Copilot Memory** | **Preview** | `github.copilot.chat.copilotMemory.enabled` | Store/recall info across sessions; memory tool auto-recognizes when to store; manage at GitHub's Copilot settings page |
| **External Indexing** | **Preview** | `github.copilot.chat.advanced.workspace.codeSearchExternalIngest.enabled` | Non-GitHub workspaces remotely indexed for fast semantic search |
| **Read Files Outside Workspace** | GA | — | Permission prompt for external file/folder access; session-wide allow option |
| **Performance Improvements** | GA | — | Large chat optimizations, parallel dependent task processing |

### 2.6 Agent Security & Trust

| Feature | Maturity | Settings | Details |
|---------|----------|----------|---------|
| **Terminal Sandboxing** | Experimental | `chat.tools.terminal.sandbox.enabled`, `.linuxFileSystem`, `.macFileSystem`, `.network` | macOS/Linux only; restricts FS to workspace; blocks network by default |
| **Terminal Lifecycle** | GA | — | Manual push to background, `timeout` property, `awaitTerminal` tool, `killTerminal` tool |
| **Terminal Auto-Approval Updates** | GA | — | Added `Set-Location`, `dir`, `docker`, `npm/yarn/pnpm` safe subcommands |

### 2.7 Engineering Notable

- **Copilot Extension Deprecated**: GitHub Copilot extension removed; all AI functionality in Copilot Chat extension.
- **Windows Installation Redesign**: Versioned package paths inspired by Chromium's update client.
- **Windows 11 Context Menu Integration**: Top-level right-click entry.
- **macOS DMG Images**: Native drag-and-drop installation.

---

## 3. Custom Agents Best Practices

### Agent File Format (`.agent.md`)

Best practices from VS Code 1.109 documentation and community patterns:

```markdown
---
name: my-agent
description: "What this agent does"
model: ['Claude Opus 4.6 (copilot)', 'Claude Sonnet 4.5 (copilot)']
tools: ['codebase', 'terminal', 'agent', 'askQuestions']
user-invokable: true
disable-model-invocation: false
agents: ['Implementer', 'Reviewer', 'Test']
---

# Agent Instructions

System prompt and behavioral guidelines...
```

**Key Frontmatter Attributes (1.109):**

| Attribute | Type | Purpose |
|-----------|------|---------|
| `name` | string | Display name in agent picker |
| `description` | string | Short description shown on hover |
| `model` | string or array | Model preference with fallback chain |
| `tools` | array | Tools the agent can use |
| `user-invokable` | bool | Whether user can select from dropdown |
| `disable-model-invocation` | bool | Whether other agents can invoke as subagent |
| `agents` | array | Allowlist of subagents this agent can invoke |

**Best Practices Identified:**
1. **Use model fallback arrays** — ensures availability: `model: ['Claude Opus 4.6 (copilot)', 'Claude Sonnet 4.5 (copilot)']`
2. **Add `agent` tool** for orchestrating agents that need subagent capability
3. **Set `user-invokable: false`** for agents only used as subagents (reduces UI clutter)
4. **Use `agents` allowlist** on conductor/orchestrator to control delegation scope
5. **Keep instructions focused** — one role per agent, delegate to specialists
6. **Include `askQuestions` tool** for agents that need clarification before acting

### Community Orchestration Patterns

Two notable community projects cited in VS Code 1.109 release notes:

- **[Copilot Orchestra](https://github.com/ShepAlderson/copilot-orchestra)** — Multi-agent system with Conductor orchestrating planning, implementation, and review subagents
- **[GitHub Copilot Atlas](https://github.com/bigguy345/Github-Copilot-Atlas)** — Extended orchestration with "Prometheus" (planning), "Oracle" (research), "Sisyphus" (implementation), "Explorer" (discovery)

---

## 4. Instruction Files Best Practices

### File Format (`.instructions.md`)

```markdown
---
applyTo: "**/*.ts"
---

# TypeScript Guidelines

- Use strict TypeScript with no `any` types
- Prefer interfaces over type aliases for object shapes
```

**Best Practices from Official Docs:**

1. **Always-on instructions**: Use `copilot-instructions.md` or `AGENTS.md` at workspace root for project-wide conventions. These apply to every session.
2. **File-based instructions**: Use `applyTo` glob patterns to scope rules. Apply to specific file types (`**/*.py`) or directories (`src/api/**`).
3. **Layered loading**: VS Code loads from multiple sources — workspace, user home, organization, extensions. Use the hierarchy intentionally.
4. **Organization-level instructions** (1.109 GA): `github.copilot.chat.organizationInstructions.enabled` — automatically applied across all team members' sessions.
5. **Keep concise**: Instructions count against context window. Focus on rules the AI wouldn't infer from code alone.
6. **Diagnostics**: Use Chat → Diagnostics to verify which instructions are loaded and check for errors.

### Instruction Hierarchy (highest to lowest priority)

1. Agent-specific instructions (in `.agent.md` file)
2. File-based instructions (matching `applyTo` glob)
3. Always-on workspace instructions (`copilot-instructions.md`, `AGENTS.md`)
4. Organization-level instructions
5. User-level instructions (`~/.copilot/instructions/`)

---

## 5. Prompt Files Best Practices

### File Format (`.prompt.md`)

Prompt files (slash commands) are invoked with `/command-name` in chat. They encode task-specific workflows.

**Best Practices:**
1. **One task per prompt** — create-component, run-tests, prepare-pr
2. **Include context references** — use `#file`, `#selection`, `#codebase` to pull relevant context
3. **Provide clear output format** — specify what the response should look like
4. **Use for repeatable workflows** — component scaffolding, code reviews, documentation generation
5. **Override default behavior** — prompts can customize how a custom agent handles specific tasks
6. **`/init` command (1.109)** — built-in prompt that generates workspace instructions from codebase analysis; customizable since it's a contributed prompt file

---

## 6. Agent Skills

### Maturity: **GA** (as of 1.109)

Skills provide specialized capabilities loaded on-demand. They're an [open standard](https://agentskills.io/) working across VS Code, GitHub Copilot CLI, and GitHub Copilot coding agent.

### File Structure

```
.github/skills/
  my-skill/
    SKILL.md          # Required: skill definition
    examples/         # Optional: example files
    scripts/          # Optional: helper scripts
    resources/        # Optional: additional resources
```

### SKILL.md Format

The `SKILL.md` file defines the skill's behavior, loaded when the AI determines the skill is relevant.

### Search Paths (in order)

1. `.github/skills/` (workspace)
2. `.claude/skills/` (workspace, backwards compatibility)
3. `~/.copilot/skills/` (user home)
4. `~/.claude/skills/` (user home, backwards compatibility)
5. Custom paths via `chat.agentSkillsLocations` setting
6. Extension-contributed skills via `chatSkills` contribution point

### When to Use What

| Mechanism | Scope | Loading | Best For |
|-----------|-------|---------|----------|
| **Instructions** | Always-on or file-matched | Automatic | Coding standards, project conventions |
| **Skills** | On-demand, description-matched | When relevant | Specialized workflows, domain expertise, reusable capabilities |
| **Prompts** | User-invoked | Manual (`/command`) | One-shot tasks, repeatable workflows |
| **Agents** | Session-level | Manual selection or subagent | Role-specific personas, orchestrated workflows |

### Key Differences from Instructions

- Skills are **loaded on-demand** based on relevance, not always applied
- Skills can include **bundled resources** (scripts, examples, templates)
- Skills work **cross-tool** (VS Code, CLI, coding agent)
- Skills have their own **directory structure** vs. single instruction files

---

## 7. Model Selection

### Current Best Models (as of Feb 2026)

| Model | Vendor | Best For | Tier |
|-------|--------|----------|------|
| **Claude Opus 4.6** | Anthropic/Copilot | Planning, review, research, security, complex reasoning | Premium |
| **Codex 5.2** | OpenAI/Copilot | Implementation, coding tasks, plan execution | Premium/Execution |
| **Claude Sonnet 4.5** | Anthropic/Copilot | Implementation, analysis, testing, support tasks | Execution |
| **Gemini 3 Pro** | Google/Copilot | Analysis, implementation, cross-language tasks | Execution |
| **Claude Haiku 4.5** | Anthropic/Copilot | Documentation, linting, routine tasks | Routine |
| **Gemini 3 Flash** | Google/Copilot | Fast routine tasks, simple queries | Routine |

**Notable:** Claude Opus 4.6 "Fast mode" entered public preview on Feb 7, 2026 (GitHub Changelog).

### Model Fallback Arrays (1.109 GA)

Agents should specify fallback chains:
```yaml
model: ['Claude Opus 4.6 (copilot)', 'Claude Sonnet 4.5 (copilot)']
```

### Third-Party Coding Agents (Preview)

As of Feb 4, 2026, Claude and Codex are available as third-party coding agents on GitHub with Copilot Pro+ or Enterprise subscriptions. Available in both cloud agent mode and local VS Code sessions.

### Auto Model Selection

GitHub Copilot now supports automatic model selection for Chat and coding agent tasks (per GitHub Docs).

### Plan Agent Default Model

Use `github.copilot.chat.implementAgent.model` to set default for implementation step (e.g., `"Codex 5.2 (copilot)"`).

---

## 8. Multi-Agent Orchestration

### Conductor Pattern

The official VS Code 1.109 release notes explicitly document agent orchestration as a first-class pattern with three key benefits:
1. **Context efficiency** — each subagent has dedicated context window
2. **Specialization** — different agents use different models optimized for their task
3. **Parallel execution** — independent tasks run in parallel across multiple subagents

### Building Blocks (1.109)

| Building Block | Purpose |
|----------------|---------|
| Custom agents (`.agent.md`) | Define specialized personas |
| Subagents (`#runSubagent` / `agent` tool) | Delegate subtasks |
| `agents` allowlist | Control which subagents a conductor can invoke |
| `user-invokable: false` | Hide implementation-only agents |
| `disable-model-invocation: true` | Prevent unwanted auto-delegation |
| Model fallback arrays | Ensure availability across tiers |
| Handoff `model` parameter | Per-handoff model selection |
| `chat.customAgentInSubagent.enabled` | Enable custom agent subagent support |

### Best Practices for Orchestration

1. **Conductor controls flow** — one top-level agent with explicit `agents` allowlist
2. **Pause points** — require human approval after plans and reviews
3. **State persistence** — save artifacts to `artifacts/` folder for resume
4. **Parallel subagents** — split independent tasks (e.g., separate file analysis) across parallel subagents
5. **Context isolation** — each subagent gets its own context window, preventing overflow
6. **Handoff with model** — specify optimal model per handoff to balance cost/quality

### Community References

- **GitHub Blog** (Feb 2, 2026): "[How to maximize GitHub Copilot's agentic capabilities](https://github.blog/ai-and-ml/github-copilot/how-to-maximize-github-copilots-agentic-capabilities/)" — Architecture-aware workflows, system decomposition, multi-file coordination
- **GitHub Blog** (Feb 5, 2026): "[Continuous AI in practice](https://github.blog/ai-and-ml/generative-ai/continuous-ai-in-practice-what-developers-can-automate-today-with-agentic-ci/)" — Background agents as "agentic CI" for reasoning-heavy repo tasks
- **GitHub Blog** (Jan 22, 2026): "[GitHub Copilot SDK](https://github.blog/news-insights/company-news/build-an-agent-into-any-app-with-the-github-copilot-sdk/)" — Programmable agent layer for any application (technical preview)

---

## 9. Terminal and Tool Integration

### Auto-Approve Settings (1.108+)

| Setting | Purpose |
|---------|---------|
| `chat.tools.terminal.enableAutoApprove` | Master toggle for auto-approval |
| `chat.tools.terminal.autoApproveWorkspaceNpmScripts` | Auto-approve npm scripts in package.json |
| `chat.tools.terminal.preventShellHistory` | Exclude agent commands from shell history |

### Auto-Approved Commands (1.109)

`Set-Location`, `dir`, `od`, `xxd`, `docker` (safe sub-commands), `npm`/`yarn`/`pnpm` (safe sub-commands), `git ls-files`, `rg`, `sed` (restricted), `Out-String`

### Terminal Sandboxing (Experimental, macOS/Linux only)

| Setting | Purpose |
|---------|---------|
| `chat.tools.terminal.sandbox.enabled` | Enable sandbox |
| `chat.tools.terminal.sandbox.linuxFileSystem` | Linux FS restrictions |
| `chat.tools.terminal.sandbox.macFileSystem` | macOS FS restrictions |
| `chat.tools.terminal.sandbox.network` | Network access restrictions |

### Terminal Tool Lifecycle (1.109)

- **Manual background push** — free agent to continue while command runs
- **`timeout` property** — required escape hatch for hung commands
- **`awaitTerminal` tool** — wait for background terminal completion
- **`killTerminal` tool** — clean up background terminals

### Background Agents with Git Worktrees

- `git.worktreeIncludeFiles` setting copies specified files (e.g., `.env.local`, `token-thresholds.json`) to worktree folder after creation
- Background agents now auto-commit at end of each turn
- Custom agents available for background sessions
- Image context support for background agents
- Multi-root workspace support

### Terminal Formatting

~800 GPU-accelerated custom glyphs for box drawing, block elements, Braille, Powerline, progress indicators, Git branch symbols. Improved curly underline rendering.

---

## 10. Session Management

### Agent Sessions UI (1.108–1.109)

| Feature | Release | Details |
|---------|---------|---------|
| Keyboard navigation | 1.108 | ↑↓ arrows, Enter, Delete, Space |
| Session grouping | 1.108 | By state (Active/Unread/Read/Archived) or age |
| Multi-session operations | 1.108 | Shift+Click, Ctrl+Click for batch archiving |
| Changed files display | 1.108 | Modified files shown per session |
| PR integration | 1.108 | Linked PRs and status in session list |
| Quick Open | 1.108 | `agent <name>` in Ctrl+P |
| Session type picker | 1.109 | Local/Background/Cloud/Claude Agent |
| Agent status indicator | 1.109 | Command center badge with counts |
| Welcome page | 1.109 (Experimental) | Agent sessions on startup |
| Parallel subagent visibility | 1.109 | Full details of subagent tasks/tools/prompts |

### Session Best Practices

1. **New session per task** — prevents context leakage
2. **Set `chat.restoreLastPanelSession: false`** — start fresh on VS Code restart
3. **Use session grouping by State** — track multiple parallel workflows
4. **Mark Read after review** — use Agent Sessions view lifecycle
5. **Archive after completion** — keep workspace clean
6. **Hand off between types** — plan locally, implement in cloud

---

## 11. MCP (Model Context Protocol)

### MCP Apps (1.109 GA)

MCP servers can now render rich, interactive UI directly in chat. This opens up dashboards, flame graphs, forms, and other visualizations.

**Resources:**
- [MCP Apps Demo Repo](https://github.com/digitarald/mcp-apps-playground)
- [MCP Apps SDK](https://github.com/modelcontextprotocol/ext-apps/)
- [VS Code MCP Docs](https://code.visualstudio.com/docs/copilot/customization/mcp-servers)
- [MCP Developer Guide](https://code.visualstudio.com/docs/copilot/guides/mcp-developer-guide)

### Custom Registry Base URLs (1.109)

The `registryBaseUrl` property in MCP server manifests enables organizations to use private/alternative package registries (Azure DevOps feeds, custom PyPI repos).

### Awesome Copilot MCP Server

The awesome-copilot repo provides an MCP server for searching and installing agents, prompts, instructions, and skills from the repository. Requires Docker.

Install URLs:
- VS Code: `https://aka.ms/awesome-copilot/mcp/vscode`
- VS Code Insiders: `https://aka.ms/awesome-copilot/mcp/vscode-insiders`
- Visual Studio: `https://aka.ms/awesome-copilot/mcp/vs`

---

## 12. Copilot Memory

### Maturity: **Preview** (1.109)

Setting: `github.copilot.chat.copilotMemory.enabled`

**How It Works:**
- Memory tool auto-recognizes when to store information ("always ask clarifying questions when in doubt")
- Retrieves relevant memories to inform responses
- Persists across sessions via GitHub's servers
- Manage at [GitHub's Copilot settings](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/copilot-memory)

**Best Practices:**
1. Store **codebase-specific facts** that won't be inferred from code (conventions, preferences, verified commands)
2. Include **reason and citations** for stored facts
3. Avoid secrets or sensitive data
4. Store facts that are **unlikely to change** over time
5. Facts should be **actionable** for future tasks
6. Replaces legacy `github.copilot.chat.tools.memory.enabled`

**GitHub Docs Categories for Memory:**
- About agentic memory for GitHub Copilot
- Stores details learned about a codebase for future work

---

## 13. Search Subagent

### Maturity: **Experimental** (1.109)

Setting: `github.copilot.chat.searchSubagent.enabled`

**How It Works:**
- Runs in an isolated agent loop with its own context window
- Iteratively refines searches, tries multiple queries, explores different workspace parts
- Preserves main agent's context window
- Enables main agent to continue working while search runs

**Best Practices:**
1. Use for **complex queries** where a single search isn't sufficient
2. Especially useful for **large codebases** where multiple search iterations are needed
3. Prefer over direct `#codebase` when context window is at premium
4. The subagent handles deduplication and relevance ranking internally

---

## 14. Plan Command (`/plan`)

### Maturity: **GA** (1.109)

**4-Phase Workflow:**

1. **Discovery** — Autonomously explores codebase, searches relevant files, understands project structure
2. **Alignment** — Pauses to ask clarifying questions (uses `askQuestions` tool), catches ambiguities early
3. **Design** — Drafts comprehensive implementation plan with steps, file locations, code snippets
4. **Refinement** — Adds verification criteria, documents decisions made during planning

**Usage:** Type `/plan <task description>` in chat.

**Configuration:**
- `github.copilot.chat.implementAgent.model` — set default model for implementation step
- Works with `chat.askQuestions.enabled` for alignment phase

**Best Practices:**
1. Use `/plan` before diving into complex multi-file tasks
2. Review the alignment questions carefully — this is where misunderstandings get caught
3. The plan serves as a contract between you and the agent
4. Implementation can be handed off to cloud/background agents after planning locally

---

## 15. Community Resources (awesome-copilot)

### Repository Stats (Feb 2026)

- **Stars:** 20.5k
- **Contributors:** 227+
- **Forks:** 2.4k
- **Activity:** Multiple PRs merged daily (last commit: 3 days ago)

### Repository Structure

```
prompts/          # Task-specific prompts (.prompt.md)
instructions/     # Coding standards (.instructions.md)
agents/           # AI personas (.agent.md)
collections/      # Curated collections (.collection.yml)
plugins/          # Installable plugin packages
scripts/          # Maintenance utilities
skills/           # AI capabilities (SKILL.md)
cookbook/          # Copy-paste code snippets
```

### Key Resources

- **[Awesome Agents](https://github.com/github/awesome-copilot/blob/main/docs/README.agents.md)** — Specialized agents with MCP integration
- **[Awesome Prompts](https://github.com/github/awesome-copilot/blob/main/docs/README.prompts.md)** — Task-specific prompt templates
- **[Awesome Instructions](https://github.com/github/awesome-copilot/blob/main/docs/README.instructions.md)** — Coding standards and best practices
- **[Awesome Skills](https://github.com/github/awesome-copilot/blob/main/docs/README.skills.md)** — Self-contained capability folders
- **[Awesome Collections](https://github.com/github/awesome-copilot/blob/main/docs/README.collections.md)** — Curated bundles around themes
- **[Cookbook Recipes](https://github.com/github/awesome-copilot/blob/main/cookbook/README.md)** — Real-world code snippets

### New Features (Recent)

- **Plugins**: Installable packages generated from collections. Install via `copilot plugin install <name>@awesome-copilot`
- **MCP Server**: Browse and install customizations directly in editor
- **llms.txt**: Machine-readable index at `https://github.github.io/awesome-copilot/llms.txt` for LLM discovery
- **Featured Collections**: Awesome Copilot (meta), Copilot SDK (multi-language), Partners (20 vendor agents)
- **Copilot SDK**: Build applications with GitHub Copilot SDK in C#, Go, Node.js/TypeScript, Python

### Partner Agents (Collection)

20 partner agents covering: DevOps, security, database, cloud, infrastructure, observability, feature flags, CI/CD, migration, performance.

---

## 16. GitHub Blog Highlights (Dec 2025 – Feb 2026)

| Date | Title | Key Takeaway |
|------|-------|-------------|
| Feb 7, 2026 | Claude Opus 4.6 Fast Mode Preview | Fast mode for premium model in public preview |
| Feb 5, 2026 | Continuous AI in Practice | Background agents as "agentic CI" for reasoning tasks |
| Feb 4, 2026 | Pick Your Agent: Claude and Codex | Third-party agents in public preview (Pro+/Enterprise) |
| Feb 2, 2026 | Maximizing Agentic Capabilities | Architecture-aware multi-step workflows guide |
| Jan 28, 2026 | Copilot CLI ASCII Banner | Terminal engineering patterns |
| Jan 22, 2026 | GitHub Copilot SDK | Programmable agent layer (technical preview) |
| Jan 21, 2026 | Slash Commands Cheat Sheet | CLI command patterns |
| Dec 12, 2025 | AI-Powered Software Optimization | Continuous Efficiency vision |
| Dec 11, 2025 | GitHub Actions Rebuilt | Core architecture improvements |

---

## 17. Workspace Alignment Assessment

### Already Covered by This Repo

Based on INSTRUCTION_CHANGELOG.md and docs/CHANGELOG.md:

- [x] VS Code 1.108 integration (v0.6.0, 2026-01-09)
- [x] VS Code 1.109 integration (v2.0.0, 2026-02-06)
- [x] Model tier overhaul (Claude Opus 4.6, Codex 5.2, Sonnet 4.5, Gemini 3 Pro, Haiku 4.5, Gemini 3 Flash)
- [x] Model fallback arrays for all 22 agents
- [x] Agent Skills GA with 12 skills
- [x] `agent` tool added to all 22 agents
- [x] `askQuestions` tool added to conductor, planner, beast-mode
- [x] All deprecated settings removed
- [x] Organization instructions setting
- [x] Search subagent, Copilot Memory, Anthropic enhancements
- [x] Agent status indicator, session type picker
- [x] Terminal sandboxing, lifecycle improvements
- [x] Integrated browser settings
- [x] Kitty keyboard protocol, worktree include files
- [x] Conductor `agents` allowlist

### Gaps / Opportunities

1. **Copilot SDK integration** — The GitHub Copilot SDK (Jan 22 technical preview) could enable programmatic agent creation. Not yet documented.
2. **Awesome-Copilot MCP server** — Not yet configured for this workspace. Could streamline agent/skill discovery.
3. **Plugins system** — The awesome-copilot plugin pattern (`copilot plugin install`) is new; not yet evaluated for this repo.
4. **Claude Opus 4.6 Fast Mode** — Entered preview Feb 7, 2026. Could become a model option for latency-sensitive agents.
5. **`/init` command documentation** — Could document how `/init` interacts with existing `copilot-instructions.md` and `AGENTS.md`.
6. **Terminal sandboxing** — Windows not yet supported. Document this limitation for Windows users.
7. **MCP Apps patterns** — No MCP Apps integration yet. Could create interactive dashboards for session analytics.
8. **Extension-contributed skills** — The `chatSkills` contribution point in `package.json` enables distributing skills via extensions. Not yet explored.
9. **llms.txt adoption** — Consider creating an llms.txt for this repo to enable LLM discovery of agents/skills.

---

## Contradictions / Gaps in Sources

1. **Setting name inconsistency**: The 1.109 release notes reference `github.copilot.chat.anthropic.thinking.budgetTokens` while the workspace uses the same name. Confirmed consistent.
2. **Claude Agent availability**: Preview only — capabilities and API surface may change. Not suitable for production orchestration workflows yet.
3. **Terminal sandboxing**: Only macOS/Linux. **No Windows support** currently — significant gap for this Windows-based workspace.
4. **External indexing rollout**: "Rolling out gradually over next few weeks" — may not be available to all users immediately.
5. **Model names**: VS Code 1.109 examples still reference `GPT-5` — our workspace correctly uses newer model names (Opus 4.6, Codex 5.2, etc.).

---

## Recommendations

1. **Track Claude Opus 4.6 Fast Mode** — Evaluate for latency-sensitive agents (e.g., lint, docs) once GA. Could enable upgrading routine-tier agents.
2. **Evaluate Copilot SDK** — The programmable agent layer could formalize the conductor workflow as a reusable SDK-based solution.
3. **Install awesome-copilot MCP server** — Enable team members to discover and install community agents/skills from within the editor.
4. **Document Windows sandboxing gap** — Add note to docs that terminal sandboxing is macOS/Linux only.
5. **Create llms.txt** — Machine-readable index of this repo's agents, skills, and prompts for external LLM discovery.
6. **Monitor Agent Skills ecosystem** — The `agentskills.io` open standard and extension-contributed skills pattern represent a growing ecosystem.
7. **Update for Claude Opus 4.6 Fast** — Once GA, add as fallback option in premium-tier agents for time-sensitive operations.

---

## Open Questions

- [ ] When will Claude Opus 4.6 Fast Mode reach GA?
- [ ] Will terminal sandboxing be extended to Windows?
- [ ] What is the timeline for Copilot SDK moving from technical preview to GA?
- [ ] Should this repo publish its agents/skills as an awesome-copilot plugin?
- [ ] What is the token cost difference between Copilot Memory storage vs. re-providing context?
- [ ] Will MCP Apps support server-side rendering for non-interactive environments?
