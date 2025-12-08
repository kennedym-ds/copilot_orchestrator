# GitHub Copilot CLI Usage Guide

This guide explains how to invoke the custom agents in this repository from the GitHub Copilot CLI.

## Prerequisites

1. **GitHub Copilot subscription**: Copilot Pro, Pro+, Business, or Enterprise
2. **Node.js**: Version 22 or later
3. **npm**: Version 10 or later
4. **Copilot CLI installed**:
   ```bash
   npm install -g @github/copilot
   ```

## Quick Start

Navigate to the repository root and start a session:

```bash
cd path/to/copilot_orchestrator
copilot
```

Or run a one-off prompt:

```bash
copilot --agent=conductor --prompt "Plan a new feature for agent handoffs"
```

## Available Agents

### Core Workflow Agents

| Agent | Command | Use Case |
|-------|---------|----------|
| Conductor | `--agent=conductor` | Orchestrate multi-phase tasks |
| Planner | `--agent=planner` | Create implementation plans |
| Implementer | `--agent=implementer` | Execute plans with TDD |
| Reviewer | `--agent=reviewer` | Review changes for quality |
| Researcher | `--agent=researcher` | Gather context and evidence |

### Support Agents

| Agent | Command | Use Case |
|-------|---------|----------|
| Security | `--agent=security` | Security and compliance review |
| Performance | `--agent=performance` | Performance analysis |
| Docs | `--agent=docs` | Documentation updates |
| Accessibility | `--agent=accessibility` | WCAG compliance audits |
| Test | `--agent=test` | Write comprehensive tests |
| Lint | `--agent=lint` | Code style and formatting |

### Specialized Agents

| Agent | Command | Use Case |
|-------|---------|----------|
| Terraform | `--agent=terraform` | Infrastructure as Code (multi-cloud) |
| Bicep | `--agent=bicep` | Azure IaC |
| Data Analytics | `--agent=data-analytics` | DS-Star iterative analysis |
| Observability | `--agent=observability` | Telemetry and metrics |
| Red Team | `--agent=red-team` | Adversarial testing |
| Beast Mode | `--agent=beast-mode` | Extended reasoning with visible thinking |

## Example Workflows

### Plan and Implement a Feature

```bash
# Step 1: Create a plan
copilot --agent=planner --prompt "Create a multi-phase plan to add input validation to all PowerShell scripts"

# Step 2: Execute the first phase
copilot --agent=implementer --prompt "Execute Phase 1: Add parameter validation to validate-copilot-assets.ps1"

# Step 3: Review the changes
copilot --agent=reviewer --prompt "Review the parameter validation changes for correctness and coverage"
```

### Security Review

```bash
copilot --agent=security --prompt "Review the recent changes to scripts/ for credential handling and input validation"
```

### Run Tests and Fix Issues

```bash
# Check test coverage
copilot --agent=test --prompt "Identify coverage gaps in tests/powershell/ and write tests for uncovered functions"

# Fix style issues
copilot --agent=lint --prompt "Run lint checks and fix formatting issues in scripts/"
```

### Data Analysis (DS-Star Workflow)

```bash
copilot --agent=data-analytics --prompt "Analyze agent session logs to identify patterns in escalation frequency"
```

### Accessibility Audit

```bash
copilot --agent=accessibility --prompt "Conduct WCAG 2.2 AA audit on the dashboard documentation"
```

## Interactive Mode

Start an interactive session for back-and-forth conversation:

```bash
copilot
```

Then switch agents during the session:

```
> @conductor Plan a new documentation update workflow
> @planner Break this into phases
> @implementer Execute Phase 1
```

## Programmatic Mode

For CI/CD pipelines or scripts, use programmatic mode with auto-approval:

```bash
# Run validation with auto-approval (use with caution)
copilot --agent=lint --prompt "Fix all markdown formatting issues" --allow-all-tools

# Generate test coverage report
copilot --agent=test --prompt "Run tests and report coverage gaps" -p
```

## Tips for Effective Prompts

### Be Specific

```bash
# ✅ Good - specific scope and outcome
copilot --agent=implementer --prompt "Add parameter validation to Get-ValidationResult function in validate-copilot-assets.ps1 following the existing patterns in the file"

# ❌ Vague - unclear scope
copilot --agent=implementer --prompt "Make the code better"
```

### Provide Context

```bash
# ✅ Good - includes relevant context
copilot --agent=security --prompt "Review changes in PR #42 affecting scripts/add-prompt-metadata.ps1 for path traversal and input validation"

# ❌ Missing context
copilot --agent=security --prompt "Is it secure?"
```

### Chain Agent Calls

```bash
# Use output from one agent as input to another
PLAN=$(copilot --agent=planner --prompt "Plan token budget optimization" -p)
copilot --agent=implementer --prompt "Execute this plan: $PLAN"
```

## Troubleshooting

### Agent Not Found

Ensure the agent file exists in `.github/agents/` with the correct naming:
- File: `agent-name.agent.md`
- Command: `--agent=agent-name`

### Permission Errors

When prompted, select the appropriate trust level:
- "Yes, proceed" - Trust for this session only
- "Yes, and remember this folder" - Trust for future sessions

### Tool Approval

Some tools require approval before execution. Options:
- "Yes" - Approve once
- "Yes, and approve for session" - Approve for remaining session
- "No" - Reject and provide alternative instructions

## Resources

- [GitHub Copilot CLI Documentation](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli)
- [About GitHub Copilot CLI](https://docs.github.com/en/copilot/concepts/agents/about-copilot-cli)
- [Custom Agents Documentation](https://docs.github.com/en/copilot/concepts/agents/coding-agent/about-custom-agents)
- [MCP Server Integration](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli#add-an-mcp-server)
