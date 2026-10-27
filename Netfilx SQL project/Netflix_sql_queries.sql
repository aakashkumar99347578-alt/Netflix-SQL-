--Netflix SQL Project

-- Create table 
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix(
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(250),
	casts VARCHAR(1100),
	country VARCHAR(175),
	date_added VARCHAR(75),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(125),
	description VARCHAR(250)
);

-- see the data
SELECT * FROM netflix

-- total content
SELECT COUNT(*) AS total_content FROM netflix

-- distinct type 
SELECT DISTINCT TYPE FROM netflix

-- 15 business problems
--1. count the number of movie vs tv shows
SELECT type,count(*) as total_content 
FROM netflix
GROUP BY type

--2. Find the most common rating for movie and tv shows

SELECT type,rating 
FROM(
	SELECT type,rating,COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC ) AS ranking
FROM netflix
GROUP BY type,rating
ORDER BY 1,3 DESC
) AS t1
WHERE ranking =1;

--3.list all movies released in a specific year (e.g.,2020)
SELECT * FROM netflix
WHERE release_year=2020 AND type='Movie';

--4. Find the top 5 countries with the most content on netflix
SELECT UNNEST(STRING_TO_ARRAY(country,',')) AS new_country,
	COUNT(show_id) AS total_contetn
FROM netflix
GROUP BY 1
ORDER BY 2 DESC LIMIT 5;

--5. Identify the longest movie?
SELECT * FROM netflix
WHERE type='Movie' 
AND duration =(SELECT MAX(duration) FROM netflix)

--6. Find contetn added in the last 5 year
SELECT *
	FROM netflix
	WHERE 
		TO_DATE(date_added,'Month DD,YYYY')>=CURRENT_DATE-INTERVAL '5 years'

--7. Find all the movies/Tv shows by director 'Rajiv Chilaka'
SELECT * FROM netflix
WHERE director LIKE '%Rajiv Chilaka%'

--8. List all Tv shows with more than 5 seasons
SELECT *, 
       CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) AS sessions 
FROM netflix 
WHERE type = 'TV Show' 
  AND CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5;

--9. Count the number of content items in each genre 
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in,',')) AS genre,
	COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;

--10. Find each year and the average number of content release by India on netflix. return top 5 year with highest avg content release !
SELECT
	EXTRACT (YEAR FROM TO_DATE(date_added,'Month DD,YYYY')) AS year,
	COUNT(*),
	ROUND(COUNT(*)::NUMERIC/(SELECT COUNT(*) FROM netflix WHERE country ILIKE '%India%')::NUMERIC * 100,2)AS avg_content_per_year
FROM netflix
WHERE country ILIKE '%India'
GROUP BY 1
ORDER BY 2 DESC LIMIT 5;

--11. List all movie that are documentaries
SELECT *
FROM netflix
WHERE listed_in LIKE '%Documentaries%'

--12. Find all content withour a director
SELECT * FROM netflix
WHERE director IS NULL

--13. Find how many movies actor 'salman khan' appeared in last 10 years!
SELECT * FROM netflix
WHERE casts ILIKE '%Salman khan%'
	AND release_year > EXTRACT(YEAR FROM CURRENT_DATE)-10

--14. Find the top 10 actors who have appeared in the highest number of movies produced in india.
SELECT 
	UNNEST(STRING_TO_ARRAY(casts,',')) AS new_cast,
	COUNT(*) AS total_content
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

--15. categorize the content based on the [resence if the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. count how many items fail into each category]. 
WITH new_table
AS(
	SELECT *,
		CASE
		WHEN 
			description ILIKE '%kill%' OR
			description ILIKE '%violence' THEN 'Bad content'
			ELSE 'Good content'
		END category
FROM netflix
)
SELECT category,
	count(*) AS total_content
FROM new_table
GROUP BY 1;




















