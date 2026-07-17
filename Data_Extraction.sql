Select * From dbo.products
Select * From dbo.customer_reviews
Select * From dbo.customer_journey
Select * From dbo.customers
Select * From dbo.engagement_data
Select * From dbo.geography

Select c.ReviewId, c.CustomerId ,p.ProductName, p.Category, c.Rating, p.Price
From dbo.customer_reviews c
JOIN dbo.products p ON
c.ProductID = p.ProductID

--To categorize products based on their price

Select ProductID,
	   ProductName,
	   Price,
	   CASE
		WHEN Price < 50 THEN 'LOW'
		WHEN price BETWEEN 50 AND 100 THEN 'Medium'
		ELSE 'High'
	   End as PriceCategory
FROM dbo.products



Select c.CustomerID, c.CustomerName, c.Email, c.Gender, c.Age,
g.City, g.Country
From customers c
LEFT JOIN geography g ON
c.GeographyID = g.GeographyID

SELECT 
    c.CustomerID,
    c.CustomerName,
    c.Age,
	g.City,
    g.Country,
    CASE 
        WHEN c.Age <= 30 THEN 'Younger'
        WHEN c.Age BETWEEN 31 AND 50 THEN 'Middle Age'
        ELSE 'Old Age'
    END AS AgeCategory,
    COUNT(*) OVER (PARTITION BY g.Country ) AS TotalCustomers 
FROM customers c
LEFT JOIN geography g 
ON c.GeographyID = g.GeographyID
ORDER BY c.customerID
