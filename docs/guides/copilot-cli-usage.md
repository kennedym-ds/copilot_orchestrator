---
version: 3.0.0
lastUpdated: 2026-04-16
---

# GitHub Copilot CLI Usage Guide

Definitive guide for using the Copilot Orchestrator with GitHub Copilot CLI. Covers all 16 agents, complexity routing, MCP integration, and new verification features.

## Prerequisites

1. **GitHub Copilot subscription**: Copilot Pro, Business, or Enterprise
2. **Copilot CLI**: VS Code 1.113+ with CLI support
3. **Workspace cloned**:
   ```powershell
   git clone https://github.com/your-org/copilot_orchestrator.git
   cd copilot_orchestrator
   ```
4. **MCP servers configured**: See `.vscode/mcp.json` (auto-loaded in CLI sessions)

## Quick Start

Start a CLI session with agent context from the workspace root:

```bash
# Interactive session with conductor
copilot chat --agent conductor

# One-off command
copilot chat --agent planner "Create a plan for adding input validation to scripts"
```

Agents, instructions, and skills are auto-discovered from workspace paths. MCP servers bridge to CLI sessions.

## Agent Roster

### Core Agents (11)

| Agent | Tier | Purpose | When to Use |
|-------|------|---------|-------------|
| **conductor** | Premium | Lifecycle orchestration, delegation, pause points | Multi-phase tasks requiring planning â†’ implementation â†’ review |
| **planner** | Premium | Multi-phase planning, risk analysis | Deep/Ultra complexity tasks before implementation |
| **reviewer** | Premium | Multi-mode code review (standard/security/adversarial/performance) | After implementation or for standalone review |
| **implementer** | Execution | TDD execution, validation, pushback | Execute plans, implement features, fix bugs |
| **researcher** | Execution | Evidence gathering, citation | Investigate issues, gather context before planning |
| **ops** | Execution | Issues, PRs, CI/CD, releases, telemetry | DevOps tasks, GitHub workflows, deployment |
| **test** | Execution | Test authoring, coverage analysis | Write tests, identify gaps, improve coverage |
| **iac** | Execution | Terraform, Bicep, Pulumi | Infrastructure changes, cloud resources |
| **gui-tester** | Execution | Browser automation, visual regression | End-to-end testing, UI validation |
| **docs** | Fast | Documentation, onboarding | Update guides, write API docs, create READMEs |
| **ux** | Fast | UX review, WCAG accessibility, diagrams | Accessibility audits, UX improvements |

### Translation Agents (5)

| Agent | Purpose |
|-------|---------|
| **translation-conductor** | Full-repo translation orchestration |
| **translator** | File-level code translation |
| **translation-analyzer** | Dependency graph, complexity assessment |
| **translation-validator** | Validation stack, confidence scoring |
| **translation-styler** | Target language idioms |

## Complexity Routing

The conductor routes tasks based on complexity:

| Tier | Path | Use For |
|------|------|---------|
| **Instant** | â†’ Implementer directly | Single-file edits, simple fixes, no plan needed |
| **Standard** | â†’ Implementer + inline plan | 2-3 file changes, clear scope, optional review |
| **Deep** | â†’ Planner â†’ Implementer â†’ Reviewer | Multi-phase work, cross-cutting changes, new features |
| **Ultra** | â†’ Full cycle + pause points | Major refactors, architecture changes, high-risk work |

## Common Workflows

### Feature Development

```bash
# Step 1: Conductor assesses complexity and routes
copilot chat --agent conductor "Add validation to all PowerShell scripts"

# OR manual routing for Deep tasks:
# Step 2: Plan the work
copilot chat --agent planner "Create multi-phase plan for PowerShell validation"

# Step 3: Execute phase 1
copilot chat --agent implementer "Execute Phase 1: Add param validation to validate-copilot-assets.ps1"

# Step 4: Review
copilot chat --agent reviewer "Review validation changes for correctness"
```

### Bug Fix

```bash
# Step 1: Investigate
copilot chat --agent researcher "Investigate why token-report.ps1 fails on empty directories"

# Step 2: Fix (implementer will run TDD cycle)
copilot chat --agent implementer "Fix token-report.ps1 to handle empty directories gracefully"

# Step 3: Review
copilot chat --agent reviewer --security "Review the fix for edge cases and error handling"
```

### Code Review with Modes

```bash
# Standard review
copilot chat --agent reviewer "Review recent changes to scripts/mcp/"

# Security-focused review
copilot chat --agent reviewer --security "Review scripts/add-prompt-metadata.ps1 for path traversal and injection risks"

# Adversarial review (stress-test logic)
copilot chat --agent reviewer --adversarial "Find edge cases in validation-server.py"

# Performance review
copilot chat --agent reviewer --performance "Analyze token-report.ps1 for optimization opportunities"
```

