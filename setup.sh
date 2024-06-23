#!/bin/bash

# Parse variables
DB_HOST="$DB_HOST"
DB_PORT="$DB_PORT"
DB_USER="$DB_USER"
DB_PASSWORD="$DB_PASSWORD"
DB_NAME="$DB_NAME"
VOCAB_DATA_DIR="$VOCAB_DATA_DIR"
SCHEMA_NAME="$SCHEMA_NAME"

# SQL files
sql_files=(pk.sql constraint.sql index.sql)
vocab_tables=(DRUG_STRENGTH CONCEPT CONCEPT_RELATIONSHIP CONCEPT_ANCESTOR CONCEPT_SYNONYM VOCABULARY RELATIONSHIP CONCEPT_CLASS DOMAIN)

# Directory paths
script_dir="/scripts"
temp_dir="/tmp"

# Check if the schema already exists
schema_exists=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT 1 FROM information_schema.schemata WHERE schema_name = '${SCHEMA_NAME}'")
if [ "$schema_exists" ]; then
    echo "Schema '${SCHEMA_NAME}' already exists. Skipping CDM creation."
    exit 0  # Exit gracefully
fi

# Create schema
PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "CREATE SCHEMA IF NOT EXISTS ${SCHEMA_NAME};"

# Create tables 
temp_ddl="${temp_dir}/temp_ddl.sql"
sed "s/@cdmDatabaseSchema/${SCHEMA_NAME}/g" "${script_dir}/ddl.sql" > "$temp_ddl"
PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$temp_ddl"
rm "$temp_ddl"

# Load vocabs
for table in "${vocab_tables[@]}"; do
    echo 'loading: ' $table
    table_lower=$(echo "$table" | tr '[:upper:]' '[:lower:]')
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
        -c "\COPY ${SCHEMA_NAME}.${table_lower} FROM '${VOCAB_DATA_DIR}/${table}.csv' WITH (FORMAT csv, DELIMITER E'\t', NULL '""', QUOTE E'\b', HEADER, ENCODING 'UTF8')"
done

# Create pk, constraints, indexes
for sql_file in "${sql_files[@]}"; do
    input_file="${script_dir}/${sql_file}"
    temp_file="${temp_dir}/temp_${sql_file}"

    # Replace placeholder
    sed "s/@cdmDatabaseSchema/${SCHEMA_NAME}/g" "$input_file" > "$temp_file"
    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$temp_file"
    rm "$temp_file"
done
