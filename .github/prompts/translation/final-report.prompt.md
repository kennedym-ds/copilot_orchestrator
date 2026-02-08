---
description: "Generate the final translation report with per-file and repo-level confidence scores, test coverage, and security findings."
mode: agent
agent: translation-conductor
---

# Final Translation Report

## Context
All translation phases are complete. Compile the final report for the translated repository.

## Source
- **Source Repo:** ${input:source_repo}
- **Source Language:** ${input:source_language}
- **Target Language:** ${input:target_language}

## Report Sections

### 1. Executive Summary
- Total files translated, total LOC
- Overall repo confidence score
- Total tests written, pass rate
- Security findings summary
- Time/effort metrics

### 2. Per-File Confidence Matrix
| Source File | Target File | LOC | Confidence | Status | Notes |
|-------------|-------------|-----|------------|--------|-------|
| ... | ... | ... | 0.XX | ✅/⚠️/❌ | ... |

### 3. Validation Summary
- Layer-by-layer aggregate scores
- Files requiring manual review
- Known behavioral differences

### 4. Test Coverage Report
- Unit tests: count, pass rate, coverage %
- Integration tests: count, pass rate
- Functional tests: count, pass rate
- Untested areas and recommendations

### 5. Security Review Summary
- STRIDE threat model findings
- Dependency vulnerability scan results
- Compliance checkpoint results
- Remediation actions taken

### 6. Translation Decisions Log
- Major architectural decisions
- Framework/library choices with rationale
- Patterns that were redesigned (not 1:1 translated)
- Areas where source language features had no direct equivalent

### 7. Recommendations
- Files recommended for manual review
- Performance optimization opportunities
- Suggested improvements over source codebase
- Follow-up tasks and technical debt items

### 8. Repo Confidence Score
Weighted average: Σ(LOC × Score) / Σ(LOC)
Display with breakdown by confidence band:
- High (≥0.9): X files (Y% of LOC)
- Medium (0.7–0.89): X files (Y% of LOC)
- Low (0.5–0.69): X files (Y% of LOC)
- Critical (<0.5): X files (Y% of LOC)
