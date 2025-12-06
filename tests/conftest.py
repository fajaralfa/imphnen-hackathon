import sys
from pathlib import Path

import pytest
from fastapi.testclient import TestClient
from unittest.mock import MagicMock

sys.path.append(str(Path(__file__).resolve().parent.parent))
from app import app, get_genai_client
from app import require_auth

# Mock the auth dependency
def mock_require_auth():
    return {"sub": 123}  # Mocked user info

@pytest.fixture
def client():
    # Override the dependency before creating TestClient
    app.dependency_overrides[require_auth] = mock_require_auth

    with TestClient(app) as c:
        yield c

    # Clean up overrides after test
    app.dependency_overrides = {}

@pytest.fixture(autouse=True)
def mock_genai_client():
    mock_client = MagicMock()
    mock_response = MagicMock()
    mock_response.text = "Mocked caption"
    mock_client.models.generate_content.return_value = mock_response

    app.dependency_overrides[get_genai_client] = lambda: mock_client
    yield
    app.dependency_overrides[get_genai_client] = None
