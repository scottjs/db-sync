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

# Create directory to store dumps
mkdir -p $CONFIG/setup

# Check for database connections
if mysql -h $LOCAL_DATABASE_HOST -u $LOCAL_DATABASE_USER -p$LOCAL_DATABASE_PASS -e 'use '"$LOCAL_DATABASE_NAME"; then

	# Download database dump
	echo Exporting database \'$LOCAL_DATABASE_NAME\' from local server: $LOCAL_DATABASE_HOST
	mysqldump -v -h $LOCAL_DATABASE_HOST -u $LOCAL_DATABASE_USER -p$LOCAL_DATABASE_PASS $LOCAL_DATABASE_NAME > $CONFIG/setup/database.sql

	echo COMPLETE: Local database \'$LOCAL_DATABASE_NAME\' exported: setup/database.sql

else
	echo ERROR: Could not connect to local database: $LOCAL_DATABASE_NAME
fi
