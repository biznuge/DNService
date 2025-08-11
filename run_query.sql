/*
=================================================================================================
-- Query to Generate Postcode Prefixes with Country Codes (E, S, B) --
-- V2: With Full Postcode Requirement for Borders --
=================================================================================================
*/

-- CTE 1: Create a master lookup table for the country status of every possible prefix.
WITH prefix_summary AS (
    SELECT
        p.prefix,
        CASE
            WHEN COUNT(DISTINCT t.countrycode) > 1 THEN 'B'
            ELSE MIN(t.countrycode)
        END AS country_code
    FROM (
        SELECT DISTINCT SUBSTRING(UPPER(REPLACE(postcode, ' ', '')) FROM 1 FOR s.len) AS prefix
        FROM address_data,
             generate_series(1, LENGTH(REPLACE(postcode, ' ', ''))) s(len)
    ) p
    JOIN address_data t ON UPPER(REPLACE(t.postcode, ' ', '')) LIKE p.prefix || '%'
    GROUP BY
        p.prefix
),

-- CTE 2: Identify all unique postcodes that fall under a 'Borders' prefix.
borders_postcodes AS (
    SELECT DISTINCT t.postcode
    FROM address_data t
    WHERE EXISTS (
        SELECT 1
        FROM prefix_summary ps
        WHERE ps.country_code = 'B'
          AND UPPER(REPLACE(t.postcode, ' ', '')) LIKE ps.prefix || '%'
    )
)

-- Final Query: Combine the two distinct result sets.
SELECT
    postcode AS partial_postcode,
    'B' AS country_code
FROM
    borders_postcodes

UNION

SELECT
    (
        SELECT ps.prefix
        FROM prefix_summary ps
        WHERE UPPER(REPLACE(t.postcode, ' ', '')) LIKE ps.prefix || '%'
          AND ps.country_code IN ('E', 'S')
        ORDER BY
            LENGTH(ps.prefix) ASC
        LIMIT 1
    ) AS partial_postcode,
    MIN(t.countrycode) AS country_code
FROM
    address_data t
WHERE
    t.postcode NOT IN (SELECT postcode FROM borders_postcodes)
GROUP BY
    t.postcode
ORDER BY
    partial_postcode;