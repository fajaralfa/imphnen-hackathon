# UMKMCaptGen

## Installation

### Requirements:
- Python 3.10
- Google AI Studio API Key

### Installation step

```bash
# Clone this repository
git clone https://github.com/fajaralfa/imphnen-hackathon

# Move to cloned repository
cd imphnen-hackathon

# Create virtual environment
python3 -m venv .penv

# Activate virtual environment
source .penv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Copy .env.example to .env
cp .env.example .env

# Fill the environment variable below:
# GEMINI_API_KEY=your-gemini-api-key
# SECRET KEY=random-long-string

# Run dev server
fastapi dev app.py

```
