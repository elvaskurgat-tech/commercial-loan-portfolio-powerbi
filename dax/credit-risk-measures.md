# Credit Risk Analytics – DAX Measures

This document contains selected DAX measures developed for the Commercial Loan Portfolio and Credit Risk Analytics Power BI dashboard.

The measures demonstrate portfolio monitoring, delinquency analysis, credit classification, provisioning, concentration risk and maturity analysis.

---

## 1. Total Loan Portfolio

```DAX
Total Loan Balance KES =
SUM('Loan Book'[Loan Balance KES])
```

Measures the total outstanding loan portfolio under the current filter context.

---

## 2. PAR 30 Balance

```DAX
PAR 30 Balance KES =
CALCULATE(
    [Total Loan Balance KES],
    'Loan Book'[DPD] > 30
)
```

Identifies outstanding loan exposure that is more than 30 days past due.

---

## 3. PAR 30 %

```DAX
PAR 30 % =
DIVIDE(
    [PAR 30 Balance KES],
    [Total Loan Balance KES],
    0
)
```

Measures PAR 30 exposure as a percentage of the total loan portfolio.

---

## 4. PAR 90 Balance

```DAX
PAR 90 Balance KES =
CALCULATE(
    [Total Loan Balance KES],
    'Loan Book'[DPD] > 90
)
```

Identifies loan exposure that is more than 90 days past due.

---

## 5. PAR 90 %

```DAX
PAR 90 % =
DIVIDE(
    [PAR 90 Balance KES],
    [Total Loan Balance KES],
    0
)
```

Measures PAR 90 exposure relative to the total portfolio.

---

## 6. Provision Required

```DAX
Provision Required KES =
SUMX(
    'Loan Book',
    SWITCH(
        TRUE(),
        'Loan Book'[Classification] = "Normal",
            'Loan Book'[Loan Balance KES] * 0.01,
        'Loan Book'[Classification] = "Watch",
            'Loan Book'[Loan Balance KES] * 0.03,
        'Loan Book'[Classification] = "Substandard",
            'Loan Book'[Loan Balance KES] * 0.20,
        'Loan Book'[Classification] = "Doubtful",
            'Loan Book'[Loan Balance KES] * 1.00,
        'Loan Book'[Classification] = "Loss",
            'Loan Book'[Loan Balance KES] * 1.00,
        0
    )
)
```

Calculates estimated provision requirements based on the classification assigned to each facility.

---

## 7. Provision % of Portfolio

```DAX
Provision % of Portfolio =
DIVIDE(
    [Provision Required KES],
    [Total Loan Balance KES],
    0
)
```

Measures estimated provisions relative to the outstanding portfolio.

---

## 8. Largest Client Share

```DAX
Largest Client Share % =
VAR LargestClientBalance =
    MAXX(
        VALUES('Portfolio'[Client]),
        [Total Loan Balance KES]
    )
RETURN
    DIVIDE(
        LargestClientBalance,
        [Total Loan Balance KES],
        0
    )
```

Measures the largest individual client exposure as a percentage of the total portfolio.

---

## 9. Sector Concentration – HHI

```DAX
Sector HHI =
SUMX(
    VALUES('Loan Book'[Sector Name]),
    VAR SectorBalance =
        [Total Loan Balance KES]
    VAR PortfolioBalance =
        CALCULATE(
            [Total Loan Balance KES],
            ALL('Loan Book'[Sector Name])
        )
    VAR SectorShare =
        DIVIDE(
            SectorBalance,
            PortfolioBalance,
            0
        )
    RETURN
        SectorShare * SectorShare
) * 10000
```

Calculates the Herfindahl-Hirschman Index (HHI) to measure concentration of portfolio exposure across sectors.

A higher HHI indicates greater concentration of exposure among fewer sectors.

---

## 10. Facilities Over Limit

```DAX
Facilities Over Limit =
CALCULATE(
    DISTINCTCOUNT('Loan Book'[Facility ID]),
    'Loan Book'[Loan Balance KES] >
        'Loan Book'[Approved Limit KES]
)
```

Counts facilities where the outstanding balance exceeds the approved facility limit.

---

## 11. Total Over-Limit Exposure

```DAX
Total Over Limit Amount KES =
SUMX(
    FILTER(
        'Loan Book',
        'Loan Book'[Loan Balance KES] >
            'Loan Book'[Approved Limit KES]
    ),
    'Loan Book'[Loan Balance KES] -
        'Loan Book'[Approved Limit KES]
)
```

Measures the total amount by which facilities exceed their approved limits.

---

## 12. Facilities Over Limit %

```DAX
Facilities Over Limit % =
DIVIDE(
    [Facilities Over Limit],
    DISTINCTCOUNT('Loan Book'[Facility ID]),
    0
)
```

Measures facilities exceeding approved limits as a percentage of total facilities.

---

## 13. Past-Maturity Balance

```DAX
Past-Maturity Balance KES =
CALCULATE(
    [Total Loan Balance KES],
    FILTER(
        'Loan Book',
        'Loan Book'[Maturity Date] < TODAY()
    )
)
```

Identifies outstanding exposure where the contractual maturity date has passed.

---

## 14. Past-Maturity %

```DAX
Past-Maturity % of Balance =
DIVIDE(
    [Past-Maturity Balance KES],
    [Total Loan Balance KES],
    0
)
```

Measures past-maturity exposure relative to the total loan portfolio.

---

## 15. Balance Maturing Within 30 Days

```DAX
Balance Maturing Next 30 Days KES =
CALCULATE(
    [Total Loan Balance KES],
    FILTER(
        'Loan Book',
        'Loan Book'[Maturity Date] >= TODAY()
            && 'Loan Book'[Maturity Date] <= TODAY() + 30
    )
)
```

Identifies the outstanding loan balance scheduled to mature within the next 30 days.

---

## 16. Process Events Within 30 Days

```DAX
Process Events Next 30 Days =
CALCULATE(
    COUNTROWS('Loan Book'),
    FILTER(
        'Loan Book',
        'Loan Book'[Maturity Date] >= TODAY()
            && 'Loan Book'[Maturity Date] <= TODAY() + 30
    )
)
```

Counts facilities approaching maturity within the next 30 days.

---

## 17. Scheduled Interest Within 30 Days

```DAX
Scheduled Interest Next 30 Days KES =
CALCULATE(
    SUM('Loan Book'[Scheduled Interest KES]),
    FILTER(
        'Loan Book',
        'Loan Book'[Maturity Date] >= TODAY()
            && 'Loan Book'[Maturity Date] <= TODAY() + 30
    )
)
```

Measures scheduled interest associated with facilities maturing within the next 30 days.

---

## 18. Accrued Interest

```DAX
Accrued Interest at Process Dates KES =
CALCULATE(
    SUM('Loan Book'[Accrued Interest KES]),
    NOT(
        ISBLANK('Loan Book'[Process Date])
    )
)
```

Measures accrued interest associated with facilities having a recorded process date.

---

## 19. Remaining Maturity Days

```DAX
Remaining Maturity Days =
DATEDIFF(
    TODAY(),
    'Loan Book'[Maturity Date],
    DAY
)
```

Calculates the number of days remaining until facility maturity.

---

## Analytical Applications

The measures above support analysis of:

* Portfolio size and growth
* Delinquency and portfolio-at-risk
* Non-performing exposure
* Credit classification
* Provision requirements
* Client concentration
* Sector concentration
* Limit breaches
* Maturity risk
* Interest pipeline
* Portfolio monitoring

These measures are integrated into the Power BI dashboard to provide management-level visibility into commercial loan portfolio performance and credit risk.
