# Validation Scripts — Script Catalog

Detailed reference for the PowerShell 5.1 validation scripts used in conductor and implementer workflows. Use these per-script entries when you need syntax, parameters, exit semantics, or troubleshooting guidance.

## `validate-copilot-assets.ps1`

**Purpose:** Validates Copilot assets for frontmatter, YAML structure, and expected repository placement.

### Syntax

```powershell
powershell -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .
```

### Parameters

- `-RepositoryRoot` — Path to the repository root. Required.

### What It Checks

- Required frontmatter fields in agent, prompt, instruction, and skill assets
- YAML frontmatter parse validity
- File placement in expected directories
- Structural consistency for Copilot customization assets

### Success/Failure Output

- **Success:** Reports that all Copilot assets passed validation.
- **Failure:** Reports one or more asset-specific errors with file paths and missing or invalid fields.

### Exit Code

- `0` — All validations passed
- `1` — One or more validations failed

### When to Run

- After editing agents, prompts, instructions, or skills
- Before handing implementation back for review
- Before final workflow completion checks

## `run-lint.ps1`

**Purpose:** Checks markdown and repository assets for formatting issues such as trailing whitespace, long lines, and structural problems.

### Syntax

```powershell
powershell -File scripts/run-lint.ps1 -RepositoryRoot .
```

### Parameters

- `-RepositoryRoot` — Path to the repository root. Required.

### What It Checks

- Trailing whitespace
- Excessive line length
- Tab usage where spaces are expected
- Repository-specific markdown or file-format issues

### Success/Failure Output

- **Success:** Reports no errors. Warnings may still appear.
- **Failure:** Reports one or more blocking lint errors, typically with file path and line number.

### Exit Code

- `0` — No blocking lint errors
- `1` — One or more lint errors

### When to Run

- After editing documentation or markdown-based assets
- Before pause-point validation or review handoff
- After bulk formatting or content migrations

## `run-smoke-tests.ps1`

**Purpose:** Runs critical-path repository smoke tests to confirm loadability and basic structural integrity.

### Syntax

```powershell
powershell -File scripts/run-smoke-tests.ps1 -RepositoryRoot .
```

### Parameters

- `-RepositoryRoot` — Path to the repository root. Required.

### What It Checks

- Presence of critical files and directories
- Basic parseability of agents, prompts, instructions, and skills
- Script loadability and critical integration points
- Core repository conventions needed for orchestration workflows

### Success/Failure Output

- **Success:** Reports that smoke tests passed across critical checks.
- **Failure:** Reports which smoke-test category failed and any file-specific details.

### Exit Code

- `0` — All smoke tests passed
- `1` — One or more smoke tests failed

### When to Run

- After major structural changes
- Before plan completion or release-readiness checks
- After adding or removing major customization assets

## `token-report.ps1`

**Purpose:** Generates token usage totals and threshold comparisons for agents, prompts, and instructions.

### Syntax

```powershell
powershell -File scripts/token-report.ps1 -Path . -ConfigPath token-thresholds.json
```

### Parameters

- `-Path` — Path to analyze. Required.
- `-ConfigPath` — Threshold configuration file. Optional; defaults to `token-thresholds.json`.
- `-OutputPath` — Output report path. Optional.

### What It Checks

- Token counts per asset
- Total token usage versus configured thresholds
- Files over budget or near budget
- Report generation to JSON output

### Success/Failure Output

- **Success:** Reports totals, threshold status, and output location.
- **Failure:** If the script fails operationally, the terminal shows the PowerShell error details.

### Exit Code

- `0` — Report generated successfully

### When to Run

- After adding or expanding large instructions, prompts, or agents
- During periodic budget reviews
- Before releases that materially expand customization assets

## `add-prompt-metadata.ps1`

**Purpose:** Adds or checks prompt metadata to keep prompt files structurally consistent.

### Syntax

```powershell
powershell -File scripts/add-prompt-metadata.ps1 -RepositoryRoot . -CheckOnly
```

### Parameters

- `-RepositoryRoot` — Path to the repository root. Required.
- `-CheckOnly` — Validate without modifying files. Optional.

### What It Checks

- Missing prompt metadata fields
- Outdated metadata structure
- Files that need automatic metadata insertion or normalization

### Success/Failure Output

- **Check only:** Reports prompts that are compliant or missing metadata.
- **Modify mode:** Reports files updated and counts of changes made.

### Exit Code

- `0` — Check passed or metadata updated successfully
- `1` — Errors encountered

### When to Run

- After creating new prompt files
- During prompt metadata standardization work
- When validation reports missing prompt metadata

## `init-artifacts.ps1`

**Purpose:** Creates the local `artifacts/` directory structure for plans, reviews, research, and other workflow outputs.

### Syntax

```powershell
powershell -File scripts/init-artifacts.ps1
```

### Parameters

- None

### What It Checks

- Whether the current repository has the required artifacts layout
- Which folders and support files need creation

### Success/Failure Output

- **Success:** Reports each created folder or file, then confirms the artifacts structure is initialized.
- **Failure:** PowerShell reports the filesystem error that blocked directory creation.

### Exit Code

- `0` — Folder structure created successfully

### When to Run

- First-time repository setup
- After cloning to a new location
- After accidental deletion of the artifacts tree

## Troubleshooting

### Script not found

- Confirm the working directory is the repository root.
- Use `Get-Location` before running the script if path context is unclear.
- Run scripts with `powershell -File scripts/...` so the host and path are explicit.

### Execution policy blocks the script

- Check the current policy with `Get-ExecutionPolicy`.
- If local policy blocks execution, use an approved PowerShell 5.1 policy such as `RemoteSigned` for the current user.
- Re-run the script after policy changes only if that change is allowed in your environment.

### Exit code confusion

- After the script runs, inspect `$LASTEXITCODE`.
- Treat `0` as success and `1` as a blocking failure unless the script documentation states otherwise.
- For non-blocking warnings, read the terminal summary rather than inferring failure from warning text alone.