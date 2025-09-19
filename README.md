# Local-Shop-Analysis
📊 Sales Data Analysis Using SQL Server
🚀 Project Overview

This project demonstrates end-to-end data analysis using SQL Server on the Local Shop retail dataset.
The objective is to explore, analyze, and generate actionable business insights through SQL queries, KPIs, and advanced techniques like window functions and outlier detection.

🔑 Key Features & Analysis

✅ Data Cleaning & Transformation
Standardized inconsistent values (e.g., Low Fat, LF → Low Fat) for accurate reporting.

✅ Exploratory Data Analysis (EDA)

Total & Average Sales across multiple dimensions

Sales distribution by Item Type, Fat Content, and Outlet Size

KPIs including Total Sales, Avg Sales, No. of Items, Avg Ratings

✅ Business Insights

Top 10 Best-Selling Item Types

Least-Selling Item Types (candidates for discontinuation)

Sales by Outlet Establishment Year (impact of outlet age on performance)

Sales % Contribution by Outlet Size & Location

Correlation Checks: Item Visibility vs. Sales, Item Weight vs. Sales

✅ Advanced SQL Concepts Used

Window Functions → Ranking outlets & products by sales

Pivot Queries → Comparing Fat Content sales across locations

CTEs (Common Table Expressions) → Clean modular queries

Outlier Detection → Flagging unusually high/low performing outlets

📈 Sample Insights

Outlets established earlier consistently show higher sales stability.

High shelf visibility correlates with better sales.

Certain item categories dominate total revenue (Pareto effect).

Outliers detected → A few outlets significantly underperform compared to peers.

🛠 Tech Stack

Database: SQL Server

Tool: SQL Server Management Studio (SSMS)

Language: T-SQL (Transact-SQL)

📂 Project Structure

Queries/ → Contains all SQL queries organized by topic (KPIs, Sales Analysis, Outliers).

Dataset/ → Original Dataset which I got from Local Vendors.

README.md → Project documentation.

🌟 What I Learned

Writing efficient SQL queries for real-world analytics

Using window functions & aggregations for insights

Designing KPIs & reports for retail businesses

Business thinking + technical SQL skills combined

📌 Future Scope

Integration with Power BI for visualization

Automation of queries for regular reporting

Expanding dataset with customer demographics
