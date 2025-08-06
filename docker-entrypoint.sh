#!/bin/sh

MAX_RETRIES=10
RETRY_INTERVAL=3

echo "Waiting for PostgreSQL..."

# Wait for the database to be ready
for i in $(seq 1 $MAX_RETRIES); do
    if pg_isready -d "$DATABASE_URL"; then
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