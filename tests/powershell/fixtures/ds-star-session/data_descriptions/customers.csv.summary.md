## File: customers.csv
**Path**: `data/customers.csv`
**Format**: CSV
**Rows**: 15,234
**Columns**: 7

### Schema
| Column | Type | Nulls | Unique | Range/Sample |
| --- | --- | --- | --- | --- |
| customer_id | int64 | 0% | 15,234 | 1-15234 |
| region | string | 0% | 4 | ["North", "South", "East", "West"] |
| cohort | string | 0% | 6 | ["Q2-2023", "Q3-2023", "Q4-2023", ...] |
| activity_band | string | 0% | 4 | ["High", "Medium", "Low", "Dormant"] |
| age | int64 | 1.8% | 68 | 18-86 |
| churned | bool | 0% | 2 | [true, false] |
| months_active | int64 | 0% | 72 | 1-72 |

### Data Quality
- **Completeness**: 98.2% (minor nulls in `age`)
- **Uniqueness**: `customer_id` fully unique; `cohort` balanced except `Q4-2024`
- **Anomalies**: 12 customers flagged with negative `months_active` (fixed upstream)
- **Hypotheses**: Expect churn acceleration for `activity_band = Low` during `Q4-2024`
