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
SELECT
    postcode AS partial_postcode,
    'B' AS country_code
FROM
    address_data
WHERE
    postcode IN (
        -- Subquery to find all unique postcodes that fall under a 'Borders' prefix.
        -- This replaces the 'borders_postcodes' CTE.
        SELECT DISTINCT t.postcode
        FROM address_data t
        WHERE EXISTS (
            SELECT 1
            FROM (
                -- Nested subquery to calculate the country status for every possible prefix.
                -- This replaces the 'prefix_summary' CTE.
                SELECT
                    p.prefix,
                    CASE WHEN COUNT(DISTINCT t_inner.countrycode) > 1 THEN 'B' ELSE MIN(t_inner.countrycode) END AS country_code
                FROM (
                    SELECT DISTINCT SUBSTRING(UPPER(REPLACE(ad.postcode, ' ', '')) FROM 1 FOR s.len) AS prefix
                    FROM address_data ad, generate_series(1, LENGTH(REPLACE(ad.postcode, ' ', ''))) s(len)
                ) p
                JOIN address_data t_inner ON UPPER(REPLACE(t_inner.postcode, ' ', '')) LIKE p.prefix || '%'
                GROUP BY p.prefix
            ) ps
            WHERE
                ps.country_code = 'B' AND UPPER(REPLACE(t.postcode, ' ', '')) LIKE ps.prefix || '%'
        )
    )

UNION

-- Part 2: For all other postcodes, apply the simplification logic.
SELECT
    (
        -- Correlated subquery to find the shortest 'E' or 'S' prefix for a given postcode.
        SELECT ps.prefix
        FROM (
            -- The 'prefix_summary' logic is repeated here as a nested subquery.
            SELECT
                p.prefix,
                CASE WHEN COUNT(DISTINCT t_inner.countrycode) > 1 THEN 'B' ELSE MIN(t_inner.countrycode) END AS country_code
            FROM (
                SELECT DISTINCT SUBSTRING(UPPER(REPLACE(ad.postcode, ' ', '')) FROM 1 FOR s.len) AS prefix
                FROM address_data ad, generate_series(1, LENGTH(REPLACE(ad.postcode, ' ', ''))) s(len)
            ) p
            JOIN address_data t_inner ON UPPER(REPLACE(t_inner.postcode, ' ', '')) LIKE p.prefix || '%'
            GROUP BY p.prefix
        ) ps
        WHERE
            UPPER(REPLACE(t_outer.postcode, ' ', '')) LIKE ps.prefix || '%' AND ps.country_code IN ('E', 'S')
        ORDER BY
            LENGTH(ps.prefix) ASC
        LIMIT 1
    ) AS partial_postcode,
    MIN(t_outer.countrycode) AS country_code
FROM
    address_data t_outer
WHERE
    t_outer.postcode NOT IN (
        -- The 'borders_postcodes' logic is repeated here to filter out border postcodes.
        SELECT DISTINCT t.postcode
        FROM address_data t
        WHERE EXISTS (
            SELECT 1
            FROM (
                -- The 'prefix_summary' logic is repeated a third time.
                SELECT
                    p.prefix,
                    CASE WHEN COUNT(DISTINCT t_inner.countrycode) > 1 THEN 'B' ELSE MIN(t_inner.countrycode) END AS country_code
                FROM (
                    SELECT DISTINCT SUBSTRING(UPPER(REPLACE(ad.postcode, ' ', '')) FROM 1 FOR s.len) AS prefix
                    FROM address_data ad, generate_series(1, LENGTH(REPLACE(ad.postcode, ' ', ''))) s(len)
                ) p
                JOIN address_data t_inner ON UPPER(REPLACE(t_inner.postcode, ' ', '')) LIKE p.prefix || '%'
                GROUP BY p.prefix
            ) ps
            WHERE
                ps.country_code = 'B' AND UPPER(REPLACE(t.postcode, ' ', '')) LIKE ps.prefix || '%'
        )
    )
GROUP BY
    t_outer.postcode
ORDER BY
    partial_postcode;