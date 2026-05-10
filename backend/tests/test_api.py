from datetime import UTC, datetime

from fastapi.testclient import TestClient

from lafo_backend.app import create_app


def auth_headers(token: str) -> dict[str, str]:
    return {"Authorization": f"Bearer {token}"}


def test_apple_login_returns_session_token() -> None:
    client = TestClient(create_app())

    response = client.post("/auth/apple", json={"identity_token": "apple-user-1"})

    assert response.status_code == 200
    payload = response.json()
    assert payload["user_id"].startswith("user_")
    assert payload["session_token"].startswith("lafo_session_")


def test_phone_code_verify_returns_session_token() -> None:
    client = TestClient(create_app())

    send_response = client.post("/auth/phone/send-code", json={"phone": "+8613800000000"})
    verify_response = client.post(
        "/auth/phone/verify",
        json={"phone": "+8613800000000", "code": "123456"},
    )

    assert send_response.status_code == 200
    assert send_response.json() == {"sent": True, "expires_in_seconds": 300}
    assert verify_response.status_code == 200
    assert verify_response.json()["session_token"].startswith("lafo_session_")


def test_creating_entry_requires_auth() -> None:
    client = TestClient(create_app())

    response = client.post(
        "/entries",
        json={
            "client_id": "client-entry-1",
            "timestamp": "2026-05-10T08:30:00Z",
            "status": "smooth",
            "note": "很顺",
        },
    )

    assert response.status_code == 401


def test_entries_can_be_created_and_listed_by_date_range() -> None:
    client = TestClient(create_app())
    token = client.post("/auth/apple", json={"identity_token": "apple-user-1"}).json()[
        "session_token"
    ]

    create_response = client.post(
        "/entries",
        headers=auth_headers(token),
        json={
            "client_id": "client-entry-1",
            "timestamp": "2026-05-10T08:30:00Z",
            "status": "smooth",
            "note": "很顺",
        },
    )
    list_response = client.get(
        "/entries?from=2026-05-10&to=2026-05-10",
        headers=auth_headers(token),
    )

    assert create_response.status_code == 201
    assert create_response.json()["status"] == "smooth"
    payload = list_response.json()
    assert len(payload["entries"]) == 1
    assert payload["entries"][0]["note"] == "很顺"
    assert payload["summaries"][0]["poop_count"] == 1
    assert payload["summaries"][0]["display_status"] == "smooth"


def test_ambient_count_returns_backend_generated_count_and_cute_copy() -> None:
    client = TestClient(create_app())

    response = client.get("/ambient-count?at=2026-05-10T08:31:12Z")

    assert response.status_code == 200
    payload = response.json()
    assert 12000 <= payload["count"] <= 26000
    assert payload["generated_at"] == "2026-05-10T08:31:12Z"
    assert "人也在拉屎" in payload["copy"]
    assert "估算" in payload["explanation"]


def test_share_config_uses_remote_copy_without_private_fields() -> None:
    client = TestClient(create_app())

    response = client.get("/config/share-copy")

    assert response.status_code == 200
    payload = response.json()
    assert payload["brand"] == "Lafo"
    assert payload["emoji"] == "🚽💩"
    assert "今天拉了吗" in payload["footer"]
    assert payload["hidden_fields"] == ["note", "exact_time", "phone", "account"]


def test_share_preview_does_not_expose_note_or_exact_time() -> None:
    client = TestClient(create_app())
    token = client.post("/auth/apple", json={"identity_token": "apple-user-1"}).json()[
        "session_token"
    ]
    client.post(
        "/entries",
        headers=auth_headers(token),
        json={
            "client_id": "client-entry-1",
            "timestamp": "2026-05-10T08:30:00Z",
            "status": "smooth",
            "note": "这句不应该出现在分享卡",
        },
    )

    response = client.get(
        "/share/preview?day=2026-05-10&at=2026-05-10T08:31:12Z",
        headers=auth_headers(token),
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["status"] == "smooth"
    assert "这句不应该" not in str(payload)
    assert "08:30" not in str(payload)
    assert "此刻也有" in payload["ambient_copy"]
