import json


class GeoJsonValidator:
    def __init__(self, geojson_obj: dict):
        """
        Initialize with a GeoJSON object (a Python dict).
        Performs basic validation.
        """
        self.geojson = geojson_obj
        self.validate()

    @classmethod
    def from_string(cls, geojson_str: str):
        """
        Initialize a GeoJSONValidator from a GeoJSON string.
        """
        try:
            geojson_obj = json.loads(geojson_str)
        except json.JSONDecodeError as e:
            raise ValueError("Invalid GeoJSON string") from e
        return cls(geojson_obj)

    @classmethod
    def from_filepath(cls, filepath: str):
        """
        Initialize a GeoJSONValidator from a file path.
        """
        try:
            with open(filepath, "r") as f:
                geojson_obj = json.load(f)
        except FileNotFoundError as e:
            raise ValueError(f"File not found: {filepath}") from e
        except json.JSONDecodeError as e:
            raise ValueError("Invalid GeoJSON file content") from e
        return cls(geojson_obj)

    def validate(self):
        """
        Basic validation: Ensure the GeoJSON object has the required structure.
        For instance, a valid GeoJSON should contain a 'type' key.
        Additional validation rules can be added as needed.
        """
        if "type" not in self.geojson:
            raise ValueError("Invalid GeoJSON: missing 'type'")
        # Further validation logic can be added here

    def is_valid(self) -> bool:
        """
        Returns True if the GeoJSON is valid, otherwise raises an exception.
        """
        try:
            self.validate()
            return True
        except ValueError:
            return False
