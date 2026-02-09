---
name: validate-translation
description: "Run the 6-layer validation stack against translated files and produce confidence scores."
argument-hint: "Provide the source and target files to validate translation"
model: Claude Sonnet 4.5 (copilot)
agent: translation-validator
tools:
  - search
  - readFile
  - runCommands
  - problems
---

# Validate Translation

## Context
Validate the translated file(s) against the 6-layer validation stack and produce per-file confidence scores.

## Files to Validate
- **Translated File(s):** ${input:translated_file_paths}
- **Source Language:** ${input:source_language}
- **Target Language:** ${input:target_language}
- **Original Source:** ${input:source_file_paths}

## Validation Stack

Execute each layer in sequence. Stop and report if a layer fails catastrophically.

### Layer 1: Syntax Validation (Weight: 0.15)
Run the target language parser to verify the code parses cleanly.

### Layer 2: Type Correctness (Weight: 0.15)
Run the type checker in strict mode. Document all type errors.

### Layer 3: Lint Compliance (Weight: 0.10)
Run the linter. Check naming, formatting, anti-patterns.

### Layer 4: Unit Test Pass Rate (Weight: 0.25)
Run translated unit tests. Report pass/fail ratio.

### Layer 5: Integration Test Pass Rate (Weight: 0.15)
Run cross-module integration tests if available.

### Layer 6: Behavioral Equivalence (Weight: 0.20)
Compare function signatures and behaviors between source and target.

## Output
- Validation report with per-layer scores
- Overall confidence score (0.0–1.0)
- List of failures with remediation recommendations
- Updated manifest.json with validation results

## On Failure
Follow retry protocol:
1. Fix based on error messages → re-validate
2. Provide broader context → re-translate + re-validate
3. Simplify / break into units → re-validate
4. Escalate to human with full error history
