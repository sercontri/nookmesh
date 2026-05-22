# ------------------------------------------------------------
# NookMesh API Security
# NookMesh request authentication helpers
# ------------------------------------------------------------

from pathlib import Path

from fastapi import HTTPException

TOKEN_FILE = Path("/config/generated/api-tokens.txt")


# ------------------------------------------------------------
# Token loading
# ------------------------------------------------------------
def load_tokens():
    tokens = {}

    if not TOKEN_FILE.exists():
        print(f"[WARN] {TOKEN_FILE} not found")
        return tokens

    try:
        with open(TOKEN_FILE, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()

                if not line or line.startswith("#"):
                    continue

                if ":" not in line:
                    continue

                user, token = line.split(":", 1)
                tokens[token] = user.lower()

    except Exception as e:
        print(f"[ERROR] Could not read token file: {e}")

    return tokens


# ------------------------------------------------------------
# Authentication
# ------------------------------------------------------------
def authenticate(token: str):
    if not token:
        raise HTTPException(
            status_code=403,
            detail="Missing authentication token"
        )

    tokens = load_tokens()

    viewer_lc = tokens.get(token)

    if not viewer_lc:
        raise HTTPException(
            status_code=403,
            detail="Invalid token"
        )

    return viewer_lc