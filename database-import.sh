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
if ! mysql -h $LOCAL_DATABASE_HOST -u $LOCAL_DATABASE_USER -p$LOCAL_DATABASE_PASS -e 'use '"$LOCAL_DATABASE_NAME" &> /dev/null; then

	if [ -f $CONFIG/setup/database.sql ]; then

		# Create local database
		echo Creating local database: $LOCAL_DATABASE_NAME
		mysqladmin -h $LOCAL_DATABASE_HOST -u $LOCAL_DATABASE_USER -p$LOCAL_DATABASE_PASS create $LOCAL_DATABASE_NAME

		echo Database created: $LOCAL_DATABASE_NAME

		# Upload dump to local database
		echo Importing database \'setup/database.sql\' to local server: $LOCAL_DATABASE_HOST
		mysql -h $LOCAL_DATABASE_HOST -u $LOCAL_DATABASE_USER -p$LOCAL_DATABASE_PASS $LOCAL_DATABASE_NAME < $CONFIG/setup/database.sql

		echo COMPLETE: Database \'setup/database.sql\' imported: $LOCAL_DATABASE_NAME

	else
		echo ERROR: Database file not found: setup/database.sql
	fi

else
	echo ERROR: Database \'$LOCAL_DATABASE_NAME\' already exists
fi
