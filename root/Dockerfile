# Multi-stage build for optimized production image
# Stage 1: Builder stage for Python dependencies
FROM python:3.11-slim as builder

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    POETRY_VERSION=1.7.1 \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=false \
    POETRY_HOME="/opt/poetry"

# Install system dependencies for building Python packages
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libpq-dev \
    curl \
    make \
    && rm -rf /var/lib/apt/lists/*

# # Create and activate virtual environment
# RUN python -m venv /opt/venv
# ENV PATH="/opt/venv/bin:$PATH"

# Install Python dependencies
COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r /tmp/requirements.txt

# Stage 2: Runtime stage
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH" \
    PYTHONPATH="/app" \
    # Railway specific
    PORT=8000

RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Create non-root user for security
RUN groupadd -r django && useradd -r -g django django

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    curl \
    netcat-traditional \
    libmagic1 \
    procps \
    # Clean up
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Copy virtual environment from builder stage
# COPY --from=builder /opt/venv /opt/venv

# Create app directory
WORKDIR /app

# Copy application code
COPY --chown=django:django . /app/

# Create necessary directories
RUN mkdir -p /app/staticfiles /app/mediafiles /app/logs \
    && chown -R django:django /app/staticfiles /app/mediafiles /app/logs

# Create entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch to non-root user
USER django

# Collect static files during build (optional, can also be done at runtime)
RUN python manage.py collectstatic --noinput --clear 2>/dev/null || true

# Expose port (Railway uses $PORT environment variable)
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:$PORT/health/ || exit 1

# Entrypoint script
ENTRYPOINT ["/entrypoint.sh"]

# Default command (can be overridden by Railway)
CMD ["gunicorn", "core.wsgi:application", "--bind", "0.0.0.0:8000"]