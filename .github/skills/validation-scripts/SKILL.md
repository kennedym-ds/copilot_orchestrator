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
| `validate-copilot-assets.ps1` | Validates frontmatter, YAML, file structure | ✓ Yes | 0=pass, 1=fail |
| `run-lint.ps1` | Checks markdown style, line length, whitespace | ✓ Yes | 0=pass, 1=fail |
| `run-smoke-tests.ps1` | Tests critical paths, file existence | ✓ Yes | 0=pass, 1=fail |
| `token-report.ps1` | Generates token budget report | ✓ Yes | 0=success |
| `add-prompt-metadata.ps1` | Adds/updates prompt metadata | ✗ No | 0=success, 1=fail |
| `init-artifacts.ps1` | Creates artifacts folder structure | ✗ No | 0=success |

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
- `-RepositoryRoot` — Path to repository root (required)

**What It Checks:**
- Agent files (*.agent.md) have required frontmatter: name, description, version
- Prompt files (*.prompt.md) have required frontmatter: title, description, version
- Instruction files (*.instructions.md) have required frontmatter: applyTo, description, version
- YAML frontmatter is valid and parseable
- Files are in correct directories (.github/agents, .github/prompts, instructions/)

**Success Output:**
```
Scanning Copilot assets under C:\Projects\copilot_orchestrator ...
✅ All Copilot assets passed validation.
```

**Failure Output:**
```
Scanning Copilot assets under C:\Projects\copilot_orchestrator ...
❌ Validation failed:
  [Error] .github/agents/conductor.agent.md — Missing required frontmatter: version
  [Error] .github/prompts/planning/plan.prompt.md — Invalid YAML in frontmatter
```

**Exit Code:**
- `0` — All validations passed
- `1` — One or more validations failed

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
- `-RepositoryRoot` — Path to repository root (required)

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
- `0` — No errors (warnings are acceptable)
- `1` — One or more errors found

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
- `-RepositoryRoot` — Path to repository root (required)

**What It Checks:**
- Critical files exist (AGENTS.md, README.md, .github/copilot-instructions.md)
- Directory structure is correct (.github/agents, .github/prompts, instructions/)
- Scripts are executable and have correct syntax
- Core functionality works (token counting, metadata parsing)
- Integration points are valid

**Success Output:**
```
Running smoke tests...
✓ File structure validation passed
✓ Agent definitions loadable
✓ Prompt files parseable
✓ Instruction files valid
✅ All smoke tests passed.
```

**Failure Output:**
```
Running smoke tests...
✓ File structure validation passed
✗ Agent definitions loadable — conductor.agent.md missing required field
✗ Prompt files parseable — plan.prompt.md has invalid frontmatter
❌ 2 smoke tests failed.
```

**Exit Code:**
- `0` — All smoke tests passed
- `1` — One or more smoke tests failed

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
- `-Path` — Path to analyze (required, typically `.` for repository root)
- `-ConfigPath` — Path to threshold config (optional, default: `token-thresholds.json`)
- `-OutputPath` — Output file path (optional, default: `artifacts/token-report.json`)

**What It Reports:**
- Token counts per file (instructions, prompts, agents)
- Total token budget across all files
- Files exceeding thresholds (warnings)
- Comparison to configured limits
- Recommendations for optimization

**Success Output:**
```
Analyzing token usage in C:\Projects\copilot_orchestrator ...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Token Budget Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Instructions:     42,150 tokens (18 files)
Prompts:          12,340 tokens (35 files)
Agents:            8,920 tokens (22 files)
────────────────────────────────────────────────
Total:            63,410 tokens
Threshold:       100,000 tokens
Status:           ✅ PASS (36.6% under limit)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Report saved to: artifacts/token-report.json
```

**Warning Output:**
```
⚠️ Warnings:
  instructions/global/security.instructions.md — 8,420 tokens (threshold: 8,000)
  .github/prompts/planning/comprehensive-plan.prompt.md — 3,210 tokens (threshold: 3,000)
```

**Exit Code:**
- `0` — Report generated successfully (warnings acceptable)

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
- `-RepositoryRoot` — Path to repository root (required)
- `-CheckOnly` — Validate metadata without modifying files (optional)

