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
sql_files=(ddl.sql pk.sql constraint.sql index.sql)

# Directory paths
script_dir="/scripts"
temp_dir="/tmp"

# Create the schema
PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "CREATE SCHEMA IF NOT EXISTS ${SCHEMA_NAME};"

# loop through the sql files, create temp files to execute
for sql_file in "${sql_files[@]}"; do
    input_file="${script_dir}/${sql_file}"
    temp_file="${temp_dir}/temp_${sql_file}"

    # Replace placeholder
    sed "s/@cdmDatabaseSchema/${SCHEMA_NAME}/g" "$input_file" > "$temp_file"

    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$temp_file"

    rm "$temp_file"
done

# # Load user-provided vocabs
# if [ -d "$VOCAB_DATA_DIR" ]; then
#     for file in $VOCAB_DATA_DIR/*.sql; do
#         psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f $file
#     done
# fi
