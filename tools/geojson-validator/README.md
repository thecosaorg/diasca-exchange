# DIASCA GeoJSON Validator

> Python library for validating GeoJSON plot geometries in agricultural supply chains.

Part of the [DIASCA](../../README.md) data exchange toolkit.

## 🎯 Purpose

This library validates GeoJSON files to ensure plot geometries are correctly formatted and compliant with spatial standards required for:

- **EUDR compliance** – Validate plot polygons for deforestation-free sourcing
- **Traceability** – Ensure site geometries meet data quality requirements
- **Data exchange** – Validate GeoJSON before import/export

## 📦 Installation

```bash
cd tools/geojson-validator
poetry install
```

## 🚀 Quick Start

```python
from src.geojson_validator import GeoJsonValidator

# From a dictionary
validator = GeoJsonValidator({"type": "Point", "coordinates": [0, 0]})

# From a file
validator = GeoJsonValidator.from_filepath("path/to/plot.geojson")

# From a string
validator = GeoJsonValidator.from_string('{"type": "Polygon", ...}')

# Check validity
if validator.is_valid():
    print("Valid GeoJSON!")
```

## 🧪 Running Tests

```bash
poetry run pytest
```

## 🛠 Development

### Setup

```bash
# Install dependencies
poetry install

# Install pre-commit hooks
poetry run pre-commit install
```

### Code Quality

```bash
# Run linting and formatting
poetry run pre-commit run --all-files

# Run tests
poetry run pytest
```

### Adding Dependencies

```bash
# Production dependency
poetry add package_name

# Development dependency
poetry add --group dev package_name
```

## 📋 API Reference

### `GeoJsonValidator`

| Method | Description |
|--------|-------------|
| `__init__(geojson_obj)` | Initialize with a GeoJSON dict |
| `from_string(geojson_str)` | Create from a JSON string |
| `from_filepath(filepath)` | Create from a file path |
| `validate()` | Validate the GeoJSON structure |
| `is_valid()` | Returns `True` if valid, `False` otherwise |

## 📄 License

MIT License – See [LICENSE](../../LICENSE)

---

_Part of the DIASCA project, maintained by [COSA](https://thecosa.org)_
