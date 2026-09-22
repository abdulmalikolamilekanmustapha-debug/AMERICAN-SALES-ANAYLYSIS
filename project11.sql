
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