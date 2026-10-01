/*
===========================================================
Commercial Loan Portfolio & Credit Risk Analytics
SQL Analysis Examples
===========================================================

Purpose:
Demonstrate SQL techniques used for commercial loan portfolio
monitoring, credit risk analysis and management reporting.

Dataset:
Fictional commercial lending dataset.

Tools:
SQL Server / T-SQL

No confidential customer, account or company information is used.
===========================================================
*/


/* =========================================================
1. TOTAL LOAN PORTFOLIO
========================================================= */

SELECT
    SUM(LoanBalanceKES) AS TotalLoanPortfolioKES
FROM LoanBook;


/* =========================================================
2. PORTFOLIO BY PRODUCT
========================================================= */

SELECT
    Product,
    COUNT(DISTINCT FacilityID) AS NumberOfFacilities,
    SUM(LoanBalanceKES) AS PortfolioBalanceKES
FROM LoanBook
GROUP BY Product
ORDER BY PortfolioBalanceKES DESC;


/* =========================================================
3. PORTFOLIO BY SECTOR
========================================================= */

SELECT
    SectorName,
    COUNT(DISTINCT FacilityID) AS NumberOfFacilities,
    SUM(LoanBalanceKES) AS PortfolioBalanceKES
FROM LoanBook
GROUP BY SectorName
ORDER BY PortfolioBalanceKES DESC;


/* =========================================================
4. PORTFOLIO BY RELATIONSHIP MANAGER
========================================================= */

SELECT
    RelationshipManager,
    COUNT(DISTINCT FacilityID) AS NumberOfFacilities,
    SUM(LoanBalanceKES) AS PortfolioBalanceKES
FROM LoanBook
GROUP BY RelationshipManager
ORDER BY PortfolioBalanceKES DESC;


/* =========================================================
5. PAR 30 ANALYSIS
========================================================= */

SELECT
    SUM(
        CASE
            WHEN DPD > 30 THEN LoanBalanceKES
            ELSE 0
        END
    ) AS PAR30BalanceKES,

    SUM(LoanBalanceKES) AS TotalPortfolioKES,

    CAST(
        SUM(
            CASE
                WHEN DPD > 30 THEN LoanBalanceKES
                ELSE 0
            END
        ) * 100.0
        / NULLIF(SUM(LoanBalanceKES), 0)
        AS DECIMAL(10,2)
    ) AS PAR30Percentage

FROM LoanBook;


/* =========================================================
6. PAR 90 ANALYSIS
========================================================= */

SELECT
    SUM(
        CASE
            WHEN DPD > 90 THEN LoanBalanceKES
            ELSE 0
        END
    ) AS PAR90BalanceKES,

    SUM(LoanBalanceKES) AS TotalPortfolioKES,

    CAST(
        SUM(
            CASE
                WHEN DPD > 90 THEN LoanBalanceKES
                ELSE 0
            END
        ) * 100.0
        / NULLIF(SUM(LoanBalanceKES), 0)
        AS DECIMAL(10,2)
    ) AS PAR90Percentage

FROM LoanBook;


/* =========================================================
7. LOAN CLASSIFICATION
========================================================= */

SELECT
    Classification,
    COUNT(DISTINCT FacilityID) AS NumberOfFacilities,
    SUM(LoanBalanceKES) AS PortfolioBalanceKES
FROM LoanBook
GROUP BY Classification
ORDER BY PortfolioBalanceKES DESC;


/* =========================================================
8. DPD BUCKET ANALYSIS
========================================================= */

SELECT
    CASE
        WHEN DPD = 0 THEN 'Current'
        WHEN DPD BETWEEN 1 AND 30 THEN '1-30 Days'
        WHEN DPD BETWEEN 31 AND 60 THEN '31-60 Days'
        WHEN DPD BETWEEN 61 AND 90 THEN '61-90 Days'
        WHEN DPD BETWEEN 91 AND 180 THEN '91-180 Days'
        ELSE '180+ Days'
    END AS DPD_Bucket,

    COUNT(DISTINCT FacilityID) AS NumberOfFacilities,

    SUM(LoanBalanceKES) AS PortfolioBalanceKES

FROM LoanBook

GROUP BY
    CASE
        WHEN DPD = 0 THEN 'Current'
        WHEN DPD BETWEEN 1 AND 30 THEN '1-30 Days'
        WHEN DPD BETWEEN 31 AND 60 THEN '31-60 Days'
        WHEN DPD BETWEEN 61 AND 90 THEN '61-90 Days'
        WHEN DPD BETWEEN 91 AND 180 THEN '91-180 Days'
        ELSE '180+ Days'
    END

