#!/bin/bash
set -e

echo "=== Starting Django Application ==="

# Debug information
echo "Current directory: $(pwd)"
echo "Python path: $(which python)"
echo "Python version: $(python --version)"
echo "Pip path: $(which pip)"
echo "Pip version: $(pip --version)"

# List installed packages
echo "=== Installed Python Packages ==="
pip list || echo "pip list failed"

# Check for Django
echo "=== Checking Django ==="
python -c "import sys; print('Python sys.path:', sys.path)" || echo "Python check failed"

# Try to import Django
python -c "
try:
    import django
    print(f'✓ Django {django.__version__} is installed')
    from django.conf import settings
    print('✓ Django settings can be imported')
except ImportError as e:
    print(f'✗ Django import failed: {e}')
except Exception as e:
    print(f'✗ Error: {e}')
"

# Check for requirements.txt
echo "=== Checking requirements.txt ==="
if [ -f "requirements.txt" ]; then
    echo "✓ requirements.txt found"
    echo "Contents:"
    cat requirements.txt
else
    echo "✗ requirements.txt not found!"
    ls -la
fi

# Check for manage.py
echo "=== Checking manage.py ==="
if [ -f "manage.py" ]; then
    echo "✓ manage.py found"
else
    echo "✗ manage.py not found!"
fi

# Wait for database if needed
if [ -n "${DATABASE_HOST}" ] && [ -n "${DATABASE_PORT}" ]; then
    echo "=== Waiting for database ==="
    echo "Database host: ${DATABASE_HOST}:${DATABASE_PORT}"
    
    # Install netcat if not available
    if ! command -v nc &> /dev/null; then
        echo "Installing netcat..."
        apt-get update && apt-get install -y netcat-traditional
    fi
    
    counter=0
    max_attempts=30
    while ! nc -z ${DATABASE_HOST} ${DATABASE_PORT}; do
        counter=$((counter+1))
        if [ $counter -eq $max_attempts ]; then
            echo "✗ Database connection failed after $max_attempts attempts"
            exit 1
        fi
        echo "Attempt $counter/$max_attempts: Database not ready..."
        sleep 2
    done
    echo "✓ Database is ready!"
fi

# Run migrations
if [ "${RUN_MIGRATIONS:-true}" = "true" ]; then
    echo "=== Running migrations ==="
    python manage.py migrate --noinput || echo "Migrations failed, continuing..."
fi

# Create superuser (optional, for development)
if [ -n "${DJANGO_SUPERUSER_USERNAME}" ] && [ -n "${DJANGO_SUPERUSER_PASSWORD}" ] && [ -n "${DJANGO_SUPERUSER_EMAIL}" ]; then
    echo "=== Creating superuser ==="
    python manage.py shell -c "
from django.contrib.auth import get_user_model;
User = get_user_model();
if not User.objects.filter(username='${DJANGO_SUPERUSER_USERNAME}').exists():
    User.objects.create_superuser('${DJANGO_SUPERUSER_USERNAME}', '${DJANGO_SUPERUSER_EMAIL}', '${DJANGO_SUPERUSER_PASSWORD}')
    print('✓ Superuser created')
else:
    print('✓ Superuser already exists')
" || echo "Superuser creation failed"
fi

# Collect static files
if [ "${COLLECT_STATIC:-true}" = "true" ]; then
    echo "=== Collecting static files ==="
    python manage.py collectstatic --noinput --clear || echo "Static collection failed, continuing..."
fi

# Execute the main command
echo "=== Starting server ==="
echo "Command: $@"
exec "$@"