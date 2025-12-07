from unittest.mock import patch


# valid image upload
def test_caption_single_image(client):
    with open("tests/images/sample.png", "rb") as f:
        response = client.post(
            "/api/v1/caption/generate",
            files={"images": ("sample.png", f, "image/png")},
            data={"context": "promosi"},
        )

    assert response.status_code == 200
    assert "caption" in response.json()


# unsupported file type
def test_invalid_mime_type(client):
    response = client.post(
        "/api/v1/caption/generate",
        files={"images": ("test.txt", b"hello", "text/plain")},
    )

    assert response.status_code == 415
    assert "Unsupported file type" in response.json()["detail"]


# oversized file (mock length)
def test_oversized_image(client):
    big_file = b"a" * (11 * 1024 * 1024)  # 11MB

    with patch("services.gencaption.UploadFile.read", return_value=big_file):
        response = client.post(
            "/api/v1/caption/generate",
            files={"images": ("big.jpg", big_file, "image/jpeg")},
        )

    assert response.status_code == 413


# mock GenAI API
def test_caption_genai_mock(client):
    with open("tests/images/sample.png", "rb") as f:
        response = client.post(
            "/api/v1/caption/generate", files={"images": ("sample.png", f, "image/png")}
        )

    assert response.status_code == 200
    assert response.json()["caption"] == "Mocked caption"


# mock google ID token verification
def test_google_login(client):
    fake_payload = {"sub": "123", "email": "abc@test.com"}

    with patch("app.verify_google_id_token", return_value=fake_payload):
        res = client.post("/api/auth/mobile/google", json={"id_token": "fake-token"})

        assert res.status_code == 200
        assert "access_token" in res.json()
