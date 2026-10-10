import pandas as pd
import matplotlib.pyplot as plt
import json
import os

# Ensure directories exist
os.makedirs('visualizations', exist_ok=True)

# Load data findings directly from JSON to maintain sync with clean_and_eda
with open('narrator/findings.json', 'r') as f:
    findings = json.load(f)

# --- 1. Return Rate by Payment Bar Chart ---
rates = findings['return_rate_by_payment']
# Sort descending
rates = dict(sorted(rates.items(), key=lambda item: item[1], reverse=True))

fig, ax = plt.subplots(figsize=(8, 5))
bars = ax.bar(rates.keys(), rates.values(), color=['#FF6B6B', '#4ECDC4', '#45B7D1'])

ax.set_title(f"COD Returns at {rates['COD']}% — 3x Card")
ax.set_ylabel("Return Rate (%)")
ax.set_ylim(0, 60)

# Exact percentage labels
for bar in bars:
    yval = bar.get_height()
    ax.text(bar.get_x() + bar.get_width()/2, yval + 1, f"{yval}%", ha='center', va='bottom', fontweight='bold')

plt.tight_layout()
plt.savefig('visualizations/return_rate_by_payment.png', dpi=300)
plt.close()

# --- 2. Monthly Revenue Trend Line Chart ---
# Rebuilding the corrected series for plotting
orders = pd.read_csv('data/orders.csv')
products = pd.read_csv('data/products.csv')
orders['payment_method'] = orders['payment_method'].str.strip().str.upper()
orders = orders.drop_duplicates(subset=['customer_id', 'product_id', 'order_date', 'quantity', 'discount_pct', 'payment_method', 'rating', 'returned'], keep='first')
orders['discount_pct'] = orders['discount_pct'].fillna(0)
merged = orders.merge(products, on='product_id')
Q1 = merged['quantity'].quantile(0.25)
Q3 = merged['quantity'].quantile(0.75)
IQR = Q3 - Q1
upper = Q3 + 1.5 * IQR
lower = Q1 - 1.5 * IQR
clean_merged = merged[(merged['quantity'] >= lower) & (merged['quantity'] <= upper)].copy()
clean_merged['order_date'] = pd.to_datetime(clean_merged['order_date'])
clean_merged['order_value'] = clean_merged['quantity'] * clean_merged['price'] * (1 - clean_merged['discount_pct']/100)
monthly_revenue = clean_merged.groupby(clean_merged['order_date'].dt.to_period('M'))['order_value'].sum()

fig, ax = plt.subplots(figsize=(10, 5))
monthly_revenue.plot(kind='line', marker='o', color='#2C3E50', ax=ax)

ax.set_title(f"Monthly Revenue (Outlier-Corrected) — True Peak in March")
ax.set_xlabel("Month")
ax.set_ylabel("Revenue (INR)")
ax.grid(True, linestyle='--', alpha=0.7)

plt.tight_layout()
plt.savefig('visualizations/monthly_revenue_trend.png', dpi=300)
plt.close()

print("Generated visualizations in visualizations/ folder.")
