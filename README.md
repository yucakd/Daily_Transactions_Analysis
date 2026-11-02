# Daily Transactions Analytics

A personal-finance analytics project built with **SQL Server (T-SQL)**, **Excel** and **Power BI**. It analyzes 2,461 household transactions (Jan 2015 – Sep 2018, INR) to show where money comes from, where it goes, and how the balance changes over time.


## Key Figures

| Metric | Value |
|---|---|
| Total transactions | 2,461 |
| Total income | 3,042,397 |
| Total expense | 1,957,391 |
| Net balance (income − expense) | 1,085,007 |
| Income / expense ratio | 1.55 |

## Power BI Dashboard

The report has four pages, each with slicers and a page navigator:

| Page | What it shows |
|---|---|
| **Overview** | KPI cards, income / expense / transfer-out distribution (donut), trend line |
| **Category** | Top 5 expense and income categories, category → subcategory treemap |
| **Time Trend** | Yearly income, expense and net balance, YoY growth, busiest month per year |
| **Transaction Method** | Top 3 payment modes by count and by amount |

## SQL Analysis

`Daily_Transactions.sql` contains 16 queries (T-SQL) that cover:

1. Amount and count distribution by transaction type
2. Income / expense ratio
3. Top payment modes by count and amount
4. Categories by transaction count
5. Top 5 categories by amount (overall, expense and income)
6. Top 3 subcategories per category with percentage share
7. Monthly transaction count and net amount
8. Busiest months per year
9. Cumulative balance and yearly net balance with YoY change
10. Overall summary

Window functions (`SUM() OVER`, `ROW_NUMBER`, `LAG`) and CTEs are used throughout.

## Dataset

`Daily_Transactions.xlsx` (sheet: *Daily Household Transactions*)

| Column | Description |
|---|---|
| Date | Transaction date and time |
| Mode | Payment method (cash, bank account, credit card, ...) |
| Category / Subcategory | Spending or income category |
| Note | Free-text description |
| Amount | Transaction amount |
| Income/Expense | Income, Expense or Transfer-Out |
| Currency | INR |

> When importing into SQL Server, name the table `daily_transactions` and the column `Income_Expense` (the queries expect these names).

## Findings

- Income exceeds expenses: **1.55×** overall, with a net balance of about **1.09M**.
- **Salary** makes up most income (about 2.53M of 3.04M).
- Largest expense categories: **Money Transfer**, **Investment**, **Transportation**, **Household** and **Subscription**.
- **Saving Bank account 1** and **Cash** account for most transactions.
- 2017 is the busiest year (1,035 transactions).

## Repository Files

- 📊 [Power BI report](Daily_Transactions.pbix)
- 🧮 [SQL queries](Daily_Transactions.sql)
- 📗 [Excel dataset](Daily_Transactions.xlsx)

## How to Use

1. Load `Daily_Transactions.xlsx` into SQL Server and run the queries in `Daily_Transactions.sql`.
2. Open `Daily_Transactions.pbix` in Power BI Desktop to explore the interactive report.

## Tools

SQL Server (T-SQL) · Microsoft Excel · Power BI
