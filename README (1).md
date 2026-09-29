# Olist E-Commerce Analysis: Python, PostgreSQL & Power BI

## Overview
An end-to-end analysis of the public **Olist Brazilian E-Commerce dataset** (~100K real orders, 2016-2018). Nine relational tables were cleaned and merged with Python, analyzed with advanced SQL in PostgreSQL, and visualized in an interactive Power BI dashboard.

Dataset: [Brazilian E-Commerce Public Dataset by Olist (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

## Dashboard
![Olist Sales Dashboard](dashboard.png)

## Tools Used
- **Python** (Pandas): data cleaning, merging, feature engineering
- **PostgreSQL / pgAdmin**: database and advanced queries
- **Power BI Desktop**: dashboard, connected live to PostgreSQL

## Workflow

### 1. Data Preparation (Python)
- Merged 7 source tables (orders, order items, customers, sellers, products, payments, reviews) into one master table of **112,650 order-item rows**
- Translated product categories from Portuguese to English using the provided translation table
- Aggregated payments and reviews to order level (an order can have multiple payment and review records)
- Engineered a `delivery_delay_days` feature (actual vs. estimated delivery date)
- Kept missing values where they carried business meaning (e.g. undelivered orders have no delivery date) instead of filling them blindly

### 2. Analysis (PostgreSQL)
Advanced SQL including aggregations, `CASE WHEN` logic, `DATE_TRUNC`, window functions (`RANK() OVER (PARTITION BY ...)`), and CTEs. All queries are in `olist_queries.sql`.

### 3. Dashboard (Power BI)
KPI cards (revenue, orders, average review score), revenue by state, monthly revenue trend, and top product categories.

## Key Findings
- **Total revenue: ~13.59M** across **98,666 orders**, with an average review score of **4.03 / 5**
- **Geographic concentration:** São Paulo (SP) alone generates ~**38%** of revenue, well ahead of RJ and MG
- **Top categories by revenue:** health_beauty, watches_gifts, bed_bath_table, sports_leisure, computers_accessories
- **Delivery drives satisfaction:** orders delivered **late average a 2.26 review score vs. 4.21 for on-time or early orders**, the strongest operational lever for customer satisfaction in the data
- **Payments:** credit card dominates (~77% of orders), followed by boleto (~20%), a Brazilian bank-slip payment method
- **Growth:** monthly revenue grew from ~0.1M (Jan 2017) to ~1M by late 2017, then plateaued at roughly 0.85-1M

## Data Limitations
- The dataset contains very few orders before Jan 2017 and after Aug 2018 (e.g. 16 orders in Sep 2018), so the trend chart is restricted to Jan 2017 - Aug 2018 to avoid a misleading drop-off from incomplete data.
- The Nov 2017 spike may relate to seasonal sales events, but this is a hypothesis and is not confirmed by the data.

## Repository Contents
- `README.md`: this file
- `merge_data.py`: cleaning and merging script
- `olist_queries.sql`: PostgreSQL queries (table schema plus analysis)
- `dashboard.png`: dashboard screenshot
- `Olist_Sales_Dashboard.pbix`: Power BI file
