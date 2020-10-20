# Looker Retail Application

## What does this block do for me?

The retail application connects directly to your transaction-item-level table to deliver dashboards and insights that are useful to various teams in a retail organisation:
- Regional and store managers
- Merchandising and planning
- CRM and customer teams
- eCommerce teams
- Fraud detection for delivery

While it is reproducible on most databases, it is optimised for Google BigQuery. It uses **BigQuery nested tables** and partition/cluster keys to optimize performance, and **BigQuery Machine Learning** (BQML) to:
- create dynamic customer clusters based on their shopping patterns
- generate stock/sales predictions at the item-store-week level

The block delivers the following content:

### Group Overview dashboard
