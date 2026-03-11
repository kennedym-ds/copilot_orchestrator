---
name: translate-module
description: "Translate a specific module or file from source language to target language following dependency order."
argument-hint: "Specify source language, target language, and module path"
model: GPT-5 mini (copilot)
agent: translator
tools: [search, read, edit, execute]
---

# Translate Module

## Context
Translate the specified module from **${input:source_language}** to **${input:target_language}** following the approved translation plan.

## Module Details
- **Source Path:** ${input:source_file_path}
- **Target Path:** ${input:target_file_path}
- **Translation Layer:** ${input:layer_number}
- **Dependencies:** Already translated — see `artifacts/plans/translation/manifest.json`

## Instructions

### Pre-Translation
1. Read the full source file (2,000+ surrounding lines of context)
2. Load the translation manifest for framework/package mappings
3. Review already-translated dependency files for consistent type usage
4. Identify patterns requiring special handling

### Translation Rules
1. **Functional equivalence:** Same inputs must produce same outputs
2. **Idiomatic code:** Use target language conventions and patterns
3. **Naming conventions:** Apply target language naming (camelCase, snake_case, etc.)
4. **Comment translation:** Convert doc comments to target format
5. **Import mapping:** Use mapped target packages from manifest
6. **Error handling:** Map to target language error conventions

### Post-Translation
1. Add `// Translated from: {source_path}` header comment
2. Document any translation decisions or attention areas
3. Produce confidence factors table
4. Update manifest.json status for this module

## Output Format

- Translated source file at target path
- Translation decision notes documenting non-obvious choices
- Confidence score breakdown (syntax, types, lint, tests, behavioral equivalence)
