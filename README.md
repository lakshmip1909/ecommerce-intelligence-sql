# E-commerce Intelligence: SQL Analytics

## Project Overview

An end-to-end SQL analytics project using the Brazilian Olist e-commerce dataset to investigate revenue performance, delivery reliability and customer retention.

The project demonstrates data modelling, data quality checks, multi-table joins, common table expressions (CTEs), window functions, cohort analysis and query optimisation.

## Tools and Technologies

- MySQL
- MySQL Workbench
- SQL (CTEs, window functions, joins and aggregations)

## Dataset

The Brazilian E-Commerce Public Dataset by Olist contains approximately 100,000 orders and related customer, product, payment, review and delivery information.

Source: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

## Key Findings

- **Payment performance:** R$16.01 million in recorded payments across 99,440 paid orders.
- **Delivery reliability:** Late deliveries were associated with lower average review scores (2.57 versus 4.29 for on-time deliveries).
- **Customer retention:** Only 3.00% of customers made multiple delivered purchases during the observation period.
- **Category concentration:** The five leading product categories accounted for approximately 39.74% of merchandise value.

## SQL Project Structure

| File | Purpose |
|---|---|
| 01_create_database.sql | Database setup |
| 02_create_tables.sql | Relational table definitions |
| 03_import_data.sql | CSV data loading |
| 04_data_quality.sql | Missing values, duplicates and integrity checks |
| 05_revenue_analysis.sql | Revenue trends and category performance |
| 06_delivery_analysis.sql | Delivery delays and customer satisfaction |
| 07_customer_retention.sql | Repeat purchases and cohort retention |
| 08_query_optimisation.sql | Indexing and execution-plan analysis |
| 09_business_insights.sql | Business insights and recommendations |

All SQL scripts are located in the `sql/` directory.

## Business Recommendations

1. Investigate late deliveries and prioritise regions with high delay rates.
2. Test customer retention initiatives and measure repeat purchase behaviour.
3. Monitor high-performing product categories and evaluate profitability before increasing investment.

## Limitations

The dataset is historical and covers a limited observation period. Results describe observed purchasing behaviour rather than lifetime customer retention. Delivery and review relationships are observational and do not establish causation.

## Author

Lakshmi Priya Subramonian