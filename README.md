USA STORE SALES ANALYSIS

A SQL and POWER BI based analysis of retail sales data to uncover sales performance, product trends, customer behavior, region based analysis and sale performance and profitability insights.

Project Overview

This project focuses on analyzing a USA store sales dataset using SQL to clean and extract meaningful insights, performing exploratory data analysis, and using SQL queries to examine sales trends, product performance, revenue, and profitability. Through the use of MYSQL functions like the aggregate functions, filtering, and data manipulation techniques this project demonstrates how raw sales data can be transformed into meaningful insights while also using Power BI to illustrate beautiful stories in a way that tells the audience exactly what that bunch of datasets says.

The goal is to strengthen my SQL skills so I can use it to create and extract meaningful and sharp KPI ideas that tell the stories the mere numbers in the dataset cannot while gaining insights into retail sales performance and business operations.

Project Objective

Analyze overall sales performance
Examine sales by category/region
Calculate revenue, cost, and profit
Identify trends in customer purchases
Practice data cleaning and transformation using MYSQL
Tools and Technologies

MySQL Workbench
Power BI
GitHub
CSV Dataset
Data Cleaning and Preparation

Correcting column data types
Converting date values
Handling inconsistent data
Renaming columns where neccesary
Checking for missing/duplicate records
Preparing the dataset for analysis

**SQL ANALYSIS**

**SQL**
CREATE DATABASE project1;
USE project1;


SELECT DATABASE();

RENAME TABLE `original customer_usa` TO customer_usa;
RENAME TABLE `original region_usa` TO region_usa;
RENAME TABLE `original sales_team_usa` TO sales_team_usa;
RENAME TABLE `orignial store_sales_usa` TO store_sales_usa;
RENAME TABLE `original sales_order_usa` TO sales_order_usa;
SHOW TABLES;



DESCRIBE sales_order_usa;
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'project1'
AND table_name = 'sales_order_usa'
ORDER BY ordinal_position;


DROP TABLE IF EXISTS sales_order_clean;
CREATE TABLE sales_order_clean AS
SELECT
    `OrderNumber`,
    `Sales Channel`,
    `WarehouseCode`,
    STR_TO_DATE(`ProcuredDate`, '%d/%m/%Y') AS ProcuredDate,
    STR_TO_DATE(`OrderDate`, '%d/%m/%Y') AS OrderDate,
    STR_TO_DATE(`ShipDate`, '%d/%m/%Y') AS ShipDate,
    STR_TO_DATE(`DeliveryDate`, '%d/%m/%Y') AS DeliveryDate,
    `CurrencyCode`,
    CAST(`_SalesTeamID` AS UNSIGNED) AS `_SalesTeamID`,
    CAST(`_CustomerID` AS UNSIGNED) AS `_CustomerID`,
    CAST(`_StoreID` AS UNSIGNED) AS `_StoreID`,
    CAST(`_ProductID` AS UNSIGNED) AS `_ProductID`,
    CAST(`Order Quantity` AS UNSIGNED) AS `Order Quantity`,
    CAST(`Discount Applied` AS DECIMAL(10,4)) AS `Discount Applied`,
    CAST(REPLACE(`Unit Price`, ',', '') AS DECIMAL(12,2)) AS `Unit Price`,
    CAST(REPLACE(`Unit Cost`, ',', '') AS DECIMAL(12,2)) AS `Unit Cost`
FROM sales_order_usa;


SELECT
    COUNT(*) AS Total_Rows,
    SUM(`OrderNumber` IS NULL) AS Missing_OrderNumber,
    SUM(`OrderDate` IS NULL) AS Missing_OrderDate,
    SUM(`_CustomerID` IS NULL) AS Missing_CustomerID,
    SUM(`_StoreID` IS NULL) AS Missing_StoreID,
    SUM(`_ProductID` IS NULL) AS Missing_ProductID,
    SUM(`Order Quantity` IS NULL) AS Missing_Quantity,
    SUM(`Unit Price` IS NULL) AS Missing_UnitPrice,
    SUM(`Unit Cost` IS NULL) AS Missing_UnitCost
FROM sales_order_clean;


SELECT
    `OrderNumber`,
    COUNT(*) AS Number_of_Times
FROM sales_order_clean
GROUP BY `OrderNumber`
HAVING COUNT(*) > 1;


SELECT
    `Sales Channel`,
    ROUND(
        SUM(
            `Unit Price` * `Order Quantity`
            * (1 - `Discount Applied`)
        ), 2
    ) AS Total_Revenue
