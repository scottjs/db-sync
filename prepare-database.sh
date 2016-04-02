#!/bin/bash

# Config file
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
	DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
	SOURCE="$( readlink "$SOURCE" )"
	[[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done

DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

CONFIG=${DIR%/*/*/*}

# Import config settings
source "$CONFIG/.env"

# Local config
LOCAL_DATABASE_HOST=$DB_HOST
LOCAL_DATABASE_NAME=$DB_DATABASE
LOCAL_DATABASE_USER=$DB_USERNAME
LOCAL_DATABASE_PASS=$DB_PASSWORD

# Current timestamp
CURRENT_TIME=$(date "+%Y.%m.%d-%H.%M.%S")

# Create directory to store dumps
mkdir -p $CONFIG/dumps

echo Backing up local database: $LOCAL_DATABASE_NAME
mysqldump -v -h $LOCAL_DATABASE_HOST -u $LOCAL_DATABASE_USER -p$LOCAL_DATABASE_PASS $LOCAL_DATABASE_NAME > $CONFIG/dumps/local-database-$CURRENT_TIME.sql

if [ -f vendor/interconnectit/search-replace-db/srdb.cli.php ]; then

    # Run find/replace script
    php vendor/interconnectit/search-replace-db/srdb.cli.php -h $LOCAL_DATABASE_HOST -n $LOCAL_DATABASE_NAME -u $LOCAL_DATABASE_USER -p $LOCAL_DATABASE_PASS -s "$DOMAIN_LOCAL" -r "$DOMAIN_REMOTE"

	echo Downloading prepared database: $LOCAL_DATABASE_NAME
	mysqldump -v -h $LOCAL_DATABASE_HOST -u $LOCAL_DATABASE_USER -p$LOCAL_DATABASE_PASS $LOCAL_DATABASE_NAME > $CONFIG/dumps/prepared-database-$CURRENT_TIME.sql

	echo COMPLETE: Replaced \'$DOMAIN_LOCAL\' with \'$DOMAIN_REMOTE\': prepared-database-$CURRENT_TIME.sql
else
	echo ERROR: Script not found: vendor/interconnectit/search-replace-db/srdb.cli.php
fi
