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


RUN apt-get update && apt-get install -y netcat-traditional && rm -rf /var/lib/apt/lists/*

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv

# Set working directory
WORKDIR /app

RUN echo "Current directory: $(pwd)"
RUN echo "Files in current directory: $(ls -F)"

# Copy application code
COPY --chown=django:django . .

# Create necessary directories
RUN mkdir -p staticfiles mediafiles logs && \
    chown -R django:django staticfiles mediafiles logs


RUN sed -i 's/\r$//' /app/entrypoint.sh && \
    chmod +x /app/entrypoint.sh

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

RUN echo "Current directory: $(pwd)"
RUN echo "Files in current directory: $(ls -F)"
# Entrypoint and command
ENTRYPOINT ["sh", "/app/entrypoint.sh"]
# CMD [ "python", "manage.py", "runserver", "0.0.0.0:8000" ]
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--chdir", "/app", "--workers", "4", "--threads", "2", "--timeout", "120", "core.wsgi:application"]