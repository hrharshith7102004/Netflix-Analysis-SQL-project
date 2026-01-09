use project

select * from netflix_titles

--1. Count the Number of Movies vs TV Shows

select distinct 
type ,count(*)  as count  from netflix_titles
where count * 100 
group by type

--2. Find the Most Common Rating for Movies and TV Shows


with ratingcounts as (
	select 
		type,
		rating,
		count(*) as rating_count
		from netflix_titles
		where rating is not null
		group by type, rating
),
ranked_rating as (
	select 
		type,
		rating,
		rank() over (partition by type order by rating_count desc ) as rank
		from ratingcounts
		
)
select 
	type,
	rating as most_frequently_rating
	from ranked_rating
	where rank = 1


-- 3. List All Movies Released in a Specific Year (e.g., 2020)

select * from netflix_titles 
	where release_year = 2020


-- 4. Find the Top 5 Countries with the Most Content on Netflix

select top 5 country ,count(*) as content_count
	from netflix_titles
	where country is not null and country <> ''
	group by country
	order by content_count desc


-- 5. Identify the Longest Movie

-- This is for movie
select top 1 title, type ,duration,
	cast(replace(duration , ' min', '') as int) as movie_runtime
	from netflix_titles
	where type = 'Movie' and duration like '%min%'
	order by movie_runtime desc


-- this is for seasons

select  top 1
	title,
	type,
	duration,
	cast(replace( duration, ' Seasons', '') as int) as seasons
	from netflix_titles
	where type = 'TV Show' and duration like '%Seasons%'
	order by seasons desc

-- 6. Find Content Added in the Last 5 Years

select	
	show_id, 
	type,
	title,
	country,
	date_added,
	release_year,
	rating
	from netflix_titles
	where date_added >= dateadd(year, -5, getdate())
	order by date_added desc


-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

select * from netflix_titles
	where director like '%Rajiv Chilak%'


-- 8. List All TV Shows with More Than 5 Seasons

select * from netflix_titles
	where type = 'TV Show' and duration > '5 Seasons'


-- 9. Count the Number of Content Items in Each Genre
 
 WITH GenreExploded AS (
    SELECT 
        show_id,
        LTRIM(RTRIM(value)) AS genre
    FROM netflix_titles
    CROSS APPLY STRING_SPLIT(listed_in, ',')
)
SELECT top 20 genre, COUNT(*) AS content_count
FROM GenreExploded
GROUP BY genre
ORDER BY content_count DESC;


select * from netflix_titles

-- 10.Find each year and the average numbers
--of content release in India on netflix.


	SELECT 
    release_year,
    COUNT(*) AS total_releases,
    AVG(COUNT(*)) OVER() AS avg_releases_per_year
FROM netflix_titles
WHERE country LIKE '%India%'
GROUP BY release_year
ORDER BY release_year;


-- 11. List All Movies that are Documentaries

select title
	from netflix_titles
	where type = 'Movie' and listed_in like 'Documentaries'



--12. Find All Content Without a Director



select listed_in
	from netflix_titles
	where director is null



-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years



select count(*) as no_of_movie
	from netflix_titles
	where type = 'Movie'
	and cast like '%Salman Khan%' and
	release_year >= YEAR(GETDATE()) - 10;





-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India


select top 10
	actor_name,
	count(*) as Total_movies
	from 
		(
			select 
				trim(value) as actor_name,
				release_year,
				country,
				type
				from 
					netflix_titles
				cross apply string_split(cast , ',')
		) as actor
		where type = 'Movie'
			and country like '%India%'
			group by actor_name
			order by Total_movies desc
	

-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords


	-- Categorize Content Based on 'Kill' and 'Violence' Keywords

SELECT 
    title,
    type,
    release_year,
    CASE
        WHEN description LIKE '%Kill%' OR description LIKE '%Violence%' 
            THEN 'Violent Content'
        ELSE 'Non-Violent Content'
    END AS content_category
FROM netflix_titles
ORDER BY content_category, release_year DESC;
	
-- Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.


SELECT 
    CASE
        WHEN description LIKE '%Kill%' 
          OR description LIKE '%Violence%' 
          OR description LIKE '%Murder%' 
          OR description LIKE '%Crime%' 
        THEN 'Bad'
        ELSE 'Good'
    END AS content_category,
    COUNT(*) AS total_items
FROM netflix_titles
GROUP BY 
    CASE
        WHEN description LIKE '%Kill%' 
          OR description LIKE '%Violence%' 
          OR description LIKE '%Murder%' 
          OR description LIKE '%Crime%' 
        THEN 'Bad'
        ELSE 'Good'
    END;


















