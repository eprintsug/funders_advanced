# Funders Advanced #

Adds a new funders field that stores both the funders name and ID, along with a lookup against the Crossref API to help ensure the funder and ID are recognised.

## RIOXX2 Support ##

If the RIOXX2 package is installed (https://github.com/eprintsug/rioxx2) it will be automatically configured to use the replacement funders field provided by this package. The RIOXX validation for the project field has also been relaxed to not check that the name and ID given are present in its static list of funders. The RIOXX lookup has been updated to look in both the static list, and against the Crossref API.

## Setup ##

After installation the following steps are required:

### Add new field to workflow ###

Edit workflow file (usually archives/repoid/cfg/workflows/eprint/default.xml) and replacing all occurences of "funders" with "funders_advanced"

### Migrate existing records ###

To migrate all existing records to use the new funders_advanced field, run the following command:

````
bin/epadmin recommit <repoid> eprint --verbose
````

### Update Funders with IDs (Optional) ###
To autopopulate existing funder names with their associated IDs, a script is included that can be run after the funder name values have been copied over to the new field:

````
bin/update_with_crossref <repoid>
````

This will lookup each existing funder name against the Crossref API and if there is an unambiguous result (i.e. the funder name matches a record held in Crossref exactly), the ID will be added. To help with rate limiting on the Crossref API, the script will sleep after each query based on the X-Rate-Limit-Interval response. Results are also cached by the script to prevent repeated lookups.
