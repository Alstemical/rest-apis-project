#!/bin/sh

flask db upgrade

exec gunicorn --bind 0.0.0.0:$PORT "app:create_app()"