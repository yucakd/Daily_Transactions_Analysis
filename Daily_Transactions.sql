
-- 1.) Amount Distribution by Transaction Type

SELECT 
    Income_Expense,
    SUM(amount) AS Total_Amount,
    CAST(SUM(amount) * 100.0 / SUM(SUM(Amount)) OVER () AS DECIMAL(5,2) ) AS Total_Amount_prc
FROM daily_transactions
GROUP BY Income_Expense
ORDER BY Total_Amount DESC; 


-- 2.) Count Transaction Distribution by Transaction Type

SELECT 
    Income_Expense,
    COUNT(*) AS Transaction_Count,
    CAST( COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2) ) AS Transaction_Prc
FROM daily_transactions
GROUP BY Income_Expense
ORDER BY Transaction_Count DESC;

-- 3.) Income/Expense Ratio 

SELECT 
    SUM(CASE 
            WHEN Income_Expense = 'Income' 
            THEN Amount 
            ELSE 0 
        END) AS Total_Income,

    SUM(CASE 
            WHEN Income_Expense = 'Expense' 
            THEN Amount 
            ELSE 0 
        END) AS Total_Expense,

    ROUND(SUM(CASE 
            WHEN Income_Expense = 'Income' 
            THEN Amount 
            ELSE 0 
        END)
    /
    NULLIF(SUM(CASE 
            WHEN Income_Expense = 'Expense' 
            THEN Amount 
            ELSE 0 
        END),0),2) AS Income_Expense_Ratio
FROM daily_transactions;


-- 4.) Transaction Count by Transaction Method

SELECT TOP 3
    Mode,
    COUNT(*) AS Mode_count,
    CAST( COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2) ) AS transaction_prc
FROM daily_transactions
GROUP BY mode 
ORDER BY Mode_count DESC;


-- 5.) Top 3 Modes Methods by Total Amount

SELECT  TOP 3
	Mode,
	SUM(Amount) AS Total_Amount,
	SUM(CASE WHEN Income_Expense='Income' THEN Amount ELSE 0 END) AS Mode_Income,
	SUM(CASE WHEN Income_Expense='Expense' THEN Amount ELSE 0 END) AS Mode_Expense,
	SUM(CASE WHEN Income_Expense='Transfer-out' THEN Amount ELSE 0 END) AS Mode_Transfer_Out
FROM daily_transactions
GROUP BY Mode
ORDER BY Total_Amount DESC; 

-- 6.) Categories by Transaction Count

SELECT 
    Category,
    COUNT(*) as Total_Count,
    SUM(CASE WHEN Income_Expense = 'Income' THEN 1 ELSE 0 END) AS Income,
    SUM(CASE WHEN Income_Expense = 'Expense' THEN 1 ELSE 0 END) AS Expense,
    SUM(CASE WHEN Income_Expense = 'Transfer-out' THEN 1 ELSE 0 END) AS Transfer_Out
FROM daily_transactions
GROUP BY Category
ORDER BY COUNT(*) DESC;

-- 7.) Top 5 Categories by Total Amount 

    WITH category_amounts AS (
        SELECT 
            Income_Expense,
            Category,
            SUM(Amount) AS Total_Amount,
            CAST(
                SUM(Amount) * 100.0 / SUM(SUM(Amount)) OVER ()
                AS DECIMAL(5,2)
            ) AS Overall_Prc,
            ROW_NUMBER() OVER (
                PARTITION BY Income_Expense 
                ORDER BY SUM(Amount) DESC
            ) AS rn
        FROM daily_transactions
        GROUP BY Income_Expense, Category
    )
    SELECT 
        Income_Expense,
        Category,
        Total_Amount,
        Overall_Prc
    FROM category_amounts
    WHERE rn <= 5
    ORDER BY Income_Expense, Total_Amount DESC;


-- 8.) TOP 5 Categories by Expense

SELECT TOP 5
    Income_Expense,
    Category,
    SUM(AMOUNT) as Expense_Amounts,
    CAST(SUM(AMOUNT) * 100.0 / SUM(SUM(AMOUNT)) OVER () AS DECIMAL (5,2) ) AS Expenses_prc
FROM daily_transactions
WHERE Income_Expense='Expense' 
GROUP BY Income_Expense, Category
ORDER BY Expense_Amounts DESC;


-- 9.) TOP 5 Categories by Income

SELECT TOP 5
     Income_Expense,
    Category,
    SUM(AMOUNT) as Income_Amounts,
    CAST(SUM(AMOUNT) * 100.0 / SUM(SUM(AMOUNT)) OVER () AS DECIMAL (5,2) ) AS Incomes_prc
FROM daily_transactions
WHERE Income_Expense='Income' 
GROUP BY Income_Expense, Category
ORDER BY Income_Amounts DESC;


-- 10.) Top 3 Subcategories by Category & Percentage Share

WITH SubcategoryTotals AS (
    SELECT 
        Category, 
        Subcategory, 
        SUM(Amount) AS Sub_Amount
    FROM daily_transactions 
    WHERE Subcategory IS NOT NULL 
    GROUP BY Category, Subcategory
),
RankedData AS (
    SELECT 
        Category,
        Subcategory,
        Sub_Amount,
        SUM(Sub_Amount) OVER(PARTITION BY Category) AS Category_Amount,
        ROW_NUMBER() OVER(
            PARTITION BY Category 
            ORDER BY Sub_Amount DESC
        ) AS rn
    FROM SubcategoryTotals
)
SELECT 
    Category,
    Subcategory,
    Sub_Amount,
    Category_Amount,
    CAST(
        Sub_Amount * 100.0 / Category_Amount 
        AS DECIMAL(5,2)
    ) AS Subcategory_Prc
