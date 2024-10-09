-- Question 4
-- Step 1: Identify loans with less than 1% repayment in the first three months
WITH LoanInitialRepayment AS (
    SELECT
        l."LoanId",
        l."Country",
        l."Amount" AS original_loan_amount,
        l."MaritalStatus",
        l."NrOfDependants",
        -- Calculate the sum of principal repayments made in the first three months after the loan is issued
        SUM(CASE 
            WHEN CAST(r."Date" AS DATE) <= CAST(l."ListedOnUTC" AS DATE) + INTERVAL '3 months' 
            THEN r."PrincipalRepayment" 
            ELSE 0 
        END) AS principal_repaid_in_first_3_months
    FROM
        "LoanData" l
    LEFT JOIN
        "RepaymentsData" r ON l."LoanId" = r."loan_id"
    -- Group by relevant fields to ensure accurate aggregation of repayments
    GROUP BY
        l."LoanId", l."Country", l."Amount", l."MaritalStatus", l."NrOfDependants"
),

-- Step 2: Flag loans with less than 1% repayment in the first three months
LowRepaymentLoans AS (
    SELECT
        "LoanId",
        "Country",
        original_loan_amount,
        principal_repaid_in_first_3_months,
        "MaritalStatus",
        "NrOfDependants",
        -- Flag loans where the principal repaid in the first three months is less than 1% of the original loan amount
        CASE 
            WHEN principal_repaid_in_first_3_months < original_loan_amount * 0.01 THEN 1 
            ELSE 0 
        END AS low_repayment_flag
    FROM
        LoanInitialRepayment
),

-- Step 2: Check repayment status of these low repayment loans
LoanFinalRepaymentStatus AS (
    SELECT
        l."LoanId",
        l."low_repayment_flag",
        l.original_loan_amount,
        l."MaritalStatus",
        l."NrOfDependants",
        -- Calculate the total principal repaid for loans flagged as low repayment
        SUM(r."PrincipalRepayment") AS total_principal_repaid,
        -- Determine whether each loan was eventually fully repaid
        CASE 
            WHEN SUM(r."PrincipalRepayment") >= l.original_loan_amount THEN 'Fully Repaid'
            ELSE 'Not Fully Repaid'
        END AS repayment_status
    FROM
        LowRepaymentLoans l
    LEFT JOIN
        "RepaymentsData" r ON l."LoanId" = r."loan_id"
    -- Filter to include only loans with the low repayment flag set to 1
    WHERE
        l.low_repayment_flag = 1
    -- Group by relevant fields to ensure accurate calculation of repayment status
    GROUP BY
        l."LoanId", l.low_repayment_flag, l.original_loan_amount, l."MaritalStatus", l."NrOfDependants"
),

-- Step 3: Analyze the relationship with marital status and number of children (dependants)
RepaymentAnalysis AS (
    SELECT
        l."MaritalStatus",
        l."NrOfDependants",
        -- Count the number of low repayment loans that were eventually fully repaid
        COUNT(CASE WHEN lf.repayment_status = 'Fully Repaid' THEN 1 END) AS fully_repaid_count,
        -- Count the total number of low repayment loans
        COUNT(*) AS total_low_repayment_loans,
        -- Calculate the percentage of low repayment loans that were fully repaid
        ROUND(CAST(COUNT(CASE WHEN lf.repayment_status = 'Fully Repaid' THEN 1 END) AS numeric) / COUNT(*) * 100, 2) AS repayment_rate
    FROM
        LoanFinalRepaymentStatus lf
    JOIN
        LowRepaymentLoans l ON lf."LoanId" = l."LoanId"
    -- Group by marital status and number of dependents to analyze trends
    GROUP BY
        l."MaritalStatus", l."NrOfDependants"
)

-- Final result: Display the analysis of repayment rates by marital status and number of dependents
SELECT
    "MaritalStatus",
    "NrOfDependants",
    fully_repaid_count,
    total_low_repayment_loans,
    repayment_rate
FROM
    RepaymentAnalysis
ORDER BY
    "MaritalStatus", "NrOfDependants";
