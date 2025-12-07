from typing import Any, Dict

import httpx
from jose import jwt, JWTError
from fastapi import HTTPException, Depends
from fastapi.security import HTTPAuthorizationCredentials
from fastapi.security import HTTPBearer

from services.config import config
from services.log import logger

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
        certs_res = await client.get(config.GOOGLE_CERT_URL)
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
            audience=config.GOOGLE_CLIENT_ID,
            issuer=config.GOOGLE_ISSUERS,
        )
        logger.info(f"Google ID token verified: sub={payload['sub']}")
        return payload

    except Exception as e:
        raise HTTPException(400, f"Invalid Google ID token: {str(e)}")


def require_auth(token: HTTPAuthorizationCredentials = Depends(auth_scheme)):
    try:
        decoded = jwt.decode(
            token.credentials, config.JWT_SECRET, algorithms=[config.JWT_ALGO]
        )
        logger.info(f"Authenticated user: {decoded['sub']}")
        return decoded
    except JWTError:
        logger.warning("Invalid or missing JWT")
        raise HTTPException(401, "Unauthorized")
