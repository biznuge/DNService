# Scot'ish Postcode Checking

In this repo I'm messing around with:
- Determining whether a postcode is in Scotland, England or spans the border between the two countries.
- Whether Postcode minification of postcodes without loss of information is possible within the database. This is in opposition to number crunching in the application domain, which can be costly and time consuming
- This is with an eye to adapting this to work with Ordnance Survey Address Base Plus / Islands / Premium datasets


**Caveats:**
- Currently this pumps out Scottish, English and borders information, but COULD be _easily_ limited to return only non-English


## Installation

From your terminal (making sure you're in the project directory where this readme lives), run the following command to start your database in the background:

> docker compose up -d

You should see output indicating that the postgres-db container is being created, started and data loaded.

## Execute the query script:

Connect to a docker terminal - Note this also specifices the correct db to connect to.

> docker exec -it postgres-db psql -U postgres -d testdb

Now for the main event! Use the \i command to run the script file.

> \i /docker-entrypoint-initdb.d/2-run-query.sql

## Execute to file output

If you want to simply pump out a file that represents the query results so that you can handle a file rather than console output, the following query should help.

> docker exec postgres-db psql -U postgres -d testdb --csv -f /docker-entrypoint-initdb.d/2-run-query.sql > results.csv

## Cleaning up

To exit the psql shell, simply type:

> \q

When you're finished, you can stop and completely remove the database container and its data with a single command from your project folder:

> docker-compose down -v

