#!/bin/sh

# Parse the hostname from the DATABASE_URL
# Example: postgresql://user:pass@host:port/dbname
DB_HOST=$(echo "$DATABASE_URL" | awk -F'[@/:]' '{print $5}')
# Parse the port from the DATABASE_URL
DB_PORT=$(echo "$DATABASE_URL" | awk -F'[:@]' '{print $4}' | awk -F'/' '{print $1}')

# Fallback for local development if DATABASE_URL doesn't contain host/port (e.g., sqlite)
# Or if you want to explicitly use 'db' for local Docker Compose
if [ -z "$DB_HOST" ] || [ "$DB_HOST" = "" ]; then
    DB_HOST="db"
fi
if [ -z "$DB_PORT" ] || [ "$DB_PORT" = "" ]; then
    DB_PORT="5432"
fi


MAX_RETRIES=10
RETRY_INTERVAL=3


# Wait for the database to be ready
echo "Waiting for PostgreSQL at ${DB_HOST}:${DB_PORT}..."

# Loop for a number of retries
for i in $(seq 1 $MAX_RETRIES); do
    # Check if the port is open using pg_isready
    # We use pg_isready directly as it's more robust for PostgreSQL
    if pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$POSTGRES_USER"; then
        echo "PostgreSQL is up! Running migrations and starting server."
        break
    else
        echo "PostgreSQL is not yet ready. Retrying in ${RETRY_INTERVAL} seconds..."
        sleep $RETRY_INTERVAL
    fi
    # If we've exhausted all retries, exit
    if [ "$i" -eq "$MAX_RETRIES" ]; then
        echo "Max retries reached. PostgreSQL is not available."
        exit 1
    fi
done

flask db upgrade

# Ensure Gunicorn binds to 0.0.0.0 on port 80 as per Dockerfile's EXPOSE
exec gunicorn --bind 0.0.0.0:80 "app:create_app()"