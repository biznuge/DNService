/*
=================================================================================================
-- Single Monolithic Query (No CTEs) --
=================================================================================================
This is a functionally equivalent version of the previous query, rewritten to avoid
using Common Table Expressions (CTEs) by using nested subqueries instead.

NOTE: This format is significantly harder to read and maintain and may be less
performant than the CTE version. The CTE version is generally the recommended approach.
*/

-- Part 1: Select all full postcodes that are identified as being in a 'Borders' area.
-- SELECT
--     postcode_locator AS partial_postcode,
--     'B' AS country_code
-- FROM
--     address_data
-- WHERE
--     postcode_locator IN (
--         -- Subquery to find all unique postcodes that fall under a 'Borders' prefix.
--         -- This replaces the 'borders_postcodes' CTE.
--         SELECT DISTINCT t.postcode_locator
--         FROM address_data t
--         WHERE EXISTS (
--             SELECT 1
--             FROM (
--                 -- Nested subquery to calculate the country status for every possible prefix.
--                 -- This replaces the 'prefix_summary' CTE.
--                 SELECT
--                     p.prefix,
--                     CASE WHEN COUNT(DISTINCT t_inner.country) > 1 THEN 'B' ELSE MIN(t_inner.country) END AS country_code
--                 FROM (
--                     SELECT DISTINCT SUBSTRING(UPPER(REPLACE(ad.postcode_locator, ' ', '')) FROM 1 FOR s.len) AS prefix
--                     FROM address_data ad, generate_series(1, LENGTH(REPLACE(ad.postcode_locator, ' ', ''))) s(len)
--                 ) p
--                 JOIN address_data t_inner ON UPPER(REPLACE(t_inner.postcode_locator, ' ', '')) LIKE p.prefix || '%'
--                 GROUP BY p.prefix
--             ) ps
--             WHERE
--                 ps.country_code = 'B' AND UPPER(REPLACE(t.postcode_locator, ' ', '')) LIKE ps.prefix || '%'
--         )
--     )

-- UNION

-- -- Part 2: For all other postcodes, apply the simplification logic.
-- SELECT
--     (
--         -- Correlated subquery to find the shortest 'E' or 'S' prefix for a given postcode.
--         SELECT ps.prefix
--         FROM (
--             -- The 'prefix_summary' logic is repeated here as a nested subquery.
--             SELECT
--                 p.prefix,
--                 CASE WHEN COUNT(DISTINCT t_inner.country) > 1 THEN 'B' ELSE MIN(t_inner.country) END AS country_code
--             FROM (
--                 SELECT DISTINCT SUBSTRING(UPPER(REPLACE(ad.postcode_locator, ' ', '')) FROM 1 FOR s.len) AS prefix
--                 FROM address_data ad, generate_series(1, LENGTH(REPLACE(ad.postcode_locator, ' ', ''))) s(len)
--             ) p
--             JOIN address_data t_inner ON UPPER(REPLACE(t_inner.postcode_locator, ' ', '')) LIKE p.prefix || '%'
--             GROUP BY p.prefix
--         ) ps
--         WHERE
--             UPPER(REPLACE(t_outer.postcode_locator, ' ', '')) LIKE ps.prefix || '%' AND ps.country_code IN ('E', 'S')
--         ORDER BY
--             LENGTH(ps.prefix) ASC
--         LIMIT 1
--     ) AS partial_postcode,
--     MIN(t_outer.country) AS country_code
-- FROM
--     address_data t_outer
-- WHERE
--     t_outer.postcode_locator NOT IN (
--         -- The 'borders_postcodes' logic is repeated here to filter out border postcodes.
--         SELECT DISTINCT t.postcode_locator
--         FROM address_data t
--         WHERE EXISTS (
--             SELECT 1
--             FROM (
--                 -- The 'prefix_summary' logic is repeated a third time.
--                 SELECT
--                     p.prefix,
--                     CASE WHEN COUNT(DISTINCT t_inner.country) > 1 THEN 'B' ELSE MIN(t_inner.country) END AS country_code
--                 FROM (
--                     SELECT DISTINCT SUBSTRING(UPPER(REPLACE(ad.postcode_locator, ' ', '')) FROM 1 FOR s.len) AS prefix
--                     FROM address_data ad, generate_series(1, LENGTH(REPLACE(ad.postcode_locator, ' ', ''))) s(len)
--                 ) p
--                 JOIN address_data t_inner ON UPPER(REPLACE(t_inner.postcode_locator, ' ', '')) LIKE p.prefix || '%'
--                 GROUP BY p.prefix
--             ) ps
--             WHERE
--                 ps.country_code = 'B' AND UPPER(REPLACE(t.postcode_locator, ' ', '')) LIKE ps.prefix || '%'
--         )
--     )
-- GROUP BY
--     t_outer.postcode_locator
-- ORDER BY
--     partial_postcode;

