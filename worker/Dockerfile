# ------------------------------------------------------------
# NookMesh Worker
# Generates nookmesh.geojson from OwnTracks recorder data
# ------------------------------------------------------------

FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY geojson_exporter.py .

CMD ["python", "geojson_exporter.py"]