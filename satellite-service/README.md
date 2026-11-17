# Satellite service

Reserved for scheduled Sentinel-1 processing with Google Earth Engine. No imagery is fetched and no risk result is generated in this scaffold. Real processing requires an approved Earth Engine project, a validated method, and reviewed Semarang baseline data; do not populate the API with unverified outputs.

Next setup step after the team has GEE access: create a Python 3.11+ environment, install the Earth Engine API, authenticate, then implement and validate the water-mask/change-detection pipeline against known scenes before exporting GeoJSON.
