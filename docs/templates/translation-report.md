## Final Translation Report: {Source Language} → {Target Language}

**Source Repository:** {source_repo_url}
**Target Repository:** {target_repo_url}
**Translation Date:** {ISO 8601 date}
**Conductor:** translation-conductor

---

### Executive Summary

{2-4 sentence summary of the translation outcome, scope, and overall confidence.}

| Metric | Value |
|--------|-------|
| Total Files Translated | {N} |
| Total LOC (Source) | {N} |
| Total LOC (Target) | {N} |
| Repo Confidence Score | {0.XX} ({High/Medium/Low/Critical}) |
| Unit Tests Written | {N} |
| Unit Test Pass Rate | {N}% |
| Integration Tests | {N} |
| Security Findings | {N BLOCKER, N MAJOR, N MINOR} |
| Duration | {estimated hours/days} |

---

### Per-File Confidence Matrix

| # | Source File | Target File | LOC | Confidence | Band | Notes |
|---|------------|-------------|-----|------------|------|-------|
| 1 | {src/models/user.py} | {src/models/user.ts} | {120} | {0.92} | High | {Clean translation} |
| 2 | ... | ... | ... | ... | ... | ... |

**Distribution by Band:**
- **High (≥0.9):** {X} files ({Y}% of LOC)
- **Medium (0.7–0.89):** {X} files ({Y}% of LOC)
- **Low (0.5–0.69):** {X} files ({Y}% of LOC)
- **Critical (<0.5):** {X} files ({Y}% of LOC)

---

### Validation Summary

| Layer | Weight | Aggregate Score | Details |
|-------|--------|----------------|---------|
| Syntax | 0.15 | {0.XX} | {N files with syntax errors} |
| Types | 0.15 | {0.XX} | {N type inference gaps} |
| Lint | 0.10 | {0.XX} | {N warnings, M errors} |
| Unit Tests | 0.25 | {0.XX} | {pass/total tests} |
| Integration | 0.15 | {0.XX} | {pass/total tests} |
| Equivalence | 0.20 | {0.XX} | {N edge case differences} |

---

### Test Coverage Report

**Unit Tests:**
| Metric | Value |
|--------|-------|
| Total Tests | {N} |
| Passing | {N} |
| Failing | {N} |
| Skipped | {N} |
| Line Coverage | {N}% |
| Branch Coverage | {N}% |

**Integration Tests:**
| Metric | Value |
|--------|-------|
| Total Tests | {N} |
| Passing | {N} |
| Failing | {N} |

**Failing Tests Requiring Attention:**
1. {test_name} — {reason for failure}
2. ...

---

### Security Review Summary

**STRIDE Assessment:**
| Category | Findings | Severity | Status |
|----------|----------|----------|--------|
| Spoofing | {N} | {High/Med/Low} | {Fixed/Open} |
| Tampering | {N} | {High/Med/Low} | {Fixed/Open} |
| Repudiation | {N} | {High/Med/Low} | {Fixed/Open} |
| Info Disclosure | {N} | {High/Med/Low} | {Fixed/Open} |
| Denial of Service | {N} | {High/Med/Low} | {Fixed/Open} |
| Elevation of Privilege | {N} | {High/Med/Low} | {Fixed/Open} |

**Dependency Vulnerabilities:**
- {dependency}: {vulnerability description}

---

### Translation Decisions Log

| # | Decision | Rationale | Impact |
|---|----------|-----------|--------|
| 1 | {Source pattern → Target pattern} | {Why this mapping was chosen} | {Files affected} |
| 2 | ... | ... | ... |

---

### Framework & Library Mappings Applied

| Source ({language}) | Target ({language}) | Notes |
|---------------------|---------------------|-------|
| {framework} | {framework} | {Migration notes} |
| ... | ... | ... |

---

### Known Limitations & Differences

1. **{Area}:** {Description of known difference between source and target behavior}
2. ...

---

### Files Recommended for Manual Review

| File | Confidence | Reason |
|------|-----------|--------|
| {file_path} | {0.XX} | {Why this file needs human attention} |
| ... | ... | ... |

---

### Recommendations for Next Steps

1. {Recommendation 1}
2. {Recommendation 2}
3. {Recommendation 3}

---

### Phases Completed

1. ✅ Phase 1: Discovery & Analysis
2. ✅ Phase 2: Foundation Translation (Types, Models, Constants)
3. ✅ Phase 3: Core Business Logic Translation
4. ✅ Phase 4: Integration & API Layer Translation
5. ✅ Phase 5: Debug, Test & Security Cycle
6. ✅ Phase 6: Documentation & Final Report
