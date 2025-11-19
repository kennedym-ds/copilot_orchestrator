import pandas as pd
from pathlib import Path

data = pd.read_csv(Path('../data/customers.csv'))
summary = (
    data.groupby(['cohort', 'activity_band'])['churned']
    .mean()
    .reset_index(name='churn_rate')
)
summary.to_csv('final_output/churn_summary_export.csv', index=False)
print('Exported churn summary to final_output/churn_summary_export.csv')
