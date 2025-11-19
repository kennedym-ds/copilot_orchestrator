import pandas as pd
from pathlib import Path

DATASET = Path('data/customers.csv')

def summarize():
    df = pd.read_csv(DATASET)
    summary = {
        "rows": len(df),
        "churn_rate": df['churned'].mean(),
        "regions": df['region'].value_counts(normalize=True).to_dict(),
        "activity_band": df['activity_band'].value_counts().to_dict()
    }
    return summary

if __name__ == "__main__":
    report = summarize()
    print(report)