-- -- Sanity check to ensure that the data is as expected.
-- SELECT * FROM address_data LIMIT 10;


-- -- Count properties in each country
-- SELECT Country, COUNT(*) FROM address_data GROUP BY COUNTRY ORDER BY COUNTRY;


-- -- AI re-generated query (using revised schema from workshop)
-- SELECT
--     postcode_locator AS partial_postcode,
--     'B' AS country_code
-- FROM
--     address_data
-- WHERE
--     postcode_locator IN (
--         -- Subquery to find all unique postcodes that fall under a 'Borders' prefix.
--         SELECT DISTINCT t.postcode_locator
--         FROM address_data t
--         WHERE EXISTS (
--             SELECT 1
--             FROM (
--                 -- Nested subquery to calculate the country status for every possible prefix.
--                 SELECT
--                     p.prefix,
--                     CASE WHEN COUNT(DISTINCT t_inner.country) > 1 THEN 'B' ELSE MIN(t_inner.country) END AS country_code
--                 FROM (
--                     SELECT DISTINCT SUBSTRING(UPPER(REPLACE(ad.postcode_locator, ' ', '')) FROM 1 FOR s.len) AS prefix
--                     FROM address_data ad, generate_series(1, LENGTH(REPLACE(ad.postcode_locator, ' ', ''))) s(len)
--                 ) p
--                 JOIN address_data t_inner ON UPPER(REPLACE(t_inner.postcode_locator, ' ', '')) LIKE p.prefix || '%'
--                 GROUP BY p.prefix
--             ) ps
--             WHERE
--                 ps.country_code = 'B' AND UPPER(REPLACE(t.postcode_locator, ' ', '')) LIKE ps.prefix || '%'
--         )
--     )

-- UNION

-- -- Part 2: For all other postcodes, apply the simplification logic.
-- SELECT
--     (
--         -- Correlated subquery to find the shortest 'E' or 'S' prefix for a given postcode.
--         SELECT ps.prefix
--         FROM (
--             -- The prefix summary logic is repeated here as a nested subquery.
--             SELECT
--                 p.prefix,
--                 CASE WHEN COUNT(DISTINCT t_inner.country) > 1 THEN 'B' ELSE MIN(t_inner.country) END AS country_code
--             FROM (
--                 SELECT DISTINCT SUBSTRING(UPPER(REPLACE(ad.postcode_locator, ' ', '')) FROM 1 FOR s.len) AS prefix
--                 FROM address_data ad, generate_series(1, LENGTH(REPLACE(ad.postcode_locator, ' ', ''))) s(len)
--             ) p
--             JOIN address_data t_inner ON UPPER(REPLACE(t_inner.postcode_locator, ' ', '')) LIKE p.prefix || '%'
--             GROUP BY p.prefix
--         ) ps
--         WHERE
--             UPPER(REPLACE(t_outer.postcode_locator, ' ', '')) LIKE ps.prefix || '%' AND ps.country_code IN ('E', 'S')
--         ORDER BY
--             LENGTH(ps.prefix) ASC
--         LIMIT 1
--     ) AS partial_postcode,
--     MIN(t_outer.country) AS country_code
-- FROM
--     address_data t_outer
-- WHERE
--     t_outer.postcode_locator NOT IN (
--         -- The borders postcodes logic is repeated here to filter out border postcodes.
--         SELECT DISTINCT t.postcode_locator
--         FROM address_data t
--         WHERE EXISTS (
--             SELECT 1
--             FROM (
--                 -- The prefix summary logic is repeated a third time.
--                 SELECT
--                     p.prefix,
--                     CASE WHEN COUNT(DISTINCT t_inner.country) > 1 THEN 'B' ELSE MIN(t_inner.country) END AS country_code
--                 FROM (
--                     SELECT DISTINCT SUBSTRING(UPPER(REPLACE(ad.postcode_locator, ' ', '')) FROM 1 FOR s.len) AS prefix
--                     FROM address_data ad, generate_series(1, LENGTH(REPLACE(ad.postcode_locator, ' ', ''))) s(len)
--                 ) p
--                 JOIN address_data t_inner ON UPPER(REPLACE(t_inner.postcode_locator, ' ', '')) LIKE p.prefix || '%'
--                 GROUP BY p.prefix
--             ) ps
--             WHERE
--                 ps.country_code = 'B' AND UPPER(REPLACE(t.postcode_locator, ' ', '')) LIKE ps.prefix || '%'
--         )
--     )
-- GROUP BY
--     t_outer.postcode_locator
-- ORDER BY
--     partial_postcode;

