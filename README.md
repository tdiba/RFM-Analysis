# RFM-Analysis


### Table Of Contents
- [Project Overview](#project-overview)
- [Business Problem](#business-problem)
- [Solution Approach](#solution-approach)
- [Tools and Technologies](#tools-and-technologies)
- [Data Preparation](#data-preparation)
- [Key Insights](#key-insights)
- [Business Impact](#business-impact)


### Project Overview
This project performs RFM (Recency, Frequency, Monetary) analysis on an online retail dataset using MySQL to segment customers based on purchasing behavior.
The goal is to identify high-value customers, loyal buyers, and at-risk segments to support data-driven business decisions in retail and FMCG environments.



### Business Problem
Retail and FMCG companies need to understand:
- Who their most valuable customers are
- Which customers are at risk of churn
- How purchasing behavior differs across segments


Without this insight, companies struggle with:
- Inefficient marketing spend
- Poor customer retention
- Missed revenue opportunities



### Solution Approach
This project applies RFM analysis, a proven customer segmentation technique used in:
- Retail analytics
- FMCG market research
- Customer relationship management (CRM)

Customers are scored based on:
- Recency → How recently they purchased
- Frequency → How often they purchase
- Monetary → How much they spend


### Tools and Technologies
- MySQL – Data cleaning, transformation, and analysis
- SQL Window Functions – RFM scoring (NTILE)
- Dataset: Online Retail Dataset (UCI / Kaggle)


### Data Preparation
The dataset required cleaning before analysis:
- Removed records with missing CustomerID
- Removed cancelled transactions (InvoiceNo LIKE 'C%')
- Removed negative quantities (returns)
- Removed zero or negative prices


A cleaned table was created:
``` sql
CREATE TABLE clean_retail AS
SELECT *
FROM online_retail
WHERE CustomerID IS NOT NULL
  AND Quantity > 0
  AND UnitPrice > 0
  AND InvoiceNo NOT LIKE 'C%';
```


Feature Engineering:

1. Converted text date to datetime:

  ```sql
  UPDATE clean_retail
  SET InvoiceDateTime = STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i');
  ```


2. Revenue Calculation
   ```sql
   UPDATE clean_retail
   SET Revenue = Quantity * UnitPrice;
   ```


3. RFM Calculation
   ```sql
   SELECT
    CustomerID,
    DATEDIFF(
        (SELECT MAX(InvoiceDateTime) FROM clean_retail),
        MAX(InvoiceDateTime)
    ) AS Recency,
    COUNT(DISTINCT InvoiceNo) AS Frequency,
    SUM(Revenue) AS Monetary
    FROM clean_retail
    GROUP BY CustomerID;
   ```


4. RFM Scoring
Customers were scored using quintiles (NTILE):

  ```sql
SELECT *,
    NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
    NTILE(5) OVER (ORDER BY Frequency) AS F_Score,
    NTILE(5) OVER (ORDER BY Monetary) AS M_Score
FROM rfm_base;
```


5. Customer Segmentation
Example segmentation logic:

  ```sql
CASE
    WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4 THEN 'VIP'
    WHEN R_Score >= 4 AND F_Score >= 3 THEN 'Loyal'
    WHEN R_Score <= 2 THEN 'At Risk'
    ELSE 'Regular'
END AS Customer_Type
```

### Key Insights
- A small percentage of customers contribute to a large portion of revenue (VIP segment)
- Some customers purchase frequently but spend less → potential upsell targets
- Customers with high recency values are at risk of churn
- Identifying these segments enables targeted marketing strategies


### Business Impact 
This analysis can be used to:
- Target high-value customers with loyalty programs
- Re-engage at-risk customers with promotions
- Optimize product recommendations
- Improve marketing ROI
