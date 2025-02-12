```sql
-- Create Dump
DATE=$(date +%Y%m%d-%H%M%S)
export HOSTNAME=""
export USERNAME=""
export DBNAME=""
export PGPASSWORD=""
pg_dump -h $HOSTNAME -U $USERNAME -d $DBNAME > db-$DATE.sql
pg_dump -h $HOSTNAME -U $USERNAME -d $DBNAME | gzip -9c > db-$DATE.sql.gz

gzip db-$DATE.sql.gz
--
SELECT pg_size_pretty(pg_database_size('SOURCE_DB')) AS database_size;

CREATE USER vendasdb_user WITH ENCRYPTED PASSWORD 'PASS';
-- Grant usage on the public schema
GRANT USAGE ON SCHEMA public TO vendasdb_user;
-- Grant all privileges on all tables in the public schema
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO vendasdb_user;
-- Grant all privileges on all sequences in the public schema
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO vendasdb_user;
-- Grant all privileges on all functions in the public schema
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO vendasdb_user;
--
GRANT ALL ON SCHEMA public TO vendasdb_user;
-- Specific to Azure
GRANT azure_pg_admin TO vendasdb_user;

-------------------------------------------------------------------------------------------------------------------------

CREATE DATABASE temporarydbbasfprod;
ALTER DATABASE temporarydbbasfprod OWNER TO vendasdb_user;
-- Restore
-- psql -h TARGET_HOSTNAME -U TARGET_USER -d TARGET_DB -f db-$DATE.sql
SELECT pg_size_pretty(pg_database_size('TARGET_DB')) AS database_size;
-- Target may be lighter in size

```