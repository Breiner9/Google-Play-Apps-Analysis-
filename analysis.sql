-- =============================================
-- DATA ANALYSIS - GOOGLE PLAY STORE
-- Author: Breiner Pinilla
-- Tool: PostgreSQL
-- Description: Analytical queries to answer
-- the 5 key questions about the Google Play Store dataset.
-- =============================================


-- =============================================
-- QUESTION 1: Which categories have the most
-- installs and best average rating?
-- Skill: Grouping and sorting
-- =============================================

SELECT
    category,
    SUM(installs) AS num_installs,
    ROUND(AVG(rating)::NUMERIC, 2) AS avg_rating
FROM apps_clean
GROUP BY category
ORDER BY num_installs DESC
LIMIT 10;


-- =============================================
-- QUESTION 2: Do paid apps have better ratings
-- than free apps?
-- Skill: Segment comparison
-- =============================================

SELECT ROUND(AVG(rating)::NUMERIC, 2) AS avg_rating, type
FROM apps_clean
GROUP BY type;


-- =============================================
-- QUESTION 3: What is the price range with the
-- highest acceptance in terms of installs and rating?
-- Skill: Segmentation and business logic
-- =============================================

SELECT
    CASE
        WHEN price = 0 THEN 'Free'
        WHEN price > 0 AND price <= 5 THEN '$0-$5'
        WHEN price > 5 AND price <= 10 THEN '$5-$10'
        WHEN price > 10 THEN '$10+'
    END AS range_price,
    ROUND(AVG(rating)::NUMERIC, 2) AS avg_rating,
    SUM(installs) AS total_installs,
    COUNT(*) AS num_apps
FROM apps_clean
GROUP BY range_price
ORDER BY total_installs DESC;


-- =============================================
-- QUESTION 4: Is there a relationship between
-- the number of reviews and the rating?
-- Skill: Correlation analysis
-- =============================================

SELECT
    CASE
        WHEN rating >= 1 AND rating <= 2 THEN 'Low_Rating'
        WHEN rating >= 2 AND rating <= 3 THEN 'Low_Med_Rating'
        WHEN rating >= 3 AND rating <= 4 THEN 'Med_Rating'
        WHEN rating >= 4 AND rating <= 5 THEN 'High_Rating'
    END AS range_rating,
    ROUND(AVG(reviews), -1) AS avg_reviews
FROM apps_clean
GROUP BY range_rating
ORDER BY avg_reviews DESC;



-- =============================================
-- QUESTION 5: Which categories are saturated and
-- which represent a growth opportunity?
-- Skill: Market vision
-- =============================================

-- Criteria defined based on data analysis:
-- Saturated: 400+ apps in the category
-- Opportunity: < 400 apps, avg installs > 255,500 and avg rating > 4
-- (255,500 is the overall average of installs across all apps)

SELECT
    category,
    COUNT(*) AS num_apps,
    ROUND(AVG(installs), 2) AS avg_installs,
    ROUND(AVG(rating)::NUMERIC, 2) AS avg_rating,
    CASE
        WHEN COUNT(*) >= 400 THEN 'Saturated'
        WHEN COUNT(*) < 400 AND AVG(installs) > 255500 AND AVG(rating) > 4 THEN 'Opportunity'
    END AS criteria
FROM apps_clean
GROUP BY category
HAVING COUNT(*) >= 400
    OR (COUNT(*) < 400
    AND AVG(installs) > 255500 AND AVG(rating) > 4)
ORDER BY criteria ASC;
