RENAME TABLE `online retail` TO online_retail;

SELECT * FROM online_retail;

-- clean data 
CREATE TABLE clean_retail AS
SELECT *
FROM online_retail
WHERE CustomerID IS NOT NULL
  AND Quantity > 0
  AND UnitPrice > 0
  AND InvoiceNo NOT LIKE 'C%';
  
  -- convert date column from text to datetime
  ALTER TABLE clean_retail
ADD COLUMN InvoiceDateTime DATETIME;

UPDATE clean_retail
SET InvoiceDateTime = STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i');

-- Create Revenue Column
ALTER TABLE clean_retail
ADD COLUMN Revenue DECIMAL(10,2);

UPDATE clean_retail
SET Revenue = Quantity * UnitPrice;


-- Build RFM Metrics

-- Find Latest Date (Reference Point)
SELECT MAX(InvoiceDateTime) FROM clean_retail;

-- Calculate RFM
CREATE TABLE rfm_base AS
SELECT
    CustomerID,
    
    -- Recency
    DATEDIFF(
        (SELECT MAX(InvoiceDateTime) FROM clean_retail),
        MAX(InvoiceDateTime)
    ) AS Recency,
    
    -- Frequency
    COUNT(DISTINCT InvoiceNo) AS Frequency,
    
    -- Monetary
    SUM(Revenue) AS Monetary

FROM clean_retail
GROUP BY CustomerID;


-- Scoring Customers (1–5)

-- Creating RFM Scores
CREATE TABLE rfm_scores AS
SELECT *,
    
    NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
    NTILE(5) OVER (ORDER BY Frequency) AS F_Score,
    NTILE(5) OVER (ORDER BY Monetary) AS M_Score

FROM rfm_base;


-- Combining Scores
SELECT *,
    CONCAT(R_Score, F_Score, M_Score) AS RFM_Segment
FROM rfm_scores;


-- Customer Segmentation
SELECT *,
CASE
    WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4 THEN 'VIP'
    WHEN R_Score >= 4 AND F_Score >= 3 THEN 'Loyal'
    WHEN R_Score <= 2 THEN 'At Risk'
    ELSE 'Regular'
END AS Customer_Type
FROM rfm_scores;