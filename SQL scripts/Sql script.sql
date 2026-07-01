show tables;
select * from enriched_sales;
desc enriched_sales;


-- Business Problem Statements

-- 1Q.Revenue Growth categories are driving 80% of the profit?: Which product 
SELECT
    Category,
    SUM(Quantity * (`Unit Price USD` - `Unit Cost USD`)) AS computed_profit
FROM enriched_sales
GROUP BY Category
ORDER BY computed_profit DESC;

SELECT
    `Product Name`,
    SUM(Quantity * (`Unit Price USD` - `Unit Cost USD`)) AS computed_profit
FROM enriched_sales
GROUP BY `Product Name`
ORDER BY computed_profit DESC;


-- 2Q.Seasonality: Are there specific months where certain categories see a spike?

    --  Use this query to find which months each category peaks in by total units sold:
SELECT
    Category,
    MONTH(STR_TO_DATE(`Order Date`, '%c/%e/%Y')) AS order_month_num,
    DATE_FORMAT(STR_TO_DATE(`Order Date`, '%c/%e/%Y'), '%b') AS order_month_name,
    SUM(Quantity) AS total_units_sold
FROM enriched_sales
GROUP BY
    Category,
    MONTH(STR_TO_DATE(`Order Date`, '%c/%e/%Y')),
    DATE_FORMAT(STR_TO_DATE(`Order Date`, '%c/%e/%Y'), '%b')
ORDER BY
    Category,
    total_units_sold DESC;
    
          -- If you want only the peak month for each category
    WITH monthly_sales AS (
    SELECT
        Category,
        MONTH(STR_TO_DATE(`Order Date`, '%c/%e/%Y')) AS order_month_num,
        DATE_FORMAT(STR_TO_DATE(`Order Date`, '%c/%e/%Y'), '%b') AS order_month_name,
        SUM(Quantity) AS total_units_sold
    FROM enriched_sales
    GROUP BY
        Category,
        MONTH(STR_TO_DATE(`Order Date`, '%c/%e/%Y')),
        DATE_FORMAT(STR_TO_DATE(`Order Date`, '%c/%e/%Y'), '%b')
),
ranked_sales AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY Category
            ORDER BY total_units_sold DESC
        ) AS rn
    FROM monthly_sales
)
SELECT
    Category,
    order_month_name,
    total_units_sold
FROM ranked_sales
WHERE rn = 1
ORDER BY total_units_sold DESC;


-- 3Q. Which categories generate the most revenue?
SELECT
    Category,
    ROUND(SUM(Quantity * `Unit Price USD`), 2) AS revenue
FROM enriched_sales
GROUP BY Category
ORDER BY revenue DESC;

-- 4Q. Which brands drive the highest revenue?
SELECT
    Brand,
    ROUND(SUM(Quantity * `Unit Price USD`), 2) AS revenue
FROM enriched_sales
GROUP BY Brand
ORDER BY revenue DESC
LIMIT 10;

-- 5Q. What is the monthly order volume trend?
SELECT
    DATE_FORMAT(STR_TO_DATE(`Order Date`, '%c/%e/%Y'), '%Y-%m') AS month,
    COUNT(DISTINCT OrderID) AS orders
FROM enriched_sales
GROUP BY month
ORDER BY month;

-- 6Q. Which products sell the most units?
SELECT
    `Product Name`,
    SUM(Quantity) AS units_sold
FROM enriched_sales
GROUP BY `Product Name`
ORDER BY units_sold DESC
LIMIT 10;

-- 7Q. Which customers place the most orders?
SELECT
    CustomerID,
    COUNT(DISTINCT OrderID) AS order_count
FROM enriched_sales
GROUP BY CustomerID
ORDER BY order_count DESC
LIMIT 10;

-- 8Q. Which stores have the highest sales volume?
SELECT
    StoreID,
    COUNT(*) AS line_items
FROM enriched_sales
GROUP BY StoreID
ORDER BY line_items DESC;

-- 9Q. Which categories have the highest average basket size?
SELECT
    Category,
    ROUND(AVG(Quantity), 2) AS avg_quantity
FROM enriched_sales
GROUP BY Category
ORDER BY avg_quantity DESC;

-- 10Q. What is the color preference by category?
SELECT
    Category,
    Color,
    COUNT(*) AS items_sold
FROM enriched_sales
GROUP BY Category, Color
ORDER BY Category, items_sold DESC;

