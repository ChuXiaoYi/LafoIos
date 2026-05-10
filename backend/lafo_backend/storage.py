from __future__ import annotations

from dataclasses import dataclass
from datetime import date
from hashlib import sha256

from lafo_backend.domain import AmbientCountConfig, PoopEntry


@dataclass(frozen=True)
class StoredEntry:
    client_id: str
    entry: PoopEntry


class InMemoryStorage:
    def __init__(self) -> None:
        self._identity_to_user: dict[tuple[str, str], str] = {}
        self._sessions: dict[str, str] = {}
        self._phone_codes: dict[str, str] = {}
        self._entries: dict[str, list[StoredEntry]] = {}
        self._user_counter = 0
        self._session_counter = 0
        self._entry_counter = 0
        self.ambient_config = AmbientCountConfig(
            base_count=18000,
            min_count=12000,
            max_count=26000,
            jitter_range=500,
            hourly_curve={7: 0.9, 8: 1.1, 9: 1.05, 13: 0.95, 22: 1.0},
        )

    def user_for_identity(self, provider: str, subject: str) -> str:
        key = (provider, self._hash(subject))
        if key not in self._identity_to_user:
            self._user_counter += 1
            self._identity_to_user[key] = f"user_{self._user_counter}"
        return self._identity_to_user[key]

    def create_session(self, user_id: str) -> str:
        self._session_counter += 1
        token = f"lafo_session_{self._session_counter}"
        self._sessions[token] = user_id
        return token

    def user_for_session(self, token: str) -> str | None:
        return self._sessions.get(token)

    def send_phone_code(self, phone: str) -> None:
        self._phone_codes[self._hash(phone)] = "123456"

    def verify_phone_code(self, phone: str, code: str) -> bool:
        return self._phone_codes.get(self._hash(phone)) == code

    def add_entry(self, user_id: str, client_id: str, entry: PoopEntry) -> StoredEntry:
        self._entry_counter += 1
        stored = StoredEntry(
            client_id=client_id,
            entry=PoopEntry(
                id=f"entry_{self._entry_counter}",
                user_id=user_id,
                timestamp=entry.timestamp,
                status=entry.status,
                note=entry.note,
            ),
        )
        self._entries.setdefault(user_id, []).append(stored)
        return stored

    def list_entries(self, user_id: str, from_day: date, to_day: date) -> list[StoredEntry]:
        return [
            stored
            for stored in self._entries.get(user_id, [])
            if from_day <= stored.entry.timestamp.date() <= to_day
        ]

    def _hash(self, value: str) -> str:
        return sha256(value.encode("utf-8")).hexdigest()
