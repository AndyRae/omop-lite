FROM alpine:latest

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN apk --no-cache add bash postgresql-client wait4x

USER appuser

# Set environment variables
ENV DB_HOST="db"
ENV DB_PORT="5432"
ENV DB_USER="postgres"
ENV DB_PASSWORD="password"
ENV DB_NAME="omop"
ENV SCHEMA_NAME="omop"
ENV VOCAB_DATA_DIR="vocabs"

# Copy files
COPY --chown=appuser:appgroup scripts /scripts
COPY --chown=appuser:appgroup setup.sh /setup.sh
RUN chmod +x /setup.sh

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/setup.sh"]
