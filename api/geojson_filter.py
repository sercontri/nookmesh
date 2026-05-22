# ------------------------------------------------------------
# NookMesh API GeoJSON
# Viewer-filtered GeoJSON delivery with visibility rules
# ------------------------------------------------------------

import json
import os
from pathlib import Path
from collections import defaultdict

from fastapi import APIRouter
from fastapi.responses import JSONResponse
from dotenv import load_dotenv

from security import authenticate
from utils import haversine

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------
ENV_FILE = "/config/filtros.env"
GEOJSON_FILE = Path("/data/public/nookmesh.geojson")
VISIBILITY_FILE = Path("/data/runtime/visibility.json")

if not os.path.exists(ENV_FILE):
    print(f"[WARN] {ENV_FILE} not found, using defaults")

load_dotenv(ENV_FILE)

MAX_EDAD_MIN = int(os.getenv("MAX_EDAD_MIN", "60"))

EXCLUDE_VIEWER_IN_OUTPUT = (
    os.getenv("EXCLUDE_VIEWER_IN_OUTPUT", "true").lower() == "true"
)

EXCLUDE_NEARBY_METROS = int(
    os.getenv("EXCLUDE_NEARBY_METROS", "80")
)

REQUIRE_RECENT_VIEWER_POSITION_FOR_PROXIMITY = (
    os.getenv(
        "REQUIRE_RECENT_VIEWER_POSITION_FOR_PROXIMITY",
        "true"
    ).lower() == "true"
)

MERGE_CLOSEST_DEVICES = (
    os.getenv("MERGE_CLOSEST_DEVICES", "true").lower() == "true"
)

MERGE_MAX_METROS = int(
    os.getenv("MERGE_MAX_METROS", "100")
)

router = APIRouter()


# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------
def make_circle_svg(rol, stroke, rumbo=None):
    fill = (
        "#5EA8FF"
        if rol == "staff"
        else "#FFD93D"
    )

    border = {
        "green": "lime",
        "orange": "darkorange",
        "red": "tomato"
    }.get(stroke, "#9E9E9E")

    marker = ""

    if isinstance(rumbo, (int, float)):
        marker = (
            f"<g transform='rotate({rumbo} 32 32)'>"
            f"<path "
            f"d='M 26 4 A 28 28 0 0 1 38 4' "
            f"stroke='black' "
            f"stroke-width='6' "
            f"fill='none' "
            f"stroke-linecap='round'/>"
            f"</g>"
        )

    return (
        f"<svg xmlns='http://www.w3.org/2000/svg' "
        f"width='64' height='64' viewBox='0 0 64 64'>"
        f"<circle cx='32' cy='32' r='28' fill='none' "
        f"stroke='{border}' stroke-width='6'/>"
        f"<circle cx='32' cy='32' r='26' fill='{fill}'/>"
        f"{marker}"
        f"</svg>"
    )


def load_geojson():
    if not GEOJSON_FILE.exists():
        raise FileNotFoundError("GeoJSON not found")

    with open(GEOJSON_FILE, encoding="utf-8") as f:
        return json.load(f)


def load_visibility():
    if not VISIBILITY_FILE.exists():
        return {}

    try:
        with open(VISIBILITY_FILE, encoding="utf-8") as f:
            return json.load(f)
    except Exception as e:
        print(f"[ERROR] Could not read visibility.json: {e}")
        return {}


def merge_close_devices(features):
    devices_by_user = defaultdict(list)

    for feat in features:
        user = feat["properties"].get("name", "").lower()
        devices_by_user[user].append(feat)

    merged = []

    for devices in devices_by_user.values():
        selected = []

        for device in devices:
            coords_d = device["geometry"]["coordinates"]
            lat_d = coords_d[1]
            lon_d = coords_d[0]

            tst_d = device["properties"].get("tst", 0)
            acc_d = device["properties"].get("acc", 9999)

            nearby = False

            for selected_device in selected:
                coords_s = selected_device["geometry"]["coordinates"]
                lat_s = coords_s[1]
                lon_s = coords_s[0]

                distance = haversine(
                    lat_d,
                    lon_d,
                    lat_s,
                    lon_s
                )

                if distance <= MERGE_MAX_METROS:
                    tst_s = selected_device["properties"].get("tst", 0)
                    acc_s = selected_device["properties"].get("acc", 9999)

                    if (
                        tst_d > tst_s
                        or (
                            tst_d == tst_s
                            and acc_d < acc_s
                        )
                    ):
                        selected_device.update(device)

                    nearby = True
                    break

            if not nearby:
                selected.append(device)

        merged.extend(selected)

    return merged


