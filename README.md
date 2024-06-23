# omop-lite

A small container to get an OMOP CDM Vocabulary Postgres database running quickly.

Drop your Vocabularies into `vocabs/`, and run the container.

## Environment Variables

You can configure the Docker container using the following environment variables:

- `DB_HOST`: The hostname of the PostgreSQL database. Default is `db`.
- `DB_PORT`: The port number of the PostgreSQL database. Default is `5432`.
- `DB_USER`: The username for the PostgreSQL database. Default is `postgres`.
- `DB_PASSWORD`: The password for the PostgreSQL database. Default is `password`.
- `DB_NAME`: The name of the PostgreSQL database. Default is `omop`.
- `SCHEMA_NAME`: The name of the schema to be created/used in the database. Default is `omop`.
- `VOCAB_DATA_DIR`: The directory containing the vocabulary CSV files. Default is `vocabs`.

## Usage

`docker run -v ./vocabs:/vocabs ghcr.io/AndyRae/omop-lite`

```yaml
# docker-compose.yml
services:
  omop-lite:
    image: ghcr.io/andyrae/omop-lite
    volumes:
      - ./vocabs:/vocabs
    depends_on:
      - db

  db:
    image: postgres:latest
    environment:
      - POSTGRES_DB=omop
      - POSTGRES_PASSWORD=password
    ports:
      - "5432:5432"
```

## Bring Your Own Vocabularies

You can provide your own data for loading into the tables by placing your CSV files in the `vocabs/` directory. This directory should contain CSV files named according to the vocab tables (DRUG_STRENGTH.csv, CONCEPT.csv, etc.).

## Setup Script

The `setup.sh` script included in the Docker image will:

1. Create the schema if it does not already exist.
2. Execute the SQL files to set up the database schema, constraints, and indexes.
3. Load data from the CSV files located in the `VOCAB_DATA_DIR`.
