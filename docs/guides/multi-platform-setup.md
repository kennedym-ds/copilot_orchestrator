# Multi-Platform Setup Guide

> **Scope:** VS Code | Visual Studio | Claude Code | Antigravity | Copilot CLI
> **Version:** 1.2.0 | **Last Updated:** 2026-03-10

## Overview

The Copilot Orchestrator's 29 agents and 16 skills can be used across five platforms:

| Platform | Agent Format | Setup Script | OS Support |
|----------|-------------|-------------|------------|
| **VS Code** | `.github/agents/*.agent.md` | Built-in (native) | Windows, macOS, Linux |
| **Visual Studio** | `.github/agents/*.agent.md` | `setup-vs-cli.ps1` / `.sh` | Windows |
| **Claude Code** | `.claude/agents/*.md` | `setup-claude-code.ps1` / `.sh` | Windows, macOS, Linux |
| **Antigravity** | `.agent/agents/*.md` | `setup-antigravity.ps1` / `.sh` | Windows, macOS, Linux |
| **Copilot CLI** | `.github/agents/*.agent.md` | `setup-vs-cli.ps1` / `.sh` | Windows, macOS, Linux |

VS Code is the native environment -- no setup needed. The other four platforms require either file transformation (Claude Code, Antigravity) or file distribution (VS / CLI).

## Quick Start

### VS Code (Native)

No setup required. Clone the repo and open it — agents, skills, and prompts load automatically from:
- `.github/agents/` — Agent definitions
- `.github/skills/` — Reusable skills
- `.github/prompts/` — Prompt templates
- `instructions/` — Layered instruction files

### Claude Code

**Windows (PowerShell):**
```powershell
# Project-level — agents available in one project
powershell -File scripts/setup-claude-code.ps1 -Mode Project -TargetPath C:\Projects\my-app

# User-level — agents available globally
powershell -File scripts/setup-claude-code.ps1 -Mode User

# Plugin — distributable package
powershell -File scripts/setup-claude-code.ps1 -Mode Plugin -TargetPath ./dist/copilot-plugin
```

**macOS / Linux (Bash):**
```bash
# Project-level
./scripts/setup-claude-code.sh --mode project --target ~/projects/my-app

# User-level
./scripts/setup-claude-code.sh --mode user

# Plugin
./scripts/setup-claude-code.sh --mode plugin --target ./dist/copilot-plugin
```

### Antigravity IDE

**Windows (PowerShell):**
```powershell
# Project-level -- agents available in one project
powershell -File scripts/setup-antigravity.ps1 -Mode Project -TargetPath C:\Projects\my-app

# User-level -- skills available globally
powershell -File scripts/setup-antigravity.ps1 -Mode User

# Force overwrite existing
powershell -File scripts/setup-antigravity.ps1 -Mode Project -TargetPath . -Force
```

**macOS / Linux (Bash):**
```bash
# Project-level
./scripts/setup-antigravity.sh --mode project --target ~/projects/my-app

# User-level
./scripts/setup-antigravity.sh --mode user

# Force overwrite
./scripts/setup-antigravity.sh --mode project --target . --force
```

### Visual Studio & Copilot CLI

**Windows (PowerShell):**
```powershell
# Symlink orchestrator assets into target project (recommended)
powershell -File scripts/setup-vs-cli.ps1 -Strategy Symlink -TargetPath C:\Projects\my-app

# Copy files instead of symlinking
powershell -File scripts/setup-vs-cli.ps1 -Strategy Copy -TargetPath C:\Projects\my-app

# Just show settings to add manually
powershell -File scripts/setup-vs-cli.ps1 -Strategy Reference

# Validate existing setup
powershell -File scripts/setup-vs-cli.ps1 -ValidateOnly -TargetPath C:\Projects\my-app
```

**macOS / Linux (Bash):**
```bash
# Symlink
./scripts/setup-vs-cli.sh --strategy link --target ~/projects/my-app

# Copy
./scripts/setup-vs-cli.sh --strategy copy --target ~/projects/my-app

# Reference (print settings)
./scripts/setup-vs-cli.sh --strategy reference

# Validate
./scripts/setup-vs-cli.sh --validate --target ~/projects/my-app
```

---

## Platform Details

### Claude Code

Claude Code uses a different agent format than VS Code. The setup scripts automatically transform:

| VS Code Format | Claude Code Format |
|---------------|-------------------|
| `.github/agents/*.agent.md` | `.claude/agents/*.md` |
| `.github/skills/*/SKILL.md` | `.claude/skills/*/SKILL.md` |
| `.github/copilot-instructions.md` | `.claude/CLAUDE.md` |
| `instructions/global/*.md` | `.claude/rules/global/*.md` |
| `instructions/languages/*.md` | `.claude/rules/languages/*.md` (with `paths` frontmatter) |
| `.vscode/mcp.json` | `.mcp.json` |

#### Key Transformations

**Model names** are mapped from VS Code format to Claude Code aliases:

