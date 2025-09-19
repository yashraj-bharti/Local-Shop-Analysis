select * from localShop_data;

select count(*) from localShop_data

-- A. DATA CLEANING

-- cleaning Item_Fat_Content column
update localShop_data set Item_Fat_Content = 
case 
when Item_Fat_Content in ('low fat','LF') then 'Low Fat'
when Item_Fat_Content = 'reg' then 'Regular'
else Item_Fat_Content
end 

-- check the query works properly or not
select distinct(Item_Fat_Content) from localShop_data

-- B. KPI's Requirements

-- 1.Total Sales: The overall revenue generated from all items sold.
select CAST(round(sum(Total_Sales/ 1000000),2) AS VARCHAR(10)) + ' M'  as "Total Sales" 
from localShop_data

-- 2. Average Sales: The average revenue per sale.
select cast(AVG(total_Sales) AS int) as "Average Sales" 
from localShop_data

-- 3. Number of Items: The total count of different items sold.
select cast(round(COUNT(*)/1000,2) AS varchar(10)) + ' K' as "Number of Items Sold"  
from localShop_data

-- 4. Average Rating: The average customer rating for items sold. 
select round(AVG(rating),1) as "Average Rating" 
from localShop_data

-- Merging all KPI's in one
select item_fat_content,
	CAST(round(sum(Total_Sales),2) AS VARCHAR(10))  as "Total Sales", 
	cast(AVG(total_Sales) AS int) as "Average Sales" ,
	cast(round(COUNT(*),2) AS varchar(10)) as "Number of Items Sold",
	round(AVG(rating),1) as "Average Rating"
from localShop_data
group by item_fat_content
order by [Total Sales] desc

-- Check KPI's based on Item Type Top 5
select top 5 Item_Type,
	CAST(round(sum(Total_Sales),2) AS VARCHAR(10))  as "Total Sales", 
	cast(AVG(total_Sales) AS int) as "Average Sales" ,
	cast(round(COUNT(*),2) AS varchar(10)) as "Number of Items Sold",
	cast(AVG(rating) AS decimal(10,2)) as "Average Rating"
from localShop_data
group by Item_Type
order by [Total Sales] desc

-- C. Granular Requirements

--  1. Total Sales by Fat Content:
--	Objective: Analyze the impact of fat content on total sales.
select Item_Fat_Content, 
cast(sum(total_sales) as decimal(10,2)) as "Total Sales" 
from localShop_data
group by Item_Fat_Content

--  2. Total Sales by Item Type:
--	Objective: Identify the performance of different item types in terms of total sales.
select Item_Type, 
cast(sum(total_sales) as decimal(10,2)) as "Total Sales" 
from localShop_data
group by Item_Type
order by [Total Sales] desc

-- 3. Fat Content by Outlet for Total Sales:
-- Objective: Compare total sales across different outlets segmented by fat content.
SELECT Outlet_Location_Type, 
 -- If there is no sales data for a particular category 
 -- (e.g., no "Low Fat" sales in an outlet), we get NULL
 -- ISNULL(..., 0) replaces those NULLs with 0 for better readability.
       ISNULL([Low Fat], 0) AS Low_Fat, 
       ISNULL([Regular], 0) AS Regular
FROM 
(
-- This part groups the data by Outlet_Location_Type and Item_Fat_Content and It calculates the total sales per combination
    SELECT Outlet_Location_Type, Item_Fat_Content, 
           CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
    FROM localShop_data
    GROUP BY Outlet_Location_Type, Item_Fat_Content
) AS SourceTable
PIVOT 
(
    SUM(Total_Sales) -- Fill total sales values in low fat and regular column
    FOR Item_Fat_Content IN ([Low Fat], [Regular]) --Low Fat and Regular becomes column headers
) AS PivotTable
ORDER BY Outlet_Location_Type;

--  4. Total Sales by Outlet Establishment:
--	Objective: Evaluate how the age or type of outlet establishment influences total sales.
select Outlet_Establishment_Year, 
	CAST(SUM(total_Sales) AS decimal(10,2)) as "Total Sales",
	cast(AVG(total_Sales) AS int) as "Average Sales" ,
	cast(round(COUNT(*),2) AS varchar(10)) as "Number of Items Sold",
	cast(AVG(rating) AS decimal(10,2)) as "Average Rating"
from localShop_data
group by Outlet_Establishment_Year
order by Outlet_Establishment_Year

-- D. Chart’s Requirements

