# Configuring and Running Flyway Locally
This section gives some details on how to configure flyway to use on the command line (CLI).
This is needed whenever the DB needs to be configured as part of a deployment process (f.e. CITUS)

The objective is to be able to perform the DB migration without needing to run EHRbase while
keeping the schema history synchronized.

## Flyway Installation

Download the installer from https://flywaydb.org/documentation/usage/commandline/ and follow
the installation instruction depending on the platform O/S.

## Flyway Configuration
It is assumed that EHRbase GitHub repository is cloned or at least, the migration directory
is copied locally.

GitHub repository is at: https://github.com/ehrbase/ehrbase

In particular, the migration is relatively located at

`base/src/main/resources/db/migration`

This path will be used for the flyway configuration.

In flyway installation directory, edit `conf/flyway.conf` with the following parameters

```properties
# JDBC url to use to connect to the database
# Examples
# --------
# Most drivers are included out of the box.
#...
flyway.url=jdbc:postgresql://192.168.0.18:5432/ehrbase

# Fully qualified classname of the JDBC driver (autodetected by default based on flyway.url)
flyway.driver=org.postgresql.Driver

# User to use to connect to the database. Flyway will prompt you to enter it if not specified, and if the JDBC
# connection is not using a password-less method of authentication.
flyway.user=postgres

# Password to use to connect to the database. Flyway will prompt you to enter it if not specified, and if the JDBC
# connection is not using a password-less method of authentication.
flyway.password=postgres

# The default schema managed by Flyway. This schema name is case-sensitive. If not specified, but flyway.schemas
# is, Flyway uses the first schema in that list. If that is also not specified, Flyway uses the default schema for the
# database connection.
# Consequences:
# - This schema will be the one containing the schema history table.
# - This schema will be the default for the database connection (provided the database supports this concept).
flyway.defaultSchema=ehr

# Comma-separated list of the schemas managed by Flyway. These schema names are case-sensitive. If not specified, Flyway uses
# the default schema for the database connection. If flyway.defaultSchema is not specified, then the first of
# this list also acts as the default schema.
# Consequences:
# - Flyway will automatically attempt to create all these schemas, unless they already exist.
# - The schemas will be cleaned in the order of this list.
# - If Flyway created them, the schemas themselves will be dropped when cleaning.
flyway.schemas=ehr

#
# Locations starting with filesystem: point to a directory on the filesystem, may only
# contain SQL migrations and are only scanned recursively down non-hidden directories.
# Locations starting with s3: point to a bucket in AWS S3, may only contain SQL migrations, and are scanned
# recursively. They are in the format s3:<bucket>(/optionalfolder/subfolder)
# Locations starting with gcs: point to a bucket in Google Cloud Storage, may only contain SQL migrations, and are scanned
# recursively. They are in the format gcs:<bucket>(/optionalfolder/subfolder)
# Wildcards can be used to reduce duplication of location paths. (e.g. filesystem:migrations/*/oracle) Supported wildcards:
# ** : Matches any 0 or more directories
# *  : Matches any 0 or more non-separator characters
# ?  : Matches any 1 non-separator character
#
flyway.locations=filesystem:/<cloned path>/ehrbase/base/src/main/resources/db/migration
```
## Performing the Migration
At this stage, cd into the flyway installation directory (f.e. `cd ~/flyway-8.4.4`) and run it as follows:

```shell
./flyway migrate
```