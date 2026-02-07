# Use a specific Python version for consistency
FROM python:3.11.7-slim-bullseye as builder

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip and install wheel
RUN pip install --upgrade pip wheel

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Runtime stage
FROM python:3.11.7-slim-bullseye

# Environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH" \
    PYTHONPATH="/app" \
    PORT=8000

# Create non-root user
RUN groupadd -g 1001 django && \
    useradd -r -u 1001 -g django django

# Install runtime dependencies (minimal)
RUN apt-get update && apt-get install -y \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv

# Set working directory
WORKDIR /app

# Copy application code
COPY --chown=django:django . .

# Create necessary directories
RUN mkdir -p staticfiles mediafiles logs && \
    chown -R django:django staticfiles mediafiles logs

# Create entrypoint script
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
echo "Starting Django application..."\n\
\n\
# Check Python and pip\n\
echo "Python version: $(python --version)"\n\
echo "Pip version: $(pip --version)"\n\
\n\
# List installed packages\n\
echo "Installed packages:"\n\
pip list\n\
\n\
# Wait for database if needed\n\
if [ -n "$DATABASE_HOST" ] && [ -n "$DATABASE_PORT" ]; then\n\
    echo "Waiting for database..."\n\
    while ! nc -z $DATABASE_HOST $DATABASE_PORT; do\n\
        sleep 0.5\n\
    done\n\
    echo "Database is ready!"\n\
fi\n\
\n\
# Run migrations\n\
if [ "$RUN_MIGRATIONS" = "true" ]; then\n\
    echo "Running migrations..."\n\
    python manage.py migrate --noinput\n\
fi\n\
\n\
# Collect static files\n\
if [ "$COLLECT_STATIC" = "true" ]; then\n\
    echo "Collecting static files..."\n\
    python manage.py collectstatic --noinput --clear\n\
fi\n\
\n\
# Execute the main command\n\
echo "Starting server with command: $@"\n\
exec "$@"' > /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Switch to non-root user
USER django

# Verify Python environment
RUN python -c "import sys; print('Python path:', sys.path)" && \
    python -c "import django; print(f'Django version: {django.__version__}')" || \
    echo "Django not installed. Check requirements.txt"

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:$PORT/health/ || exit 1

# Entrypoint and command
ENTRYPOINT ["/entrypoint.sh"]
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "--threads", "2", "--timeout", "120", "core.wsgi:application"]