-- 5. Percentage of Sales by Outlet Size:
--	Objective: Analyze the correlation between outlet size and total sales.
select Outlet_Size,
CAST(SUM(total_Sales) AS decimal(10,2)) as Total_Sales,
cast((SUM(Total_Sales)*100/sum(sum(Total_Sales)) over()) 
AS decimal(10,2)) as "Sales Percentage"
from localShop_data
group by Outlet_Size
order by Total_Sales desc

-- 6. Sales by Outlet Location:
--	Objective: Assess the geographic distribution of sales across different locations.
select Outlet_Location_Type, CAST(SUM(total_Sales) as decimal(10,2)) as "Total Sales"
from localShop_data
group by Outlet_Location_Type
order by [Total Sales]

-- 7. All Metrics by Outlet Type:
--	Objective: Provide a comprehensive view of all key metrics (Total Sales, 
--  Average Sales, Number of Items, Average Rating) broken down by different outlet types.
select Outlet_Type,
	CAST(SUM(total_Sales) AS decimal(10,2)) as "Total Sales",
	cast(AVG(total_Sales) AS int) as "Average Sales" ,
	cast(round(COUNT(*),2) AS varchar(10)) as "Number of Items Sold",
	cast(AVG(rating) AS decimal(10,2)) as "Average Rating"
from localShop_data
group by Outlet_Type
order by Outlet_Type

/* E. 
Top 10 Best-Selling Items
Objective: Identify which specific items contribute most to sales.*/
select  top 10 Item_Type, cast(sum(Total_Sales) as decimal(10,2)) as Total_Sales
from localShop_data
group by Item_Type
order by Total_Sales desc -- based on total sales

-- Top 20 product based on customer rating 
select  top 20 Item_Type, Rating
from localShop_data
order by Rating desc

/*Least-Selling Items
Objective: Highlight products type with poor sales for potential discontinuation.*/
select  top 5 Item_Identifier, cast(sum(Total_Sales) as decimal(10,2)) as Poor_Sales
from localShop_data
group by Item_Identifier
order by Poor_Sales

/*
Monthly/Yearly Sales Trend (based on Outlet_Establishment_Year)
Objective: See how sales change over time.*/
select 
    Outlet_Establishment_Year,
    cast(sum(Total_Sales) as decimal(10,2)) as Total_Sales,
    RANK() over(order by sum(Total_Sales) desc) as Sales_Rank
from localShop_data
group by Outlet_Establishment_Year
order by Sales_Rank;

/*Average Sales by Item Visibility Range
Objective: Does more shelf visibility lead to higher sales?*/
select 
    case 
        when Item_Visibility < 0.05 then 'Low Visibility'
        when Item_Visibility between 0.05 and 0.15 then 'Medium Visibility'
        else 'High Visibility'
    end as Visibility_Range,
    cast(avg(Total_Sales) as decimal(10,2)) as Average_Sales
from localShop_data
group by 
    case 
        when Item_Visibility < 0.05 then 'Low Visibility'
        when Item_Visibility between 0.05 and 0.15 then 'Medium Visibility'
        else 'High Visibility'
    end
order by Average_Sales desc;

/*Correlation between Item Weight & Sales
Objective: Check if lighter or heavier products sell better.*/
select
case
	when Item_Weight < 5 then 'Less than 5Kg'
	when Item_Weight between 5 and 10 then 'Weight Between 5Kg and 10Kg'
	when Item_Weight between 10 and 15 then 'Weight Between 10Kg and 15Kg'
	else 'Above 15Kg'
end as Item_weight,
CAST(AVG(total_Sales) as decimal(10,2)) as Average_Sales
from localShop_data
group by case
	when Item_Weight < 5 then 'Less than 5Kg'
	when Item_Weight between 5 and 10 then 'Weight Between 5Kg and 10Kg'
	when Item_Weight between 10 and 15 then 'Weight Between 10Kg and 15Kg'
	else 'Above 15Kg'
end
order by Item_Weight


/*Contribution of Each Outlet to Total Sales (in %)
Objective: Rank outlets by their revenue contribution.*/
select Outlet_Type,
cast(round((SUM(Total_Sales)*100/sum(sum(Total_Sales)) over()),2) 
AS varchar(10))+'%' as "Sales Percentage",
RANK() over(order by sum(Total_Sales) desc) as Sales_Rank
from localShop_data
group by Outlet_Type
order by Sales_Rank;

