---
name: validation-scripts
description: "PowerShell 5.1 validation script operations including asset validation, lint checking, smoke tests, and token budget reporting. Use for pre-PR validation and conductor pause point checks."
---

# Validation Scripts

Provides PowerShell 5.1 validation script operations for conductor workflows, including asset validation, lint checking, smoke tests, and token budget reporting.

## Description

This skill teaches agents how to run and interpret PowerShell validation scripts used throughout the conductor lifecycle. It covers validation script purposes, execution patterns, output interpretation, terminal auto-approve behavior, and integration with conductor pause points.

## When to Use

This skill is relevant when:
- Validating changes after phase completion
- Checking frontmatter and YAML structure
- Running lint checks before phase-complete.md
- Executing smoke tests for critical paths
- Generating token budget reports
- Preparing for plan-complete.md finalization

## Entry Points

### Trigger Phrases
- "validate changes"
- "run lint check"
- "check asset validation"
- "run smoke tests"
- "generate token report"
- "validate frontmatter"

### Context Patterns
- After implementing phase changes
- Before creating phase-complete.md
- After modifying instruction files
- Before creating plan-complete.md
- After adding new prompts or agents
- During Phase 7 (Rollout & Validation)

## Core Knowledge

### Validation Scripts Overview

| Script | Purpose | Auto-Approved | Exit Code |
|--------|---------|---------------|-----------|
| `validate-copilot-assets.ps1` | Validates frontmatter, YAML, file structure | âœ“ Yes | 0=pass, 1=fail |
| `run-lint.ps1` | Checks markdown style, line length, whitespace | âœ“ Yes | 0=pass, 1=fail |
| `run-smoke-tests.ps1` | Tests critical paths, file existence | âœ“ Yes | 0=pass, 1=fail |
| `token-report.ps1` | Generates token budget report | âœ“ Yes | 0=success |
| `add-prompt-metadata.ps1` | Adds/updates prompt metadata | âœ— No | 0=success, 1=fail |
| `init-artifacts.ps1` | Creates artifacts folder structure | âœ— No | 0=success |

### Terminal Auto-Approve Behavior

**Auto-Approved Scripts** (Read-only operations):
These scripts execute immediately without user prompts when run through VS Code Chat:
```powershell
.\scripts\validate-copilot-assets.ps1 -RepositoryRoot .
.\scripts\run-lint.ps1 -RepositoryRoot .
.\scripts\run-smoke-tests.ps1 -RepositoryRoot .
.\scripts\token-report.ps1 -Path .
```

**Requires Approval** (Modifies files):
These scripts prompt for approval before execution:
```powershell
.\scripts\add-prompt-metadata.ps1 -RepositoryRoot .  # Modifies prompt files
.\scripts\init-artifacts.ps1                         # Creates directories
```

## Script Details

### 1. validate-copilot-assets.ps1

**Purpose:** Validates all Copilot assets (agents, prompts, instructions) for correct frontmatter, YAML structure, and file organization.

**Syntax:**
```powershell
.\scripts\validate-copilot-assets.ps1 -RepositoryRoot <path>
```

**Parameters:**
- `-RepositoryRoot` â€” Path to repository root (required)

**What It Checks:**
- Agent files (*.agent.md) have required frontmatter: name, description, version
- Prompt files (*.prompt.md) have required frontmatter: title, description, version
- Instruction files (*.instructions.md) have required frontmatter: applyTo, description, version
- YAML frontmatter is valid and parseable
- Files are in correct directories (.github/agents, .github/prompts, instructions/)

**Success Output:**
```
Scanning Copilot assets under C:\Projects\copilot_orchestrator ...
âœ… All Copilot assets passed validation.
```

**Failure Output:**
```
Scanning Copilot assets under C:\Projects\copilot_orchestrator ...
âŒ Validation failed:
  [Error] .github/agents/conductor.agent.md â€” Missing required frontmatter: version
  [Error] .github/prompts/planning/plan.prompt.md â€” Invalid YAML in frontmatter
```

**Exit Code:**
- `0` â€” All validations passed
- `1` â€” One or more validations failed

**When to Run:**
- After creating/modifying agent files
- After creating/modifying prompt files
- After creating/modifying instruction files
- Before phase-complete.md creation
- Before plan-complete.md creation

### 2. run-lint.ps1

**Purpose:** Checks markdown files for style issues, line length, trailing whitespace, and formatting problems.

