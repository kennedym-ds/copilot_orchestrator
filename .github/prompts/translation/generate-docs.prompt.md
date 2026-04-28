---
name: generate-docs
description: "Generate comprehensive documentation for a translated repository including technical, business, and test documentation."
argument-hint: "Specify the translated module to generate documentation for"
model: GPT-5.3-Codex (copilot)
agent: docs
tools: [search, read, edit]
---

# Generate Translation Documentation

## Context
Generate comprehensive documentation for the translated repository after all translation and validation phases are complete.

## Repository Details
- **Source Language:** ${input:source_language}
- **Target Language:** ${input:target_language}
- **Source Repo:** ${input:source_repo}
- **Target Repo:** ${input:target_repo}

## Instructions

Generate each documentation category below for the translated repository.

### 1. Technical Documentation
- **README.md:** Project overview, setup instructions, dependencies, usage examples
- **ARCHITECTURE.md:** Module structure, dependency graph (Mermaid), design decisions
- **API Reference:** All public APIs documented with parameters, returns, examples
- **Module Documentation:** Per-module docs explaining purpose, usage, and patterns
- **Configuration Guide:** Environment variables, config files, deployment settings

### 2. Business Documentation
- **Feature Matrix:** Complete mapping of source features → translated features
- **Capability Summary:** What the application does, for non-technical stakeholders
- **Migration Guide:** Steps to switch from source to target codebase
- **Risk Summary:** Known limitations, areas requiring manual attention
- **Stakeholder Brief:** Executive summary of translation scope and outcomes

### 3. Functional Test Documentation
- **Test Plan:** Overall testing strategy and approach
- **Test Cases:** Documented test scenarios with expected outcomes
- **Coverage Matrix:** Which features are covered by which tests
- **Test Environment Setup:** How to set up and run the test suite
- **Regression Test Guide:** How to verify behavioral equivalence

### 4. Translation-Specific Documentation
- **Translation Decisions Log:** Why specific patterns/libraries were chosen
- **Known Differences:** Intentional behavioral differences between source and target
- **Manual Review Areas:** Files/functions flagged for human review
- **Framework Migration Notes:** Source framework → target framework mapping details

## Output Format

Follow the documentation-style skill patterns:
- Active voice, second person ("You can configure...")
- Start with action verbs
- Complete, runnable code examples
- Error handling in all examples
- Tables for structured comparisons
