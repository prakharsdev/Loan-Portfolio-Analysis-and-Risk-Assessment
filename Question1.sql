-- Question 1
-- Query to retrieve count of loans by status, month of issue date, and loan rating
SELECT 
	EXTRACT(MONTH FROM TO_DATE("ListedOnUTC", 'YYYY-MM-DD')) AS loan_issue_month,  -- Extracting the month from the loan issue date
    EXTRACT(YEAR FROM TO_DATE("ListedOnUTC", 'YYYY-MM-DD')) AS loan_issue_year,  -- Extracting the year from the loan issue date    
    "Status" AS loan_status,  -- Loan status (e.g., Repaid, Current, Late)
    "Rating",                 -- Current rating of the loan
    "Rating_V0",              -- Previous version 0 rating of the loan (historical)
    "Rating_V1",              -- Previous version 1 rating of the loan (historical)
    "Rating_V2",              -- Previous version 2 rating of the loan (historical)
    COUNT(*) AS loan_count    -- Counting the number of loans in each category
FROM 
    "LoanData"  -- Table containing loan information
GROUP BY 
    loan_issue_year,          -- Grouping by the year of loan issue to analyze trends over time
    loan_issue_month,         -- Grouping by the month of loan issue for more granular analysis
    "Status",                 -- Grouping by the loan status to compare active and repaid loans
    "Rating", "Rating_V0", "Rating_V1", "Rating_V2"  -- Grouping by all rating columns to observe rating transitions
ORDER BY 
    loan_issue_year,          -- Ordering results by year for chronological analysis
    loan_issue_month, 
    loan_status;              -- Ordering by loan status to easily identify patterns by status

-------------------------------------------------------------------------------------------------------------------------
-- Query calculates the distribution of loans based on their status to understand the overall state of the loan portfolio.

SELECT
    "Status",  -- The current status of the loan, such as Repaid, Current, or Late
    COUNT(*) AS count  -- Counting the number of loans for each status
FROM
    "LoanData"  -- Table containing information about the loans
GROUP BY
    "Status"  -- Grouping by the loan status to categorize loans based on their current state
ORDER BY
    count DESC;  -- Sorting the results in descending order to highlight the most common loan statuses


-------------------------------------------------------------------------------------------------------------------------

-- Query calculates the distribution of loans based on their ratings to assess the credit risk profile of the loan portfolio.

SELECT
    "Rating",  -- The credit rating assigned to the loan, indicating its creditworthiness (e.g., AA, A, B, C, etc.)
    COUNT(*) AS count  -- Counting the number of loans for each rating
FROM
    "LoanData"  -- Table containing information about loans and their assigned ratings
GROUP BY
    "Rating"  -- Grouping by loan rating to categorize loans based on their creditworthiness
ORDER BY
    count DESC;  -- Sorting the results in descending order to highlight the most common loan ratings



-------------------------------------------------------------------------------------------------------------------------

-- Query analyzes the count of loans based on their rating and status to understand the relationship between credit risk and loan performance.

SELECT
    "Rating",  -- The credit rating assigned to the loan, indicating its creditworthiness (e.g., AA, A, B, C, etc.)
    "Status",  -- The current status of the loan, such as Repaid, Current, or Late
    COUNT(*) AS loan_count  -- Counting the number of loans for each combination of rating and status
FROM
    "LoanData"  -- Table containing detailed information about loans, including their ratings and statuses
GROUP BY
    "Rating",  -- Grouping by rating to categorize loans based on their creditworthiness
    "Status"  -- Grouping by status to analyze how loans with each rating are performing
ORDER BY
    "Rating",  -- Sorting by rating to organize the data by creditworthiness levels
    loan_count DESC;  -- Sorting by the count of loans in descending order to highlight the most common loan statuses within each rating category

-------------------------------------------------------------------------------------------------------------------------

-- Query analyzes the count of loans based on their issue date, rating, and status to identify trends in loan distribution.