FROM sales_order_clean
GROUP BY `Sales Channel`
ORDER BY Total_Revenue DESC;


SELECT
    `Sales Channel`,
    ROUND(
        SUM(
            `Unit Price` * `Order Quantity`
            * (1 - `Discount Applied`)
        ) / COUNT(DISTINCT `OrderNumber`),
        2
    ) AS Average_Order_Value
FROM sales_order_clean
GROUP BY `Sales Channel`
ORDER BY Average_Order_Value DESC;


SELECT
    YEAR(`OrderDate`) AS Year,
    MONTH(`OrderDate`) AS Month_Number,
    MONTHNAME(`OrderDate`) AS Month,
    ROUND(
        SUM(
            `Unit Price` * `Order Quantity`
            * (1 - `Discount Applied`)
        ), 2
    ) AS Total_Revenue
FROM sales_order_clean
GROUP BY
    YEAR(`OrderDate`),
    MONTH(`OrderDate`),
    MONTHNAME(`OrderDate`)
ORDER BY Year, Month_Number;


SELECT
    r.Region,
    ROUND(
        SUM(
            s.`Unit Price` * s.`Order Quantity`
            * (1 - s.`Discount Applied`)
        ), 2
    ) AS Total_Revenue,
    ROUND(
        SUM(
            (
                s.`Unit Price` * s.`Order Quantity`
                * (1 - s.`Discount Applied`)
            )
            -
            (s.`Unit Cost` * s.`Order Quantity`)
        ), 2
    ) AS Total_Profit
FROM sales_order_clean s
JOIN store_sales_usa st
    ON s.`_StoreID` = st.`_StoreID`
JOIN region_usa r
    ON st.`StateCode` = r.`StateCode`
GROUP BY r.Region
ORDER BY Total_Revenue DESC;


SELECT
    r.State,
    r.Region,
    ROUND(
        SUM(
            s.`Unit Price` * s.`Order Quantity`
            * (1 - s.`Discount Applied`)
        ), 2
    ) AS Total_Revenue,
    ROUND(
        SUM(
            (
                s.`Unit Price` * s.`Order Quantity`
                * (1 - s.`Discount Applied`)
            )
            -
            (s.`Unit Cost` * s.`Order Quantity`)
        ), 2
    ) AS Total_Profit
FROM sales_order_clean s
JOIN store_sales_usa st
    ON s.`_StoreID` = st.`_StoreID`
JOIN region_usa r
    ON st.`StateCode` = r.`StateCode`
GROUP BY r.State, r.Region
ORDER BY Total_Revenue DESC;

SELECT
    c.`_CustomerID`,
    c.`Customer Names`,
    ROUND(
        SUM(
            s.`Unit Price` * s.`Order Quantity`
            * (1 - s.`Discount Applied`)
        ), 2
    ) AS Total_Spending
FROM sales_order_clean s
JOIN customer_usa c
    ON s.`_CustomerID` = c.`_CustomerID`
GROUP BY
    c.`_CustomerID`,
    c.`Customer Names`
ORDER BY Total_Spending DESC;

SELECT
    t.`Sales Team`,
    t.Region,
    ROUND(
        SUM(
            s.`Unit Price` * s.`Order Quantity`
            * (1 - s.`Discount Applied`)
        ), 2
    ) AS Total_Revenue,
    ROUND(
        SUM(
            (
                s.`Unit Price` * s.`Order Quantity`
                * (1 - s.`Discount Applied`)
            )
            -
            (s.`Unit Cost` * s.`Order Quantity`)
        ), 2
    ) AS Total_Profit
FROM sales_order_clean s
JOIN sales_team_usa t
    ON s.`_SalesTeamID` = t.`_SalesTeamID`
GROUP BY
    t.`Sales Team`,
    t.Region
ORDER BY Total_Revenue DESC;

SELECT
    `Sales Channel`,
    ROUND(
        AVG(`Discount Applied`) * 100,
        2
    ) AS Average_Discount_Percent,
    ROUND(
        SUM(
            `Unit Price` * `Order Quantity`
            * (1 - `Discount Applied`)
        ), 2
    ) AS Total_Revenue
FROM sales_order_clean
GROUP BY `Sales Channel`
ORDER BY Average_Discount_Percent DESC;

SELECT
    p.`Product Name`,
    p.Category,
    p.Brand,
    ROUND(
        SUM(
            s.`Unit Price` * s.`Order Quantity`
            * (1 - s.`Discount Applied`)
        ), 2
    ) AS Total_Revenue,
    ROUND(
        SUM(
            (
                s.`Unit Price` * s.`Order Quantity`
                * (1 - s.`Discount Applied`)
            )
            -
            (s.`Unit Cost` * s.`Order Quantity`)
        ), 2
    ) AS Total_Profit
