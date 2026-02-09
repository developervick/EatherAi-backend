# 1. Project Setup Guide

## Backend Setup

### 1. Clone the Repository
```bash
git clone <project-repository-url>
cd <project-directory>
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
cd root pip install -r requirements.txt
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
sudo docker compose -f docker-compose.local.yaml up --build
```

### 7. Frontend Setup

Follow the setup instructions from the frontend repository: (Link)[https://]