SELECT
    EXTRACT(YEAR FROM TO_DATE("ListedOnUTC", 'YYYY-MM-DD')) AS loan_issue_year,  -- Extracting the year from the loan issue date to categorize loans by the year they were issued
    EXTRACT(MONTH FROM TO_DATE("ListedOnUTC", 'YYYY-MM-DD')) AS loan_issue_month,  -- Extracting the month from the loan issue date to identify monthly trends in loan issuance
    "Rating",  -- The rating of the loan, indicating its creditworthiness
    "Status",  -- The current status of the loan, such as Repaid, Current, or Late
    COUNT(*) AS loan_count  -- Counting the number of loans for each combination of year, month, rating, and status
FROM
    "LoanData"  -- Table containing loan records and their details
GROUP BY
    loan_issue_year,  -- Grouping by the year of loan issuance to analyze yearly trends
    loan_issue_month,  -- Grouping by the month of loan issuance for monthly trend analysis
    "Rating",  -- Grouping by the rating to understand the distribution of creditworthiness over time
    "Status"  -- Grouping by the loan status to compare how many loans fall into each status category (Repaid, Current, Late)
ORDER BY
    loan_issue_year,  -- Sorting by year to display the results chronologically
    loan_issue_month,  -- Sorting by month to ensure the data is organized in a monthly sequence within each year
    "Rating",  -- Sorting by loan rating to group similar creditworthiness levels together
    loan_count DESC;  -- Sorting by the count of loans in descending order to highlight the most common loan statuses and ratings

-------------------------------------------------------------------------------------------------------------------------

-- Query calculates the total repayments for each month and year to analyze repayment trends over time.

SELECT
    EXTRACT(YEAR FROM TO_DATE("Date", 'YYYY-MM-DD')) AS repayment_year,  -- Extracting the year from the repayment date to analyze yearly trends
    EXTRACT(MONTH FROM TO_DATE("Date", 'YYYY-MM-DD')) AS repayment_month,  -- Extracting the month from the repayment date to analyze monthly trends
    SUM("PrincipalRepayment" + "InterestRepayment" + "LateFeesRepayment") AS total_repayment  -- Calculating the total repayment amount for each month, including principal, interest, and late fees
FROM
    "RepaymentsData"  -- Table containing repayment records for various loans
GROUP BY
    repayment_year, repayment_month  -- Grouping by year and month to aggregate total repayments for each time period
ORDER BY
    repayment_year, repayment_month;  -- Sorting the results chronologically by year and month for an organized view of repayment patterns

-------------------------------------------------------------------------------------------------------------------------

-- Query analyze average monthly repayments to identify trends in total payments per month
SELECT
    EXTRACT(MONTH FROM TO_DATE("Date", 'YYYY-MM-DD')) AS repayment_month,  -- Extracting the month from the repayment date
    AVG("PrincipalRepayment" + "InterestRepayment" + "LateFeesRepayment") AS avg_total_repayment  -- Calculating average monthly repayment
FROM 
    "RepaymentsData"  -- Table containing repayment information
GROUP BY 
    repayment_month  -- Grouping by month to analyze repayment trends across different periods
ORDER BY 
    repayment_month;  -- Sorting by month to view the repayment trend in chronological order

-------------------------------------------------------------------------------------------------------------------------

-- Query calculates the Year-over-Year(YOY) growth percentage in total repayments, highlighting how repayments have changed from one year to the next.

