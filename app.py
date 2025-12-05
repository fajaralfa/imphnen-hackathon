from fastapi import FastAPI, UploadFile, File, Form, HTTPException, status
from PIL import Image, UnidentifiedImageError
from io import BytesIO
from starlette.middleware.sessions import SessionMiddleware
import gradio as gr
from google import genai
from dotenv import load_dotenv
from os import getenv

load_dotenv()

app = FastAPI()
client = genai.Client()
secret_key = getenv("SECRET_KEY")
assert secret_key != None

app.add_middleware(SessionMiddleware, secret_key=secret_key)

def generate_caption(img, additional_context):
    prompt = f"Buatlah satu caption yang sangat menarik dan manusiawi untuk mempromosikan produk ini. Buat saja teks captionnya, jangan berikan teks lain. {additional_context}"
    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=[prompt, img],
    )
    return response.text


ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp"}
MAX_IMAGE_SIZE_MB = 10  # adjust for your use-case


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
        pil_image.verify()         # Validate integrity
        pil_image = Image.open(BytesIO(image_bytes))  # Reopen after verify()
    except UnidentifiedImageError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Uploaded file is not a valid image.",
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Error reading image: {str(e)}"
        )

    return pil_image


@app.post("/api/v1/caption/generate")
async def caption_generate(
    image: UploadFile = File(...),
    context: str | None = Form(None)
):
    # Read image bytes
    image_bytes = await image.read()

    # Validate image and produce a safe PIL object
    image_pil = validate_image(image, image_bytes)

    # Pass to your model
    caption = generate_caption(image_pil, context)

    return {"caption": caption}


with gr.Blocks() as gr_io:
    gr.Markdown("## Caption Generator")

    with gr.Column():    # <-- This ensures vertical stacking
        img_input = gr.Image(type="pil", label="Upload Image", height="500px")
        caption_output = gr.TextArea(label="✨ Caption")

        generate_btn = gr.Button("Generate Caption")

        # When button is clicked, call the function
        generate_btn.click(fn=generate_caption, inputs=img_input, outputs=caption_output, show_progress="full")

# Mount Gradio on FastAPI
app = gr.mount_gradio_app(app, gr_io, path="/")