### Infrastructure Changes

```bash
# Bicep/Terraform changes
copilot chat --agent iac "Add Azure Storage account with lifecycle policies to infra/bicep/storage.bicep"

# Review IaC changes
copilot chat --agent reviewer --security "Review infra/ changes for least-privilege and encryption"
```

### GUI Testing

```bash
# Create browser test
copilot chat --agent gui-tester "Write Playwright test for docs/guides/ navigation flow"

# Run visual regression
copilot chat --agent gui-tester "Capture screenshots and compare against baseline"
```

### Documentation Updates

```bash
# Update guide
copilot chat --agent docs "Update docs/guides/onboarding.md to reflect new MCP servers"

# API docs
copilot chat --agent docs "Document the validation-server MCP endpoints"
```

### Translation Workflow

```bash
# Translate entire repo
copilot chat --agent translation-conductor "Translate this Python codebase to Go"

# Single file translation
copilot chat --agent translator "Translate scripts/mcp/validation_server.py to TypeScript"
```

## New Features in Practice

### Pushback System

The implementer can refuse or counter questionable requests:

```bash
# User request
copilot chat --agent implementer "Remove all error handling to improve performance"

# Implementer response
# âš ï¸ PUSHBACK: Removing error handling violates safety baseline and would introduce
# production risks. COUNTER: Profile first to identify actual bottlenecks, then
# optimize hot paths while preserving error handling. Proceed? (y/n)
```

### File Risk Classification

Reviewer tags files by risk level in findings:

```
ðŸŸ¢ Additive: scripts/new-helper.ps1 (new utility, low risk)
ðŸŸ¡ Existing logic: scripts/validate-copilot-assets.ps1 (modified validation, medium risk)
ðŸ”´ Critical path: scripts/mcp/validation_server.py (core MCP server, high risk)
```

### Evidence-Based Verification

3-tier cascade for validation:

1. **Automated** (preferred): Run tests, lint, build
2. **Manual** (fallback): Smoke tests, spot checks
3. **Formal** (high-risk): Compliance scans, security audits

```bash
# Implementer runs verification after changes
# âœ… VERIFICATION:
# - Build: PASS (pwsh syntax check)
# - Tests: PASS (Pester: 12/12)
# - Lint: PASS (PSScriptAnalyzer: 0 issues)
# - Typecheck: N/A
```

### Confidence Levels

Reviewer reports confidence for each finding:

```
HIGH: 3+ signal types (static analysis + runtime behavior + security scan)
MEDIUM: 2 signal types (e.g., code inspection + manual test)
LOW: 1 signal type (code inspection only)
```

Minimum signal: â‰¥2 required to surface a finding.

### Auto-Commit Offer

After validation passes, implementer offers to commit:

```bash
# âœ… All validation passed. Commit changes? (y/n)
# Files:
# - scripts/validate-copilot-assets.ps1
# - tests/powershell/Validate-CopilotAssets.Tests.ps1
```

### Context7 MCP Integration

Agents with Context7 access (implementer, researcher) fetch live library docs:

```bash
# Implementer fetches FastAPI docs
copilot chat --agent implementer "Add rate limiting to validation-server using FastAPI middleware"

# (Implementer queries Context7 for FastAPI middleware docs, then implements)
```

### Wiki Memory

Persistent knowledge base across sessions:

- **Location**: `artifacts/memory/wiki/`
- **Pages**: 5 core pages (Karpathy pattern)
- **Usage**: Agents read/write to preserve learnings

```bash
# Session 1: Create validation pattern
copilot chat --agent implementer "Implement Pester test pattern for MCP servers"

# Session 2: Reuse pattern
copilot chat --agent implementer "Apply the MCP test pattern to analytics-server"
# (Implementer reads wiki entry from Session 1)
```

## MCP Server Integration

MCP servers are configured in `.vscode/mcp.json` and bridge to CLI sessions:

| Server | Path | Purpose |
|--------|------|---------|
| **validation-server** | `scripts/mcp/validation_server.py` | Validate agents, prompts, skills |
| **analytics-server** | `scripts/mcp/analytics_server.py` | Session analytics, metrics |
| **research-server** | `scripts/mcp/research_server.py` | Evidence gathering, citations |
| **translation-server** | `scripts/mcp/translation_server.py` | Translation validation, confidence |
| **Context7** | `https://mcp.context7.com/mcp` | Live library documentation |

CLI sessions automatically discover and connect to MCP servers. No additional setup required.

## Skills Ecosystem

