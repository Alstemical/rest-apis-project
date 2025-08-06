#!/bin/sh

set -e

echo "Waiting for PostgreSQL..."

while ! nc -z dpg-d294dher433s73c72qs0-a 5432; do
  sleep 0.1
done

echo "PostgreSQL is up! Running migrations and starting server."

alembic upgrade head

# Start RQ worker in the background
rq worker &

# Start Gunicorn web server in the foreground
exec gunicorn --bind 0.0.0.0:80 "app:create_app()"