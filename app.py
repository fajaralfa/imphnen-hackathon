from fastapi import FastAPI, UploadFile, File, Form, HTTPException, status
from PIL import Image, UnidentifiedImageError
from io import BytesIO
from starlette.middleware.sessions import SessionMiddleware
from google import genai
from dotenv import load_dotenv
from os import getenv
from typing import List

load_dotenv()

app = FastAPI()
client = genai.Client()
secret_key = getenv("SECRET_KEY")
assert secret_key is not None

app.add_middleware(SessionMiddleware, secret_key=secret_key)

ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp"}
MAX_IMAGE_SIZE_MB = 10


def validate_image(upload: UploadFile, image_bytes: bytes) -> Image.Image:
    # Validate content type
    if upload.content_type not in ALLOWED_IMAGE_TYPES:
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail=f"Unsupported file type: {upload.content_type}. "
                   f"Allowed types: {', '.join(ALLOWED_IMAGE_TYPES)}"
        )

    # Validate file size
    size_mb = len(image_bytes) / (1024 * 1024)
    if size_mb > MAX_IMAGE_SIZE_MB:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail=f"Image too large ({size_mb:.2f}MB). Max size is {MAX_IMAGE_SIZE_MB}MB."
        )

    # Validate PIL image parsing
    try:
        pil_image = Image.open(BytesIO(image_bytes))
        pil_image.verify()
        pil_image = Image.open(BytesIO(image_bytes))
    except UnidentifiedImageError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Uploaded file '{upload.filename}' is not a valid image.",
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Error reading image '{upload.filename}': {str(e)}"
        )

    return pil_image


def generate_caption_multi(images: List[Image.Image], additional_context: str | None = None):
    """
    Pass multiple images to Google GenAI and generate one combined caption.
    """
    prompt = f"Buatlah satu caption yang sangat menarik dan manusiawi untuk mempromosikan produk ini. Buat saja teks captionnya, jangan berikan teks lain. {additional_context or ''}"
    
    # Convert PIL images to bytes
    img_bytes_list = []
    for img in images:
        buf = BytesIO()
        img.save(buf, format="PNG")
        img_bytes_list.append(buf.getvalue())

    # GenAI accepts multiple contents
    contents = [prompt] + images
    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=contents
    )

    return response.text


@app.post("/api/v1/caption/generate")
async def caption_generate(
    images: List[UploadFile] = File(...),
    context: str | None = Form(None)
):
    pil_images = []

    for image in images:
        image_bytes = await image.read()
        pil_image = validate_image(image, image_bytes)
        pil_images.append(pil_image)

    caption = generate_caption_multi(pil_images, context)
    return {"caption": caption}


