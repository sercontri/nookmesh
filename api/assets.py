# ------------------------------------------------------------
# NookMesh API Assets
# Protected styles + public icons
# ------------------------------------------------------------

import mimetypes
from pathlib import Path

from fastapi import APIRouter
from fastapi.responses import FileResponse, JSONResponse

from security import authenticate

router = APIRouter()

PUBLIC_DIR = Path("/data/public")
ICONS_DIR = PUBLIC_DIR / "icons"


# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------
def is_safe_path(base: Path, target: Path) -> bool:
    try:
        target.resolve().relative_to(base.resolve())
        return True
    except ValueError:
        return False


# ------------------------------------------------------------
# Protected MapCSS
# ------------------------------------------------------------
@router.get("/{filename}.mapcss")
def serve_mapcss(
    filename: str,
    token: str = None
):
    authenticate(token)

    path = PUBLIC_DIR / f"{filename}.mapcss"

    if not is_safe_path(PUBLIC_DIR, path):
        return JSONResponse(
            status_code=403,
            content={"detail": "Forbidden"}
        )

    if not path.exists():
        return JSONResponse(
            status_code=404,
            content={"detail": "Not Found"}
        )

    return FileResponse(
        str(path),
        media_type="text/css"
    )


# ------------------------------------------------------------
# Public icons
# ------------------------------------------------------------
@router.get("/icons/{filename}")
def serve_icon(filename: str):
    path = ICONS_DIR / filename

    if not is_safe_path(ICONS_DIR, path):
        return JSONResponse(
            status_code=403,
            content={"detail": "Forbidden"}
        )

    if not path.exists():
        return JSONResponse(
            status_code=404,
            content={"detail": "Not Found"}
        )

    mime, _ = mimetypes.guess_type(str(path))

    return FileResponse(
        str(path),
        media_type=mime or "application/octet-stream"
    )