# Notes on Setting EHRbase DB with CITUS

## IMPORTANT
Make sure you run this to create a new DB with distribution
DO NOT USE WITH AN EXISTING DB

## Sequence

1. Create DB on coordinator and all workers

```shell
psql -h <coordinator> -U postgres -w < citus-db-setup.sql
psql -h <worker_1> -U postgres -w < citus-db-setup.sql
psql -h <worker_2> -U postgres -w < citus-db-setup.sql
```

2. Configure the CITUS network (WARNING: deployment specific)
```shell
psql -h <coordinator> -U postgres -d ehrbase -w < citus-coordinator-setup.sql
```
3. Perform the migration to create the tables
NB. you should run the migration outside of the standard EHRbase startup. This is required
since there are a number of post migration operations to be performed.

cd to the location where flyway is installed and run it with:

```shell
./flyway migrate
```
Flyway has to be configured to perform the migration on the *coordinator*.

See https://flywaydb.org/documentation/usage/commandline/

4. Configure EHRbase DB to allow distribution using `ehr_id` as key
```shell
psql -h <coordinator> -U postgres -d ehrbase -w < citus-coordinator-ehrbase-setup.sql
```
5. Finalize the installation for test
```shell
psql -h <coordinator> -U postgres -d ehrbase -w < citus-coordinator-post-setup.sql
```
7. Run ehrbase

## Dropping the DB
Dropping the distributed DB requires some preliminary operation as it cannot be performed (yet)
using a simple `DROP DATABASE ehrbase command` (this is actually a CITUS bug)

Connect to each CITUS node (coordinator and workers), and run this SQL script on EHRbase

```sql
DROP EXTENSION citus CASCADE ;
```

Then disconnect from each node (if you psql this is not required), and invoke

```sql
DROP DATABASE ehrbase;
```