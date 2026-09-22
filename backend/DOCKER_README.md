# Docker Setup for Tuymet Backend

## Prerequisites
- Docker installed (https://docs.docker.com/get-docker/)
- Docker Compose installed (usually comes with Docker Desktop)

## Quick Start

### 1. Configure Environment Variables

Copy the example environment file and customize it:

```bash
cp .env.docker .env
```

**Important:** Edit `.env` and change these values before deployment:
- `DB_PASSWORD` - Use a strong password
- `FLASK_SECRET_KEY` - Generate with: `openssl rand -hex 32`
- `ALLOWED_ORIGINS` - Set to your frontend URLs

### 2. Build and Run

Start all services (PostgreSQL + Flask backend):

```bash
docker-compose up --build
```

Or run in detached mode (background):

```bash
docker-compose up -d --build
```

### 3. Access the Application

- **Backend API**: http://localhost:5000
- **Database**: localhost:5432

### 4. View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f db
```

### 5. Stop Services

```bash
docker-compose down
```

To also remove volumes (database data):

```bash
docker-compose down -v
```

## Development Commands

```bash
# Rebuild after code changes
docker-compose build

# Restart services
docker-compose restart

# Run one-off command in backend container
docker-compose run backend python app.py

# Access backend shell
docker-compose exec backend bash

# Access database shell
docker-compose exec db psql -U postgres -d TUIYMET
```

## Architecture

```
┌─────────────────┐     ┌─────────────────┐
│   Flask App     │────▶│   PostgreSQL    │
│   (Port 5000)   │     │   (Port 5432)   │
└─────────────────┘     └─────────────────┘
        ▲
        │
   HTTP/HTTPS
        │
        ▼
┌─────────────────┐
│   Frontend      │
│   (React/Vue)   │
└─────────────────┘
```

## Security Notes

⚠️ **Before Production Deployment:**

1. Change default passwords in `.env`
2. Generate secure `FLASK_SECRET_KEY`
3. Set `FLASK_DEBUG=False`
4. Restrict `ALLOWED_ORIGINS` to your domain(s)
5. Consider using Docker secrets for sensitive data
6. Enable SSL/TLS for database connections
7. Implement proper JWT token verification

## Troubleshooting

### Database Connection Issues

If the backend can't connect to the database:

```bash
# Check if database is healthy
docker-compose ps

# View database logs
docker-compose logs db

# Restart database
docker-compose restart db
```

### Port Conflicts

If port 5000 or 5432 is already in use, edit `docker-compose.yml`:

```yaml
ports:
  - "5001:5000"  # Change host port to 5001
```

### Reset Database

```bash
docker-compose down -v
docker-compose up -d --build
```

## File Structure

```
backend/
├── Dockerfile           # Backend container image
├── docker-compose.yml   # Multi-container orchestration
├── .env.docker          # Example environment config
├── .env                 # Your actual config (gitignored)
├── requirements.txt     # Python dependencies
├── app.py              # Flask application
└── db.py               # Database connection
```
