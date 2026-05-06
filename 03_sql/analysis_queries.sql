-- Q1: Count transactions by status
SELECT
    status,
    COUNT(*) AS transaction_count
FROM cleaned_transactions
GROUP BY status
ORDER BY transaction_count DESC;


-- Q2: Calculate total captured GMV by merchant
SELECT
    merchant_id,
    merchant_name,
    SUM(amount_usd) AS captured_gmv
FROM cleaned_transactions
WHERE status = 'captured'
GROUP BY merchant_id, merchant_name
ORDER BY captured_gmv DESC;


-- Q3: Show top 10 merchants by captured GMV
SELECT
    merchant_id,
    merchant_name,
    SUM(amount_usd) AS captured_gmv
FROM cleaned_transactions
WHERE status = 'captured'
GROUP BY merchant_id, merchant_name
ORDER BY captured_gmv DESC
LIMIT 10;


-- Q4: Show daily GMV and successful transaction count
SELECT
    transaction_date,
    SUM(amount_usd) AS daily_gmv,
    SUM(CASE WHEN status = 'captured' THEN 1 ELSE 0 END) AS successful_txn_count
FROM cleaned_transactions
GROUP BY transaction_date
ORDER BY transaction_date;


-- Q5: Find merchants with chargeback ratio above 1%
SELECT
    merchant_id,
    merchant_name,
    COUNT(*) AS total_txns,
    SUM(CASE WHEN status = 'chargeback' THEN 1 ELSE 0 END) AS chargeback_count,
    ROUND(SUM(CASE WHEN status = 'chargeback' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS chargeback_ratio_pct
FROM cleaned_transactions
GROUP BY merchant_id, merchant_name
HAVING SUM(CASE WHEN status = 'chargeback' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) > 1
ORDER BY chargeback_ratio_pct DESC;


-- Q6: Find regions with average risk score above 50 and more than 20 transactions
SELECT
    gateway_region,
    COUNT(*) AS total_txns,
    ROUND(AVG(risk_score), 1) AS avg_risk_score
FROM cleaned_transactions
GROUP BY gateway_region
HAVING AVG(risk_score) > 50
    AND COUNT(*) > 20;


-- Q7: Find users with 3 or more failed or chargeback transactions on the same day
SELECT
    user_id,
    transaction_date,
    COUNT(*) AS bad_txn_count
FROM cleaned_transactions
WHERE status IN ('failed', 'chargeback')
GROUP BY user_id, transaction_date
HAVING COUNT(*) >= 3
ORDER BY bad_txn_count DESC;


-- Q8: Show chargeback count, unique affected users, and chargeback amount by merchant
SELECT
    merchant_id,
    merchant_name,
    COUNT(*) AS chargeback_count,
    COUNT(DISTINCT user_id) AS affected_users,
    SUM(amount_usd) AS chargeback_amount
FROM cleaned_transactions
WHERE status = 'chargeback'
GROUP BY merchant_id, merchant_name
ORDER BY chargeback_amount DESC;