FROM sales_order_clean s
JOIN product_usa p
    ON s.`_ProductID` = p.`_ProductID`
GROUP BY
    p.`Product Name`,
    p.Category,
    p.Brand
ORDER BY Total_Revenue DESC;

SELECT
    p.Category,
    ROUND(
        SUM(
            s.`Unit Price` * s.`Order Quantity`
            * (1 - s.`Discount Applied`)
        ), 2
    ) AS Total_Revenue,
    ROUND(
        SUM(
            (
                s.`Unit Price` * s.`Order Quantity`
                * (1 - s.`Discount Applied`)
            )
            -
            (s.`Unit Cost` * s.`Order Quantity`)
        ), 2
    ) AS Total_Profit,
    ROUND(
        SUM(
            (
                s.`Unit Price` * s.`Order Quantity`
                * (1 - s.`Discount Applied`)
            )
            -
            (s.`Unit Cost` * s.`Order Quantity`)
        )
        /
        SUM(
            s.`Unit Price` * s.`Order Quantity`
            * (1 - s.`Discount Applied`)
        ) * 100,
        2
    ) AS Profit_Margin_Percent
FROM sales_order_clean s
JOIN product_usa p
    ON s.`_ProductID` = p.`_ProductID`
GROUP BY p.Category
ORDER BY Total_Revenue DESC;


SELECT
    p.Brand,
    ROUND(
        SUM(
            s.`Unit Price` * s.`Order Quantity`
            * (1 - s.`Discount Applied`)
        ), 2
    ) AS Total_Revenue,
    ROUND(
        SUM(
            s.`Unit Price` * s.`Order Quantity`
            * (1 - s.`Discount Applied`)
        )
        /
        (
            SELECT SUM(
                x.`Unit Price` * x.`Order Quantity`
                * (1 - x.`Discount Applied`)
            )
            FROM sales_order_clean x
        ) * 100,
        2
    ) AS Revenue_Share_Percent
FROM sales_order_clean s
JOIN product_usa p
    ON s.`_ProductID` = p.`_ProductID`
GROUP BY p.Brand
ORDER BY Total_Revenue DESC;

SELECT
    `WarehouseCode`,
    COUNT(DISTINCT `OrderNumber`) AS Total_Orders,
    ROUND(
        AVG(
            DATEDIFF(`DeliveryDate`, `OrderDate`)
        ), 2
    ) AS Avg_Delivery_Days,
    MIN(
        DATEDIFF(`DeliveryDate`, `OrderDate`)
    ) AS Fastest_Delivery_Days,
    MAX(
        DATEDIFF(`DeliveryDate`, `OrderDate`)
    ) AS Slowest_Delivery_Days
FROM sales_order_clean
GROUP BY `WarehouseCode`
ORDER BY Avg_Delivery_Days;

WITH Monthly_Region_Revenue AS (
    SELECT
        r.Region,
        DATE_FORMAT(
            s.`OrderDate`,
            '%Y-%m'
        ) AS Sales_Month,
        SUM(
            s.`Unit Price` * s.`Order Quantity`
            * (1 - s.`Discount Applied`)
        ) AS Monthly_Revenue
    FROM sales_order_clean s
    JOIN store_sales_usa st
        ON s.`_StoreID` = st.`_StoreID`
    JOIN region_usa r
        ON st.`StateCode` = r.`StateCode`
    GROUP BY
        r.Region,
        DATE_FORMAT(s.`OrderDate`, '%Y-%m')
)
SELECT
    Region,
    Sales_Month,
    ROUND(Monthly_Revenue, 2) AS Monthly_Revenue,
    ROUND(
        SUM(Monthly_Revenue) OVER (
            PARTITION BY Region
            ORDER BY Sales_Month
        ), 2
    ) AS Running_Total_Revenue
FROM Monthly_Region_Revenue
ORDER BY Region, Sales_Month;

WITH Store_Revenue AS (
    SELECT
        st.`_StoreID`,
        st.`City Name`,
        st.State,
        r.Region,
        ROUND(
            SUM(
                s.`Unit Price` * s.`Order Quantity`
                * (1 - s.`Discount Applied`)
            ), 2
        ) AS Total_Revenue
    FROM sales_order_clean s
   JOIN store_sales_usa st
	ON s.`_StoreID` = st.`_StoreID`
    JOIN region_usa r
        ON st.`StateCode` = r.`StateCode`
    GROUP BY
        st.`_StoreID`,
        st.`City Name`,
        st.State,
        r.Region
),
Ranked_Stores AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY Region
            ORDER BY Total_Revenue DESC
        ) AS Store_Rank
    FROM Store_Revenue
)
SELECT
    Region,
    Store_Rank,
    `_StoreID`,
    `City Name`,
    State,
    Total_Revenue
