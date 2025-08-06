#!/bin/sh

# Use a combination of `cut` and `tr` for a more reliable URL parsing.
# The URL is in the format: postgresql://user:password@host:port/database

DB_URL_PART=$(echo "$DATABASE_URL" | cut -d'@' -f2)
DB_HOST=$(echo "$DB_URL_PART" | cut -d':' -f1)
DB_PORT=$(echo "$DB_URL_PART" | cut -d':' -f2 | cut -d'/' -f1)
DB_NAME=$(echo "$DATABASE_URL" | cut -d'/' -f4)
DB_USER=$(echo "$DATABASE_URL" | cut -d'/' -f3 | cut -d':' -f1)
DB_PASS=$(echo "$DATABASE_URL" | cut -d'/' -f3 | cut -d':' -f2 | cut -d'@' -f1)

# Default to 'db' if a host isn't parsed (for local development)
if [ -z "$DB_HOST" ]; then
  DB_HOST="db"
fi

MAX_RETRIES=10
RETRY_INTERVAL=3

echo "Waiting for PostgreSQL at ${DB_HOST}:${DB_PORT}..."

# Wait for the database to be ready
for i in $(seq 1 $MAX_RETRIES); do
    # Use pg_isready with the parsed variables
    if PGPASSWORD=$DB_PASS pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME"; then
        echo "PostgreSQL is up! Running migrations and starting server."
        break
    else
        echo "PostgreSQL is not yet ready. Retrying in ${RETRY_INTERVAL} seconds..."
        sleep $RETRY_INTERVAL
    fi

    if [ "$i" -eq "$MAX_RETRIES" ]; then
        echo "Max retries reached. PostgreSQL is not available."
        exit 1
    fi
done

flask db upgrade

exec gunicorn --bind 0.0.0.0:80 "app:create_app()"