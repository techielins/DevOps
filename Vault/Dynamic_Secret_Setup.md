## Setup Postgres [Assumption is that both docker and vault running on same server]
Pull a Postgres server image with docker.
```
docker pull postgres:latest
```
Create a Postgres database with a root user named root with the password rootpassword.
```
docker run \
    --detach \
    --name postgres-ct \
    -e POSTGRES_USER=root \
    -e POSTGRES_PASSWORD=rootpassword \
    -p 5432:5432 \
    --rm \
    postgres
```
Verify that the postgres container is running.
```
docker ps -f name=postgres-ct --format "table {{.Names}}\t{{.Status}}"
```
Create a role named ro.
```
docker exec -i \
    postgres-ct \
    psql -U root -c "CREATE ROLE \"ro\" NOINHERIT;"
```
Grant the ability to read all tables to the role named ro.
```
docker exec -i \
    learn-postgres \
    psql -U root -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"ro\";"
```
The database is available and the role is created with the appropriate permissions.

## Enable the database secrets engine
The database secrets engine generates database credentials dynamically based on configured roles.

Unseal vault and login
```
vault operator unseal
vault login
```
Enable the database secrets engine at the database/ path.
```
vault secrets enable database
```
## Configure PostgreSQL secrets engine
The database secrets engine supports many databases through a plugin interface. To use a Postgres database with the secrets engine requires further configuration with the postgresql-database-plugin plugin and connection information.

Set an environment variable for the PostreSQL address.
```
export POSTGRES_URL=127.0.0.1:5432
```
Configure the database secrets engine with the connection credentials for the Postgres database.
```
vault write database/config/postgresql \
     plugin_name=postgresql-database-plugin \
     connection_url="postgresql://{{username}}:{{password}}@$POSTGRES_URL/postgres?sslmode=disable" \
     allowed_roles=readonly \
     username="root" \
     password="rootpassword"
```
## Create a role
A role is a logical name within Vault that maps to database credentials. These credentials are expressed as SQL statements and assigned to the Vault role.
```
Define the SQL used to create credentials.
tee readonly.sql <<EOF
CREATE ROLE "{{name}}" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT;
GRANT ro TO "{{name}}";
EOF
```
The SQL contains the templatized fields {{name}}, {{password}}, and {{expiration}}. These values are provided by Vault when the credentials are created. This creates a new role and then grants that role the permissions defined in the Postgres role named ro. 
Create the role named readonly that creates credentials with the readonly.sql.
```
vault write database/roles/readonly \
      db_name=postgresql \
      creation_statements=@readonly.sql \
      default_ttl=1h \
      max_ttl=24h
```
The role generates database credentials with a default TTL of 1 hour and max TTL of 24 hours.
## Request PostgreSQL credentials
The applications that require the database credentials read them from the secret engine's readonly role.
Read credentials from the readonly database role.
```
vault read database/creds/readonly
```
The Postgres credentials are displayed as username and password. The credentials are identified within Vault by the lease_id.
## Validation
Connect to the Postgres database and list all database users.
```
docker exec -i \
    postgres-ct \
    psql -U root -c "SELECT usename, valuntil FROM pg_user;"
```
The output displays a table of all the database credentials generated. The credentials that were recently generated appear in this list.
```
                     usename                     |        valuntil
-------------------------------------------------+------------------------
 root                                            |
 v-root-readonly-sCiakphgX4GbqPStJeS6-1694449135 | 2023-09-11 17:19:00+00
(2 rows)
```










