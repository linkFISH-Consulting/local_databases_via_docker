# Local databases via Docker
Docker compose file and snippets to quickly start and reset local databases


## Getting started

```bash
git clone https://github.com/linkFISH-Consulting/local_databases_via_docker.git
cd local_databases_via_docker
docker compose up -d
```

Creates the stack `lf_dev` with Postgres and MSSQL containers.
To access:

```
PostgreSQL
    host: localhost
    port: 5432
    db:   test_db
    user: postgres
    pass: postgres
    cli:  psql -h localhost -p 5432 -U postgres -d test_db

MSSQL
    host: localhost
    port: 1433
    db:   master
    user: SA
    pass: BetterUseP0stgres!
    cli:  sqlcmd -S localhost,1433 -U SA -P 'BetterUseP0stgres!' -C
```


Fastest way to reset all databases (only works when in this folder):

```bash
docker-compose kill && docker-compose down -v && docker-compose up -d
```

Or interact containers (works everywhere):

```bash
# stop containers
docker stop lf_dev_postgres lf_dev_mssql

# remove volumes
docker volume rm lf_dev_mssqldata lf_dev_pgdata

# start containers
docker start lf_dev_postgres lf_dev_mssql

# access a container (and the db cli)
docker exec -it lf_dev_postgres bash
psql -h localhost -p 5432 -U postgres -d test_db

docker exec -it lf_dev_mssql bash
/opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P 'BetterUseP0stgres!' -C
```


## Note on MSQL under arm:
on arm (macos) we have two options: emulate the platform (slow) or use another image.
unfortunately, `mcr.microsoft.com/azure-sql-edge:latest` has no support for
common language runtime (CLR) which we need for date formatting.
Note: to get emulation working proper, you need to enable rosetta
in docker desktop settings [see here](https://stackoverflow.com/a/75975040/22346289)

Want a fix? [See Github issue](https://github.com/microsoft/mssql-docker/issues/802) and vote for MS to support arm:

## Need other databases?

See [this github repo](https://github.com/luisaveiro/localhost-databases)
