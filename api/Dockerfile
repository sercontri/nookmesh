# ------------------------------------------------------------
# NookMesh API
# FastAPI HTTP layer
# ------------------------------------------------------------

FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY api_server.py .
COPY geojson_filter.py .
COPY assets.py .
COPY security.py .
COPY utils.py .

CMD ["uvicorn", "api_server:app", "--host", "0.0.0.0", "--port", "8089"]