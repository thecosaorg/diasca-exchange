from geojson_validator import GeoJsonValidator


def test_validates_geojson_string():
    geojson_str = '{"type": "FeatureCollection", "features": []}'
    try:
        validator = GeoJsonValidator.from_string(geojson_str)
        assert validator.is_valid()
    except ValueError as err:
        print("Validation error:", err)


def test_validates_geojson_file():
    filepath = "tests/data/central_park.geojson"
    try:
        validator = GeoJsonValidator.from_filepath(filepath)
        assert validator.is_valid()
    except ValueError as err:
        print("Validation error:", err)
