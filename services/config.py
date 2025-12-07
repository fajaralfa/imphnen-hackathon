from pydantic_settings import BaseSettings
from dotenv import load_dotenv

load_dotenv()

class Config(BaseSettings):
    JWT_SECRET: str
    JWT_ALGO: str = "HS256"
    JWT_EXP_MINUTES: int = 60 * 24 * 30  # 30 days token
    GOOGLE_CLIENT_ID: str
    GOOGLE_CERT_URL: str = "https://www.googleapis.com/oauth2/v3/certs"
    GOOGLE_ISSUERS: list = [
            "https://accounts.google.com",
            "accounts.google.com"
        ]
    GEMINI_API_KEY: str
    ALLOWED_IMAGE_TYPES: list = {"image/jpeg", "image/png", "image/webp"}
    MAX_IMAGE_SIZE_MB: int = 10

config = Config()