ORDER BY
    CASE
        WHEN DPD = 0 THEN 1
        WHEN DPD BETWEEN 1 AND 30 THEN 2
        WHEN DPD BETWEEN 31 AND 60 THEN 3
        WHEN DPD BETWEEN 61 AND 90 THEN 4
        WHEN DPD BETWEEN 91 AND 180 THEN 5
        ELSE 6
    END;


/* =========================================================
9. TOP 10 CLIENT EXPOSURES
========================================================= */

SELECT TOP 10
    ClientName,
    SUM(LoanBalanceKES) AS TotalExposureKES
FROM LoanBook
GROUP BY ClientName
ORDER BY TotalExposureKES DESC;


/* =========================================================
10. FACILITIES ABOVE APPROVED LIMIT
========================================================= */

SELECT
    FacilityID,
    ClientName,
    ApprovedLimitKES,
    LoanBalanceKES,
    LoanBalanceKES - ApprovedLimitKES AS ExcessExposureKES
FROM LoanBook
WHERE LoanBalanceKES > ApprovedLimitKES
ORDER BY ExcessExposureKES DESC;


/* =========================================================
11. SECTOR CONCENTRATION
========================================================= */

SELECT
    SectorName,
    SUM(LoanBalanceKES) AS SectorExposureKES,

    CAST(
        SUM(LoanBalanceKES) * 100.0
        / NULLIF(
            (SELECT SUM(LoanBalanceKES) FROM LoanBook),
            0
        )
        AS DECIMAL(10,2)
    ) AS PortfolioSharePercentage

FROM LoanBook

GROUP BY SectorName

ORDER BY SectorExposureKES DESC;


/* =========================================================
12. PAST-MATURITY EXPOSURE
========================================================= */

SELECT
    COUNT(DISTINCT FacilityID) AS PastMaturityFacilities,

    SUM(LoanBalanceKES) AS PastMaturityBalanceKES

FROM LoanBook

WHERE MaturityDate < CAST(GETDATE() AS DATE);


/* =========================================================
13. MATURITIES WITHIN NEXT 30 DAYS
========================================================= */

SELECT
    COUNT(DISTINCT FacilityID) AS FacilitiesMaturingNext30Days,

    SUM(LoanBalanceKES) AS MaturingBalanceKES

FROM LoanBook

WHERE MaturityDate >= CAST(GETDATE() AS DATE)
  AND MaturityDate <= DATEADD(DAY, 30, CAST(GETDATE() AS DATE));


/* =========================================================
14. PORTFOLIO VINTAGE ANALYSIS
========================================================= */

SELECT
    YEAR(DisbursementDate) AS DisbursementYear,

    COUNT(DISTINCT FacilityID) AS NumberOfFacilities,

    SUM(LoanBalanceKES) AS CurrentPortfolioBalanceKES

FROM LoanBook

GROUP BY YEAR(DisbursementDate)

ORDER BY DisbursementYear;


/* =========================================================
15. HIGH-RISK EXPOSURE BY SECTOR
========================================================= */

SELECT
    SectorName,

    SUM(
        CASE
            WHEN DPD > 90 THEN LoanBalanceKES
            ELSE 0
        END
    ) AS PAR90BalanceKES,

    SUM(LoanBalanceKES) AS TotalSectorExposureKES,

    CAST(
        SUM(
            CASE
                WHEN DPD > 90 THEN LoanBalanceKES
                ELSE 0
            END
        ) * 100.0
        / NULLIF(SUM(LoanBalanceKES), 0)
        AS DECIMAL(10,2)
    ) AS PAR90Percentage

FROM LoanBook

GROUP BY SectorName

ORDER BY PAR90BalanceKES DESC;


/* =========================================================
16. PORTFOLIO RISK BY RELATIONSHIP MANAGER
========================================================= */

SELECT
    RelationshipManager,

    SUM(LoanBalanceKES) AS PortfolioBalanceKES,

    SUM(
        CASE
            WHEN DPD > 30 THEN LoanBalanceKES
            ELSE 0
        END
    ) AS PAR30BalanceKES,

    CAST(
        SUM(
            CASE
                WHEN DPD > 30 THEN LoanBalanceKES
                ELSE 0
            END
        ) * 100.0
        / NULLIF(SUM(LoanBalanceKES), 0)
        AS DECIMAL(10,2)
    ) AS PAR30Percentage

FROM LoanBook

GROUP BY RelationshipManager

ORDER BY PAR30Percentage DESC;