FROM Ranked_Stores
WHERE Store_Rank <= 3
ORDER BY Region, Store_Rank;

SELECT
    CASE
        WHEN st.`Household Income` < 50000
            THEN 'Low Income'
        WHEN st.`Household Income` < 100000
            THEN 'Middle Income'
        ELSE 'High Income'
    END AS Income_Group,
    COUNT(DISTINCT s.`OrderNumber`) AS Total_Orders,
    ROUND(
        SUM(
            s.`Unit Price` * s.`Order Quantity`
            * (1 - s.`Discount Applied`)
        )
        /
        COUNT(DISTINCT s.`OrderNumber`),
        2
    ) AS Average_Order_Value
FROM sales_order_clean s
JOIN store_sales_usa st
    ON s.`_StoreID` = st.`_StoreID`
GROUP BY Income_Group
ORDER BY Average_Order_Value DESC;


WITH Customer_Spending AS (
    SELECT
        c.`_CustomerID`,
        c.`Customer Names`,
        SUM(
            s.`Unit Price` * s.`Order Quantity`
            * (1 - s.`Discount Applied`)
        ) AS Total_Spending
    FROM sales_order_clean s
    JOIN customer_usa c
        ON s.`_CustomerID` = c.`_CustomerID`
    GROUP BY
        c.`_CustomerID`,
        c.`Customer Names`
)
SELECT
    CASE
        WHEN Total_Spending >= 100000
            THEN 'High Spender'
        WHEN Total_Spending >= 50000
            THEN 'Medium Spender'
        ELSE 'Low Spender'
    END AS Spending_Tier,
    COUNT(*) AS Number_of_Customers,
    ROUND(
        AVG(Total_Spending),
        2
    ) AS Average_Spending
FROM Customer_Spending
GROUP BY Spending_Tier
ORDER BY Average_Spending DESC;

select * from retail_sales_powerbi;

**KEY INSIGHTS**

* Total revenue generated was approximately $73.14 million, with $21.33 million in total profit, resulting in an overall profit margin of about 29%.
* Cedarline was the highest-performing brand by revenue, generating approximately $10.32 million, followed by Oakwell ($8.53M) and Greenridge ($8.52M).
* The business recorded approximately 8,000 orders and 36,000 units sold, showing a substantial volume of sales across the different products and sales channels.
* The average order value was approximately $9.15K, indicating that each order contributed a significant amount of revenue on average.
* Revenue and profit varied across regions, sales channels, brands, and categories, highlighting differences in performance across the business and providing areas for further analysis.

  CONCLUSION

The analysis shows that the business generated approximately $73.14 million in total revenue and $21.33 million in total profit, resulting in an overall profit margin of approximately 29%. This indicates that the business generated positive profit across the analyzed sales activities.

The analysis also showed that the business processed approximately 8,000 orders and sold 36,000 units, with an average order value of about $9.15K. Brand performance varied, with Cedarline recording the highest revenue at approximately $10.32 million. These results provide useful insights into the company’s sales performance and highlight areas where management can further examine product, regional, customer, and sales-team performance
<img width="840" height="629" alt="Screen Shot 2026-09-22 at 12 22 50 PM" src="https://github.com/user-attachments/assets/a74e911d-2d17-415c-ad26-77c422d0060b" />
<img width="843" height="636" alt="Screen Shot 2026-09-22 at 12 22 14 PM" src="https://github.com/user-attachments/assets/c0c3c283-0057-4f75-a23e-77d2056856ef" />
<img width="843" height="636" alt="Screen Shot 2026-09-22 at 12 21 59 PM" src="https://github.com/user-attachments/assets/cda3ba31-e158-4a9d-bc45-2f6d132d9fa9" />
<img width="843" height="636" alt="Screen Shot 2026-09-22 at 12 21 39 PM" src="https://github.com/user-attachments/assets/7b9edab9-fa30-4a26-9e0a-a75f2df03fe7" />
<img width="849" height="638" alt="Screen Shot 2026-09-22 at 12 21 08 PM" src="https://github.com/user-attachments/assets/f57e7dbd-00ef-4ad0-b066-94b07801e9e8" />
les-team performance.


