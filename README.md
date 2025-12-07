# CAPTIONIZE

## Development

### Requirements

- Pixi 0.60.0 (later version are not tested, but should be work)
- Google AI Studio API Key

### Steps

```bash

# 1. Install pixi (cross-platform)
curl -fsSL https://pixi.sh/install.sh | sh

# 2. Clone this repository
git clone https://github.com/fajaralfa/imphnen-hackathon

# 3. Move to the repository
cd imphnen-hackathon

# 4. Create the development environment
# Installs Python and all project dependencies in an isolated, reproducible environment
pixi install

# 5. Copy environment template
cp .env.example .env

# 6. Fill in your environment variables in .env
# Example values:
# GEMINI_API_KEY=your-gemini-api-key
# GOOGLE_CLIENT_ID=your-google-client-id
# SECRET_KEY=random-long-string
# JWT_SECRET=random-long-string

# 7. Run the development server
# Note: This is for development only. For production, use uvicorn/gunicorn under systemd or Docker.
pixi run uvicorn app:app --reload

# 8. Add the pre-commit formatter & linter hook
git config core.hooksPath git-hooks/

```
