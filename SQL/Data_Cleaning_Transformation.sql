-- Query to clean whitespace issues in the ReviewText column

SELECT
    ReviewID,      -- Selects the unique identifier for each review
    CustomerID,    -- Selects the unique identifier for each customer
    ProductID,     -- Selects the unique identifier for each product
    ReviewDate,    -- Selects the date when the review was written
    Rating,        -- Selects the numerical rating given by the customer (e.g., 1 to 5 stars)

    -- Cleans up the ReviewText by replacing double spaces with single spaces to ensure the text is more readable and standardized
    REPLACE(ReviewText, '  ', ' ') AS ReviewText

FROM
    dbo.customer_reviews;  -- Specifies the source table from which to select the data

Select * From dbo.engagement_data

Select EngagementID, 
	ContentID, 
	CampaignID, 
	ProductID,
	UPPER(REPLACE(ContentType, 'Socialmedia', 'Social Media')) as ContentType,
	LEFT(ViewsClicksCombined, CHARINDEX('-', ViewsClicksCombined) -1) as Views,
	RIGHT(ViewsClicksCombined, LEN(ViewsClicksCombined) - CHARINDEX('-', ViewsClicksCombined) ) as Clicks,
	Likes,
	CONVERT(Date, EngagementDate) as EngagementDate
	From dbo.engagement_data

Select * from dbo.customer_journey;

WITH DuplicateRecords as (
	Select
		JourneyID,
		CustomerID,
		ProductID,
		VisitDate,
		Stage,
		Action,
		Duration,
		ROW_NUMBER() OVER( PARTITION BY CustomerID, ProductID,VisitDate, Stage, Action
		ORDER BY JourneyID ) as row_num
		FROM dbo.customer_journey
)

Select * From DuplicateRecords
WHERE row_num > 1
Order BY JourneyID

-- Outer query selects the final cleaned and standardized data
SELECT
    JourneyID,      -- Selects the unique identifier for each journey to ensure data traceability
    CustomerID,     -- Selects the unique identifier for each customer to link journeys to specific customers
    ProductID,      -- Selects the unique identifier for each product to analyze customer interactions with different products
    VisitDate,      -- Selects the date of the visit to understand the timeline of customer interactions
    Stage,          -- Uses the uppercased stage value from the subquery for consistency in analysis
    Action,         -- Selects the action taken by the customer (e.g., View, Click, Purchase)
    COALESCE(Duration, avg_duration) AS Duration  -- Replaces missing durations with the average duration
FROM
(
    -- Subquery to process and clean the data
    SELECT
        JourneyID,      -- Selects the unique identifier for each journey to ensure data traceability
        CustomerID,     -- Selects the unique identifier for each customer to link journeys to specific customers
        ProductID,      -- Selects the unique identifier for each product to analyze customer interactions
        VisitDate,      -- Selects the date of the visit to understand the timeline of customer interactions
        UPPER(Stage) AS Stage,   -- Converts Stage values to uppercase for consistency in data analysis
        Action,         -- Selects the action taken by the customer (e.g., View, Click, Purchase)
        Duration,       -- Uses Duration directly, assuming it's already a numeric type
        AVG(Duration) OVER (PARTITION BY VisitDate) AS avg_duration,  -- Calculates the average duration for each date

        ROW_NUMBER() OVER (
            PARTITION BY CustomerID, ProductID, VisitDate, UPPER(Stage), Action
            ORDER BY JourneyID
        ) AS row_num   -- Assigns a row number to each row within the partition to identify duplicates

    FROM dbo.customer_journey   -- Specifies the source table
) AS subquery

WHERE row_num = 1;   -- Keeps only the first occurrence of each duplicate group

