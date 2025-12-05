from io import BytesIO
from typing import List

from PIL import Image, UnidentifiedImageError
from fastapi import  UploadFile, HTTPException, status
from google import genai

from log import logger

client = genai.Client()

ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp"}
MAX_IMAGE_SIZE_MB = 10


async def validate_image(upload: UploadFile) -> Image.Image:
    logger.info(f"Validating image: {upload.filename}, type={upload.content_type}")
    # Validate content type
    if upload.content_type not in ALLOWED_IMAGE_TYPES:
        logger.warning(f"Rejected image type: {upload.content_type}")
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail=f"Unsupported file type: {upload.content_type}. "
                   f"Allowed types: {', '.join(ALLOWED_IMAGE_TYPES)}"
        )

    # Validate file size
    image_bytes = await upload.read()
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

    logger.info(f"Image {upload.filename} validated successfully")
    return pil_image


async def generate_multi(images: List[Image.Image], additional_context: str | None = None):
    """
    Pass multiple images to Google GenAI and generate one combined caption.
    """
    logger.info(f"Generating caption for {len(images)} images")
    prompt = f"Buatlah satu caption yang sangat menarik dan manusiawi untuk mempromosikan produk ini. Buat saja teks captionnya, jangan berikan teks lain. {additional_context or ''}"
    
    # GenAI accepts multiple contents
    contents = [prompt] + images
    logger.info("Sending request to GenAI")
    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=contents
    )
    logger.info("Caption generated successfully")

    return response.text

