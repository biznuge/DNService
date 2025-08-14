-- This script will be run automatically when the container first starts.

DROP TABLE IF EXISTS address_data;


-- 1. Create the table schema
CREATE TABLE address_data (
    UPRN BIGINT,
    COUNTRY TEXT,
    TOWN_NAME TEXT,
    ADMINISTRATIVE_AREA TEXT,
    POSTCODE_LOCATOR TEXT,
    area TEXT,
    district TEXT,
    sector TEXT
);


-- CREATE INDEX idx_address_data_normalized_postcode
-- ON address_data (UPPER(REPLACE(postcode_locator, ' ', '')));

CREATE INDEX idx_address_data_postcode_locator
ON address_data (postcode_locator);


CREATE INDEX idx_address_data_country
ON address_data (country);




-- CREATE INDEX idx_address_data_postcode_prefix
-- ON address_data (LEFT(UPPER(REPLACE(postcode_locator, ' ', '')), 4));

CREATE INDEX idx_address_data_area
ON address_data (area);

CREATE INDEX idx_address_data_district
ON address_data (district);

CREATE INDEX idx_address_data_sector
ON address_data (sector);


-- 2. Copy data from the CSV file located at /tmp/ inside the container
\copy address_data FROM '/tmp/sample_data.csv' WITH (FORMAT CSV, HEADER);