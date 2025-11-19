# Churn Acceleration – Q4 2024 Cohort Deep Dive

## Executive Summary
- Q4-2024 low-activity customers show a 31% churn rate (+18 pp vs Q3).
- Dormant customers in Q4-2024 spiked to 44% churn (+15 pp), statistically significant at p < 0.001.
- Engagement campaigns targeting low-activity cohorts could recover ~$3.8M ARR.

## Methodology
1. Analyzer summarized customer demographics and data quality artifacts.
2. Planner issued sequential steps to ensure DS-Star loop compliance.
3. Implementer executed Python notebooks stored under `steps/003_*` and `steps/006_*`.
4. Reviewer enforced SUFFICIENT/INSUFFICIENT verdicts with router directives logged in `verdict_log.ndjson`.
5. Docs persona created this report plus reproducibility steps.

## Key Findings
| Cohort | Activity Band | Churn Rate | 95% CI |
| --- | --- | --- | --- |
| Q4-2024 | Low | 31% | 28-34% |
| Q4-2024 | Dormant | 44% | 39-49% |

## Reproducibility
```
pwsh -File scripts/run-data-session.ps1 -Session 20251115_094200_dsstar
python plans/data-analysis/20251115_094200_dsstar/final_output/final_analysis.py
```

Logs are stored under `plans/data-analysis/20251115_094200_dsstar/logs/`.