| VS Code Model | Claude Code Alias |
|--------------|-------------------|
| `Claude Opus 4.6 (copilot)` | `opus` |
| `Claude Sonnet 4.6 (copilot)` | `sonnet` |
| `Claude Haiku 4.5 (copilot)` | `haiku` |
| `GPT-5.3-Codex (copilot)` | `sonnet` (fallback) |
| `Gemini 3.1 Pro (Preview) (copilot)` | `sonnet` (fallback) |

**Tool names** are mapped:

| VS Code Tool | Claude Code Tool |
|-------------|-----------------|
| `runSubagent` / `agent` | `Task` or `Task(agent1, agent2)` |
| `edit` | `Edit` |
| `readFile` | `Read` |
| `runCommands` | `Bash` |
| `search` | `Grep` |
| `fileSearch` | `Glob` |
| `fetch` | `Bash(curl *)` |
| `githubRepo` | `Bash(gh *)` |
| `changes` | `Bash(git diff*)` |
| `todos` | `TodoWrite` |

#### Three Output Modes

1. **Project Mode** — Creates `.claude/` in your target project. Agents are available only in that project.
2. **User Mode** — Installs to `~/.claude/`. Agents are available in all Claude Code sessions.
3. **Plugin Mode** — Creates a distributable plugin package with `.claude-plugin/plugin.json` manifest.

#### Plugin Distribution

Plugin mode creates a package that can be shared with your team:

```
copilot-orchestrator-plugin/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── agents/                   # 29 transformed agents
├── skills/                   # 16 skills + instruction skills
├── .mcp.json                 # MCP server config
└── README.md                 # Usage instructions
```

Install plugins in Claude Code:
```bash
# Test locally
claude --plugin-dir ./copilot-orchestrator-plugin

# Or install permanently
/plugin install
```

### Visual Studio

Visual Studio 2022 (17.x+) and Visual Studio 2025 support the same `.github/agents/` and `.github/prompts/` format as VS Code. No file transformation is needed — the setup script distributes files directly.

**Requirements:**
- Visual Studio 2022 version 17.x or later, or Visual Studio 2025
- GitHub Copilot extension enabled
- Active Copilot subscription

**What gets distributed:**

| Source | Destination (in target project) |
|--------|-------------------------------|
| `.github/agents/*.agent.md` | `.github/agents/*.agent.md` |
| `.github/skills/*/SKILL.md` | `.github/skills/*/SKILL.md` |
| `.github/prompts/*.prompt.md` | `.github/prompts/*.prompt.md` |
| `instructions/**/*.md` | `instructions/**/*.md` |
| `.github/copilot-instructions.md` | `.github/copilot-instructions.md` |

**How it works:**
- VS discovers agent files from `.github/agents/` in the solution/project root
- Use `@conductor` or other agents in Copilot Chat
- Skills, prompts, and instruction files load from standard locations
- Agent hooks defined in frontmatter (`hooks:` section) are included with the agent files

### Copilot CLI

The GitHub Copilot CLI discovers agents from `.github/agents/` in the current working directory. It uses the same format as VS Code — the setup script distributes files the same way as for Visual Studio.

