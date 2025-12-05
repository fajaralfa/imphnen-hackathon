from typing import List
import uuid

from dotenv import load_dotenv
load_dotenv()

from fastapi import Body, FastAPI, UploadFile, File, Form, Depends
from datetime import datetime, timedelta, timezone
from jose import jwt

from auth import verify_google_id_token, JWT_SECRET, JWT_ALGO, JWT_EXP_MINUTES, require_auth
from gencaption import validate_image, generate_multi
from log import logger

app = FastAPI()

@app.middleware("http")
async def log_requests(request, call_next):
    request_id = str(uuid.uuid4())
    logger.info(f"[{request_id}] Incoming: {request.method} {request.url.path}")
    response = await call_next(request)
    logger.info(f"[{request_id}] Completed: {request.method} {request.url.path} -> {response.status_code}")
    return response

@app.post("/api/v1/caption/generate")
async def caption_generate(
    user=Depends(require_auth),
    images: List[UploadFile] = File(...),
    context: str | None = Form(None)
):
    logger.info(f"Caption request received: {len(images)} images")
    pil_images = []

    for image in images:
        pil_image = await validate_image(image)
        pil_images.append(pil_image)

    caption = await generate_multi(pil_images, context)
    logger.info("Caption returned to client")
    return {"caption": caption}


@app.post("/api/auth/mobile/google")
async def mobile_google_login(id_token: str = Body(..., embed=True)):
    logger.info("Login request from mobile client")
    # Verify token from Google SDK
    payload = await verify_google_id_token(id_token)

    google_sub = payload["sub"]
    email = payload.get("email")

    exp = datetime.now(timezone.utc) + timedelta(minutes=JWT_EXP_MINUTES)
    access_token = jwt.encode(
        {
            "sub": google_sub,
            "email": email,
            "exp": exp
        },
        JWT_SECRET,
        algorithm=JWT_ALGO,
    )
    logger.info(f"Issued JWT for user: {google_sub}")

    return {"access_token": access_token}

