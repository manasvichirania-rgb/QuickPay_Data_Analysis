# Spreadsheet Answers

## Cleaning Steps

1. Loaded transactions_raw.csv (30 rows) into a working sheet.
2. Trimmed leading/trailing whitespace from all text columns.
3. Removed duplicate internal spaces in merchant_name (e.g. "Beta  Stores" became "Beta Stores").
4. Standardized merchant_name to Title Case so that "ALPHA MART", " alpha mart ", "Alpha  Mart" all became "Alpha Mart".
5. Parsed transaction_date into a consistent YYYY-MM-DD date format.
6. Cleaned the status column — stripped whitespace, lowercased, then mapped values containing "failed" (like "failed e05 timeout") to "failed", values containing "chargeback" to "chargeback", and values containing "captured" to "captured".
7. Extracted numeric risk_score from mixed formats like "score:62", "risk-83", "75 " using regex. Missing/blank values were filled with the column median (61).
8. Standardized gateway_region to uppercase. Blank values were filled using the default_region from merchant_master.csv based on the merchant name.
9. Converted raw_amount to amount_usd using date-specific exchange rates from exchange_rates.csv (joined on both transaction_date and currency).
10. Merged in merchant_id, account_manager, and merchant_category from merchant_master.csv using the cleaned merchant_name as the join key.

## Standardization Rules

- **Merchant names**: lowercased, stripped, collapsed spaces, then Title Cased. Matched to merchant_master for enrichment.
- **Date format**: converted to YYYY-MM-DD using pandas datetime parser.
- **Status values**: stripped + lowercased, then keyword-mapped: "failed e05 timeout" → "failed", "chargeback" → "chargeback", "captured" → "captured".
- **Risk score**: extracted numeric portion from formats like "score:XX", "risk-XX", "XX ". Blanks filled with median value of 61.
- **Gateway region**: uppercased + stripped. Blanks filled from merchant_master.default_region.

## Lookup and Enrichment Logic

- Built a lookup from merchant_master.csv mapping merchant_name (lowercased) → merchant_id, default_region, account_manager, merchant_category.
- Joined exchange_rates.csv on (transaction_date, currency) to get the day-specific USD conversion rate.
- amount_usd = raw_amount × usd_rate for that date and currency.
- Merged merchant details (account_manager, merchant_category) on merchant_id after mapping.

## Final Answers

- **Total raw rows**: 30
- **Total cleaned rows**: 30
- **Invalid or missing rows handled**: No rows were dropped. 5 missing risk_score values were filled with the median (61). 9 missing gateway_region values were filled from merchant_master default_region.
- **Top region by GMV (captured)**: APAC ($63,415.50)
- **Number of high value transactions**: 7
- **Number of high risk transactions**: 9
- **Top merchant by captured GMV**: Beta Stores ($33,431.00)

## Formula Samples

Since the cleaning was done in Python (pandas), here are the key transformations used:

- **Merchant name standardization**: `str.strip().str.lower()` → `re.sub(r'\s+', ' ', x)` → `str.title()`
- **Status cleanup**: `str.strip().str.lower()` → keyword matching with `'failed' in x` / `'chargeback' in x`
- **Risk score extraction**: `re.findall(r'\d+', val)[0]` to pull numeric from "score:62" or "risk-83"
- **USD conversion**: `amount_usd = raw_amount * exchange_rate` (date+currency matched)
- **high_value_flag**: `IF(region="APAC" AND amount_usd>5000, 1, IF(region="EU" AND amount_usd>6000, 1, IF(region="US" AND amount_usd>7000, 1, 0)))`
- **high_risk_flag**: `IF(risk_score>=70 OR status="chargeback", 1, 0)`
