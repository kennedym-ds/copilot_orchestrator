---
title: "Claude Code Onboarding Guide"
version: "1.0.0"
lastUpdated: "2026-02-27"
status: stable
---

# Claude Code Onboarding

Get the Copilot Orchestrator's 28 agents and 16 skills running in Claude Code in under 5 minutes.

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- A local clone of the `copilot_orchestrator` repository
- PowerShell 5.1 (Windows) or Bash 4+ (macOS/Linux)

## Quick Start

### 1. Run the setup script

The script transforms VS Code agent definitions into Claude Code format automatically.

**Windows:**
```powershell
cd path\to\copilot_orchestrator
powershell -File scripts/setup-claude-code.ps1 -Mode Project -TargetPath C:\Projects\my-app
```

**macOS / Linux:**
```bash
cd path/to/copilot_orchestrator
./scripts/setup-claude-code.sh --mode project --target ~/projects/my-app
```

This creates a `.claude/` directory in your target project with all 28 agents, 16 skills, instruction rules, and MCP configuration.

### 2. Verify the setup

Open your target project in Claude Code and run:

```
/agents
```

You should see `conductor`, `planner`, `implementer`, `reviewer`, and the other 23 agents listed.

### 3. Start using agents

```
@conductor Plan a new feature for user authentication
```

That's it. You're running the full orchestration system in Claude Code.

## Setup Modes

| Mode | Command Flag | What It Does |
|------|-------------|-------------|
| **Project** | `-Mode Project` | Creates `.claude/` in one project. Agents available only there. |
| **User** | `-Mode User` | Installs to `~/.claude/`. Agents available in all Claude Code sessions. |
| **Plugin** | `-Mode Plugin` | Creates a distributable plugin package for team sharing. |

**Recommendation:** Start with Project mode. Move to User mode once you're comfortable.

### User mode example

```powershell
# Windows
powershell -File scripts/setup-claude-code.ps1 -Mode User

# macOS / Linux
./scripts/setup-claude-code.sh --mode user
```

### Plugin mode example

```powershell
# Windows
powershell -File scripts/setup-claude-code.ps1 -Mode Plugin -TargetPath ./dist/copilot-plugin

# macOS / Linux
./scripts/setup-claude-code.sh --mode plugin --target ./dist/copilot-plugin
```

Install the plugin in Claude Code:
```bash
claude --plugin-dir ./dist/copilot-plugin
```

## What Gets Transformed

The setup script converts VS Code agent formats into Claude Code equivalents:

| VS Code | Claude Code |
|---------|------------|
| `.github/agents/*.agent.md` | `.claude/agents/*.md` |
| `.github/skills/*/SKILL.md` | `.claude/skills/*/SKILL.md` |
| `.github/copilot-instructions.md` | `.claude/CLAUDE.md` |
| `instructions/**/*.md` | `.claude/rules/**/*.md` |
| `.vscode/mcp.json` | `.mcp.json` |

### Model mapping

Claude Code uses short aliases instead of VS Code's full model names:

| VS Code Model | Claude Code |
|--------------|------------|
| `Claude Opus 4.6 (copilot)` | `opus` |
| `Claude Sonnet 4.6 (copilot)` | `sonnet` |
| `Claude Haiku 4.5 (copilot)` | `haiku` |
| `GPT-5.3-Codex (copilot)` | `sonnet` (nearest equivalent) |
| `Gemini 3.1 Pro (copilot)` | `sonnet` (nearest equivalent) |

### Tool mapping

VS Code tool names are converted to Claude Code equivalents:

| VS Code Tool | Claude Code Tool |
|-------------|-----------------|
| `runSubagent` | `Task` or `Task(agent1, agent2)` |
| `edit` | `Edit` |
| `readFile` | `Read` |
| `runCommands` | `Bash` |
| `search` | `Grep` |
| `fileSearch` | `Glob` |
| `fetch` | `Bash(curl *)` |
| `todos` | `TodoWrite` |

## Using Agents in Claude Code

### Core workflow

The conductor orchestrates multi-phase tasks the same way across platforms:

```
@conductor → @planner → @implementer → @reviewer → completion
```

```
@conductor Create a REST API for user management with JWT auth
```

The conductor delegates to specialized agents automatically. You interact with the conductor; it handles the rest.

### Direct agent access

You can also invoke agents directly when you know what you need:

```
@planner Draft a 3-phase plan for migrating the database layer
@implementer Execute Phase 1 of the migration plan
@reviewer Review the Phase 1 changes for correctness
@researcher What are the trade-offs between Prisma and Drizzle ORM?
@security Review the auth changes for OWASP Top 10 compliance
```

### Useful commands

| Command | Purpose |
|---------|---------|
| `/agents` | List all available agents |
| `/skills` | List available skills |
| `/help` | General Claude Code help |

## Output Structure

After setup, your project will contain:

```
.claude/
├── agents/           # 27 transformed agent definitions
├── skills/           # 16 skill directories
├── rules/            # Instruction files organized by category
│   ├── global/       # Behavior, quality, security, model selection
│   ├── workflows/    # Conductor, implementer, reviewer workflows
│   ├── compliance/   # Security, documentation, tool-approval
│   └── languages/    # Language-specific guardrails
├── CLAUDE.md         # Project context (from copilot-instructions.md)
└── .mcp.json         # MCP server configuration (project root)
```

## Updating Agents

When the orchestrator repo updates, re-run the setup script to get the latest agents:

```powershell
# Windows — overwrites existing files
powershell -File scripts/setup-claude-code.ps1 -Mode Project -TargetPath C:\Projects\my-app

# macOS / Linux
./scripts/setup-claude-code.sh --mode project --target ~/projects/my-app
```

The script overwrites existing transformed files. Your project code is never modified.

## Troubleshooting

### Agents not visible after setup

1. Verify `.claude/agents/` exists in your project (or `~/.claude/agents/` for user mode)
2. Run `/agents` in Claude Code to list discovered agents
3. Check that agent files have `name` and `description` in their frontmatter
4. Restart Claude Code if you added agents to an already-open session

### Script fails on macOS with "bad interpreter"

The bash scripts require bash 4+. macOS ships bash 3.2.

```bash
# Install modern bash
brew install bash

# Run with explicit bash path
/opt/homebrew/bin/bash scripts/setup-claude-code.sh --mode project --target ~/projects/my-app
```

### MCP servers not connecting

1. Check `.mcp.json` exists at your project root (not inside `.claude/`)
2. Verify Python 3.10+ is available for MCP server scripts
3. Check that `scripts/mcp/` is accessible from your target project

### Plugin not loading

1. Verify `.claude-plugin/plugin.json` exists in the plugin directory
2. Check the plugin path is correct: `claude --plugin-dir ./exact/path`
3. Run `/plugins` in Claude Code to see loaded plugins

## Related Guides

- [Multi-Platform Setup Reference](multi-platform-setup.md) — Full platform comparison and technical details
- [Claude Skills Migration](claude-skills-migration.md) — Converting prompts to skills format
- [MCP Integration](mcp-integration.md) — MCP server setup across platforms
- [Onboarding Guide](onboarding.md) — VS Code-focused contributor onboarding
