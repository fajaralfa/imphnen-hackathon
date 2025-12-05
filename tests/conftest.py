import pytest
from fastapi.testclient import TestClient
import sys
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent.parent))
from app import app
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
