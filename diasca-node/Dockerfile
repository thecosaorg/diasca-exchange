FROM python:3.12-slim

WORKDIR /app

# Install PostGIS client libraries for GeoAlchemy2
RUN apt-get update && \
    apt-get install -y --no-install-recommends libpq-dev libgeos-dev curl

COPY pyproject.toml README.md ./
RUN pip install --no-cache-dir .

COPY . .

EXPOSE 8080

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
