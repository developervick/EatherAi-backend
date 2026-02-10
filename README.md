# Project Overview & Documentation

## Overview

This project is a **Dockerized Django backend application** designed for local development and production-like environments.  
It follows best practices for containerization, environment configuration, and deployment readiness.

The application is structured to:
- Run Django inside Docker using **Gunicorn**
- Use **PostgreSQL** as the primary database
- Support environment-based configuration via `.env.local`
- Perform pre-deployment checks and migrations automatically using an `entrypoint.sh` script
- Be easily extensible and production-ready

---

## High-Level Architecture

- **Backend Framework:** Django
- **Application Server:** Gunicorn
- **Containerization:** Docker & Docker Compose
- **Database:** PostgreSQL
- **Static & Media Handling:** Local directories (ready for cloud storage integration)
- **Environment Management:** `.env.local`

---


# 1. Project Setup Guide

## Backend Setup

### 1. Clone the Repository
```bash
git clone https://github.com/developervick/EatherAi-backend.git
cd EatherAi-backend
```

### 2. Create Python Virtual Environment
```bash
python3 -m venv env
```

### 3. Activate Virtual Environment
#### Linux / macOS
```bash
source env/bin/activate
```
#### Windows
```bash
env\Scripts\activate
```

### 4. Install dependencies in env
```bash
cd root
pip install -r requirements.txt
cd ..
```

### 5. Environment Variables Setup

```bash
cd root
touch .env.local
```

Add the following variables to .env.local:

```bash
DEBUG=1
DATABASE_URL=postgres://myuser:mypassword@db:5432/mydatabase
POSTGRES_DB=mydatabase
PGUSER=myuser
PGPASSWORD=mypassword
PGHOST=db
FRONTEND_URL="http://localhost:3000"
CSRF_TRUSTED_ORIGINS="http://localhost:3000"
ALLOWED_HOSTS="localhost"
PGDATABASE="mydatabase"
PGPORT=5432
SECRET_KEY="cbjsdjsjfjknfkjsdjksajdsakfkjaskfjksjkfs"

# security vars
SECURE_PROXY_SSL_HEADER=('HTTP_X_FORWARDED_PROTO','https')
SECURE_SSL_REDIRECT=True
SESSION_COOKIE_SECURE=True
CSRF_COOKIE_SECURE=True
SECURE_HSTS_SECONDS=31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS=True
SECURE_HSTS_PRELOAD=True
SECURE_CONTENT_TYPE_NOSNIFF=True
SECURE_BROWSER_XSS_FILTER=True
X_FRAME_OPTIONS='DENY'
```

### 6. Run the Application with Docker
```bash
cd ..
sudo docker compose -f docker-compose.local.yaml up --build
```

### 7. Frontend Setup

Follow the setup instructions from the frontend repository: [Click for repo](https://github.com/developervick/EatherAI-assignment)



# 2. Project Structure
```
root/
    ├── core/
    │ ├── asgi.py
    │ ├── settings.py
    │ ├── urls.py
    │ └── wsgi.py
    ├── Dockerfile
    ├── eather/
    │ ├── admin.py
    │ ├── apps.py
    │ ├── init.py
    │ ├── models.py
    │ ├── tests.py
    │ ├── urls.py
    │ └── views.py
    ├── entrypoint.sh
    ├── manage.py
    ├── media/
    ├── static/
    └── requirements.txt
docker-compose.local.yaml
.dockerignore
.gitignore
```


---

## Directory & File Explanation

### `core/`
Main Django project configuration directory.

- `settings.py` – Global project settings (apps, middleware, database, security, etc.)
- `urls.py` – Root URL routing
- `wsgi.py` – WSGI entry point for Gunicorn
- `asgi.py` – ASGI entry point for async support

---

### `eather/`
Primary Django application module.

- `models.py` – Database models
- `views.py` – API / view logic
- `urls.py` – App-level routing
- `admin.py` – Django admin configuration
- `tests.py` – Unit and integration tests
- `apps.py` – App configuration

---

### `Dockerfile`
Defines how the Django application container is built.

Key responsibilities:
- Uses **Python 3.11 slim** image
- Creates and reuses a virtual environment
- Installs system-level dependencies (`libpq-dev`, `netcat`)
- Installs Python dependencies from `requirements.txt`
- Uses a **non-root user** for security
- Runs the application with **Gunicorn**
- Adds a health check endpoint

---

### `entrypoint.sh`
Responsible for **pre-deployment and runtime checks**.

Key tasks:
- Prints debug information (Python, pip, installed packages)
- Validates Django installation
- Checks for critical files (`requirements.txt`, `manage.py`)
- Waits for the database to be available
- Runs database migrations automatically
- Executes the final container command

This ensures the container fails fast if something is misconfigured.

---

### `requirements.txt`
Contains all Python dependencies required by the project, including:
- Django
- Gunicorn
- Database drivers
- Any additional third-party libraries

This file is used during Docker image build.

---

### `manage.py`
Django’s command-line utility used for:
- Running migrations
- Creating superusers
- Running management commands

---

### `static/`
Holds collected static files (CSS, JS, images).  
Ready for integration with CDN or cloud storage.

---

### `media/`
Stores user-uploaded files.

---

## Docker & Runtime Flow

1. Docker builds the image using `Dockerfile`
2. Dependencies are installed in a virtual environment
3. Application code is copied into the container
4. `entrypoint.sh` runs:
   - Debug checks
   - Database availability check
   - Migrations
5. Gunicorn starts the Django application
6. Health check endpoint verifies container health

---

## Security & Best Practices

- Runs as a **non-root user**
- Uses environment variables for secrets
- Enforces HTTPS-related security flags
- Supports HSTS and secure cookies
- Clean multi-stage Docker build for smaller image size

---

## Deployment Readiness

This project is ready for:
- Local development
- Staging environments
- Production deployment (Docker-based platforms)

It can be easily extended to:
- Kubernetes
- Cloud-managed databases
- Object storage for static/media files
- CI/CD pipelines

---

## Summary

This backend setup provides:
- Clean project structure
- Strong Docker-based isolation
- Automated startup checks
- Secure and scalable Django deployment

A solid foundation for building and scaling modern backend services.

