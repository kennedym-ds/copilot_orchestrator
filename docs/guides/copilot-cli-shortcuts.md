---
version: 1.0.0
lastUpdated: 2026-04-22
---

# Copilot CLI Shortcuts

Productivity shortcuts for heavy Copilot CLI users. Copy-paste into your shell profile.

## PowerShell (Windows)

Add to `$PROFILE` (run `notepad $PROFILE` to edit):

```powershell
# Copilot orchestrator shortcuts
function Invoke-CopilotConductor { copilot chat --agent conductor @args }
function Invoke-CopilotPlanner { copilot chat --agent planner @args }
function Invoke-CopilotImplementer { copilot chat --agent implementer @args }
function Invoke-CopilotReviewer { copilot chat --agent reviewer @args }
function Invoke-CopilotReviewerSecurity { copilot chat --agent reviewer --security @args }
function Invoke-CopilotResearcher { copilot chat --agent researcher @args }
function Invoke-CopilotDocs { copilot chat --agent docs @args }

Set-Alias cc Invoke-CopilotConductor
Set-Alias cplan Invoke-CopilotPlanner
Set-Alias cimp Invoke-CopilotImplementer
Set-Alias crev Invoke-CopilotReviewer
Set-Alias crevsec Invoke-CopilotReviewerSecurity
Set-Alias cresearch Invoke-CopilotResearcher
Set-Alias cdocs Invoke-CopilotDocs
```

Reload: `. $PROFILE`

Usage:

```powershell
cc "Add input validation to all scripts"
cplan "Multi-phase plan for MCP server hardening"
crevsec "Review scripts/mcp/validation_server.py"
```

## Bash / Zsh (macOS, Linux, WSL)

Add to `~/.bashrc` or `~/.zshrc`:

```bash
# Copilot orchestrator shortcuts
alias cc='copilot chat --agent conductor'
alias cplan='copilot chat --agent planner'
alias cimp='copilot chat --agent implementer'
alias crev='copilot chat --agent reviewer'
alias crevsec='copilot chat --agent reviewer --security'
alias cresearch='copilot chat --agent researcher'
alias cdocs='copilot chat --agent docs'

# One-shot headless review of current branch diff
cplan-diff() {
    git diff origin/main...HEAD | copilot chat --agent reviewer -p "Review this diff"
}
```

Reload: `source ~/.bashrc` or `source ~/.zshrc`

## Fish

Add to `~/.config/fish/config.fish`:

```fish
function cc; copilot chat --agent conductor $argv; end
function cplan; copilot chat --agent planner $argv; end
function cimp; copilot chat --agent implementer $argv; end
function crev; copilot chat --agent reviewer $argv; end
function crevsec; copilot chat --agent reviewer --security $argv; end
```

## Headless One-Liners

Non-interactive invocations for scripting:

```bash
# Review the current diff
git diff | copilot chat --agent reviewer -p "Review this diff for correctness"

# Research a library
copilot chat --agent researcher -p "What are the MCP sandbox features in VS Code 1.115?"

# Generate a plan for a feature
copilot chat --agent planner -p "Plan for adding OAuth2 to the analytics MCP server"
```

Headless mode is documented per agent under the `examples:` frontmatter key. See [copilot-cli-usage.md](copilot-cli-usage.md) for full patterns.

## Related

- [copilot-cli-onboarding.md](copilot-cli-onboarding.md) — First-time setup
- [copilot-cli-usage.md](copilot-cli-usage.md) — Full agent reference and permission modes

Closes gap G35 from the SOTA gap analysis.