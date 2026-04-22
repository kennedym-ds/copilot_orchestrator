# Tooling Maintainer Guidance (scripts/)

> This is the directory-scoped AGENTS.md (standard convention). The canonical orchestrator playbook lives at [AGENTS.md](../AGENTS.md) in the repo root; read that first for agent roster, lifecycle, and model allocation. This file covers only the scripts/ maintenance contract.

Scripts in this directory provide validation, metadata normalization, reporting, and cross-platform setup for the Copilot Orchestrator. Maintain them with the following principles:

- PowerShell 5.1 compatibility is mandatory; avoid cmdlets or syntax requiring newer runtimes.
- Include `Set-StrictMode -Version 2.0` and prefer terminating errors (`$ErrorActionPreference = 'Stop'`).
- Accept a `-RepositoryRoot` or `-Path` parameter so scripts can run from CI and local terminals without relying on relative paths.
- Avoid third-party module dependencies; rely only on built-in cmdlets.
- Emit friendly console output plus non-zero exit codes when validation fails. Provide actionable remediation hints.
- When adding new scripts, document usage in `AGENTS.md` (root) and `docs/operations.md`, and wire them into CI if they gate quality.
- Update `docs/CHANGELOG.md` whenever script behavior changes and capture follow-up tasks in the operations backlog.
- For cross-platform scripts, provide both PowerShell (`.ps1`) and Bash (`.sh`) versions targeting the same behavior.

## Cross-Platform Setup Scripts

These scripts export orchestrator agents, skills, and instructions to other platforms.

### setup-claude-code.ps1 / setup-claude-code.sh

Export orchestrator assets to Claude Code format. Transforms agent frontmatter (model names, tool names), copies skills, converts instructions to CLAUDE.md + rules, and optionally creates a distributable plugin.

```powershell
# Project-level (agents available in one project)
powershell -File scripts/setup-claude-code.ps1 -Mode Project -TargetPath C:\Projects\my-app

# User-level (agents available globally)
powershell -File scripts/setup-claude-code.ps1 -Mode User

# Plugin package (distributable)
powershell -File scripts/setup-claude-code.ps1 -Mode Plugin -TargetPath ./dist/plugin
```

```bash
# Bash equivalent
./scripts/setup-claude-code.sh --mode project --target ~/projects/my-app
./scripts/setup-claude-code.sh --mode user
./scripts/setup-claude-code.sh --mode plugin --target ./dist/plugin
```

**Parameters (PS1):** `-RepositoryRoot`, `-TargetPath`, `-Mode` (Project|User|Plugin), `-IncludeInstructions`, `-IncludeMcp`, `-Force`
**Options (sh):** `--repo`, `--target`, `--mode`, `--no-instructions`, `--no-mcp`, `--force`

### setup-vs-cli.ps1 / setup-vs-cli.sh

Configure orchestrator agents for Visual Studio (2022+) and GitHub Copilot CLI. Since these platforms use the same `.github/agents/` format as VS Code, no file transformation is needed — the scripts create symlinks, copy files, or print reference settings.

```powershell
# Symlink (recommended for active development)
powershell -File scripts/setup-vs-cli.ps1 -Strategy Symlink -TargetPath C:\Projects\my-app

# Copy files
powershell -File scripts/setup-vs-cli.ps1 -Strategy Copy -TargetPath C:\Projects\my-app

# Print IDE settings for manual configuration
powershell -File scripts/setup-vs-cli.ps1 -Strategy Reference

# Validate existing setup
powershell -File scripts/setup-vs-cli.ps1 -ValidateOnly
```

```bash
# Bash equivalent
./scripts/setup-vs-cli.sh --strategy link --target ~/projects/my-app
./scripts/setup-vs-cli.sh --strategy copy --target ~/projects/my-app
./scripts/setup-vs-cli.sh --strategy reference
./scripts/setup-vs-cli.sh --validate
```

**Parameters (PS1):** `-RepositoryRoot`, `-TargetPath`, `-Platform` (VisualStudio|CopilotCLI|Both), `-Strategy` (Symlink|Copy|Reference), `-Force`, `-ValidateOnly`
**Options (sh):** `--repo`, `--target`, `--strategy`, `--force`, `--validate`

### setup-antigravity.ps1 / setup-antigravity.sh

Export orchestrator assets to Antigravity IDE format. Transforms agents into `.agent/agents/`, copies skills, generates slash-command workflows from prompt templates, converts instructions to rules, and configures MCP.

```powershell
# Project-level (agents, skills, workflows in .agent/)
powershell -File scripts/setup-antigravity.ps1 -Mode Project -TargetPath C:\Projects\my-app

# User-level (skills globally in ~/.gemini/antigravity/skills/)
powershell -File scripts/setup-antigravity.ps1 -Mode User

# Force overwrite
powershell -File scripts/setup-antigravity.ps1 -Mode Project -TargetPath . -Force
```

```bash
# Bash equivalent
./scripts/setup-antigravity.sh --mode project --target ~/projects/my-app
./scripts/setup-antigravity.sh --mode user
./scripts/setup-antigravity.sh --mode project --target . --force
```

**Parameters (PS1):** `-RepositoryRoot`, `-TargetPath`, `-Mode` (Project|User), `-IncludeInstructions`, `-IncludeMcp`, `-IncludeWorkflows`, `-Force`
**Options (sh):** `--repo`, `--target`, `--mode`, `--no-instructions`, `--no-mcp`, `--no-workflows`, `--force`

See `docs/guides/multi-platform-setup.md` for the comprehensive setup guide.