# ------------------------------------------------------------
# Routes
# ------------------------------------------------------------
@router.get("/nookmesh.geojson")
def serve_geojson(token: str = None):
    viewer_lc = authenticate(token)

    try:
        data = load_geojson()
    except FileNotFoundError:
        return JSONResponse(
            status_code=404,
            content={"error": "GeoJSON not found"},
            media_type="application/json; charset=utf-8"
        )

    features = data.get("features", [])
    visibility = load_visibility()

    viewer_cfg = visibility.get(viewer_lc, {})
    viewer_is_staff = viewer_cfg.get("rol", "").lower() == "staff"

    viewer_groups = set(
        g.lower()
        for g in viewer_cfg.get("grupos", [])
    )

    if not viewer_groups:
        return JSONResponse(
            content={
                "type": "FeatureCollection",
                "features": []
            },
            media_type="application/json; charset=utf-8"
        )

    viewer_feature = next(
        (
            feat
            for feat in features
            if feat["properties"].get("name", "").lower() == viewer_lc
        ),
        None
    )

    viewer_coords = (
        viewer_feature["geometry"]["coordinates"]
        if viewer_feature else None
    )

    viewer_age = (
        viewer_feature["properties"].get("edad_min", 9999)
        if viewer_feature else 9999
    )

    viewer_lon, viewer_lat = (
        (viewer_coords[0], viewer_coords[1])
        if viewer_coords else (None, None)
    )

    if (
        EXCLUDE_NEARBY_METROS > 0
        and REQUIRE_RECENT_VIEWER_POSITION_FOR_PROXIMITY
        and viewer_age > MAX_EDAD_MIN
    ):
        return JSONResponse(
            content={
                "type": "FeatureCollection",
                "features": []
            },
            media_type="application/json; charset=utf-8"
        )

    filtered = []

    for feat in features:
        props = feat["properties"]

        if not viewer_is_staff:
            desc = props.get("desc", "")
            filtered_lines = []

            for line in desc.splitlines():
                if line.startswith("Dispositivo "):
                    continue

                if line.startswith("Conexión "):
                    continue

                if line.startswith("Grupos:"):
                    continue

                filtered_lines.append(line)

            props["desc"] = "\n".join(filtered_lines)

        name_lc = props.get("name", "").lower()

        if EXCLUDE_VIEWER_IN_OUTPUT and name_lc == viewer_lc:
            continue

        if props.get("edad_min", 9999) > MAX_EDAD_MIN:
            continue

        user_groups = set(
            g.lower()
            for g in props.get("grupos", [])
        )

        if not user_groups:
            continue

        user_cfg = visibility.get(name_lc, {})

        hidden_for = set(
            g.lower()
            for g in user_cfg.get("oculto_para", [])
        )

        shared_groups = viewer_groups & user_groups
        visible_groups = shared_groups - hidden_for

        if not visible_groups:
            continue

        if viewer_lat is not None and viewer_lon is not None:
            coords = feat["geometry"]["coordinates"]

            distance = haversine(
                viewer_lat,
                viewer_lon,
                coords[1],
                coords[0]
            )

            if distance < EXCLUDE_NEARBY_METROS:
                continue

        filtered.append(feat)

    if MERGE_CLOSEST_DEVICES:
        filtered = merge_close_devices(filtered)

    filtered.sort(
        key=lambda f: f["properties"].get("tst", 0)
    )

    final_features = []

    for feat in filtered:
        props = feat["properties"]

        icon_svg = make_circle_svg(
            rol=props.get("rol", "usuario"),
            stroke=props.get("stroke", "red"),
            rumbo=props.get("rumbo")
        )

        final_features.append({
            "type": "Feature",
            "geometry": feat["geometry"],
            "properties": {
                "render": "icon",
                "icon_svg": icon_svg,
                "name": props.get("name", ""),
                "desc": props.get("desc", "")
            }
        })

        final_features.append({
            "type": "Feature",
            "geometry": feat["geometry"],
            "properties": {
                "render": "label",
                "tid": props.get("tid", "?"),
                "name": props.get("name", ""),
                "desc": props.get("desc", "")
            }
        })

    return JSONResponse(
        content={
            "type": "FeatureCollection",
            "features": final_features
        },
        media_type="application/json; charset=utf-8"
    )