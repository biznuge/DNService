-- This script will be run automatically when the container first starts.

-- 1. Create the table schema
CREATE TABLE address_data (
    UPRN INT,
    POSTCODE TEXT,
    COUNTRYCODE CHAR(1)
);

-- 2. Copy data from the CSV file located at /tmp/ inside the container
\copy address_data FROM '/tmp/sample_data.csv' WITH (FORMAT CSV, HEADER);