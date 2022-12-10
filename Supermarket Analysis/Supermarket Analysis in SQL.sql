/* Analyzing Supermarket Sales Data */

/* Data Cleaning (Reformatting Date and Time Columns) */

SELECT Time, RIGHT(Time,7)
 FROM SalesData

SELECT Date, LEFT(Date,12)
 FROM SalesData

UPDATE SalesData
 SET DateConverted = FORMAT(Date, 'd', 'en-US' )
 --SET TimeConverted = Time

SELECT Date, DateConverted, Time, TimeConverted
 FROM SalesData

ALTER TABLE SalesData
  --DROP COLUMN DateConverted
  ADD DateConverted nvarchar(50)
 --DROP COLUMN TimeConverted
 --ADD TimeConverted nvarchar(50)


--UPDATE SalesData
 --SET TimeConverted = Time
 --SET TimeConverted = RIGHT(TimeConverted,7)
 --SET DateConverted = Date
 --SET DateConverted = LEFT(Date,12)
 --SELECT * FROM SalesData

--SELECT Time, RIGHT(TimeConverted,7)
--FROM SalesData



-- SELECT * FROM SalesData

-- How satisfied are customers shopping at each branch? -- 

SELECT DISTINCT Branch, [Customer type], AVG(Rating) OVER (PARTITION BY [Customer type],Branch) AS AvgSatisfaction
FROM SalesData
ORDER BY [Customer type], AvgSatisfaction DESC

-- How many customers are enrolled in the loyalty program at each branch?

SELECT DISTINCT Branch, 
				[Customer type], 
				COUNT([Customer type]) OVER (PARTITION BY [Customer type],Branch) AS '# Customers Enrolled',
				COUNT([Customer type]) OVER (PARTITION BY Branch) AS '# Customers Per Branch',
				CAST(COUNT([Customer type]) OVER (PARTITION BY [Customer type],Branch) AS decimal(5,2))/CAST(COUNT([Customer type]) OVER (PARTITION BY Branch) AS decimal(5,2)) AS '% Customers Enrolled'
FROM SalesData
ORDER BY Branch

-- Correlation between gender of customer and payment type used

SELECT Gender, Payment,
	   COUNT(Payment) AS '# Customers Using Payment'
FROM SalesData
GROUP BY Gender, Payment
ORDER BY Payment, Gender DESC

-- Which product line yields the most income across all branches?

SELECT DISTINCT [Product line], 
				AVG([gross income]) OVER (PARTITION BY [Product line]) AS AvgGrossIncome
FROM SalesData
ORDER BY AvgGrossIncome DESC

-- How do the product lines perform at each branch?

SELECT DISTINCT Branch, [Product line], 
				AVG([gross income]) OVER (PARTITION BY [Product line], Branch) AS AvgIncomebyBranch
FROM SalesData
ORDER BY [Product line], Branch

-- Which branch has the best gross income / is performing the best?

SELECT DISTINCT Branch,
				AVG([gross income]) OVER (PARTITION BY Branch) AS TotalGrossIncome
FROM SalesData
ORDER BY TotalGrossIncome DESC

-- Is there a correlation between income and customer satisfaction for each product line?

SELECT DISTINCT [Product Line],
				AVG(Rating) OVER (PARTITION BY [Product Line]) AS AvgRating,
				AVG([gross income]) OVER (PARTITION BY [Product line]) AS AvgGrossIncome
FROM SalesData
ORDER BY AvgRating DESC

SELECT * FROM SalesData

-- Total number of purchases by product type and gender of customer

SELECT DISTINCT Gender AS GenderOfPurchaser, [Product line], sum(quantity) OVER (PARTITION BY Gender, [Product line]) AS PurchasesbyGender
FROM SalesData
ORDER BY [Product line], Gender