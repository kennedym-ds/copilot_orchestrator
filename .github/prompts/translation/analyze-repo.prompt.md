---
name: analyze-repo
description: "Analyze a source repository and produce a translation manifest with dependency graph, complexity assessment, and framework mappings."
argument-hint: "Specify the repository path to analyze for translation"
model: GPT-5.3-Codex (copilot)
agent: translation-analyzer
tools: [search, read, problems]
---

# Analyze Repository for Translation

## Context
Analyze the source repository to produce a comprehensive Translation Manifest that will guide the entire translation workflow.

## Source Repository
- **Path:** ${input:source_repo_path}
- **Source Language:** ${input:source_language}
- **Target Language:** ${input:target_language}

## Instructions

- Catalog every file with path, language, LOC, role (source, test, config, docs, assets), and whether it needs translation, copy-only, or exclusion
- Parse all import/require/use/include statements and build a dependency adjacency list
- Detect circular dependencies and topological-sort files into translation layers (Layer 0 = leaf nodes)
- Score each file on LOC, cyclomatic complexity, external dependencies, language-specific features, metaprogramming, and concurrency
- Identify source frameworks and map to target equivalents (web framework, ORM, test framework, all external dependencies)
- Generate `artifacts/plans/translation/manifest.json` with the complete manifest schema
- Identify high-risk areas: complex metaprogramming/reflection, platform-specific code, language features with no direct equivalent, large files (>500 LOC)

## Output Format

Produce the following deliverables:

1. **File Inventory** — table of every file with path, language, LOC, role, and translation action
2. **Dependency Graph** — adjacency list with topological layers
3. **Complexity Assessment** — per-file scores with risk indicators
4. **Framework Mappings** — source → target package/framework matrix
5. **Translation Manifest** — `artifacts/plans/translation/manifest.json`
6. **Risk Assessment** — high-risk areas with severity and mitigation notes
