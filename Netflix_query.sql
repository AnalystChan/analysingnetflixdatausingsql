/* Requirement 1: How many movies and TV shows are there in the dataset? Display the count for each type.
Database - Netflix movies and shows database - All TV Shows and Movies meta data on Netflix. Updated every month. The db includes tables like netflix_titles, brands_v2, finance, info_v2, reviews_v2, traffic_v2.
For this requirement, we use the following tables:
netflix_titles: Columns are show_id, type (category of title), title (name of movie of tv show), director, cast, country, date_added, release_year, rating, duration, listed_in (genres the title falls under), description
*/

SELECT type, count(*) as count
FROM netflix_titles
GROUP BY type;

/* Requirement 2: What percentage of content that doesn’t have a country associated with it?
Database - Netflix movies and shows database - All TV Shows and Movies meta data on Netflix. Updated every month. The db includes tables like netflix_titles, brands_v2, finance, info_v2, reviews_v2, traffic_v2.
For this requirement, we use the following tables:
netflix_titles: Columns are show_id, type (category of title), title (name of movie of tv show), director, cast, country, date_added, release_year, rating, duration, listed_in (genres the title falls under), description
*/

SELECT COUNT(CASE WHEN country = "" THEN 1 END) / COUNT(*) AS percentage_without_country
FROM netflix_titles;

/* Requirement 3: Find the top 3 directors with the most content on Netflix. Display the director's name, the count of their titles, and the year of their most recent content.
Database - Netflix movies and shows database - All TV Shows and Movies meta data on Netflix. Updated every month. The db includes tables like netflix_titles, brands_v2, finance, info_v2, reviews_v2, traffic_v2.
For this requirement, we use the following tables:
netflix_titles: Columns are show_id, type (category of title), title (name of movie of tv show), director, cast, country, date_added, release_year, rating, duration, listed_in (genres the title falls under), description
*/

WITH directorStats AS (SELECT director, COUNT(*) AS title_count, MAX(release_year) as most_recent_year
                        FROM netflix_titles
                        WHERE director != "" AND director IS NOT NULL
                        GROUP BY director
                        )
SELECT director, title_count, most_recent_year
FROM directorStats
ORDER BY title_count DESC
LIMIT 3;

/* Requirement 4: For each year from 2015 to 2021, calculate the percentage of movies vs TV shows added to Netflix.
Database - Netflix movies and shows database - All TV Shows and Movies meta data on Netflix. Updated every month. The db includes tables like netflix_titles, brands_v2, finance, info_v2, reviews_v2, traffic_v2.
For this requirement, we use the following tables:
netflix_titles: Columns are show_id, type (category of title), title (name of movie of tv show), director, cast, country, date_added, release_year, rating, duration, listed_in (genres the title falls under), description
*/

SELECT
    EXTRACT(YEAR FROM DATE(date_added)) AS year,
    type,
    COUNT(*) AS count
FROM netflix_titles
WHERE DATE(date_added) >= '2015-01-01' AND DATE(date_added) <= '2021-12-31'
GROUP BY EXTRACT(YEAR FROM DATE(date_added)), type
ORDER BY year, type;

/* Requirement 5: Calculate the average month-over-month growth rate of content added to Netflix for each genre. What are the top 5 fastest growing genres?
Database - Netflix movies and shows database - All TV Shows and Movies meta data on Netflix. Updated every month. The db includes tables like netflix_titles, brands_v2, finance, info_v2, reviews_v2, traffic_v2.
For this requirement, we use the following tables:
netflix_titles: Columns are show_id, type (category of title), title (name of movie of tv show), director, cast, country, date_added, release_year, rating, duration, listed_in (genres the title falls under), description
*/

WITH genre_months AS (
    SELECT 
        STRFTIME('%m', date_added) AS month, 
        listed_in AS genre,
        COUNT(*) AS monthly_count
    FROM netflix_titles
    WHERE date_added IS NOT NULL
    GROUP BY STRFTIME('%m', date_added), genre
    ),
    growth_rates AS (
    SELECT
        genre, month, monthly_count, LAG(monthly_count) OVER (PARTITION BY genre ORDER BY month) AS prev_month_count,
        CAST(monthly_count - (LAG(monthly_count) OVER (PARTITION BY genre ORDER BY month)) AS float) / (LAG(monthly_count) OVER (PARTITION BY genre ORDER BY month)) AS growth_rate
        FROM genre_months
        ),
    avg_growth_rates AS (
    SELECT
        genre, AVG(growth_rate) AS avg_growth_rate
    FROM growth_rates
    WHERE growth_rate IS NOT NULL
    GROUP BY genre
    )
SELECT genre, avg_growth_rate
FROM avg_growth_rates
ORDER BY avg_growth_rate DESC
LIMIT 5;


    
