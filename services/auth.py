from os import getenv
from typing import Any, Dict

import httpx
from jose import jwt
from fastapi import HTTPException, Depends
from fastapi.security import HTTPAuthorizationCredentials
from fastapi.security import HTTPBearer

from services.log import logger

JWT_SECRET = getenv("JWT_SECRET"); assert JWT_SECRET is not None
JWT_ALGO = "HS256"
JWT_EXP_MINUTES = 60 * 24 * 30  # 30 days token
GOOGLE_CLIENT_ID = getenv("GOOGLE_CLIENT_ID"); assert GOOGLE_CLIENT_ID is not None
GOOGLE_CERTS_URL = "https://www.googleapis.com/oauth2/v3/certs"
GOOGLE_ISSUERS = [
    "https://accounts.google.com",
    "accounts.google.com"
]

auth_scheme = HTTPBearer()

async def verify_google_id_token(id_token: str) -> Dict[str, Any]:
    """
    Verifies the ID token issued by Google Sign-In SDK (Android/iOS).
    Returns the decoded payload if valid.
    Raises HTTPException if invalid.
    """

    logger.info("Verifying Google ID token")
    # STEP 1 — Get Google public keys
    async with httpx.AsyncClient() as client:
        certs_res = await client.get(GOOGLE_CERTS_URL)
        certs_res.raise_for_status()
        certs = certs_res.json()["keys"]
        logger.info("Google certs fetched")

    # STEP 2 — Decode header to find the matching key
    unverified_header = jwt.get_unverified_header(id_token)
    kid = unverified_header.get("kid")

    key = next((c for c in certs if c["kid"] == kid), None)
    if key is None:
        raise HTTPException(400, "Invalid Google ID token: no matching key")

    # STEP 3 — Verify token signature and claims
    try:
        payload = jwt.decode(
            id_token,
            key,
            algorithms=["RS256"],
            audience=GOOGLE_CLIENT_ID,
            issuer=GOOGLE_ISSUERS,
        )
        logger.info(f"Google ID token verified: sub={payload['sub']}")
        return payload

    except Exception as e:
        raise HTTPException(400, f"Invalid Google ID token: {str(e)}")


def require_auth(token: HTTPAuthorizationCredentials = Depends(auth_scheme)):
    try:
        decoded = jwt.decode(token.credentials, JWT_SECRET, algorithms=[JWT_ALGO])
        logger.info(f"Authenticated user: {decoded['sub']}")
        return decoded
    except:
        logger.warning("Invalid or missing JWT")
        raise HTTPException(401, "Unauthorized")

