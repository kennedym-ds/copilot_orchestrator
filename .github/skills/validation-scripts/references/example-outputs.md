# Validation Scripts — Example Outputs

Quick reference showing expected pass/fail output for each validation script.

## validate-copilot-assets.ps1

```powershell
powershell -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .
```

### Pass Output
```
Validating copilot assets in: C:\Projects\copilot_orchestrator
Scanning agents...      27 found, 0 errors
Scanning prompts...     22 found, 0 errors
Scanning instructions.. 37 found, 0 errors
Scanning skills...      13 found, 0 errors

RESULT: PASS (0 errors, 0 warnings)
```

### Fail Output
```
Validating copilot assets in: C:\Projects\copilot_orchestrator
Scanning agents...      27 found, 2 errors
  ERROR: .github/agents/planner.agent.md - Missing required field: description
  ERROR: .github/agents/custom.agent.md - Invalid model value: "gpt-4"
Scanning prompts...     22 found, 1 error
  ERROR: .github/prompts/review.prompt.md - Missing frontmatter delimiter

RESULT: FAIL (3 errors, 0 warnings)
```

## run-lint.ps1

```powershell
powershell -File scripts/run-lint.ps1 -RepositoryRoot .
```

### Pass Output
```
Linting copilot assets...
  Agents:       27 checked, 0 issues
  Prompts:      22 checked, 0 issues
  Instructions: 37 checked, 0 issues
  Skills:       13 checked, 0 issues

Lint: PASS
```

### Fail Output
```
Linting copilot assets...
  Agents:       27 checked, 1 issue
    WARN: conductor.agent.md - Line exceeds 500 chars (line 42)
  Instructions: 37 checked, 1 issue
    WARN: global/00_behavior.instructions.md - Trailing whitespace (line 15)

Lint: 2 warnings found
```

## add-prompt-metadata.ps1

```powershell
powershell -File scripts/add-prompt-metadata.ps1 -RepositoryRoot . -CheckOnly
```

### Pass Output
```
Checking prompt metadata...
22 prompts checked, all have required metadata.
```

### Fail Output
```
Checking prompt metadata...
MISSING metadata in:
  .github/prompts/debug/debug-issue.prompt.md - missing: argument-hint
  .github/prompts/review/review.prompt.md - missing: description
2 prompts need metadata updates.
```

## run-smoke-tests.ps1

```powershell
powershell -File scripts/run-smoke-tests.ps1 -RepositoryRoot .
```

### Pass Output
```
Running smoke tests...
  Agent frontmatter parse:    PASS (27/27)
  Prompt frontmatter parse:   PASS (22/22)
  Instruction applyTo valid:  PASS (37/37)
  Skill SKILL.md exists:      PASS (13/13)
  Token budget compliance:    PASS

All smoke tests passed.
```

### Fail Output
```
Running smoke tests...
  Agent frontmatter parse:    PASS (27/27)
  Prompt frontmatter parse:   FAIL (21/22)
    ERROR: plan-feature.prompt.md - YAML parse error on line 3
  Token budget compliance:    FAIL
    ERROR: conductor.agent.md exceeds 8000 token threshold (actual: 9234)

2 smoke tests failed.
```

## token-report.ps1

```powershell
powershell -File scripts/token-report.ps1 -Path . -ConfigPath token-thresholds.json
```

### Output
```
Token Budget Report
===================
File                              Tokens    Limit    Status
----                              ------    -----    ------
conductor.agent.md                  4521     8000    OK
planner.agent.md                    3102     6000    OK
implementer.agent.md                2890     6000    OK
...
TOTAL                              45230

0 files over budget.
```

## init-artifacts.ps1

```powershell
powershell -File scripts/init-artifacts.ps1
```

### Output
```
Initializing artifacts directory...
  Created: artifacts/plans/
  Created: artifacts/reviews/
  Created: artifacts/research/
  Created: artifacts/security/
  Created: artifacts/sessions/
  Created: artifacts/performance/
  Created: artifacts/docs/
  Created: artifacts/releases/
  Created: artifacts/telemetry/
  Created: artifacts/deployments/
  Created: artifacts/red-team/
  Created: artifacts/accessibility/
  Created: artifacts/tests/
  Created: artifacts/ux/
  Created: artifacts/README.md

Artifacts directory initialized.
```

## analyze-sessions.ps1

```powershell
powershell -File scripts/analyze-sessions.ps1
```

### Output
```
Session Analytics Report
========================
Period: 2026-01-01 to 2026-02-09
Sessions analyzed: 42

Model Usage:
  Claude Opus 4.6:   18% (target: ≤20%)  ✅
  GPT-5.3-Codex:     52%
  Gemini 3 Pro:       15%
  Claude Haiku 4.5:    8%
  Gemini 3 Flash:      7%

Quality Metrics:
  Review approval rate: 92% (target: ≥90%)  ✅
  Avg phases per plan:  3.2
  Escalation rate:      12%
```
