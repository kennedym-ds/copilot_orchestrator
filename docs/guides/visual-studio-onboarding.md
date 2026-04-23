---
title: "Visual Studio Onboarding Guide"
version: "1.1.0"
lastUpdated: "2026-03-10"
status: stable
---

# Visual Studio Onboarding

Get the Copilot Orchestrator's 29 agents running in Visual Studio in under 5 minutes.

## Prerequisites

- Visual Studio 2022 (version 17.x+) or Visual Studio 2025
- GitHub Copilot extension enabled
- Active GitHub Copilot subscription (Pro, Pro+, Business, or Enterprise)
- A local clone of the `copilot_orchestrator` repository
- PowerShell 5.1 (Windows) or Bash 4+ (macOS/Linux)

## Quick Start

### 1. Run the setup script

Visual Studio uses the same `.github/agents/*.agent.md` format as VS Code — no transformation needed. The script distributes agent files to your target project.

**Windows (recommended):**
```powershell
cd path\to\copilot_orchestrator
powershell -File scripts/setup-vs-cli.ps1 -Strategy Symlink -TargetPath C:\Projects\my-app
```

**macOS / Linux:**
```bash
cd path/to/copilot_orchestrator
./scripts/setup-vs-cli.sh --strategy link --target ~/projects/my-app
```

### 2. Open the project in Visual Studio

Open your solution or project folder. Visual Studio discovers agent files from `.github/agents/` at the solution root automatically.

### 3. Start using agents

Open Copilot Chat in Visual Studio and invoke an agent:

```
@conductor Plan a new feature for user authentication
```

## Distribution Strategies

| Strategy | Command Flag | What It Does |
|----------|-------------|-------------|
| **Symlink** | `-Strategy Symlink` | Creates symbolic links to the orchestrator repo. Agents stay up-to-date automatically. |
| **Copy** | `-Strategy Copy` | Copies files into target project. Works everywhere but gets stale. |
| **Reference** | `-Strategy Reference` | Prints the settings to add manually. No files modified. |

### Which strategy to use

| Scenario | Recommended Strategy |
|----------|---------------------|
| Active development, same machine as orchestrator | Symlink |
| CI/CD pipelines, distribution to team | Copy |
| Shared environments, manual control | Reference |

### Symlink (recommended)

```powershell
powershell -File scripts/setup-vs-cli.ps1 -Strategy Symlink -TargetPath C:\Projects\my-app
```

> **Windows note:** Symlinks require either Developer Mode enabled or an elevated (Administrator) PowerShell session. If symlinks fail, the script warns you — use `-Strategy Copy` as a fallback.

**Enable Developer Mode:** Settings → Privacy & security → For developers → Developer Mode → On

### Copy

```powershell
powershell -File scripts/setup-vs-cli.ps1 -Strategy Copy -TargetPath C:\Projects\my-app
```

Files are duplicated. Re-run the script to pick up updates from the orchestrator repo.

### Reference

```powershell
powershell -File scripts/setup-vs-cli.ps1 -Strategy Reference
```

Prints the paths and settings you need to configure manually. Useful when neither Symlink nor Copy suits your workflow.

## Validate the Setup

Check that agent files are correctly distributed:

```powershell
# Windows
powershell -File scripts/setup-vs-cli.ps1 -ValidateOnly -TargetPath C:\Projects\my-app

# macOS / Linux
./scripts/setup-vs-cli.sh --validate --target ~/projects/my-app
```

Exit code `0` means all checks pass. Exit code `1` means issues were found — review the output.

## Using Agents in Visual Studio

### Core workflow

The orchestration lifecycle works the same way regardless of platform:

```
@conductor → @planner → @implementer → @reviewer → completion
```

```
@conductor Create a REST API for user management with JWT auth
```

The conductor delegates to specialized agents automatically.

### Direct agent access

Use agents directly in Copilot Chat:

```
@planner Draft a 3-phase plan for migrating the database layer
@implementer Execute Phase 1 of the migration plan
@reviewer Review the Phase 1 changes for correctness
@researcher What are the trade-offs between Prisma and Drizzle ORM?
@security Review the auth changes for OWASP Top 10 compliance
```

### Available agents

All 29 agents from the orchestrator are available:

| Category | Agents |
|----------|--------|
| **Core** | conductor, planner, implementer, reviewer, researcher, maintainer, spec |
| **Support** | security, performance, accessibility, docs, observability, visualizer, deployment, red-team |
| **Translation** | translation-conductor, translator, translation-analyzer, translation-validator, translation-styler |
| **Specialist** | test, lint, github-ops, terraform, bicep, design, gui-tester, rubber-duck |

## What Gets Distributed

Since Visual Studio uses the same format as VS Code, no transformation occurs. The script distributes these directories:

| Source | Destination (in target project) |
|--------|-------------------------------|
| `.github/agents/*.agent.md` | `.github/agents/*.agent.md` |
| `.github/skills/*/SKILL.md` | `.github/skills/*/SKILL.md` |
| `.github/prompts/*.prompt.md` | `.github/prompts/*.prompt.md` |
| `instructions/**/*.md` | `instructions/**/*.md` |
| `.github/copilot-instructions.md` | `.github/copilot-instructions.md` |

Hooks defined in agent frontmatter (`hooks:` section) are included automatically since they're part of the `.agent.md` files.

## Updating Agents

### Symlink strategy

No action needed. Symlinks point to the orchestrator repo, so pulling updates there automatically updates agents in your project.

### Copy strategy

Re-run the copy command to pick up changes:

```powershell
powershell -File scripts/setup-vs-cli.ps1 -Strategy Copy -TargetPath C:\Projects\my-app
```

## Troubleshooting

### Visual Studio doesn't show agents

1. Ensure `.github/agents/` is at the **solution root**, not inside a sub-project
2. Verify Visual Studio version: 2022 17.x+ or 2025 required
3. Confirm the Copilot extension is enabled: Extensions → Manage Extensions
4. Restart Visual Studio after adding agent files

### Symlink creation fails

1. **Enable Developer Mode:** Settings → Privacy & security → For developers → Developer Mode → On
2. Or run PowerShell as Administrator
3. Or use `-Strategy Copy` as a fallback

### Agents visible but not responding

1. Check your Copilot subscription is active: `gh auth status`
2. Verify the Copilot extension is up-to-date in Visual Studio
3. Check network connectivity — Copilot requires internet access

### Validate reports missing agents

Run the validation script and review its output:

```powershell
powershell -File scripts/setup-vs-cli.ps1 -ValidateOnly -TargetPath C:\Projects\my-app
```

Common causes:
- Target path doesn't contain `.github/agents/` — re-run setup
- Symlinks broke because the orchestrator repo moved — re-create symlinks
- File permissions prevent reading — check directory permissions

## Related Guides

- [Multi-Platform Setup Reference](multi-platform-setup.md) — Full platform comparison and technical details
- [VS Code Configuration](vscode-copilot-configuration.md) — VS Code-specific settings (many apply to VS too)
- [Onboarding Guide](onboarding.md) — VS Code-focused contributor onboarding
- [Copilot CLI Onboarding](copilot-cli-onboarding.md) — Uses the same setup script