WITH YearlyRepayments AS (
    -- Summarizing the total repayments for each year
    SELECT 
        EXTRACT(YEAR FROM TO_DATE("Date", 'YYYY-MM-DD')) AS repayment_year,  -- Extracting the year from the repayment date
        SUM("PrincipalRepayment" + "InterestRepayment" + "LateFeesRepayment") AS yearly_total_repayment  -- Summing up the total repayments for each year
    FROM 
        "RepaymentsData"  -- Table containing repayment records
    GROUP BY 
        repayment_year  -- Grouping by year to aggregate the total repayments for each year
),
GrowthCalculation AS (
    -- Calculating the repayment amounts for the current and previous years to compute growth
    SELECT
        repayment_year,  -- The current year in the analysis
        yearly_total_repayment,  -- Total repayment amount for the current year
        LAG(yearly_total_repayment) OVER (ORDER BY repayment_year) AS previous_year_repayment  -- Using the LAG function to get the total repayment of the previous year for comparison
    FROM
        YearlyRepayments  -- Using the yearly totals calculated in the previous step
)
SELECT
    repayment_year,  -- The year for which we are analyzing the YoY growth
    yearly_total_repayment,  -- Total repayment amount for the current year
    previous_year_repayment,  -- Total repayment amount for the previous year
    (yearly_total_repayment - previous_year_repayment) / previous_year_repayment * 100 AS yoy_growth_percentage  -- Calculating the YoY growth percentage in repayments
FROM
    GrowthCalculation  -- Using the calculated data to perform the YoY growth analysis
ORDER BY
    repayment_year;  -- Sorting the results chronologically to observe the growth trends over time

-------------------------------------------------------------------------------------------------------------------------


-- Query identifies anomalous months with repayment amounts that deviate significantly from the average, indicating unusual payment patterns.

WITH MonthlyTotals AS (
    -- Calculating the total repayment amount for each month
    SELECT 
        EXTRACT(YEAR FROM TO_DATE("Date", 'YYYY-MM-DD')) AS repayment_year,  -- Extracting the year from the repayment date
        EXTRACT(MONTH FROM TO_DATE("Date", 'YYYY-MM-DD')) AS repayment_month,  -- Extracting the month from the repayment date
        SUM("PrincipalRepayment" + "InterestRepayment" + "LateFeesRepayment") AS total_repayment  -- Summing up the principal, interest, and late fee repayments to get the monthly total
    FROM 
        "RepaymentsData"  -- Table containing repayment data
    GROUP BY 
        repayment_year, repayment_month  -- Grouping by year and month to calculate monthly totals
),
MonthlyStats AS (
    -- Calculating the overall average and standard deviation of the monthly repayment totals
    SELECT 
        repayment_year,
        repayment_month,
        total_repayment,
        AVG(total_repayment) OVER () AS avg_total_repayment,  -- Calculating the average of monthly repayment totals
        STDDEV(total_repayment) OVER () AS stddev_total_repayment  -- Calculating the standard deviation of monthly repayment totals
    FROM 
        MonthlyTotals  -- Using the aggregated monthly totals for statistical analysis
)
SELECT
    repayment_year,
    repayment_month,
    total_repayment,  -- The total repayment amount for each month
    avg_total_repayment,  -- The average of all monthly repayments for reference
    stddev_total_repayment,  -- The standard deviation of monthly repayments to measure variability
    CASE 
        WHEN total_repayment > avg_total_repayment + 2 * stddev_total_repayment THEN 'High Anomaly'  -- Flagging months with significantly higher repayment values
        WHEN total_repayment < avg_total_repayment - 2 * stddev_total_repayment THEN 'Low Anomaly'  -- Flagging months with significantly lower repayment values
        ELSE 'Normal'  -- Marking months that fall within the expected range as normal
    END AS anomaly_status  -- Assigning the anomaly status based on the comparison with average and standard deviation thresholds
FROM
    MonthlyStats  -- Using the statistical analysis results to identify anomalies
ORDER BY
    repayment_year, repayment_month;  -- Sorting by year and month for chronological order

-------------------------------------------------------------------------------------------------------------------------

-- Query analyze the correlation between loan status and repayment amounts
SELECT
    "Status",  -- Loan status (e.g., Repaid, Current, Late)
    AVG("PrincipalRepayment" + "InterestRepayment" + "LateFeesRepayment") AS avg_total_repayment  -- Average repayment by loan status
FROM
    "RepaymentsData" 