FROM RankedData
WHERE rn <= 3 
ORDER BY Category_Amount DESC, Category, Sub_Amount DESC;


-- 11.) Transaction Count and Amount by Year and Month

SELECT
    FORMAT(DATE,'yyyy-MM') AS YEAR_MONTH,
    COUNT(*) AS Transaction_Counts,
    SUM(CASE WHEN Income_Expense = 'Income' THEN Amount ELSE 0 END) AS Total_Income,
    SUM(CASE WHEN Income_Expense = 'Expense' THEN Amount ELSE 0 END) AS Total_Expense,
    SUM(CASE WHEN Income_Expense = 'Transfer-out' THEN Amount ELSE 0 END) AS Total_Transfer_Out,
    SUM(CASE 
            WHEN Income_Expense = 'Income' THEN Amount 
            WHEN Income_Expense = 'Expense' THEN -Amount 
            ELSE 0 
        END) AS Net_Amount
FROM daily_transactions
GROUP BY FORMAT(DATE,'yyyy-MM')
ORDER BY YEAR_MONTH ASC;


-- 12.) Top 3 Most Traded Transactions by Year

WITH monthly_transactions AS (
    SELECT  
        YEAR(Date) AS Transaction_Year,
        MONTH(Date) AS Transaction_Month,
        COUNT(*) AS Transaction_Count
    FROM daily_transactions
    GROUP BY
        YEAR(Date),
        MONTH(Date)
),
ranked_months AS (
    SELECT
        Transaction_Year,
        Transaction_Month,
        Transaction_Count,
        ROW_NUMBER() OVER (
            PARTITION BY Transaction_Year
            ORDER BY Transaction_Count DESC
        ) AS Month_Rank
    FROM monthly_transactions
)
SELECT
    Transaction_Year,
    Transaction_Month,
    Transaction_Count,
    Month_Rank
FROM ranked_months
WHERE Month_Rank <= 3
ORDER BY
    Transaction_Year,
    Month_Rank;


-- 13.) Cumulative Balance by Years and Months

WITH MonthlyNet AS (
    SELECT
        YEAR([Date]) AS Year,
        MONTH([Date]) AS Month,
        SUM(CASE 
                WHEN Income_Expense = 'Income' THEN Amount 
                WHEN Income_Expense = 'Expense' THEN -Amount 
                ELSE 0 
            END) AS NetAmount
    FROM daily_transactions
    GROUP BY YEAR([Date]), MONTH([Date])
)
SELECT
    Year,
    Month,
    NetAmount,
    SUM(NetAmount) OVER (PARTITION BY Year ORDER BY Month) AS CumulativeBalance
FROM MonthlyNet
ORDER BY Year, Month;


--14.) Yearly Net Balance

WITH yearly AS (
    SELECT
        YEAR([Date]) AS Year,
        SUM(
            CASE 
                WHEN Income_Expense = 'Income' THEN Amount 
                WHEN Income_Expense = 'Expense' THEN -Amount 
                ELSE 0 
            END
        ) AS Yearly_Net
    FROM daily_transactions
    GROUP BY YEAR([Date])
)
SELECT
    Year,
    Yearly_Net,

    COALESCE(
        LAG(Yearly_Net) OVER (ORDER BY Year),
        0
    ) AS Previous_Year_Net,

    COALESCE(
        CAST(
            (Yearly_Net - LAG(Yearly_Net) OVER (ORDER BY Year))
            * 100.0
            / NULLIF(LAG(Yearly_Net) OVER (ORDER BY Year), 0)
            AS DECIMAL(10,2)
        ),
        0
    ) AS YoY_Change_Prc

FROM yearly
ORDER BY Year;


-- 15.) TOP 1 Transactions Month by Year

WITH MonthlySummary AS (
    SELECT 
        YEAR([Date]) AS TxYear,
        DATENAME(MONTH, [Date]) AS MonthName,
        MONTH([Date]) AS MonthNumber,
        COUNT(*) AS TotalTransactions
    FROM daily_transactions
    GROUP BY 
        YEAR([Date]),
        DATENAME(MONTH, [Date]),
        MONTH([Date])
),
RankedMonths AS (
    SELECT 
        TxYear,
        MonthName,
        TotalTransactions,
        ROW_NUMBER() OVER(
            PARTITION BY TxYear 
            ORDER BY TotalTransactions DESC
        ) AS RowNum
    FROM MonthlySummary
)
SELECT 
    TxYear,
    MonthName,
    TotalTransactions
FROM RankedMonths
WHERE RowNum = 1
ORDER BY TxYear ASC;



--16.) Daily Transactions Overview 

SELECT
    SUM(CASE WHEN Income_Expense = 'Income' THEN Amount ELSE 0 END) AS Total_Income,
    SUM(CASE WHEN Income_Expense = 'Expense' THEN Amount ELSE 0 END) AS Total_Expense,
    SUM(CASE WHEN Income_Expense = 'Income' THEN Amount 
             WHEN Income_Expense = 'Expense' THEN -Amount ELSE 0 END) AS Net_Balance,
    COUNT(*) AS Total_Transactions
FROM daily_transactions;
