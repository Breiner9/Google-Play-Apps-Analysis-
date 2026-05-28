-- =============================================
-- DATA CLEANING - GOOGLE PLAY STORE
-- Author: Breiner Pinilla
-- Tool: PostgreSQL
-- Description: Exploration, problem detection
-- and cleaning script for the Google Play Store dataset.
-- =============================================


-- =============================================
-- STEP 1: INITIAL EXPLORATION
-- =============================================

-- 1.1 View table structure (columns and data types)
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'apps_data';

-- 1.2 Preview of suspicious columns
SELECT installs, reviews, size, price, last_updated
FROM apps_data
LIMIT 10;


-- =============================================
-- STEP 2: PROBLEM DETECTION
-- =============================================

-- 2.1 Find non-numeric values in installs
-- The ~ operator allows using regular expressions (regex)
-- '[^0-9]' means: any character that is NOT a number
SELECT installs
FROM apps_data
WHERE installs ~ '[^0-9]'
LIMIT 10;

-- 2.2 Find non-numeric values in reviews, size and price
SELECT reviews, size, price
FROM apps_data
WHERE reviews ~ '[^0-9]'
   OR size ~ '[^0-9]'
   OR price ~ '[^0-9]'
LIMIT 20;

-- 2.3 View unique problematic values in size
-- Added '.' because size can have valid decimals (e.g. 8.7M)
SELECT DISTINCT size
FROM apps_data
WHERE size ~ '[^0-9.]'
LIMIT 20;
-- Result: 3 patterns found → 'M' (megabytes), 'k' (kilobytes), 'Varies with device'

-- 2.4 Detect null values per column
-- COUNT(*) counts all rows
-- COUNT(column) counts only non-null rows
-- The difference = number of nulls
SELECT 
    COUNT(*) AS total,
    COUNT(*) - COUNT(rating) AS rating_nulls,
    COUNT(*) - COUNT(size) AS size_nulls,
    COUNT(*) - COUNT(price) AS price_nulls
FROM apps_data;

-- 2.5 Check ratings outside valid range (Google Play goes from 1 to 5)
SELECT COUNT(*)
FROM apps_data
WHERE rating > 5 OR rating < 1;

-- 2.6 Detect duplicates (apps appearing more than once)
SELECT app, COUNT(*)
FROM apps_data
GROUP BY app
HAVING COUNT(*) > 1;


-- =============================================
-- STEP 3: DUPLICATE REMOVAL
-- =============================================

-- Create a clean table keeping only the row with the most reviews per app.
-- ROW_NUMBER() assigns a number to each row within a group.
-- PARTITION BY app → groups by app.
-- ORDER BY reviews DESC → the row with the most reviews gets number 1.
-- We keep only rn = 1 (the most relevant).
CREATE TABLE apps_clean AS (
    SELECT * FROM (
        SELECT *, 
               ROW_NUMBER() OVER(PARTITION BY app ORDER BY reviews::INTEGER DESC) AS rn
        FROM apps_data
    ) sub
    WHERE rn = 1
);

-- Remove the auxiliary column rn (no longer needed)
ALTER TABLE apps_clean DROP COLUMN rn;


-- =============================================
-- STEP 4: CLEANING THE SIZE COLUMN
-- =============================================

-- 4.1 Create a new numeric column for size in MB
ALTER TABLE apps_clean ADD COLUMN size_mb NUMERIC;

-- 4.2 Populate the column using CASE WHEN:
-- If it has 'k' → remove k, convert to number and divide by 1000 (to get MB)
-- If it has 'M' → remove M and convert to number
-- If it says 'Varies with device' → set to NULL (not useful data)
-- '::NUMERIC' is the casting operator in PostgreSQL (converts text to number)
UPDATE apps_clean SET size_mb = (
    CASE
        WHEN size LIKE '%k%' THEN REPLACE(size, 'k', '')::NUMERIC / 1000
        WHEN size LIKE '%M%' THEN REPLACE(size, 'M', '')::NUMERIC
        WHEN size LIKE '%Varies%' THEN NULL
    END
);

-- 4.3 Drop the old size column (text)
ALTER TABLE apps_clean DROP COLUMN size;


-- =============================================
-- STEP 5: DATA TYPE CONVERSION
-- =============================================

-- Convert text columns to their correct data types
-- USING tells PostgreSQL how to perform the conversion

-- 5.1 Reviews: text → numeric
ALTER TABLE apps_clean ALTER COLUMN reviews TYPE NUMERIC USING reviews::NUMERIC;

-- 5.2 Installs: text → numeric
ALTER TABLE apps_clean ALTER COLUMN installs TYPE NUMERIC USING installs::NUMERIC;

-- 5.3 Price: text → numeric
ALTER TABLE apps_clean ALTER COLUMN price TYPE NUMERIC USING price::NUMERIC;

-- 5.4 Last_updated: text → date
-- TO_DATE converts text to date using the specified format
ALTER TABLE apps_clean ALTER COLUMN last_updated TYPE DATE USING TO_DATE(last_updated, 'MM/DD/YYYY');


-- =============================================
-- STEP 6: CATEGORICAL DATA VALIDATION
-- =============================================

-- Verify that text values are consistent
-- (no duplicates due to capitalization, spaces, etc.)

-- 6.1 Unique values of content_rating
SELECT DISTINCT content_rating FROM apps_clean;

-- 6.2 Unique values of type (Free / Paid)
SELECT DISTINCT type FROM apps_clean;

-- 6.3 Unique values of category
SELECT DISTINCT category FROM apps_clean;


-- =============================================
-- STEP 7: FINAL VERIFICATION
-- =============================================

-- Confirm that all data types are correct
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'apps_clean';
