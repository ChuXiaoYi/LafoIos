from __future__ import annotations

from datetime import date, datetime

from pydantic import BaseModel, Field

from lafo_backend.domain import DailySummary, PoopEntry, PoopStatus


class AppleLoginRequest(BaseModel):
    identity_token: str = Field(min_length=1)


class PhoneCodeRequest(BaseModel):
    phone: str = Field(min_length=4)


class PhoneVerifyRequest(BaseModel):
    phone: str = Field(min_length=4)
    code: str = Field(min_length=4)


class AuthResponse(BaseModel):
    user_id: str
    session_token: str


class SendCodeResponse(BaseModel):
    sent: bool
    expires_in_seconds: int


class EntryCreateRequest(BaseModel):
    client_id: str = Field(min_length=1)
    timestamp: datetime
    status: PoopStatus
    note: str | None = Field(default=None, max_length=120)


class EntryResponse(BaseModel):
    id: str
    client_id: str
    user_id: str
    timestamp: datetime
    status: PoopStatus
    note: str | None


class DailySummaryResponse(BaseModel):
    day: date
    poop_count: int
    display_status: PoopStatus | None
    has_explicit_none: bool
    is_unrecorded: bool

    @classmethod
    def from_domain(cls, summary: DailySummary) -> DailySummaryResponse:
        return cls(
            day=summary.day,
            poop_count=summary.poop_count,
            display_status=summary.display_status,
            has_explicit_none=summary.has_explicit_none,
            is_unrecorded=summary.is_unrecorded,
        )


class EntriesListResponse(BaseModel):
    entries: list[EntryResponse]
    summaries: list[DailySummaryResponse]


class AmbientCountResponse(BaseModel):
    count: int
    generated_at: str
    ambient_copy: str = Field(serialization_alias="copy")
    explanation: str


class ShareCopyResponse(BaseModel):
    brand: str
    emoji: str
    title: str
    footer: str
    hidden_fields: list[str]


class SharePreviewResponse(BaseModel):
    brand: str
    emoji: str
    day: date
    status: PoopStatus | None
    title: str
    ambient_copy: str
    footer: str


def entry_response_from_domain(entry: PoopEntry, client_id: str) -> EntryResponse:
    return EntryResponse(
        id=entry.id,
        client_id=client_id,
        user_id=entry.user_id,
        timestamp=entry.timestamp,
        status=entry.status,
        note=entry.note,
    )