Skills are in `.github/skills/` and follow the [vercel-labs/skills](https://github.com/vercel-labs/skills) standard.

### Installing Community Skills

```bash
# Browse skills
npx skills find testing

# Install a skill
npx skills add vercel-labs/skill-api-design

# List installed
npx skills list
```

Community skills install to `.github/skills/` and are auto-discovered by agents. Review security audits before installing.

### Current Skills (12)

- accessibility-wcag
- budget-gatekeeper
- code-topology
- conductor-lifecycle
- delegation-routing
- documentation-style
- git-operations
- memory-management
- performance-analysis
- security-review
- tdd
- validation-scripts

## Tips & Troubleshooting

### Effective Prompts

```bash
# âœ… Specific scope and expected outcome
copilot chat --agent implementer "Add PSScriptAnalyzer to validate-copilot-assets.ps1, suppress PSUseDeclaredVarsMoreThanAssignments for $ErrorActionPreference"

# âŒ Vague request
copilot chat --agent implementer "improve scripts"
```

### Context Limits

If you hit context limits:
1. Use conductor to break work into smaller phases
2. Leverage wiki memory for cross-session context
3. Use `--compact` mode (if available) to summarize prior turns

### Model Selection

Agents use fallback arrays:
- **Premium**: Claude Opus 4.6 -> Claude Opus 4.7 -> Claude Sonnet 4.6 (Planner only)
- **Execution**: Claude Sonnet 4.6 -> GPT-5.4 -> GPT-5.3-Codex (12 agents)
- **Fast**: Claude Haiku 4.5 -> GPT-5.4 mini -> GPT-5 mini (3 agents)

If a model is unavailable, the next in the array is used automatically.

### Agent Not Responding

Check:
1. Agent file exists: `.github/agents/{agent-name}.agent.md`
2. CLI is in workspace root: `cd copilot_orchestrator`
3. VS Code version: Must be â‰¥1.113

### Tool Approval

CLI prompts for tool approval. Options:
- "Yes" â€” Approve once
- "Yes, approve all" â€” Approve for session
- "No" â€” Reject and provide alternative

For unattended CI: Use `--allow-all-tools` (âš ï¸ review logs afterward)

## Headless Mode (CI / cron / hooks)

`copilot chat -p "<prompt>"` runs non-interactively. Per [ADR-headless-conductor](../../artifacts/decisions/ADR-headless-conductor.md), the conductor adapts:

| Complexity tier | Headless behavior | Exit code |
|-----------------|-------------------|-----------|
| INSTANT | Execute; no plan/review | 0 |
| STANDARD | Auto-approve inline plan; reviewer reports findings | 0 (clean) / **10** (HIGH+ findings) |
| DEEP | Fail closed — emit plan, no code changes | **20** |
| ULTRADEEP | Fail closed — emit plan, no code changes | **21** |
| `--security` review | Never auto-approves; only commits on clean | **30** on BLOCKER |

### Environment variables

| Variable | Purpose | Default |
|----------|---------|---------|
| `COPILOT_HEADLESS` | Force headless even on TTY | unset |
| `COPILOT_HEADLESS_MAX_TIER` | Upper tier conductor will execute | `STANDARD` |
| `COPILOT_HEADLESS_NO_COMMIT` | Run without committing (dry-run) | unset |
| `COPILOT_HEADLESS_REVIEWER_MODE` | Override reviewer mode | `standard` |

### Exit code scheme

| Code | Meaning |
|-----:|---------|
| 0 | Success |
| 10 | STANDARD landed with reviewer HIGH+ findings |
| 20 | DEEP refused; plan on stdout; no changes |
| 21 | ULTRADEEP refused; plan on stdout; no changes |
| 30 | Security review BLOCKER; no commit |
| 40 | Hook failure that hit `on_fail: escalate` |
| 50 | Timeout |
| 60 | Internal error (budget exceeded, model unavailable) |

### Examples

```powershell
# CI: run reviewer headless on the current diff
copilot chat --agent reviewer -p "Review the diff on HEAD. Report severity tags."

# Cron: nightly docs update (INSTANT-scope prompt)
copilot chat --agent docs -p "Refresh the CHANGELOG with today's merged PRs."

# Dry-run any tier without touching git
$env:COPILOT_HEADLESS_NO_COMMIT="1"
copilot chat --agent conductor -p "Plan a rename from defaultEffort to thinkingEffort."
```

**Rule:** CI pipelines must treat any non-zero exit as "needs human attention"; never ignore exit 10.
## Resources

- [AGENTS.md](../../AGENTS.md) â€” Complete agent reference
- [Copilot CLI Docs](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli)
- [MCP Documentation](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli#add-an-mcp-server)
- [Skills Ecosystem](https://github.com/vercel-labs/skills)
