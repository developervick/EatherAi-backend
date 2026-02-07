#!/bin/bash
set -e

echo "Starting Django application..."

# # Activate virtual environment
# export PATH="/opt/venv/bin:$PATH"

# Check if we need to wait for database
if [ -n "${DATABASE_HOST}" ] && [ -n "${DATABASE_PORT}" ]; then
    echo "Waiting for database at ${DATABASE_HOST}:${DATABASE_PORT}..."
    while ! nc -z ${DATABASE_HOST} ${DATABASE_PORT}; do
        echo "Database not ready yet. Waiting..."
        sleep 2
    done
    echo "Database is ready!"
fi

# Run database migrations
echo "Running database migrations..."
python manage.py migrate --noinput

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput --clear

# Create any other necessary setup
echo "Running any additional setup commands..."
# Add any other setup commands here

# Execute the command passed to the container
echo "Starting server..."
exec "$@"