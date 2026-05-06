# SQL Answers

## Q1
### Query
Count transactions by status.
```sql
SELECT status, COUNT(*) AS transaction_count
FROM cleaned_transactions
GROUP BY status
ORDER BY transaction_count DESC;
```
### Result Summary
| Status     | Count |
|------------|-------|
| captured   | 19    |
| failed     | 7     |
| chargeback | 4     |

Total of 30 transactions. Majority (63.3%) are captured successfully.

## Q2
### Query
Calculate total captured GMV by merchant.
```sql
SELECT merchant_id, merchant_name, SUM(amount_usd) AS captured_gmv
FROM cleaned_transactions
WHERE status = 'captured'
GROUP BY merchant_id, merchant_name
ORDER BY captured_gmv DESC;
```
### Result Summary
| Merchant       | Captured GMV  |
|----------------|---------------|
| Beta Stores    | $33,431.00    |
| Alpha Mart     | $29,984.50    |
| Delta Travels  | $10,300.00    |
| City Pharma    | $8,640.00     |

Eco Home has zero captured GMV — its 2 transactions were a chargeback and a failure. Beta Stores leads with ~$33.4K.

## Q3
### Query
Show top 10 merchants by captured GMV.
```sql
SELECT merchant_id, merchant_name, SUM(amount_usd) AS captured_gmv
FROM cleaned_transactions
WHERE status = 'captured'
GROUP BY merchant_id, merchant_name
ORDER BY captured_gmv DESC
LIMIT 10;
```
### Result Summary
Same as Q2 since we only have 5 merchants. Top merchant is Beta Stores at $33,431.00 followed by Alpha Mart at $29,984.50.

## Q4
### Query
Show daily GMV and successful transaction count.
```sql
SELECT transaction_date, SUM(amount_usd) AS daily_gmv,
       SUM(CASE WHEN status = 'captured' THEN 1 ELSE 0 END) AS successful_txn_count
FROM cleaned_transactions
GROUP BY transaction_date
ORDER BY transaction_date;
```
### Result Summary
| Date       | Daily GMV   | Successful Txns |
|------------|-------------|-----------------|
| 2026-03-01 | $26,382.00  | 5               |
| 2026-03-02 | $25,049.00  | 3               |
| 2026-03-03 | $18,391.00  | 4               |
| 2026-03-04 | $16,420.00  | 4               |
| 2026-03-05 | $19,232.00  | 1               |
| 2026-03-06 | $10,606.00  | 2               |

March 1st had the highest GMV. March 5th had the worst success rate (only 1 out of 5 succeeded — U008 had 4 failed/chargeback txns that day).

## Q5
### Query
Find merchants with chargeback ratio above 1%.
```sql
SELECT merchant_id, merchant_name, COUNT(*) AS total_txns,
       SUM(CASE WHEN status = 'chargeback' THEN 1 ELSE 0 END) AS chargeback_count,
       ROUND(SUM(CASE WHEN status = 'chargeback' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS chargeback_ratio_pct
FROM cleaned_transactions
GROUP BY merchant_id, merchant_name
HAVING chargeback_ratio_pct > 1
ORDER BY chargeback_ratio_pct DESC;
```
### Result Summary
| Merchant       | Total Txns | Chargebacks | Ratio   |
|----------------|------------|-------------|---------|
| Eco Home       | 2          | 1           | 50.00%  |
| Delta Travels  | 4          | 1           | 25.00%  |
| Alpha Mart     | 11         | 1           | 9.09%   |
| Beta Stores    | 11         | 1           | 9.09%   |

All 4 merchants with chargebacks exceed the 1% threshold. Eco Home is the most concerning at 50%, though its volume is low (only 2 transactions). City Pharma is the only merchant with 0 chargebacks.

## Q6
### Query
Find regions with average risk score above 50 and more than 20 transactions.
```sql
SELECT gateway_region, COUNT(*) AS total_txns, ROUND(AVG(risk_score), 1) AS avg_risk_score
FROM cleaned_transactions
GROUP BY gateway_region
HAVING AVG(risk_score) > 50 AND COUNT(*) > 20;
```
### Result Summary
| Region | Total Txns | Avg Risk Score |
|--------|------------|----------------|
| APAC   | 22         | 65.3           |

Only APAC qualifies — it has 22 transactions and an average risk score of 65.3. EU has only 4 transactions and US has only 4, so neither crosses the 20-transaction threshold.

## Q7
### Query
Find users with 3 or more failed or chargeback transactions on the same day.
```sql
SELECT user_id, transaction_date, COUNT(*) AS bad_txn_count
FROM cleaned_transactions
WHERE status IN ('failed', 'chargeback')
GROUP BY user_id, transaction_date
HAVING COUNT(*) >= 3
ORDER BY bad_txn_count DESC;
```
### Result Summary
| User | Date       | Bad Txn Count |
|------|------------|---------------|
| U008 | 2026-03-05 | 4             |

Only user U008 (Ishaan Verma) qualifies. On March 5th, he had 4 problematic transactions: T016 (failed), T017 (failed), T018 (chargeback), and T019 (failed). This is a strong signal for potential fraud or account compromise.

## Q8
### Query
Show chargeback count, unique affected users, and chargeback amount by merchant.
```sql
SELECT merchant_id, merchant_name,
       COUNT(*) AS chargeback_count,
       COUNT(DISTINCT user_id) AS affected_users,
       SUM(amount_usd) AS chargeback_amount
FROM cleaned_transactions
WHERE status = 'chargeback'
GROUP BY merchant_id, merchant_name
ORDER BY chargeback_amount DESC;
```
### Result Summary
| Merchant       | Chargebacks | Users | Amount    |
|----------------|-------------|-------|-----------|
| Eco Home       | 1           | 1     | $6,649.00 |
| Alpha Mart     | 1           | 1     | $5,400.00 |
| Delta Travels  | 1           | 1     | $2,500.00 |
| Beta Stores    | 1           | 1     | $1,711.00 |

Each merchant had exactly 1 chargeback from 1 unique user. Eco Home had the highest chargeback amount at $6,649. Total chargeback exposure across all merchants is $16,260.