**Syntax:**
```powershell
.\scripts\run-lint.ps1 -RepositoryRoot <path>
```

**Parameters:**
- `-RepositoryRoot` â€” Path to repository root (required)

**What It Checks:**
- Trailing whitespace at end of lines
- Line length exceeding 400 characters
- Tab characters (should use spaces)
- Markdown formatting issues
- File-specific linting rules

**Success Output:**
```
Lint findings:
  [Info] No errors found. Warnings only:
  [Warning] docs/guides/sample.md:42 - Trailing whitespace detected.
```

**Failure Output:**
```
Lint findings:
  [Error] docs/guides/broken.md:15 - Invalid markdown table structure.
  [Warning] docs/guides/long.md:103 - Line length 512 exceeds maximum 400 characters.
  [Warning] README.md:7 - Trailing whitespace detected.
```

**Exit Code:**
- `0` â€” No errors (warnings are acceptable)
- `1` â€” One or more errors found

**When to Run:**
- After creating/modifying documentation
- Before phase-complete.md creation
- Before plan-complete.md creation
- After bulk documentation updates

**Note:** Pre-existing warnings are acceptable. Focus on ensuring no new errors introduced.

### 3. run-smoke-tests.ps1

**Purpose:** Executes critical path smoke tests to ensure repository structure and core functionality work correctly.

**Syntax:**
```powershell
.\scripts\run-smoke-tests.ps1 -RepositoryRoot <path>
```

**Parameters:**
- `-RepositoryRoot` â€” Path to repository root (required)

**What It Checks:**
- Critical files exist (AGENTS.md, README.md, .github/copilot-instructions.md)
- Directory structure is correct (.github/agents, .github/prompts, instructions/)
- Scripts are executable and have correct syntax
- Core functionality works (token counting, metadata parsing)
- Integration points are valid

**Success Output:**
```
Running smoke tests...
âœ“ File structure validation passed
âœ“ Agent definitions loadable
âœ“ Prompt files parseable
âœ“ Instruction files valid
âœ… All smoke tests passed.
```

**Failure Output:**
```
Running smoke tests...
âœ“ File structure validation passed
âœ— Agent definitions loadable â€” conductor.agent.md missing required field
âœ— Prompt files parseable â€” plan.prompt.md has invalid frontmatter
âŒ 2 smoke tests failed.
```

**Exit Code:**
- `0` â€” All smoke tests passed
- `1` â€” One or more smoke tests failed

**When to Run:**
- After major structural changes
- Before plan-complete.md creation
- After adding new agents or prompts
- Before deployment or release

### 4. token-report.ps1

**Purpose:** Generates token budget report for all instruction files, prompts, and agents to ensure context window limits are respected.

**Syntax:**
```powershell
.\scripts\token-report.ps1 -Path <path> [-ConfigPath <config>] [-OutputPath <output>]
```

**Parameters:**
- `-Path` â€” Path to analyze (required, typically `.` for repository root)
- `-ConfigPath` â€” Path to threshold config (optional, default: `token-thresholds.json`)
- `-OutputPath` â€” Output file path (optional, default: `artifacts/token-report.json`)

**What It Reports:**
- Token counts per file (instructions, prompts, agents)
- Total token budget across all files
- Files exceeding thresholds (warnings)
- Comparison to configured limits
- Recommendations for optimization

**Success Output:**
```
Analyzing token usage in C:\Projects\copilot_orchestrator ...
â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
ðŸ“Š Token Budget Report
â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
Instructions:     42,150 tokens (18 files)
Prompts:          12,340 tokens (35 files)
Agents:            8,920 tokens (22 files)
â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
Total:            63,410 tokens
Threshold:       100,000 tokens
Status:           âœ… PASS (36.6% under limit)
â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
Report saved to: artifacts/token-report.json
```

**Warning Output:**
```
âš ï¸ Warnings:
  instructions/global/security.instructions.md â€” 8,420 tokens (threshold: 8,000)
  .github/prompts/planning/comprehensive-plan.prompt.md â€” 3,210 tokens (threshold: 3,000)
```

**Exit Code:**
- `0` â€” Report generated successfully (warnings acceptable)

**When to Run:**
- After adding new instruction files
- After modifying large prompts
- Monthly token budget review
- Before major releases

### 5. add-prompt-metadata.ps1

