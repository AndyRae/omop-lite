FROM alpine:latest

RUN apk --no-cache add bash
RUN apk --no-cache add postgresql-client

# Set environment variables
ENV DB_HOST="db"
ENV DB_PORT="5432"
ENV DB_USER="postgres"
ENV DB_PASSWORD="password"
ENV DB_NAME="omop"
ENV SCHEMA_NAME="omop"
ENV VOCAB_DATA_DIR="vocabs"

# Copy files
COPY scripts /scripts
COPY setup.sh /setup.sh
RUN chmod +x /setup.sh

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/setup.sh"]
