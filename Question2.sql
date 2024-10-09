-- Question 2
-- Step 1: Create a Common Table Expression (CTE) to aggregate daily loan data
WITH DailyLoans AS (
    SELECT
        "ListedOnUTC"::date AS issue_date,  -- Convert the issuance timestamp to a date
        "Country",                          -- Grouping by country
        "NewCreditCustomer",                -- Segmenting by customer status (new or returning)
        COUNT("LoanId") AS loan_count,      -- Calculating the number of loans issued per day
        SUM("Amount") AS total_loan_amount  -- Summing the total loan amount issued per day
    FROM
        "LoanData"                          -- Source table containing loan data
    GROUP BY
        "ListedOnUTC"::date, "Country", "NewCreditCustomer"  -- Grouping data by date, country, and customer status
),

-- Step 2: Use the CTE to perform day-over-day and week-over-week comparisons
DailyComparison AS (
    SELECT
        issue_date,                         -- The date of loan issuance
        "Country",                          -- Country of the customer
        "NewCreditCustomer",                -- Customer status (new or returning)
        loan_count,                         -- Number of loans issued on this date
        total_loan_amount,                  -- Total loan amount issued on this date
        
        -- Using LAG to get the previous day's loan count and amount for comparison
        COALESCE(LAG(loan_count, 1) OVER (PARTITION BY "Country", "NewCreditCustomer" ORDER BY issue_date), 0) AS prev_day_loan_count,
        COALESCE(LAG(total_loan_amount, 1) OVER (PARTITION BY "Country", "NewCreditCustomer" ORDER BY issue_date), 0) AS prev_day_loan_amount,
        
        -- Using LAG to get the loan count and amount for the same weekday of the previous week
        COALESCE(LAG(loan_count, 7) OVER (PARTITION BY "Country", "NewCreditCustomer" ORDER BY issue_date), 0) AS prev_week_loan_count,
        COALESCE(LAG(total_loan_amount, 7) OVER (PARTITION BY "Country", "NewCreditCustomer" ORDER BY issue_date), 0) AS prev_week_loan_amount
    FROM
        DailyLoans                          -- Referencing the daily aggregated loan data from the CTE
)

-- Step 3: Select the final output with calculated changes and trends
SELECT
    issue_date,                            -- The date of loan issuance
    "Country",                             -- Country of the customer
    "NewCreditCustomer",                   -- Customer status (new or returning)
    loan_count,                            -- Number of loans issued on this date
    total_loan_amount,                     -- Total loan amount issued on this date
    prev_day_loan_count,                   -- Loan count of the previous day
    prev_day_loan_amount,                  -- Loan amount of the previous day
    prev_week_loan_count,                  -- Loan count of the same weekday in the previous week
    prev_week_loan_amount,                 -- Loan amount of the same weekday in the previous week
    
    -- Calculating the absolute change in loan count and amount compared to the previous day
    (loan_count - prev_day_loan_count) AS change_vs_prev_day_count,
    (total_loan_amount - prev_day_loan_amount) AS change_vs_prev_day_amount,
    
    -- Calculating the absolute change in loan count and amount compared to the same weekday of the previous week
    (loan_count - prev_week_loan_count) AS change_vs_prev_week_count,
    (total_loan_amount - prev_week_loan_amount) AS change_vs_prev_week_amount,
    
    -- Calculating the percentage change in loan count and amount compared to the previous day
    CASE
        WHEN prev_day_loan_count = 0 THEN NULL  -- Avoid division by zero
        ELSE ROUND(CAST((loan_count - prev_day_loan_count) * 100.0 / prev_day_loan_count AS numeric), 2)
    END AS pct_change_vs_prev_day_count,
    
    CASE
        WHEN prev_day_loan_amount = 0 THEN NULL  -- Avoid division by zero
        ELSE ROUND(CAST((total_loan_amount - prev_day_loan_amount) * 100.0 / prev_day_loan_amount AS numeric), 2)
    END AS pct_change_vs_prev_day_amount,
    
    -- Calculating the percentage change in loan count and amount compared to the same weekday of the previous week
    CASE
        WHEN prev_week_loan_count = 0 THEN NULL  -- Avoid division by zero
        ELSE ROUND(CAST((loan_count - prev_week_loan_count) * 100.0 / prev_week_loan_count AS numeric), 2)
    END AS pct_change_vs_prev_week_count,
    
    CASE
        WHEN prev_week_loan_amount = 0 THEN NULL  -- Avoid division by zero
        ELSE ROUND(CAST((total_loan_amount - prev_week_loan_amount) * 100.0 / prev_week_loan_amount AS numeric), 2)
    END AS pct_change_vs_prev_week_amount,
    
    -- Trend indicator for day-over-day changes in loan count
    CASE
        WHEN (loan_count - prev_day_loan_count) > 0 THEN 'Increase'
        WHEN (loan_count - prev_day_loan_count) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS trend_vs_prev_day,
    
    -- Trend indicator for week-over-week changes in loan count
    CASE
        WHEN (loan_count - prev_week_loan_count) > 0 THEN 'Increase'
        WHEN (loan_count - prev_week_loan_count) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS trend_vs_prev_week
FROM
    DailyComparison                        -- Referencing the table with calculated daily and weekly comparisons
ORDER BY
    issue_date, "Country", "NewCreditCustomer";  -- Sorting the results by date, country, and customer status