**Purpose:** Adds or updates frontmatter metadata in prompt files to ensure consistency and searchability.

**Syntax:**
```powershell
.\scripts\add-prompt-metadata.ps1 -RepositoryRoot <path> [-CheckOnly]
```

**Parameters:**
- `-RepositoryRoot` â€” Path to repository root (required)
- `-CheckOnly` â€” Validate metadata without modifying files (optional)

**What It Does:**
- Scans all prompt files (*.prompt.md)
- Checks for required metadata fields
- Adds missing metadata with defaults
- Updates outdated metadata structure
- Reports files needing attention

**Check-Only Output:**
```
Checking prompt metadata...
âš ï¸ Missing metadata:
  .github/prompts/planning/phase-plan.prompt.md â€” Missing: version, lastUpdated
  .github/prompts/review/findings.prompt.md â€” Missing: tags
â„¹ï¸ Use without -CheckOnly to add metadata automatically.
```

**Modification Output:**
```
Adding prompt metadata...
âœ“ Updated .github/prompts/planning/phase-plan.prompt.md
âœ“ Updated .github/prompts/review/findings.prompt.md
âœ… Metadata added to 2 files.
```

**Exit Code:**
- `0` â€” Check passed or metadata added successfully
- `1` â€” Errors encountered

**âš ï¸ Requires Approval:** This script modifies files and requires user approval in VS Code Chat.

**When to Run:**
- After creating new prompt files
- During metadata standardization efforts
- Before major releases
- When prompted by validation script errors

### 6. init-artifacts.ps1

**Purpose:** Creates the local artifacts folder structure for storing conductor workflow outputs (plans, reviews, research, sessions).

**Syntax:**
```powershell
.\scripts\init-artifacts.ps1
```

**Parameters:**
- None (runs in current directory)

**What It Creates:**
```
artifacts/
â”œâ”€â”€ README.md
â”œâ”€â”€ plans/
â”œâ”€â”€ reviews/
â”œâ”€â”€ research/
â”œâ”€â”€ security/
â”œâ”€â”€ sessions/
â”œâ”€â”€ performance/
â”œâ”€â”€ docs/
â”œâ”€â”€ releases/
â”œâ”€â”€ telemetry/
â”œâ”€â”€ deployments/
â”œâ”€â”€ red-team/
â”œâ”€â”€ accessibility/
â”œâ”€â”€ tests/
â””â”€â”€ ux/
```

**Output:**
```
Creating artifacts folder structure...
âœ“ Created artifacts/plans
âœ“ Created artifacts/reviews
âœ“ Created artifacts/research
âœ“ Created artifacts/security
âœ“ Created artifacts/sessions
âœ“ Created artifacts/performance
âœ“ Created artifacts/docs
âœ“ Created artifacts/releases
âœ“ Created artifacts/telemetry
âœ“ Created artifacts/deployments
âœ“ Created artifacts/red-team
âœ“ Created artifacts/accessibility
âœ“ Created artifacts/tests
âœ“ Created artifacts/ux
âœ“ Created artifacts/README.md
âœ… Artifacts folder initialized.
```

**Exit Code:**
- `0` â€” Folder structure created successfully

**âš ï¸ Requires Approval:** This script creates directories and requires user approval in VS Code Chat.

**When to Run:**
- First time using conductor in a repository
- After cloning repository to new location
- When artifacts folder is accidentally deleted
- When setting up new consuming repository

## Common Workflows

### After Phase Implementation
```powershell
# 1. Validate assets
.\scripts\validate-copilot-assets.ps1 -RepositoryRoot .

# 2. Run lint check
.\scripts\run-lint.ps1 -RepositoryRoot .

# 3. If both pass, create phase-complete.md
# If either fails, fix issues and re-run
```

### Before Plan Completion
```powershell
# 1. Validate all assets
.\scripts\validate-copilot-assets.ps1 -RepositoryRoot .

# 2. Lint check
.\scripts\run-lint.ps1 -RepositoryRoot .

# 3. Smoke tests
.\scripts\run-smoke-tests.ps1 -RepositoryRoot .

# 4. Token budget report
.\scripts\token-report.ps1 -Path .

# 5. If all pass, create plan-complete.md
```