-- -- Finds ONLY 29 postcodes which have 2 properties with the same postcode_locator.
-- -- This was a sanity check to ensure that the data is as expected.
-- -- But actually shows that the data isn't useful from just one file.
-- SELECT postcode_locator, COUNT(*) as cnt FROM address_data 
-- GROUP BY postcode_locator
-- HAVING COUNT(*) > 1;


-- SELECT subquery.area, COUNT(subquery.countries) FROM(
--     SELECT area, country as countries FROM address_data
--     GROUP BY country, area
-- ) AS subquery
-- GROUP BY area, countries
-- ORDER BY area;
-- SELECT area, country as countries FROM address_data
-- GROUP BY country;


-- SELECT
--     usecase,
--     POSTCODE,
--     CASE
--         WHEN country_count = 1 THEN 'N'
--         WHEN country_count > 1 THEN 'Y'
--     END AS is_multi_country
-- FROM (
--     -- Your original query is nested here, without the ORDER BY

--     SELECT
--         '0000001' as usecase,
--         area as POSTCODE,
--         COUNT(DISTINCT country) AS count
--     FROM
--         address_data
--     WHERE
--         country IN ('E', 'S')
--         AND area IS NOT NULL
--         AND area <> ''
--     GROUP BY
--         area

--     UNION ALL

--     SELECT
--         '0000002' as usecase,
--         district as POSTCODE,
--         COUNT(DISTINCT country) AS count
--     FROM
--         address_data
--     WHERE
--         country IN ('E', 'S')
--         AND district IS NOT NULL
--         AND district <> ''
--     GROUP BY
--         district
    
-- ) AS results -- The subquery needs an alias
-- ORDER BY
--     usecase, POSTCODE;



SELECT
    usecase,
    POSTCODE,
    CASE
        WHEN country_count = 1 THEN 'N'
        WHEN country_count > 1 THEN 'Y'
    END AS is_multi_country
FROM (
    -- Your original query is nested here, without the ORDER BY
    SELECT
        '0000001' as usecase,
        area as POSTCODE,
        COUNT(DISTINCT country) AS country_count
    FROM
        address_data
    WHERE
        country IN ('E', 'S')
        AND area IS NOT NULL
        AND area <> ''
    GROUP BY
        area

    UNION ALL

    SELECT
        '0000002' as usecase,
        district as POSTCODE,
        COUNT(DISTINCT country) AS country_count
    FROM
        address_data
    WHERE
        country IN ('E', 'S')
        AND district IS NOT NULL
        AND district <> ''
    GROUP BY
        district

    UNION ALL

    SELECT
        '0000003' as usecase,
        sector as POSTCODE,
        COUNT(DISTINCT country) AS country_count
    FROM
        address_data
    WHERE
        country IN ('E', 'S')
        AND sector IS NOT NULL
        AND sector <> ''
    GROUP BY
        sector

) AS results -- The subquery needs an alias
ORDER BY
    usecase, POSTCODE;


