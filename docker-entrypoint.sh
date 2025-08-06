#!/bin/sh

# The host is the service name in docker-compose.yml
HOST=db
# The post is the internal container port for the database
PORT=5432
# The maximum number of retries
MAX_RETRIES=10
# The interval between retries in seconds
RETRY_INTERVAL=3


# Wait for the database to be ready
echo "Waiting for PostgreSQL at ${HOST}:${PORT}..."

# Loop for a number of retries
for i in $(seq 1 $MAX_RETRIES); do 
    # Check if the port is open. nc is 'netcat'.
    if nc -z -w 1 "$HOST" "$PORT"; then
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

exec gunicorn --bind 0.0.0.0:$PORT "app:create_app()"