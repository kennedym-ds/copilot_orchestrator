---
description: "Analyze a source repository and produce a translation manifest with dependency graph, complexity assessment, and framework mappings."
mode: agent
agent: translation-analyzer
---

# Analyze Repository for Translation

## Context
Analyze the source repository to produce a comprehensive Translation Manifest that will guide the entire translation workflow.

## Source Repository
- **Path:** ${input:source_repo_path}
- **Source Language:** ${input:source_language}
- **Target Language:** ${input:target_language}

## Required Outputs

### 1. File Inventory
Catalog every file with:
- Path, language, LOC, role (source, test, config, docs, assets)
- Whether it needs translation, copy-only, or exclusion

### 2. Dependency Graph
- Parse all import/require/use/include statements
- Build adjacency list (A depends on B)
- Detect circular dependencies
- Topological sort into translation layers (Layer 0 = leaf nodes)

### 3. Complexity Assessment
Score each file on:
- LOC, cyclomatic complexity, external dependencies
- Language-specific features, metaprogramming, concurrency

### 4. Framework Mappings
Identify source frameworks and map to target equivalents:
- Web framework → target equivalent
- ORM → target equivalent
- Test framework → target equivalent
- All external dependencies → target packages

### 5. Translation Manifest
Generate `artifacts/plans/translation/manifest.json` with the complete manifest schema.

### 6. Risk Assessment
Identify high-risk areas:
- Complex metaprogramming or reflection
- Platform-specific code
- Language features with no direct equivalent
- Large files (>500 LOC) with high complexity
