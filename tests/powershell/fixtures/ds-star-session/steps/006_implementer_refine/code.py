import pandas as pd
from pathlib import Path
from statsmodels.stats.proportion import proportion_confint

customers = pd.read_csv(Path('data/customers.csv'))

summary = (
    customers
    .groupby(['cohort', 'activity_band'])['churned']
    .agg(['sum', 'count'])
    .reset_index()
)
summary['churn_rate'] = summary['sum'] / summary['count']
ci = summary.apply(lambda row: proportion_confint(count=row['sum'], nobs=row['count'], alpha=0.05, method='wilson'), axis=1)
summary['ci_low'] = ci.apply(lambda tpl: tpl[0])
summary['ci_high'] = ci.apply(lambda tpl: tpl[1])

summary.to_csv('steps/006_implementer_refine/churn_by_cohort_band.csv', index=False)
print(summary.head())
