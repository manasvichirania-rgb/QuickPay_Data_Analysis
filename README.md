# QuickPay Data Analyst Assignment

## Student Details

* **Name**: Manasvi Chirania
* **Student ID**:bitsom\_ftai\_2601217

**GitHub Repository**: https://github.com/manasvichirania-rgb/QuickPay\_Data\_Analysis
Overview

This repository contains the complete data analysis assignment for QuickPay, covering transaction data cleaning, SQL-based business analysis, a Python reconciliation workflow, JSON normalization, and a dashboard for business monitoring.

## How to Run

1. Make sure the raw data files are placed in `01\\\_data/raw/`.
2. Open `04\\\_python/fintech\\\_pipeline.ipynb` in Jupyter and run all cells. The notebook reads from `01\\\_data/raw/` and writes outputs to `01\\\_data/processed/` and `04\\\_python/`.
3. SQL queries in `03\\\_sql/analysis\\\_queries.sql` can be run against the `cleaned\\\_transactions.csv` loaded into any SQL engine (SQLite, PostgreSQL, etc.).
4. The spreadsheet workbook is at `02\\\_spreadsheet/spreadsheet\\\_workbook.xlsx`.
5. Dashboard link is in `05\\\_visualization/dashboard\\\_link.txt`.

## Tools Used

* **Python 3.12** with pandas, numpy, openpyxl
* **Jupyter Notebook** for the reconciliation pipeline and JSON normalization
* **SQLite** for validating SQL queries
* **Excel / openpyxl** for the spreadsheet workbook
* **Looker Studio** for the dashboard

## Repository Structure

```
├── README.md
├── 01\\\_data/
│   ├── raw/           (7 input files)
│   └── processed/     (12 output CSVs)
├── 02\\\_spreadsheet/
│   ├── spreadsheet\\\_workbook.xlsx
│   └── spreadsheet\\\_answers.md
├── 03\\\_sql/
│   ├── analysis\\\_queries.sql
│   └── sql\\\_answers.md
├── 04\\\_python/
│   ├── fintech\\\_pipeline.ipynb
│   └── summary\\\_metrics.json
└── 05\\\_visualization/
    └── dashboard\\\_link.txt
```

