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
        area IS NOT NULL
        AND area <> ''
    GROUP BY
        area
    HAVING
        MAX(country) = 'S' -- This ensures 'S' is in the group

    UNION ALL

    SELECT
        '0000002' as usecase,
        district as POSTCODE,
        COUNT(DISTINCT country) AS country_count
    FROM
        address_data
    WHERE
        district IS NOT NULL
        AND district <> ''
    GROUP BY
        district
    HAVING
        MAX(country) = 'S' -- This ensures 'S' is in the group

    UNION ALL

    SELECT
        '0000003' as usecase,
        sector as POSTCODE,
        COUNT(DISTINCT country) AS country_count
    FROM
        address_data
    WHERE
        sector IS NOT NULL
        AND sector <> ''
    GROUP BY
        sector
    HAVING
        MAX(country) = 'S' -- This ensures 'S' is in the group

) AS results -- The subquery needs an alias
ORDER BY
    usecase, POSTCODE;


