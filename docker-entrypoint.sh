#!/bin/sh

# This script will parse the DATABASE_URL to get the host, port, user, and password.
# The `psql` utility's internal logic is used for a more reliable approach.
# A temporary file is used to store the password securely.

PGPASSFILE="/tmp/.pgpass"
touch "$PGPASSFILE"
chmod 0600 "$PGPASSFILE"

# Extract components from DATABASE_URL using sed
PGHOST=$(echo "$DATABASE_URL" | sed -r 's/.*@([^:]+):.*/\1/')
PGPORT=$(echo "$DATABASE_URL" | sed -r 's/.*:([0-9]+)\/.*/\1/')
PGUSER=$(echo "$DATABASE_URL" | sed -r 's/.*:\/\/\([^:]*\).*/\1/')
PGPASSWORD=$(echo "$DATABASE_URL" | sed -r 's/.*:\/\/[^:]*:\([^@]*\).*/\1/')
PGDATABASE=$(echo "$DATABASE_URL" | sed -r 's/.*\/\([^?]*\).*/\1/')

# Write the credentials to the secure file
echo "$PGHOST:$PGPORT:$PGDATABASE:$PGUSER:$PGPASSWORD" >> "$PGPASSFILE"

MAX_RETRIES=10
RETRY_INTERVAL=3

echo "Waiting for PostgreSQL at ${PGHOST}:${PGPORT}..."

for i in $(seq 1 $MAX_RETRIES); do
    # Use pg_isready with the secure password file
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

flask db upgrade

exec gunicorn --bind 0.0.0.0:80 "app:create_app()"