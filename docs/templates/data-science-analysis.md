?---
title: "Data Science Analysis Template (DS-Star Pattern)"
session_id: "{timestamp}_{random_hash}"
created_at: "{ISO8601_timestamp}"
query: "{business_question}"
data_files: []
status: "in-progress"
---

# Data Science Analysis — {Short Description}

## Business Question

{Clearly state the analytical question to be answered}

**Success Criteria**:
- {Criterion 1}
- {Criterion 2}
- {Criterion 3}

**Constraints**:
- {Constraint 1 - e.g., data privacy requirements}
- {Constraint 2 - e.g., time limitations}

---

## Phase 1: Data File Analysis

### Data Sources

| File | Format | Rows | Columns | Status |
|------|--------|------|---------|--------|
| {filename1} | CSV | {N} | {M} | ✅ Analyzed |
| {filename2} | JSON | {N} | {M} | ✅ Analyzed |

**Summaries**: See `data_descriptions/` directory

### Data Quality Assessment

- **Completeness**: {percentage}% complete
- **Anomalies**: {description of any data quality issues}
- **Privacy Concerns**: {flagged PII, sensitive attributes}

---

## Phase 2: Iterative Analysis

### Round 1

**Plan Step**: {First analysis step}

**Code**: See `steps/004_implementer/code.py`

**Results**:
```
{Key outputs from code execution}
```

**Verification**: **{SUFFICIENT | INSUFFICIENT | BLOCKED}**
- **Reason**: {Reviewer's assessment}

---

### Round 2

**Plan Step**: {Second analysis step}

**Code**: See `steps/007_implementer/code.py`

**Results**:
```
{Key outputs from code execution}
```

**Verification**: **{SUFFICIENT | INSUFFICIENT | BLOCKED}**
- **Reason**: {Reviewer's assessment}

---

### Round N

**Plan Step**: {Final analysis step}

**Code**: See `steps/{XXX}_implementer/code.py`

**Results**:
```
{Key outputs from code execution}
```

**Verification**: **SUFFICIENT** ✅
- **Reason**: {Reviewer's assessment}

---

## Phase 3: Final Analysis

### Executive Summary

**Key Findings**:
- {Finding 1 with statistical evidence}
- {Finding 2 with statistical evidence}
- {Finding 3 with statistical evidence}

**Recommendations**:
1. {Action 1 with confidence level}
2. {Action 2 with confidence level}
3. {Action 3 with confidence level}

### Detailed Results

#### {Result Category 1}

{Tables, charts, statistical tests}

**Statistical Evidence**:
- Test: {e.g., Chi-square, t-test, ANOVA}
- Statistic: {value}
- P-value: {value}
- Conclusion: {interpretation}

#### {Result Category 2}

{Tables, charts, statistical tests}

**Statistical Evidence**:
- Test: {e.g., Correlation, regression}
- Metric: {R², coefficient}
- Significance: {p-value}
- Conclusion: {interpretation}

### Visualizations

1. `final_output/visualizations/{chart1}.png` - {Description}
2. `final_output/visualizations/{chart2}.png` - {Description}

---

## Methodology

### Analysis Steps

1. **Data Loading**: {Describe how data was loaded and preprocessed}
2. **Exploratory Analysis**: {Describe initial exploration}
3. **Feature Engineering**: {Describe derived features if any}
4. **Statistical Testing**: {Describe hypothesis tests}
5. **Modeling** (if applicable): {Describe predictive models}

### Tools & Libraries

- Python {version}
- Pandas {version}
- NumPy {version}
- Scikit-learn {version} (if modeling)
- Matplotlib/Seaborn {version} (for visualizations)
- Statsmodels {version} (for statistical tests)

### Assumptions

- {Assumption 1 with justification}
- {Assumption 2 with justification}
- {Assumption 3 with justification}

### Limitations

- {Limitation 1}
- {Limitation 2}
- {Limitation 3}

---

## Reproducibility

### Re-Run Instructions

1. Place data files in `data/` directory:
   - `{filename1}`
   - `{filename2}`

2. Execute final analysis script:
   ```bash
   python plans/data-analysis/{session_id}/final_output/final_analysis.py
   ```

3. Results will be saved to:
   - `output/analysis_results.json`
   - `output/visualizations/`

### Artifact Inventory

```
plans/data-analysis/{session_id}/
├── steps/                     # All intermediate steps
│   ├── 001_analyzer_*/        # Data file analysis
│   ├── 002_planner_init/      # Initial plan
│   ├── 003_implementer/       # Round 1 code + results
│   ├── 004_reviewer/          # Round 1 verification
│   └── ...
├── data_descriptions/         # Auto-generated data summaries
├── pipeline_state.json        # Session state for resume
├── final_output/
│   ├── analysis-report.md     # This document
│   ├── final_analysis.py      # Final verified code
│   └── visualizations/        # Charts and diagrams
└── logs/
    ├── execution.log          # Code execution logs
    └── pipeline.log           # Workflow events
```

---

## Follow-Up Actions

### Immediate Next Steps

- [ ] {Action 1 with owner and due date}
- [ ] {Action 2 with owner and due date}
- [ ] {Action 3 with owner and due date}

### Future Research Questions

1. {Question 1}
2. {Question 2}
3. {Question 3}

### Data Quality Improvements

- {Improvement 1}
- {Improvement 2}

---

## Session Metadata

**Session ID**: `{session_id}`
**Created**: {ISO8601_timestamp}
**Completed**: {ISO8601_timestamp}
**Duration**: {X} minutes
**Refinement Rounds**: {N}
**Total Steps**: {M}
**Final Verification**: SUFFICIENT ✅

**Agents Involved**:
- Conductor → Researcher → Planner → Implementer → Reviewer → Docs

**Artifacts Location**: `plans/data-analysis/{session_id}/`
