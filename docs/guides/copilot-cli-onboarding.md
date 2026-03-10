---
title: "Copilot CLI Onboarding Guide"
version: "1.1.0"
lastUpdated: "2026-03-10"
status: stable
---

# Copilot CLI Onboarding

Get the Copilot Orchestrator's 29 agents running from the command line in under 5 minutes.

## Prerequisites

- Active GitHub Copilot subscription (Pro, Pro+, Business, or Enterprise)
- **Option A:** Node.js 22+ and npm 10+
- **Option B:** GitHub CLI (`gh`) installed

## Quick Start

### 1. Install the CLI

Choose one installation method:

**Option A — npm (standalone):**
```bash
npm install -g @github/copilot
```

**Option B — GitHub CLI extension:**
```bash
gh extension install github/gh-copilot
gh auth login
```

### 2. Navigate to a project with agents

The CLI discovers agents from `.github/agents/` in the current directory.

```bash
cd path/to/copilot_orchestrator
```

Or, if you want agents in a different project, distribute them first:

```powershell
# Windows
powershell -File scripts/setup-vs-cli.ps1 -Strategy Symlink -TargetPath C:\Projects\my-app

# macOS / Linux
./scripts/setup-vs-cli.sh --strategy link --target ~/projects/my-app
```

### 3. Start using agents

**Interactive mode** — start a session and switch agents freely:
```bash
copilot
```

Then in the session:
```
> @conductor Plan a new feature for user authentication
> @planner Break this into phases
> @implementer Execute Phase 1
```

**One-off mode** — run a single prompt:
```bash
copilot --agent=conductor --prompt "Plan a new feature for user authentication"
```

**GitHub CLI variant:**
```bash
gh copilot
```

## Usage Patterns

### Interactive session

Best for exploratory work and multi-step workflows:

```bash
copilot
```

Switch agents during the session with `@agent-name`:

```
> @conductor Plan a REST API for order management
> @researcher What ORMs work best with PostgreSQL in Node.js?
> @planner Create a 3-phase implementation plan
> @implementer Execute Phase 1
> @reviewer Review the Phase 1 changes
```

### One-off prompts

Best for scripting, automation, or quick tasks:

```bash
# Plan a feature
copilot --agent=planner --prompt "Plan token budget optimization for scripts/"

# Run a security review
copilot --agent=security --prompt "Review changes in scripts/ for input validation"

# Fix lint issues
copilot --agent=lint --prompt "Fix markdown formatting in docs/"

# Write tests
copilot --agent=test --prompt "Add unit tests for validate-copilot-assets.ps1"
```

### Chaining agents

Pipe the output of one agent into another:

```bash
# Plan, then implement
PLAN=$(copilot --agent=planner --prompt "Plan database migration" -p)
copilot --agent=implementer --prompt "Execute this plan: $PLAN"
```

### CI/CD automation

For pipelines, use programmatic mode with auto-approval (use with caution):

```bash
copilot --agent=lint --prompt "Fix all formatting issues" --allow-all-tools -p
copilot --agent=test --prompt "Run tests and report coverage gaps" -p
```

> **Warning:** `--allow-all-tools` grants the agent permission to execute commands without confirmation. Only use in trusted, sandboxed environments.

## Available Agents

| Category | Agents |
|----------|--------|
| **Core** | `conductor`, `planner`, `implementer`, `reviewer`, `researcher`, `maintainer`, `spec` |
| **Support** | `security`, `performance`, `accessibility`, `docs`, `observability`, `visualizer`, `deployment`, `red-team` |
| **Translation** | `translation-conductor`, `translator`, `translation-analyzer`, `translation-validator`, `translation-styler` |
| **Specialist** | `test`, `lint`, `github-ops`, `terraform`, `bicep`, `design`, `beast-mode`, `gui-tester`, `rubber-duck` |

Use `--agent=agent-name` for one-off mode or `@agent-name` in interactive mode.

## Distributing Agents to Other Projects

The CLI discovers agents from `.github/agents/` in the working directory. To use orchestrator agents in another project:

| Strategy | Command | Best For |
|----------|---------|----------|
| **Symlink** | `-Strategy Symlink` | Active development (auto-updates) |
| **Copy** | `-Strategy Copy` | CI/CD, distribution to team |
| **Reference** | `-Strategy Reference` | Manual configuration |

```powershell
# Windows
powershell -File scripts/setup-vs-cli.ps1 -Strategy Symlink -TargetPath C:\Projects\my-app

# macOS / Linux
./scripts/setup-vs-cli.sh --strategy link --target ~/projects/my-app
```

Validate the distribution:

```powershell
# Windows
powershell -File scripts/setup-vs-cli.ps1 -ValidateOnly -TargetPath C:\Projects\my-app

# macOS / Linux
./scripts/setup-vs-cli.sh --validate --target ~/projects/my-app
```

## Tips for Effective Prompts

**Be specific about scope and expected outcome:**
```bash
# Good
copilot --agent=implementer --prompt "Add parameter validation to Get-ValidationResult in validate-copilot-assets.ps1 following existing patterns"

# Vague
copilot --agent=implementer --prompt "Make scripts better"
```

**Provide context when relevant:**
```bash
# Good
copilot --agent=security --prompt "Review changes in PR #42 affecting scripts/add-prompt-metadata.ps1 for path traversal"

# Missing context
copilot --agent=security --prompt "Is it secure?"
```

## Troubleshooting

### Agent not found

1. Ensure you're in a directory with `.github/agents/` (or a parent with that directory)
2. Check agent file naming: `agent-name.agent.md` → `--agent=agent-name`
3. Verify the CLI installation: `copilot --help` or `gh copilot --help`

### Authentication issues

```bash
# Check auth status
gh auth status

# Re-authenticate
gh auth login

# Verify Copilot access
gh copilot --help
```

### Tool approval prompts

When the CLI asks for tool approval:
- **Yes** — Approve this one action
- **Yes, and approve for session** — Approve all similar actions for the session
- **No** — Reject and provide alternative instructions

### Permission errors on first run

When prompted, select the appropriate trust level:
- **Yes, proceed** — Trust for this session only
- **Yes, and remember this folder** — Trust for future sessions in this directory

## Related Guides

- [Copilot CLI Usage Guide](copilot-cli-usage.md) — Advanced usage patterns, all agent commands, programmatic mode
- [Multi-Platform Setup Reference](multi-platform-setup.md) — Full platform comparison and strategy details
- [Visual Studio Onboarding](visual-studio-onboarding.md) — Uses the same setup script
- [Onboarding Guide](onboarding.md) — VS Code-focused contributor onboarding