### After Adding New Prompt
```powershell
# 1. Add metadata (requires approval)
.\scripts\add-prompt-metadata.ps1 -RepositoryRoot .

# 2. Validate assets
.\scripts\validate-copilot-assets.ps1 -RepositoryRoot .

# 3. Update token budget
.\scripts\token-report.ps1 -Path .
```

## Interpreting Results

### Exit Codes
- **0** â€” Success (proceed with workflow)
- **1** â€” Failure (fix issues before proceeding)

### Validation Priorities
1. **Blockers** â€” Asset validation failures (must fix immediately)
2. **Errors** â€” Lint errors (must fix before completion)
3. **Warnings** â€” Pre-existing issues (acceptable, document in phase-complete.md)
4. **Info** â€” Recommendations (consider for future improvements)

### When to Pause
- âŒ Asset validation fails â†’ Fix frontmatter, re-run, do not proceed
- âŒ Smoke tests fail â†’ Fix critical issues, re-run, do not proceed
- âš ï¸ Lint errors (new) â†’ Fix formatting, re-run validation
- âœ… Lint warnings (pre-existing) â†’ Document in phase-complete.md, proceed
- âœ… Token budget warnings â†’ Document, consider optimization, proceed

## Examples

### Example 1: Phase Completion Validation
```powershell
# After implementing Phase 4
cd C:\Projects\copilot_orchestrator

# Validate changes
.\scripts\validate-copilot-assets.ps1 -RepositoryRoot .
# Output: âœ… All Copilot assets passed validation.

.\scripts\run-lint.ps1 -RepositoryRoot .
# Output: [Warning] docs/guides/vscode-copilot-configuration.md:511 - Trailing whitespace detected.
# Note: Pre-existing warning, acceptable

# Validation passed, create phase-4-complete.md
```

### Example 2: Handling Validation Failure
```powershell
# Validate after creating new instruction file
.\scripts\validate-copilot-assets.ps1 -RepositoryRoot .
# Output: âŒ Validation failed:
#   [Error] instructions/global/new-feature.instructions.md â€” Missing required frontmatter: applyTo

# Fix the frontmatter issue
# Add: applyTo: ["all-agents"]

# Re-run validation
.\scripts\validate-copilot-assets.ps1 -RepositoryRoot .
# Output: âœ… All Copilot assets passed validation.

# Now safe to proceed
```

### Example 3: Pre-existing Warnings
```powershell
# Run lint check
.\scripts\run-lint.ps1 -RepositoryRoot .
# Output shows 127 warnings (trailing whitespace, long lines)

# These are pre-existing issues, not introduced by current phase
# Document in phase-complete.md:
# "Validation Results: No new errors. Pre-existing warnings (127) noted but non-blocking."

# Proceed with phase completion
```

### Example 4: Token Budget Review
```powershell
# After adding comprehensive documentation
.\scripts\token-report.ps1 -Path .
# Output:
# Total: 78,450 tokens
# Threshold: 100,000 tokens
# Status: âœ… PASS (21.6% under limit)
#
# âš ï¸ Warnings:
#   instructions/global/terminal-formatting.instructions.md â€” 8,150 tokens

# Token budget OK, warning noted
# Consider splitting terminal-formatting.instructions.md in future
# Proceed with current implementation
```

## Troubleshooting

### Issue: Script not found

**Solution:**
```powershell
# Ensure you're in repository root
Get-Location
# Should show: C:\Projects\copilot_orchestrator

# If not, navigate to root
Set-Location C:\Projects\copilot_orchestrator

# Run script with relative path
.\scripts\validate-copilot-assets.ps1 -RepositoryRoot .
```

### Issue: PowerShell execution policy

**Solution:**
```powershell
# Check current policy
Get-ExecutionPolicy

# If Restricted, set to RemoteSigned (current user only)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Re-run script
```

### Issue: Exit code confusion

**Solution:**
Check last exit code in PowerShell:
```powershell
.\scripts\validate-copilot-assets.ps1 -RepositoryRoot .
Write-Host "Exit code: $LASTEXITCODE"
# 0 = success, 1 = failure
```

## References

- Validation script source: [scripts/](../../../scripts/)
- Terminal auto-approve documentation: [docs/guides/vscode-copilot-configuration.md](../../../docs/guides/vscode-copilot-configuration.md)
- Conductor workflow: [.github/agents/conductor.agent.md](../../agents/conductor.agent.md)
- Phase completion template: [docs/templates/phase-complete.md](../../../docs/templates/phase-complete.md)
