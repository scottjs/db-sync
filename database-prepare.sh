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

# Check for database connections
if mysql -h $LOCAL_DATABASE_HOST -u $LOCAL_DATABASE_USER -p$LOCAL_DATABASE_PASS -e 'use '"$LOCAL_DATABASE_NAME"; then

	echo Backing up local database \'$LOCAL_DATABASE_NAME\': $LOCAL_DATABASE_HOST
	mysqldump -v -h $LOCAL_DATABASE_HOST -u $LOCAL_DATABASE_USER -p$LOCAL_DATABASE_PASS $LOCAL_DATABASE_NAME > $CONFIG/dumps/local-database-$CURRENT_TIME.sql

	if [ -f vendor/interconnectit/search-replace-db/srdb.cli.php ]; then

		echo Running search and replace: $LOCAL_DATABASE_NAME

		# Run find/replace script
		php vendor/interconnectit/search-replace-db/srdb.cli.php -h $LOCAL_DATABASE_HOST -n $LOCAL_DATABASE_NAME -u $LOCAL_DATABASE_USER -p $LOCAL_DATABASE_PASS -s "$DOMAIN_LOCAL" -r "$DOMAIN_REMOTE"
		echo Search and replace complete: $LOCAL_DATABASE_NAME

		echo Exporting prepared database: $LOCAL_DATABASE_NAME

		mysqldump -v -h $LOCAL_DATABASE_HOST -u $LOCAL_DATABASE_USER -p$LOCAL_DATABASE_PASS $LOCAL_DATABASE_NAME > $CONFIG/dumps/prepared-database-$CURRENT_TIME.sql
		echo COMPLETE: Database exported and replaced \'$DOMAIN_LOCAL\' with \'$DOMAIN_REMOTE\': prepared-database-$CURRENT_TIME.sql
	else
		echo ERROR: Script not found: vendor/interconnectit/search-replace-db/srdb.cli.php
	fi

else
	echo ERROR: Could not connect to the database: $LOCAL_DATABASE_NAME
fi
