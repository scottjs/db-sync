#!/bin/bash

# Config file
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
	DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
	SOURCE="$( readlink "$SOURCE" )"
	[[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done

DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

CONFIG=$PWD

# Import config settings
source "$CONFIG/.env"

# Local config
LOCAL_DATABASE_HOST=$DB_HOST
LOCAL_DATABASE_NAME=$DB_DATABASE
LOCAL_DATABASE_USER=$DB_USERNAME
LOCAL_DATABASE_PASS=$DB_PASSWORD

# Remote config
REMOTE_DATABASE_HOST=$REMOTE_DB_HOST
REMOTE_DATABASE_NAME=$REMOTE_DB_DATABASE
REMOTE_DATABASE_USER=$REMOTE_DB_USERNAME
REMOTE_DATABASE_PASS=$REMOTE_DB_PASSWORD

# Current timestamp
CURRENT_TIME=$(date "+%Y.%m.%d-%H.%M.%S")

# Create directory to store dumps
mkdir -p $CONFIG/dumps

echo Backing up local database: $LOCAL_DATABASE_NAME
mysqldump -v -h $LOCAL_DATABASE_HOST -u $LOCAL_DATABASE_USER -p$LOCAL_DATABASE_PASS $LOCAL_DATABASE_NAME > $CONFIG/dumps/local-database-$CURRENT_TIME.sql

# Delete local database
echo Dropping local database: $LOCAL_DATABASE_NAME
mysqladmin -h $LOCAL_DATABASE_HOST -u $LOCAL_DATABASE_USER -p$LOCAL_DATABASE_PASS drop $LOCAL_DATABASE_NAME -f

# Create local database
echo Creating local database: $LOCAL_DATABASE_NAME
mysqladmin -h $LOCAL_DATABASE_HOST -u $LOCAL_DATABASE_USER -p$LOCAL_DATABASE_PASS create $LOCAL_DATABASE_NAME

# Check for database connections
if mysql -h $LOCAL_DATABASE_HOST -u $LOCAL_DATABASE_USER -p$LOCAL_DATABASE_PASS -e 'use '"$LOCAL_DATABASE_NAME" && mysql -h $REMOTE_DATABASE_HOST -u $REMOTE_DATABASE_USER -p$REMOTE_DATABASE_PASS -e 'use '"$REMOTE_DATABASE_NAME"; then

	# Download database dump
	echo Exporting database \'$REMOTE_DATABASE_NAME\' from remote server: $REMOTE_DATABASE_HOST
	mysqldump -v -h $REMOTE_DATABASE_HOST -u $REMOTE_DATABASE_USER -p$REMOTE_DATABASE_PASS $REMOTE_DATABASE_NAME > $CONFIG/dumps/remote-database-$CURRENT_TIME.sql

	echo Remote database exported: remote-database-$CURRENT_TIME.sql

	# Upload dump to local database
	echo Importing database \'remote-database-$CURRENT_TIME.sql\' to local server: $LOCAL_DATABASE_HOST
	mysql -h $LOCAL_DATABASE_HOST -u $LOCAL_DATABASE_USER -p$LOCAL_DATABASE_PASS $LOCAL_DATABASE_NAME < $CONFIG/dumps/remote-database-$CURRENT_TIME.sql

	echo COMPLETE: Database update complete: $LOCAL_DATABASE_NAME

else
	echo ERROR: Could not connect to the local or remote database
fi