**What It Does:**
- Scans all prompt files (*.prompt.md)
- Checks for required metadata fields
- Adds missing metadata with defaults
- Updates outdated metadata structure
- Reports files needing attention

**Check-Only Output:**
```
Checking prompt metadata...
⚠️ Missing metadata:
  .github/prompts/planning/phase-plan.prompt.md — Missing: version, lastUpdated
  .github/prompts/review/findings.prompt.md — Missing: tags
ℹ️ Use without -CheckOnly to add metadata automatically.
```

**Modification Output:**
```
Adding prompt metadata...
✓ Updated .github/prompts/planning/phase-plan.prompt.md
✓ Updated .github/prompts/review/findings.prompt.md
✅ Metadata added to 2 files.
```

**Exit Code:**
- `0` — Check passed or metadata added successfully
- `1` — Errors encountered

**⚠️ Requires Approval:** This script modifies files and requires user approval in VS Code Chat.

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
├── README.md
├── plans/
├── reviews/
├── research/
├── security/
├── sessions/
├── performance/
├── docs/
├── releases/
├── telemetry/
├── deployments/
├── red-team/
├── accessibility/
├── tests/
└── ux/
```

**Output:**
```
Creating artifacts folder structure...
✓ Created artifacts/plans
✓ Created artifacts/reviews
✓ Created artifacts/research
✓ Created artifacts/security
✓ Created artifacts/sessions
✓ Created artifacts/performance
✓ Created artifacts/docs
✓ Created artifacts/releases
✓ Created artifacts/telemetry
✓ Created artifacts/deployments
✓ Created artifacts/red-team
✓ Created artifacts/accessibility
✓ Created artifacts/tests
✓ Created artifacts/ux
✓ Created artifacts/README.md
✅ Artifacts folder initialized.
```

**Exit Code:**
- `0` — Folder structure created successfully

**⚠️ Requires Approval:** This script creates directories and requires user approval in VS Code Chat.

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
- **0** — Success (proceed with workflow)
- **1** — Failure (fix issues before proceeding)

### Validation Priorities
1. **Blockers** — Asset validation failures (must fix immediately)
2. **Errors** — Lint errors (must fix before completion)
3. **Warnings** — Pre-existing issues (acceptable, document in phase-complete.md)
4. **Info** — Recommendations (consider for future improvements)

### When to Pause
- ❌ Asset validation fails → Fix frontmatter, re-run, do not proceed
- ❌ Smoke tests fail → Fix critical issues, re-run, do not proceed
- ⚠️ Lint errors (new) → Fix formatting, re-run validation
- ✅ Lint warnings (pre-existing) → Document in phase-complete.md, proceed
- ✅ Token budget warnings → Document, consider optimization, proceed

## Examples

### Example 1: Phase Completion Validation
```powershell
# After implementing Phase 4
cd C:\Projects\copilot_orchestrator

# Validate changes
.\scripts\validate-copilot-assets.ps1 -RepositoryRoot .
# Output: ✅ All Copilot assets passed validation.

.\scripts\run-lint.ps1 -RepositoryRoot .
# Output: [Warning] docs/guides/vscode-copilot-configuration.md:511 - Trailing whitespace detected.
# Note: Pre-existing warning, acceptable

# Validation passed, create phase-4-complete.md
```

### Example 2: Handling Validation Failure
```powershell
# Validate after creating new instruction file
.\scripts\validate-copilot-assets.ps1 -RepositoryRoot .
# Output: ❌ Validation failed:
#   [Error] instructions/global/new-feature.instructions.md — Missing required frontmatter: applyTo

# Fix the frontmatter issue
# Add: applyTo: ["all-agents"]

# Re-run validation
.\scripts\validate-copilot-assets.ps1 -RepositoryRoot .
# Output: ✅ All Copilot assets passed validation.

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
# Status: ✅ PASS (21.6% under limit)
# 
# ⚠️ Warnings:
#   instructions/global/terminal-formatting.instructions.md — 8,150 tokens

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
