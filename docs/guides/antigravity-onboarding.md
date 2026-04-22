---
title: "Antigravity IDE Onboarding Guide"
version: "2.0.0"
lastUpdated: "2026-04-22"
status: stable
---

# Antigravity IDE Onboarding

Get the Copilot Orchestrator's 16 agents (11 core + 5 translation) and skills running in Antigravity IDE in under 5 minutes.

## Prerequisites

- [Antigravity IDE](https://antigravity.dev) installed (Google DeepMind AI coding IDE)
- A local clone of the `copilot_orchestrator` repository
- PowerShell 5.1 (Windows) or Bash 4+ (macOS/Linux)

## Quick Start

### 1. Run the setup script

The script transforms VS Code agent definitions into Antigravity format automatically.

**Windows:**
```powershell
cd path\to\copilot_orchestrator
powershell -File scripts/setup-antigravity.ps1 -Mode Project -TargetPath C:\Projects\my-app
```

**macOS / Linux:**
```bash
cd path/to/copilot_orchestrator
./scripts/setup-antigravity.sh --mode project --target ~/projects/my-app
```

This creates a `.agent/` directory in your target project with all 16 agents, skills, workflows (slash commands), instruction rules, and MCP configuration.

### 2. Verify the setup

Open your target project in Antigravity IDE. You should see the orchestrator agents listed in the agent panel. Try invoking one:

```
@conductor Plan a new feature for user authentication
```

### 3. Use slash commands

VS Code prompt templates are converted to Antigravity slash commands:

```
/analyze-repo
/translate-module
/validate-translation
```

## Setup Modes

| Mode | Command Flag | What It Does |
|------|-------------|-------------|
| **Project** | `-Mode Project` | Creates `.agent/` in one project. Agents available only there. |
| **User** | `-Mode User` | Installs skills to `~/.gemini/antigravity/skills/`. Available in all projects. |

**Recommendation:** Start with Project mode. Use User mode to share skills globally once you're comfortable.

### User mode example

```powershell
# Windows
powershell -File scripts/setup-antigravity.ps1 -Mode User

# macOS / Linux
./scripts/setup-antigravity.sh --mode user
```

### Force overwrite

To replace existing files:

```powershell
# Windows
powershell -File scripts/setup-antigravity.ps1 -Mode Project -TargetPath . -Force

# macOS / Linux
./scripts/setup-antigravity.sh --mode project --target . --force
```

## What Gets Transformed

The setup script converts VS Code agent formats into Antigravity equivalents:

| VS Code | Antigravity |
|---------|------------|
| `.github/agents/*.agent.md` | `.agent/agents/*.md` |
| `.github/skills/*/SKILL.md` | `.agent/skills/*/SKILL.md` |
| `.github/prompts/*.prompt.md` | `.agent/workflows/*.md` (slash commands) |
| `.github/copilot-instructions.md` | `.agent/ARCHITECTURE.md` |
| `instructions/**/*.md` | `.agent/rules/**/*.md` |
| `.vscode/mcp.json` | `.agent/mcp_config.json` |

### Model mapping

Antigravity uses short aliases instead of VS Code's full model names:

| VS Code Model | Antigravity |
|--------------|------------|
| `Claude Opus 4.6 (copilot)` | `opus` |
| `Claude Sonnet 4.6 (copilot)` | `sonnet` |
| `Claude Haiku 4.5 (copilot)` | `haiku` |
| `Gemini 3.1 Pro (Preview) (copilot)` | `gemini-pro` |
| `GPT-5.4 (copilot)` | `inherit` (uses IDE default) |

### Tool mapping

VS Code tool names are converted to Antigravity equivalents:

| VS Code Tool | Antigravity Tool |
|-------------|-----------------|
| `edit` | `Edit` |
| `readFile` | `Read` |
| `runCommands` | `Bash` |
| `search` | `Grep` |
| `fileSearch` | `Glob` |
| N/A | `Write` (Antigravity-specific) |

## Using Agents in Antigravity

### Core workflow

The conductor orchestrates multi-phase tasks the same way across platforms:

```
@conductor → @planner → @implementer → @reviewer → completion
```

```
@conductor Create a REST API for user management with JWT auth
```

The conductor delegates to specialized agents automatically.

### Direct agent access

Invoke agents directly when you know what you need:

```
@planner Draft a 3-phase plan for migrating the database layer
@implementer Execute Phase 1 of the migration plan
@reviewer Review the Phase 1 changes for correctness
@researcher What are the trade-offs between Prisma and Drizzle ORM?
@security Review the auth changes for OWASP Top 10 compliance
```

### Slash commands

Prompt templates become Antigravity workflows with `$ARGUMENTS` support:

```
/analyze-repo Python to TypeScript
/validate-translation --strict
```

## Output Structure

After setup, your project will contain:

```
.agent/
├── agents/           # 16 transformed agent definitions
├── skills/           # Skill directories (SKILL.md format)
├── workflows/        # Slash commands from prompt templates
├── rules/            # Instruction files organized by category
│   ├── global/       # Behavior, quality, security, model selection
│   ├── workflows/    # Conductor, implementer, reviewer workflows
│   ├── compliance/   # Security, documentation, tool-approval
│   └── languages/    # Language-specific guardrails
├── mcp_config.json   # MCP server configuration
└── ARCHITECTURE.md   # Project context (from copilot-instructions.md)
```

## Updating Agents

When the orchestrator repo updates, re-run the setup script:

```powershell
# Windows
powershell -File scripts/setup-antigravity.ps1 -Mode Project -TargetPath C:\Projects\my-app -Force

# macOS / Linux
./scripts/setup-antigravity.sh --mode project --target ~/projects/my-app --force
```

## Troubleshooting

### Agents not detected after setup

1. Verify `.agent/agents/` exists in your project root
2. Check that `.agent/` is **not** in your `.gitignore` — Antigravity needs to index it
3. If you don't want `.agent/` tracked in git, add it to `.git/info/exclude` instead
4. Restart Antigravity IDE after adding agent files

### Global skills not loading

1. Verify `~/.gemini/antigravity/skills/` exists and contains skill directories
2. Each skill directory should have a `SKILL.md` file
3. Restart Antigravity IDE after installing user-level skills

### Script fails on macOS with "bad interpreter"

The bash scripts require bash 4+. macOS ships bash 3.2.

```bash
# Install modern bash
brew install bash

# Run with explicit bash path
/opt/homebrew/bin/bash scripts/setup-antigravity.sh --mode project --target ~/projects/my-app
```

### MCP servers not connecting

1. Check `.agent/mcp_config.json` exists in your project's `.agent/` directory
2. Verify Python 3.10+ is available for MCP server scripts
3. Check that `scripts/mcp/` is accessible from your target project

## Related Guides

- [Multi-Platform Setup Reference](multi-platform-setup.md) — Full platform comparison and technical details
- [MCP Integration](mcp-integration.md) — MCP server setup across platforms
- [Onboarding Guide](onboarding.md) — VS Code-focused contributor onboarding
