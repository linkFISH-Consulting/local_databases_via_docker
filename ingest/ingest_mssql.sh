#!/bin/bash

# @Author:        F. Paul Spitzner
# @Created:       2025-09-11 11:38:37
# @Last Modified: 2025-09-11 11:58:39

# Ingest all .parquet files in /ingest/data into MSSQL as views
# Filenames become table names (without .parquet extension)

# Config
MSSQL_HOST="localhost"
MSSQL_PORT="1433"
MSSQL_USER="SA"
MSSQL_PASS="BetterUseP0stgres!"
MSSQL_DB="master"
SCHEMA="RAW_HKR"

# Path to sqlcmd (default for MSSQL container)
CMD="/opt/mssql-tools18/bin/sqlcmd -S ${MSSQL_HOST},${MSSQL_PORT} -U ${MSSQL_USER} -P ${MSSQL_PASS} -C"


echo "Creating database and schema..."
${CMD} -Q \
"IF DB_ID('${MSSQL_DB}') IS NULL CREATE DATABASE ${MSSQL_DB};"
${CMD} -d ${MSSQL_DB} -Q \
"IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = '${SCHEMA}') EXEC('CREATE SCHEMA ${SCHEMA}');"



echo "Creating views for all .parquet files in ./data..."
shopt -s nullglob
parquet_files=(/ingest/data/*.parquet)
if [ ${#parquet_files[@]} -eq 0 ]; then
    echo "No parquet files found in /ingest/data. Skipping view creation."
else
    for f in "${parquet_files[@]}"; do
        fname=$(basename "$f" .parquet)
        view_name="${SCHEMA}.${fname}"
        echo "Creating view $view_name for $f"
        # Drop view in one batch, create in another
        ${CMD} -d ${MSSQL_DB} -Q "IF OBJECT_ID('${view_name}', 'V') IS NOT NULL DROP VIEW ${view_name};"
        ${CMD} -d ${MSSQL_DB} -Q "CREATE VIEW ${view_name} AS SELECT * FROM OPENROWSET(BULK '$f', FORMAT = 'PARQUET') AS rows;"
    done
fi

echo "Done."
