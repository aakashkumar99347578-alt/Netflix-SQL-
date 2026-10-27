# Netflix SQL Project

An exploratory data analysis project using SQL (PostgreSQL) to analyze Netflix's movies and TV shows dataset and solve 15 specific business problems.

---

## Project Structure

```
├── Netfilx SQL project/
│   ├── Netflix_sql_queries.sql    # Table schema and 15 business analysis queries
│   └── netflix_titles (1).csv     # Raw Netflix dataset
└── README.md                      # Project documentation
```

---

## Database Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix (
    show_id      VARCHAR(6),
    type         VARCHAR(10),
    title        VARCHAR(150),
    director     VARCHAR(250),
    casts        VARCHAR(1100),
    country      VARCHAR(175),
    date_added   VARCHAR(75),
    release_year INT,
    rating       VARCHAR(10),
    duration     VARCHAR(15),
    listed_in    VARCHAR(125),
    description  VARCHAR(250)
);
```

---

## Business Problems & SQL Solutions

### 1. Count the number of Movies vs TV Shows
```sql
SELECT type, COUNT(*) AS total_content 
FROM netflix
GROUP BY type;
```

### 2. Find the most common rating for Movies and TV Shows
```sql
SELECT type, rating 
FROM (
    SELECT type, rating, COUNT(*),
           RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM netflix
    GROUP BY type, rating
) AS t1
WHERE ranking = 1;
```

### 3. List all movies released in a specific year (e.g., 2020)
```sql
SELECT * FROM netflix
WHERE release_year = 2020 AND type = 'Movie';
```

### 4. Find the top 5 countries with the most content on Netflix
```sql
SELECT UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
       COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 5;
```

### 5. Identify the longest movie
```sql
SELECT * FROM netflix
WHERE type = 'Movie' 
  AND duration = (SELECT MAX(duration) FROM netflix);
```

### 6. Find content added in the last 5 years
```sql
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD,YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```

### 7. Find all movies/TV shows directed by 'Rajiv Chilaka'
```sql
SELECT * FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';
```

### 8. List all TV shows with more than 5 seasons
```sql
SELECT *, 
       CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) AS sessions 
FROM netflix 
WHERE type = 'TV Show' 
  AND CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5;
```

### 9. Count the number of content items in each genre
```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;
```

### 10. Find top 5 years with the highest average content release by India
```sql
SELECT
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD,YYYY')) AS year,
    COUNT(*),
    ROUND(COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM netflix WHERE country ILIKE '%India%')::NUMERIC * 100, 2) AS avg_content_per_year
FROM netflix
WHERE country ILIKE '%India'
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 5;
```

### 11. List all movies that are documentaries
```sql
SELECT *
FROM netflix
WHERE listed_in LIKE '%Documentaries%';
```

### 12. Find all content without a director
```sql
SELECT * FROM netflix
WHERE director IS NULL;
```

### 13. Find how many movies actor 'Salman Khan' appeared in over the last 10 years
```sql
SELECT * FROM netflix
WHERE casts ILIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

### 14. Find the top 10 actors who have appeared in the highest number of Indian movies
```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS new_cast,
    COUNT(*) AS total_content
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
```

### 15. Categorize content as 'Bad' (contains 'kill' or 'violence') vs 'Good'
```sql
WITH new_table AS (
    SELECT *,
           CASE
               WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad content'
               ELSE 'Good content'
           END AS category
    FROM netflix
)
SELECT category,
       COUNT(*) AS total_content
FROM new_table
GROUP BY 1;
```
