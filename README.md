# Mamaearth Returns & Growth Intelligence Pipeline

This repository contains an end-to-end analytics pipeline designed to identify, quantify,
and report on return rate anomalies and revenue impacts for Mamaearth.
It moves from raw relational storage to Python-based data wrangling, and finally to a GenAI-powered automated narrative report.

## Repository Structure

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

## How to Run the Pipeline

### Part 1: SQL Relational Layer
1. Ensure you have SQLite installed (`sqlite3`).
2. Run the initialization script to create the schema, load data, and run the reports in order. From the repository root, run:
   sqlite3 mamaearth.db < sql/schema.sql
   sqlite3 mamaearth.db < sql/seed_data.sql
   sqlite3 mamaearth.db < sql/reports.sql

### Part 2: Python Data Wrangling & EDA
1. Ensure you have `pandas`, `numpy`, and `matplotlib` installed.
2. Run the data cleaning and EDA script. This outputs the exact metrics and writes them to `narrator/findings.json`.
   python analysis/clean_and_eda.py
3. Run the visualization script to generate the required charts in the `visualizations/` folder.
   python analysis/visualize.py

### Part 3: GenAI Narrative Layer
1. Ensure you have the `google-genai` SDK installed (`pip install google-genai`).
2. **Online mode:** Set your Gemini API key as an environment variable, then run the script:
   export GEMINI_API_KEY="your_api_key_here"
   python narrator/generate_narrative.py
3. **Offline mode:** If you do not have an API key or lack network access, simply run the script without setting the key. The script will automatically trigger the deterministic offline fallback path and successfully generate the report template:
   unset GEMINI_API_KEY
   python narrator/generate_narrative.py
