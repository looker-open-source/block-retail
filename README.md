# Looker Retail Block

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

As a group VP or regional manager, quickly identify the group's overall performance, and the top/bottom stores and product categories driving this trend.

<img alt="Group Overview" src="https://github.com/looker/block-retail/blob/master/screenshots/group_overview_1.png?raw=true">

<img alt="Group Overview - Top movers" src="https://github.com/looker/block-retail/blob/master/screenshots/group_overview_2.png?raw=true">

This block also uses BigQuery Machine Learning (BQML) to classify your customer into 4 main segments based on their spending patterns, and track how well you're retaining each segment

<img alt="Group Overview - Customer segments and retention" src="https://github.com/looker/block-retail/blob/master/screenshots/group_overview_2.png?raw=true">

From this dashboard, you can deep dive into any store, category, or customer segment to understand what's driving these trends, and get recommendations for concrete actions to drive sales in each one.

### Store Deep-dive dashboard

As a store manager, better understand which factors are driving your store's performance - absolute, YoY, and compared to similar peer stores. Factors examined:
- Performance vs. comparable peer stores
- Impact of the weather
- Key products that are over/under-performing vs sales predictions (predicted with BigQuery Machine Learning algorithm)
- Key products that are performing well in peer stores
- Retention and growth of key customer segments

In addition to identifying the driving factors, this dashboard gives you next actions to address each one.

<img alt="Store Deep Dive - Weather impact" src="https://github.com/looker/block-retail/blob/master/screenshots/store_deep_dive_1.png?raw=true">

<img alt="Store Deep Dive - Product impact" src="https://github.com/looker/block-retail/blob/master/screenshots/store_deep_dive_2.png?raw=true">

### Item affinity dashboard

As a category or store manager:
- Better understand the performance of a category or key item at the **basket** level, rather than just the item level.
- Identify product bundle promotions based on which items go well together and drive the most **basket margin** (not just individual item sales)
- Identify products to potentially remove from inventory, not just based on sales, but also on basket margin, customer loyalty, total margin.

<img alt="Basket Analysis - Bundle promotion" src="https://github.com/looker/block-retail/blob/master/screenshots/item_affinity_1.png?raw=true">

<img alt="Basket Analysis - Product rationalisation" src="https://github.com/looker/block-retail/blob/master/screenshots/item_affinity_2.png?raw=true">

## Technical installation

### Pre-requisites

- While this block is reproducible on most databases, it is optimised for Google BigQuery
- Required tables:
  - Transaction-level table (by transaction ID by store by item)
  - Store lookup (dim) table
  - Item lookup (dim) table
- Install the Looker Sankey visualization from the Marketplace (/marketplace/view/viz-sankey)

### Installation steps

1. Install this block from the marketplace
2. Optional installation parameters:
  - WEATHER_SCHEMA_NAME: the [project.dataset] where BigQuery's public global GHCN weather data is stored. If your BigQuery data is in the US GCP region, simply enter `bigquery-public-data.ghcn_d`. Otherwise, you may have to set up a data transfer to an EU dataset (quick and simple, but the data will then not be free to query), or leave blank to ignore
  - IMAGE_SEARCH_URL: if you do not have images of you products in your database, this block offers you the possibility to include them using the [Google Images API](https://discourse.looker.com/t/using-google-images-api-in-looker/3685). The value to input here is your Google Images API URL as per the linked instructions. Leave blank to ignore.
  - GOOGLE_MAPS_API_KEY: for the address deep-dive dashboard. Leave blank to ignore.
3. This block uses refinements for customization. For more information on using refinements to customize marketplace blocks, please see [this documentation](https://docs.looker.com/data-modeling/marketplace/customize-blocks).
4. Suggested: Use Refine to replace/update the key columns listed in the base_* views in the views/ folder. You can also add your own custom fields, or additional columns you have in your tables, with refinements.
5. Access the Block's LookML Dashboards from the LookML dashboards folder (/folders/lookml). You can customise these dashboards by copying them into one of your instance's folders.
