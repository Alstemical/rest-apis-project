#!/bin/sh

# This script parses the DATABASE_URL to get the host, port, user, and database.
# It handles both the local 'db' host and the full Render URL.

if echo "$DATABASE_URL" | grep -q "sqlite"; then
    echo "Using SQLite, no database readiness check needed."
else
    # Parse the DATABASE_URL string
    export PGHOST=$(echo "$DATABASE_URL" | sed -r 's|.*@([^:]+):.*|\1|')
    export PGPORT=$(echo "$DATABASE_URL" | sed -r 's|.*:([0-9]+)\/.*|\1|')
    export PGUSER=$(echo "$DATABASE_URL" | sed -r 's|.*://([^:]+):.*|\1|')
    export PGPASSWORD=$(echo "$DATABASE_URL" | sed -r 's|.*://[^:]*:\([^@]*\).*|\1|')
    export PGDATABASE=$(echo "$DATABASE_URL" | sed -r 's|.*/([^?]*).*|\1|')

    # Default to 'db' if a host isn't parsed
    if [ -z "$PGHOST" ]; then
      export PGHOST="db"
    fi

    MAX_RETRIES=10
    RETRY_INTERVAL=3

    echo "Waiting for PostgreSQL at ${PGHOST}:${PGPORT}..."

    # Wait for the database to be ready
    for i in $(seq 1 $MAX_RETRIES); do
        if pg_isready -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE"; then
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
fi

flask db upgrade

exec gunicorn --bind 0.0.0.0:80 "app:create_app()"