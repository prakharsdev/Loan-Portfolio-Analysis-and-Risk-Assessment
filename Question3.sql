-- Question 3
-- Step 1: Calculate the number of late charges per loan for each year
WITH LoanLateCharges AS (
    SELECT
        l."LoanId",
        l."Country",
        -- Extract the year from the repayment date by explicitly casting "Date" to DATE type
        EXTRACT(YEAR FROM CAST(r."Date" AS DATE)) AS year,
        -- Count the number of late charges applied to each loan
        COUNT(r."loan_id") AS late_charge_count
    FROM
        "LoanData" l
    -- Join "LoanData" and "RepaymentsData" tables on the loan identifier to link repayments to each loan
    JOIN
        "RepaymentsData" r ON l."LoanId" = r."loan_id"
    WHERE
        r."LateFeesRepayment" > 0  -- Filter to include only those repayments that incurred late fees
    -- Group by loan ID, country, and year to calculate late charges for each loan per year
    GROUP BY
        l."LoanId", l."Country", EXTRACT(YEAR FROM CAST(r."Date" AS DATE))
),

-- Step 2: Aggregate the total number of late charges and count of loans per country and year
CountryYearLateCharges AS (
    SELECT
        "Country",
        year,
        -- Sum the late charges for each country and year combination
        SUM(late_charge_count) AS total_late_charges,
        -- Count the number of distinct loans that had late charges for each country and year
        COUNT(DISTINCT "LoanId") AS loan_count
    FROM
        LoanLateCharges
    -- Group by country and year to summarize late charge data for each region
    GROUP BY
        "Country", year
)

-- Step 3: Calculate the average number of late charges per loan and display the final results
SELECT
    "Country",
    year,
    total_late_charges,  -- Total number of late charges incurred in each country per year
    loan_count,  -- Number of unique loans that had late charges in each country per year
    -- Calculate the average late charges per loan for each country and year
    ROUND(CAST(total_late_charges AS numeric) / loan_count, 2) AS avg_late_charges_per_loan
FROM
    CountryYearLateCharges
-- Order the results by country and year to display trends in late charges
ORDER BY
    "Country", year;