JOIN 
    "LoanData" 
ON 
    "RepaymentsData"."loan_id" = "LoanData"."LoanId"  -- Joining loan data with repayment data based on loan ID
GROUP BY
    "Status"  -- Grouping by loan status to analyze repayment trends for each status category
ORDER BY
    avg_total_repayment DESC;  -- Sorting by average repayment to highlight which status has the highest repayments

-------------------------------------------------------------------------------------------------------------------------

-- Query analyzes how borrower demographics, specifically age and employment status, influence repayment behavior.

SELECT
    "Age",  -- Age of the borrower, which is a key demographic factor affecting financial stability and repayment behavior
    "EmploymentStatus",  -- Employment status of the borrower, providing insight into their income stability
    COUNT(*) AS loan_count,  -- Counting the number of loans for each combination of age and employment status
    AVG("PrincipalRepayment" + "InterestRepayment" + "LateFeesRepayment") AS avg_total_repayment  -- Calculating the average total repayment amount for each group
FROM
    "LoanData"  -- Table containing information about the borrowers and their loan details
JOIN 
    "RepaymentsData"  -- Table containing repayment details for each loan
ON 
    "LoanData"."LoanId" = "RepaymentsData"."loan_id"  -- Joining loan data with repayment data to link borrowers with their repayment records
GROUP BY
    "Age",  -- Grouping by the age of the borrower to analyze repayment trends across different age groups
    "EmploymentStatus"  -- Grouping by employment status to understand how job stability affects repayment behavior
ORDER BY
    avg_total_repayment DESC;  -- Sorting the results by average repayment in descending order to highlight the most financially stable groups

-------------------------------------------------------------------------------------------------------------------------

-- Query examines how loan ratings have transitioned over different versions of the rating system.

SELECT
    "Rating",       -- The most current rating assigned to the loan
    "Rating_V0",    -- The initial or older version of the loan rating (historical rating)
    "Rating_V1",    -- The intermediate version of the loan rating (historical rating)
    "Rating_V2",    -- The latest version of the loan rating before the most current one (historical rating)
    COUNT(*) AS count_of_loans  -- Counting the number of loans that share the same rating progression
FROM
    "LoanData"  -- Table containing information about the loans and their rating transitions
GROUP BY
    "Rating", "Rating_V0", "Rating_V1", "Rating_V2"  -- Grouping by all rating columns to analyze changes in ratings over time
ORDER BY
    count_of_loans DESC;  -- Sorting by the count of loans in descending order to highlight the most common rating transitions

-------------------------------------------------------------------------------------------------------------------------

-- Query analyzes the average monthly repayment amounts categorized by the loan status.

SELECT
    EXTRACT(MONTH FROM TO_DATE("Date", 'YYYY-MM-DD')) AS repayment_month,  -- Extracting the month from the repayment date to analyze trends by month
    "Status",  -- Loan status, indicating whether the loan is Repaid, Current, or Late
    AVG("PrincipalRepayment" + "InterestRepayment" + "LateFeesRepayment") AS avg_total_repayment  -- Calculating the average repayment amount, including principal, interest, and late fees
FROM 
    "RepaymentsData"  -- Table containing information about individual repayments
JOIN 
    "LoanData"  -- Table containing detailed information about each loan
ON 
    "RepaymentsData"."loan_id" = "LoanData"."LoanId"  -- Joining repayment data with loan data based on loan ID to match each repayment with its corresponding loan
GROUP BY 
    repayment_month,  -- Grouping by the month of repayment to identify monthly repayment trends
    "Status"  -- Grouping by loan status to see how repayment behavior differs between Repaid, Current, and Late loans
ORDER BY 
    repayment_month,  -- Sorting by month to ensure that the data is displayed in chronological order
    avg_total_repayment DESC;  -- Sorting by average repayment in descending order to highlight which status has the highest repayments for each month

-------------------------------------------------------------------------------------------------------------------------