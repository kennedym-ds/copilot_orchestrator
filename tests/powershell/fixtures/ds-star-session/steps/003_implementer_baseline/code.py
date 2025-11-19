import pandas as pd
from pathlib import Path

data = pd.read_csv(Path('data/customers.csv'))

baseline = (
    data.groupby(['cohort'])['churned']
    .mean()
    .reset_index(name='churn_rate')
)

prev = baseline.copy()
prev['cohort'] = prev['cohort'].shift(1)

report = baseline.merge(prev, on='cohort', how='left', suffixes=('_current', '_prev'))
report['delta'] = report['churn_rate_current'] - report['churn_rate_prev']

report.sort_values('delta', ascending=False).to_csv('steps/003_implementer_baseline/churn_by_cohort.csv', index=False)
print(report.head())
