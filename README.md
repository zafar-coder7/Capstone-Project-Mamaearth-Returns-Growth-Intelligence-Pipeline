# Mamaearth Returns & Growth Intelligence Pipeline

This repository contains an end-to-end analytics pipeline designed to identify, quantify, and report on return rate anomalies and revenue impacts for Mamaearth. It moves from raw relational storage to Python-based data wrangling, and finally to a GenAI-powered automated narrative report.

## Repository Structure
```text
.
├── README.md
├── sql/
│   ├── schema.sql
│   ├── seed_data.sql
│   └── reports.sql
├── data/
│   ├── customers.csv
│   ├── products.csv
│   └── orders.csv
├── analysis/
│   ├── clean_and_eda.py
│   └── visualize.py
├── visualizations/
│   ├── return_rate_by_payment.png
│   └── monthly_revenue_trend.png
└── narrator/
    ├── findings.json
    └── generate_narrative.py
