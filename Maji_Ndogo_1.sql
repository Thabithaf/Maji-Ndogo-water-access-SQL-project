--  1.Understand the database structure by exploring its tables and retrieving a sample of records to familiarize
-- yourself with the data schema and content.

-- List all tables in the database
SHOW TABLES;

-- Inspect column names, data types, and sample values to understand relationships and potential keys 
-- (e.g., primary keys like source_id or visit_id).

-- Retrieve the first 10 records from the location table
SELECT * FROM md_water_services.location LIMIT 10;

 -- Retrieve the first 10 records from the visits table
SELECT * FROM visits LIMIT 10;

-- Retrieve the first 10 records from the water_sources table
SELECT * FROM md_water_services.water_source LIMIT 10;

-- Examine the structure of the water_sources table
DESCRIBE md_water_services.water_source;

-- 2.Identify and analyze the unique types of water sources in the water_sources table to understand the 
-- diversity of water access points in Maji Ndogo.

-- Retrieve unique water source types
SELECT DISTINCT type_of_water_source FROM md_water_services.water_source;

-- Count the number of water sources by type
SELECT type_of_water_source, COUNT(*) AS source_count
FROM md_water_services.water_source
GROUP BY type_of_water_source;

-- 3.Analyze the visits table to understand the frequency and distribution of visits to water sources, 
-- identifying locations with high visit counts (e.g., visited more than a certain number of times).
 
 -- view the visits table
 SELECT * 
 FROM md_water_services.visits;
 
 -- Retrieve all records from the visits table where time_in_queue exceeds 500 minutes, 
-- highlighting the extreme hardship of waiting over 8 hours for water access.
SELECT * 
FROM md_water_services.visits 
WHERE time_in_queue > 500;

-- How can people queue for over 8 hours for water? This query investigates the types of water sources 
-- associated with extreme queue times (>500 min) by joining the visits table with the water_sources table, 
-- which contains type_of_water_source,number_of_people_served and source_id. We'll check specific source_ids (AkKi00881224, 
-- SoRu37635224, SoRu36096224) from the long-queue results. 
SELECT v.source_id, v.time_in_queue, w.type_of_water_source, w.number_of_people_served
FROM visits v
JOIN water_source w ON v.source_id = w.source_id
WHERE v.source_id IN ('AkKi00881224', 'SoRu37635224', 'SoRu36096224')
   AND v.time_in_queue > 500;
   
-- Additionally, we'll explore records with 
-- 0 min queue time from the visits table to compare source types and understand access disparities.
-- People fetching water from a shared tap queue longer because of high demand, limited flow rate, and a sequential
-- queueing system. Wells allow multiple people to draw water simultaneously, and private taps serve fewer individuals
-- , reducing wait times. Social interactions at shared taps can also slow the process.
SELECT v.source_id, v.time_in_queue, w.type_of_water_source, w.number_of_people_served
FROM visits v
JOIN water_source w ON v.source_id = w.source_id
WHERE v.source_id IN ('AkRu05234224','HaZa21742224');

-- 5.Assess the quality of water sources by checking for records in the water_quality table where 
-- subjective_quality_score is 10 (indicating high-quality home taps) and the source was visited 
-- a second time. The surveyors were supposed to only revisit shared taps, not high-quality home 
-- taps, so multiple visits to sources with a score of 10 suggest potential data entry errors. 
SELECT * FROM md_water_services.water_quality
WHERE subjective_quality_score = 10
AND visit_count = 2;

-- 6.-- Investigate pollution issues in the well_pollution table, which records contamination data for well sources, 
-- including source_id, results (Clean, Contaminated: Biological, Contaminated: Chemical), biological (CFU/mL, 
-- where > 0.01 indicates contamination), and description (scientist notes). 

 
-- Display the first few rows to confirm the table structure.
SELECT * FROM md_water_services.well_pollution;

-- Identify inconsistencies where results = 'Clean' but biological > 0.01, indicating potential data entry errors.
SELECT source_id, results, biological, description
FROM well_pollution
WHERE results = 'Clean' AND biological > 0.01;

-- Find descriptions mistakenly containing 'Clean' (e.g., 'Clean Bacteria: E. coli') despite biological > 0.01, 
--    expecting 38 such records, as some data personnel misinterpreted descriptions.
SELECT source_id, description, biological
FROM well_pollution
WHERE description LIKE 'Clean%' AND biological > 0.01;

-- Update descriptions to remove 'Clean' from incorrect entries ('Clean Bacteria: E. coli' to 'Bacteria: E. coli', 
--    'Clean Bacteria: Giardia Lamblia' to 'Bacteria: Giardia Lamblia').

-- step 1: Creating a backup table (well_pollution_copy) to test changes safely
CREATE TABLE md_water_services.well_pollution_copy AS (
    SELECT * FROM md_water_services.well_pollution
);

--  Correct the results column from 'Clean' to 'Contaminated: Biological' where biological > 0.01 to ensure 
--    data integrity and prevent health risks from misclassified wells.

-- Step 2: Case 1a - Update descriptions for 'Clean Bacteria: E. coli'
UPDATE md_water_services.well_pollution_copy
SET description = 'Bacteria: E. coli'
WHERE description = 'Clean Bacteria: E. coli';

-- Step 3: Case 1b - Update descriptions for 'Clean Bacteria: Giardia Lamblia'
UPDATE md_water_services.well_pollution_copy
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';

-- Step 4: Case 2 - Update results to 'Contaminated: Biological' where biological > 0.01 and results = 'Clean'
UPDATE md_water_services.well_pollution_copy
SET results = 'Contaminated: Biological'
WHERE biological > 0.01 AND results = 'Clean';

-- remove safe mode for successful update
SET SQL_SAFE_UPDATES = 0;

-- confirm changes made (to ensure that none of the results contain clean when the biological > 0.01)
SELECT * FROM md_water_services.well_pollution_copy
WHERE results = 'clean'
AND biological > 0.01;

-- Check for remaining erroneous rows (descriptions starting with 'Clean' or results = 'Clean' with biological > 0.01)
SELECT * 
FROM md_water_services.well_pollution_copy
WHERE results = 'Clean%'
   OR (biological > 0.01 AND description LIKE 'Clean');

-- it works as intended, we can change the table back to the well_pollution and delete the well_pollution_copy table
UPDATE
well_pollution
SET
description = 'Bacteria: E. coli'
WHERE
description = 'Clean Bacteria: E. coli';
UPDATE
well_pollution
SET
description = 'Bacteria: Giardia Lamblia'
WHERE
description = 'Clean Bacteria: Giardia Lamblia';
UPDATE
well_pollution
SET
results = 'Contaminated: Biological'
WHERE
biological > 0.01 AND results = 'Clean';
DROP TABLE
md_water_services.well_pollution_copy;