**Requirements:**
- GitHub CLI (`gh`) installed from [cli.github.com](https://cli.github.com)
- `gh copilot` extension: `gh extension install github/gh-copilot`
- Authenticated: `gh auth login`

**What gets distributed:** Same as Visual Studio (agents, skills, prompts, instructions, copilot-instructions.md).

**Usage:**
```bash
# Navigate to project with agents
cd ~/projects/my-app

# Interactive mode
gh copilot

# Use specific agent in interactive mode — type @conductor to engage
```

See [Copilot CLI Onboarding](copilot-cli-onboarding.md) for interactive, one-off, chaining, and CI/CD patterns.

### Antigravity IDE

Antigravity is a Google DeepMind AI coding IDE that uses a different directory structure than VS Code. The setup scripts transform agents, skills, and instructions into the Antigravity `.agent/` format.

| VS Code Format | Antigravity Format |
|---------------|-------------------|
| `.github/agents/*.agent.md` | `.agent/agents/*.md` |
| `.github/skills/*/SKILL.md` | `.agent/skills/*/SKILL.md` |
| `.github/prompts/*.prompt.md` | `.agent/workflows/*.md` (slash commands) |
| `.github/copilot-instructions.md` | `.agent/ARCHITECTURE.md` |
| `instructions/**/*.md` | `.agent/rules/**/*.md` |
| `.vscode/mcp.json` | `.agent/mcp_config.json` |

#### Key Transformations

**Model names** are mapped from VS Code format to Antigravity aliases:

| VS Code Model | Antigravity Alias |
|--------------|-------------------|
| `Claude Opus 4.6 (copilot)` | `opus` |
| `Claude Sonnet 4.6 (copilot)` | `sonnet` |
| `Claude Haiku 4.5 (copilot)` | `haiku` |
| `Gemini 3.1 Pro (Preview) (copilot)` | `gemini-pro` |
| `GPT-5.3-Codex (copilot)` | `inherit` (uses IDE default) |

**Tool names** are mapped to Antigravity equivalents:

| VS Code Tool | Antigravity Tool |
|-------------|-----------------|
| `edit` | `Edit` |
| `readFile` | `Read` |
| `runCommands` | `Bash` |
| `search` | `Grep` |
| `fileSearch` | `Glob` |
| N/A | `Write` (Antigravity-specific) |

**Prompts become workflows** -- VS Code prompt templates are converted to Antigravity slash commands with `$ARGUMENTS` support.

#### Two Output Modes

1. **Project Mode** -- Creates `.agent/` in your target project with agents, skills, workflows, rules, and MCP config.
2. **User Mode** -- Installs skills globally to `~/.gemini/antigravity/skills/` for availability across all projects.

#### Output Structure

```
.agent/
+-- agents/           # 29 transformed agent definitions
+-- skills/           # 17 skill directories (SKILL.md format)
+-- workflows/        # Slash commands from prompt templates
+-- rules/            # Instruction files organized by category
|   +-- global/
|   +-- workflows/
|   +-- compliance/
|   +-- languages/
+-- mcp_config.json   # MCP server configuration
+-- ARCHITECTURE.md   # Project context from copilot-instructions.md
```

---

## Cross-Platform Notes

### Windows

- Use `powershell -File scripts/setup-*.ps1` (not `pwsh` — this repo targets PowerShell 5.1)
- Symlinks require elevated privileges (Run as Administrator) or Developer Mode enabled
- If symlinks fail, the script falls back with a warning — use `-Strategy Copy` instead

### macOS

- Bash scripts require bash 4+ (macOS ships bash 3.2 — install via `brew install bash`)
- Or use the PowerShell scripts with PowerShell Core: `brew install --cask powershell`
- Symlinks work without elevation

### Linux

- Bash scripts work with any modern bash (4+)
- Or install PowerShell Core: `snap install powershell --classic`
- Symlinks work without elevation

---

## Strategy Comparison

| Strategy | Pros | Cons | Best For |
|----------|------|------|----------|
| **Symlink** | Always up-to-date, no duplication | Requires linking permissions, single machine | Active development |
| **Copy** | Works everywhere, no permission issues | Gets stale, duplicates files | CI/CD, distribution |
| **Reference** | No file changes, IDE-level config | Manual setup, VS Code/VS only | Shared team environments |

---

## Troubleshooting

### Claude Code agents not visible

1. Verify `.claude/agents/` exists in your project or `~/.claude/agents/` for user-level
2. Run `/agents` in Claude Code to list discovered agents
3. Check frontmatter format — Claude Code requires `name` and `description` fields
4. For plugins, verify `.claude-plugin/plugin.json` exists

### Visual Studio doesn't show agents

1. Ensure `.github/agents/` is at the solution root, not inside a sub-project
2. Check VS version: 2022 17.x+ required
3. Ensure Copilot extension is enabled in Extensions → Manage Extensions
4. Restart VS after adding agent files

### Copilot CLI doesn't find agents

1. Ensure you're in a directory with `.github/agents/` (or a parent repo)
2. Run `gh copilot --help` to verify the extension is working
3. Check authentication: `gh auth status`
4. Reinstall extension: `gh extension install github/gh-copilot --force`

### Antigravity agents not detected

1. Verify `.agent/agents/` exists in your project root
2. Check that `.agent/` is NOT in your `.gitignore` (Antigravity needs to index it)
3. If using `.gitignore`, add `.agent/` to `.git/info/exclude` instead
4. For global skills, verify `~/.gemini/antigravity/skills/` exists
5. Restart Antigravity IDE after adding agent files

### Symlink creation fails on Windows

1. Enable Developer Mode: Settings → For developers → Developer Mode
2. Or run PowerShell as Administrator
3. Or use `-Strategy Copy` as a fallback

---

## Related Guides

### Per-Platform Onboarding

- [Claude Code Onboarding](claude-code-onboarding.md) — Quick start, model/tool mapping, project/user/plugin modes
- [Antigravity IDE Onboarding](antigravity-onboarding.md) — Quick start, workflows, project/user modes
- [Visual Studio Onboarding](visual-studio-onboarding.md) — Quick start, distribution strategies, validation
- [Copilot CLI Onboarding](copilot-cli-onboarding.md) — Quick start, interactive/one-off/chaining/CI patterns

### Reference

- [VS Code Configuration](vscode-copilot-configuration.md) — Full VS Code settings reference
- [Claude Skills Migration](claude-skills-migration.md) — Converting prompts to skills format
- [Copilot CLI Usage](copilot-cli-usage.md) — Complete CLI agent guide
- [Central Deployment](central-deployment.md) — Org-level deployment patterns
- [MCP Integration](mcp-integration.md) — MCP server setup across platforms
