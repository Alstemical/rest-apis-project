#!/bin/sh

# The script will parse the DATABASE_URL to get the host, port, user, and password.
# We will use simple string manipulation and defaults for robust parsing.

DB_HOST=$(echo "$DATABASE_URL" | sed 's|^.*@||g' | sed 's|:.*||g')
DB_PORT=$(echo "$DATABASE_URL" | sed 's|.*:\([^/]*\).*|\1|g')
DB_USER=$(echo "$DATABASE_URL" | sed 's|.*//\(.*\):.*@.*|\1|g')
DB_PASS=$(echo "$DATABASE_URL" | sed 's|.*:\(.*\s\).*|\1|g')
DB_NAME=$(echo "$DATABASE_URL" | sed 's|.*/\(.*\)|\1|g')

# Provide defaults for local development
if [ -z "$DB_HOST" ]; then
  DB_HOST="db"
fi
if [ -z "$DB_PORT" ]; then
  DB_PORT="5432"
fi

MAX_RETRIES=10
RETRY_INTERVAL=3

echo "Waiting for PostgreSQL at ${DB_HOST}:${DB_PORT}..."

# Wait for the database to be ready
for i in $(seq 1 $MAX_RETRIES); do
    if pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME"; then
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