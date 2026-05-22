import json
import os
import time
import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

from dotenv import load_dotenv


# ------------------------------------------------------------
# NookMesh GeoJSON Exporter
# Builds public GeoJSON from OwnTracks recorder data
# ------------------------------------------------------------

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------
ENV_FILE = "/config/filtros.env"

if not os.path.exists(ENV_FILE):
    print(f"[WARN] {ENV_FILE} not found, using defaults")

load_dotenv(ENV_FILE)

EXPORT_INTERVAL_SECONDS = int(
    os.getenv("EXPORT_INTERVAL_SECONDS", "3")
)

EXPORT_HOUR_START = int(
    os.getenv("EXPORT_HOUR_START", "0")
)

EXPORT_HOUR_END = int(
    os.getenv("EXPORT_HOUR_END", "23")
)

MAX_EDAD_MIN = int(
    os.getenv("MAX_EDAD_MIN", "60")
)

TIMEZONE = os.getenv(
    "TIMEZONE",
    "Europe/Madrid"
)

LAST_BASE = Path("/data/owntracks/store/last")
OUTPUT_FILE = Path("/data/public/nookmesh.geojson")
VISIBILITY_FILE = Path("/data/runtime/visibility.json")

LOCAL_TZ = ZoneInfo(TIMEZONE)


# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------
def is_export_hour(now_hour: int) -> bool:
    if EXPORT_HOUR_START < EXPORT_HOUR_END:
        return EXPORT_HOUR_START <= now_hour < EXPORT_HOUR_END

    return (
        now_hour >= EXPORT_HOUR_START
        or now_hour < EXPORT_HOUR_END
    )


def load_visibility():
    if not VISIBILITY_FILE.exists():
        print(f"[WARN] {VISIBILITY_FILE} not found")
        return {}

    try:
        with open(VISIBILITY_FILE, encoding="utf-8") as f:
            return json.load(f)

    except Exception as e:
        print(f"[ERROR] Could not read visibility.json: {e}")
        return {}


def get_connection_type(conn: str) -> str:
    if conn == "w":
        return "Wi-Fi"

    if conn == "m":
        return "Móvil"

    return conn or "desconocida"


def get_heading_text(cog) -> str:
    if not isinstance(cog, (int, float)):
        return ""

    directions = [
        "N", "NE", "E", "SE",
        "S", "SW", "W", "NW"
    ]

    idx = int((cog % 360) / 45 + 0.5) % 8

    return f"{cog}° {directions[idx]}"


def get_stroke_color(age_min: int) -> str:
    if age_min < 5:
        return "green"

    if age_min < 30:
        return "orange"

    return "red"


def format_time_text(tst: int, age_min: int) -> str:
    local_dt = datetime.datetime.fromtimestamp(
        tst,
        tz=LOCAL_TZ
    )

    local_time = local_dt.strftime("%H:%M")

    if age_min < 1:
        return f"{local_time} (menos de 1 min)"

    if age_min == 1:
        return f"{local_time} (hace 1 min)"

    return f"{local_time} (hace {age_min} min)"


def write_geojson_atomic(data: dict):
    tmp_file = OUTPUT_FILE.with_suffix(".tmp")

    try:
        with open(tmp_file, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False)

        tmp_file.replace(OUTPUT_FILE)

    except Exception as e:
        print(f"[ERROR] Could not write GeoJSON: {e}")


# ------------------------------------------------------------
# Export
# ------------------------------------------------------------
def export_last_to_geojson():
    if not LAST_BASE.exists():
        print(f"[ERROR] {LAST_BASE} does not exist")
        return

    visibility = load_visibility()
    features = []

    now_utc = datetime.datetime.now(
        datetime.timezone.utc
    )

    for user_dir in LAST_BASE.iterdir():
        if not user_dir.is_dir():
            continue

        for device_file in user_dir.glob("*/*.json"):
            try:
                with open(device_file, encoding="utf-8") as f:
                    point = json.load(f)

                username = point.get(
                    "username",
                    ""
                ).lower()

                if not username:
                    continue

                user_cfg = visibility.get(username)

                if not user_cfg:
                    continue

                if (
                    "lat" not in point
                    or "lon" not in point
                    or "tst" not in point
                ):
                    continue

                grupos_usuario = user_cfg.get(
                    "grupos",
                    []
                )

                rol = user_cfg.get(
                    "rol",
                    "usuario"
                )

                lat = point["lat"]
                lon = point["lon"]
                tst = point["tst"]

                point_utc = datetime.datetime.fromtimestamp(
                    tst,
                    tz=datetime.timezone.utc
                )

                age_min = int(
                    (now_utc - point_utc).total_seconds() // 60
                )

                if age_min > MAX_EDAD_MIN:
                    continue

                cog = point.get("cog")
                conn_type = get_connection_type(
                    point.get("conn", "")
                )

                heading = get_heading_text(cog)

                time_text = format_time_text(
                    tst,
                    age_min
                )

                grupos_txt = (
                    ", ".join(grupos_usuario)
                    if grupos_usuario
                    else "sin grupo"
                )

                rumbo_txt = heading if heading else "desconocido"
                alt_txt = point.get("alt", 0)

                vel = point.get("vel")
                vel_kmh = round(vel) if vel is not None else 0

                desc = (
                    f"Posición {time_text}\n"
                    f"Precisión {point.get('acc', 0)} m - Rumbo {rumbo_txt}\n"
                    f"Altitud {alt_txt} m - Velocidad {vel_kmh} km/h\n"
                    f"Dispositivo {point.get('device', 'desconocido')} - "
                    f"Batería {point.get('batt', 0)}%\n"
                    f"Conexión {conn_type}\n"
                    f"Grupos: {grupos_txt}\n"
                )

                feature = {
                    "type": "Feature",
                    "geometry": {
                        "type": "Point",
                        "coordinates": [
                            lon,
                            lat
                        ]
                    },
                    "properties": {
                        "name": username.upper(),
                        "desc": desc,
                        "tid": point.get("tid"),
                        "tst": tst,
                        "edad_min": age_min,
                        "rumbo": cog,
                        "grupos": [
                            g.lower()
                            for g in grupos_usuario
                        ],
                        "rol": rol.lower(),
                        "acc": point.get("acc", 0),
                        "stroke": get_stroke_color(age_min)
                    }
                }

                features.append(feature)

            except Exception as e:
                print(f"[ERROR] {device_file}: {e}")

    geojson = {
        "type": "FeatureCollection",
        "features": features
    }

    write_geojson_atomic(geojson)


# ------------------------------------------------------------
# Main loop
# ------------------------------------------------------------
if __name__ == "__main__":
    while True:
        current_hour = datetime.datetime.now(
            LOCAL_TZ
        ).hour

        if is_export_hour(current_hour):
            export_last_to_geojson()
            print("[✓] nookmesh.geojson updated")

        else:
            write_geojson_atomic({
               "type": "FeatureCollection",
               "features": []
            })
            
            print(
                "[⏸] Outside export schedule "
                "(GeoJSON cleared)"
            )

        time.sleep(EXPORT_INTERVAL_SECONDS)