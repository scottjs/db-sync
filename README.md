# DB Sync

When working on an active project, your local database may become too out of date from the database in staging or production and make local development difficult or unreliable.

DB Sync provides scripts to quickly update a local MySQL development database with a remote staging or production database, as well as the ability to run safe search/replace on your local database in preparation for deploying to a remote server. It assumes that your remote database is externally accessable via an IP whitelist or similar.

*Disclaimer: These scripts and commands were originally created for use internally within our development team to speed up common, repetitive tasks. However, they may be of some use to others. Feel free to use in your own projects, your mileage may vary.*

## Requirements

* Composer
* PHP >= 5.3.0
* A local development environment, such as Vagrant.

## Notes

* These scripts require a .env config file in the project root. If you're using WordPress, you can use [scottjs/wp-dotenv](https://github.com/scottjs/wp-dotenv) to allow WordPress to share the same .env file and avoid maintaining two config files.
* This script was designed with WordPress in mind, however it should work with other projects, such as Laravel 5.

## Installation

Add `"scottjs/db-sync": "0.*"` to your `composer.json` file:

```
"require-dev": {
	"scottjs/db-sync": "0.*"
},
```

Then add the following scripts to your `composer.json` file:

```
"scripts": {
	"database-update" : [
		"vendor/scottjs/db-sync/database-update.sh"
	],
	"database-prepare" : [
		"vendor/scottjs/db-sync/database-prepare.sh"
	]
}
```

Run the `composer update` command from the root of your project. 

Create a `.env` file in the root of your project and add/update the following configuration options:

```
DOMAIN_REMOTE=www.example.com
DOMAIN_LOCAL=www.example.local

DB_HOST=localhost
DB_DATABASE=example
DB_USERNAME=root
DB_PASSWORD=password

REMOTE_DB_HOST=123.123.123.123
REMOTE_DB_DATABASE=example
REMOTE_DB_USERNAME=root
REMOTE_DB_PASSWORD=password
```

## Usage

From the root of your project, you will be able to run the following composer commands:

* ***composer database-update*** - When working on an active project, your local database might become too out of date from the database in staging or production. This command will backup and empty your locally configured database and update it with a copy of your remote or production database. This requires all `DB_*` and `REMOTE_DB_*` options to be set in the .env file and also assumes your remote database is accessible externally.

* ***composer database-prepare*** - When developing locally, links to images and assets created within a CMS might be referencing your local development web address and won't work in staging or production. This command will run a safe search/replace script on your locally configured database, replacing all instances of `DOMAIN_LOCAL` with `DOMAIN_REMOTE` configured in the .env file. The database will then be exported to `dumps/prepared-database-YYYY.MM.DD-HH.MM.SS.sql` ready for deployment.

## Config

See below for an explanation of each configuration option used within the .env file.

* ***DOMAIN_REMOTE*** - It should point to your remote or production environment (if available) and not include http:// or trailing slashes. Example: `www.example.com` or `subdomain.example.com`.

* ***DOMAIN_LOCAL*** - It should not include http:// or trailing slashses. Example: `www.example.local` or `subdomain.example.local`.

* ***DB_**** - Provides options to set the local database connection details.

* ***REMOTE\_DB_**** - Provides options to set the remote staging or production database connection details.
