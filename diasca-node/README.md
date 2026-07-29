# DIASCA DPI Node

Reference implementation for the DIASCA Digital Public Infrastructure. 
This is a Python/FastAPI modular monolith with a PostGIS database.

## Quick Start

1. Start the PostgreSQL/PostGIS database and the app using Docker Compose:
   ```bash
   docker-compose up -d
   ```
2. The API will be available at `http://localhost:8080`.
3. Swagger UI documentation is available at `http://localhost:8080/docs`.

## Development

If you want to run the application locally (outside of Docker) for development:

1. Install dependencies:
   ```bash
   pip install -e ".[dev]"
   ```
2. Start only the database using Docker Compose:
   ```bash
   docker-compose up -d db
   ```
3. Run database migrations:
   ```bash
   alembic upgrade head
   ```
4. Start the FastAPI development server:
   ```bash
   uvicorn app.main:app --reload --port 8080
   ```