/*Compare Sales by Outlet Type + Location Type
Objective: Identify which type of outlets in which locations perform best.*/
select 
Outlet_Type,
ISNULL([Tier 1],0) as 'Tier 1',
ISNULL([Tier 2],0) as 'Tier 2',
ISNULL([Tier 3],0) as 'Tier 3'
from 
(
	select Outlet_Type, Outlet_Location_Type
	, CAST(sum(total_Sales) as decimal(10,2)) as Total_Sales
	from localShop_data
	group by Outlet_Type, Outlet_Location_Type
) as SourceTable
pivot(
	sum(total_Sales)
	for Outlet_location_type in ([Tier 1],[Tier 2],[Tier 3])
) as PivotTable
order by Outlet_Type;


/*Sales vs. Ratings Analysis
Objective: Do higher-rated products actually sell more?*/
SELECT 
    CASE 
        WHEN Rating BETWEEN 0 AND 2.5 THEN 'Low Rating'
        WHEN Rating > 2.5 AND Rating <= 4 THEN 'Good Rating'
        WHEN Rating > 4 AND Rating <= 5 THEN 'Excellent'
    END AS Rating_Category,
  CAST(round(SUM(Total_Sales)/100000,2) AS varchar(10))+ 'M'  AS Total_Sales
FROM localShop_data
GROUP BY 
    CASE 
        WHEN Rating BETWEEN 0 AND 2.5 THEN 'Low Rating'
        WHEN Rating > 2.5 AND Rating <= 4 THEN 'Good Rating'
        WHEN Rating > 4 AND Rating <= 5 THEN 'Excellent'
    END
ORDER BY Total_Sales DESC;

/*Sales Distribution by Item Type (Pie Chart style data)
Objective: See share of sales per category.*/
select Item_Type,
 CAST(round((SUM(Total_Sales)*100/sum(SUM(total_sales)) over()),2) AS varchar(10))+ '%'  AS "Sales Percentage"
from localShop_data
group by Item_Type


/*Customer Basket Analysis (Simulated)
Group items frequently sold together (if Item_Identifier + Outlet_Identifier appear together).
*/
SELECT
    a.Outlet_Identifier,
    a.Item_Identifier AS Item1,
    b.Item_Identifier AS Item2,
    COUNT(*) AS Times_Sold_Together
FROM
    localShop_data a
    INNER JOIN localShop_data b
        ON a.Outlet_Identifier = b.Outlet_Identifier
        AND a.Item_Identifier < b.Item_Identifier -- Only unique unordered pairs
GROUP BY
    a.Outlet_Identifier,
    a.Item_Identifier,
    b.Item_Identifier
HAVING
    COUNT(*) > 1 -- Filter for pairs that appear together more than once
ORDER BY
    a.Outlet_Identifier,
    Times_Sold_Together DESC;

/*Fat Content Impact on Ratings
Do “Low Fat” vs “Regular” items have better customer satisfaction?*/
SELECT
    Item_Fat_Content,
    COUNT(*) AS Num_Items,
    round(AVG(Rating * 1.0),2) AS Avg_Rating
FROM localShop_data
WHERE Item_Fat_Content IN ('Low Fat', 'Regular')
GROUP BY Item_Fat_Content;
-- No both are of same rating

/*Pareto Analysis (80/20 Rule)
Find whether ~20% of items contribute to ~80% of sales.*/
WITH RankedSales AS (
    SELECT
        Item_Identifier,
        SUM(Total_Sales) AS Total_Sales
    FROM localShop_data
    GROUP BY Item_Identifier
),
SalesWithRank AS (
    SELECT
        Item_Identifier,
        Total_Sales,
        SUM(Total_Sales) OVER (ORDER BY Total_Sales DESC ROWS UNBOUNDED PRECEDING) AS Cumulative_Sales,
        SUM(Total_Sales) OVER () AS Total_Sales_All
    FROM RankedSales
),
SalesWithCumulativePercent AS (
    SELECT
        Item_Identifier,
        Total_Sales,
        Cumulative_Sales,
        Total_Sales_All,
        100.0 * Cumulative_Sales / Total_Sales_All AS Cumulative_Sales_Percent
    FROM SalesWithRank
)
SELECT
    Item_Identifier,
    round(Total_Sales,2),
    ROUND(Cumulative_Sales_Percent, 2) AS Cumulative_Sales_Percent,
    CASE
        WHEN Cumulative_Sales_Percent <= 80 THEN 'Top 80% Sales'
        ELSE '20% Sales'
    END AS Pareto_Category
FROM SalesWithCumulativePercent
ORDER BY Total_Sales DESC;