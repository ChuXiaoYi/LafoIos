from __future__ import annotations

import logging
from datetime import UTC, date, datetime, timedelta
from typing import Annotated

from fastapi import Depends, FastAPI, Header, HTTPException, Query, status

from lafo_backend.domain import AmbientCountGenerator, PoopEntry, summarize_day
from lafo_backend.schemas import (
    AmbientCountResponse,
    AppleLoginRequest,
    AuthResponse,
    DailySummaryResponse,
    EntriesListResponse,
    EntryCreateRequest,
    EntryResponse,
    PhoneCodeRequest,
    PhoneVerifyRequest,
    SendCodeResponse,
    ShareCopyResponse,
    SharePreviewResponse,
    entry_response_from_domain,
)
from lafo_backend.storage import InMemoryStorage

logger = logging.getLogger("lafo_backend")


def create_app() -> FastAPI:
    app = FastAPI(title="Lafo Backend")
    storage = InMemoryStorage()
    app.state.storage = storage

    def current_user(authorization: Annotated[str | None, Header()] = None) -> str:
        if not authorization or not authorization.startswith("Bearer "):
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing session")
        token = authorization.removeprefix("Bearer ").strip()
        user_id = storage.user_for_session(token)
        if not user_id:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid session")
        return user_id

    @app.post("/auth/apple", response_model=AuthResponse)
    def apple_login(payload: AppleLoginRequest) -> AuthResponse:
        user_id = storage.user_for_identity("apple", payload.identity_token)
        token = storage.create_session(user_id)
        logger.info("Apple 登录成功 user_id=%s", user_id)
        return AuthResponse(user_id=user_id, session_token=token)

    @app.post("/auth/phone/send-code", response_model=SendCodeResponse)
    def send_phone_code(payload: PhoneCodeRequest) -> SendCodeResponse:
        storage.send_phone_code(payload.phone)
        logger.info("手机号验证码已发送 phone_hash_saved=true")
        return SendCodeResponse(sent=True, expires_in_seconds=300)

    @app.post("/auth/phone/verify", response_model=AuthResponse)
    def verify_phone_code(payload: PhoneVerifyRequest) -> AuthResponse:
        if not storage.verify_phone_code(payload.phone, payload.code):
            logger.warning("手机号验证码校验失败")
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid code")
        user_id = storage.user_for_identity("phone", payload.phone)
        token = storage.create_session(user_id)
        logger.info("手机号登录成功 user_id=%s", user_id)
        return AuthResponse(user_id=user_id, session_token=token)

    @app.post("/entries", response_model=EntryResponse, status_code=status.HTTP_201_CREATED)
    def create_entry(payload: EntryCreateRequest, user_id: str = Depends(current_user)) -> EntryResponse:
        stored = storage.add_entry(
            user_id=user_id,
            client_id=payload.client_id,
            entry=PoopEntry(
                id="pending",
                user_id=user_id,
                timestamp=payload.timestamp,
                status=payload.status,
                note=payload.note,
            ),
        )
        logger.info("打卡记录已保存 user_id=%s status=%s", user_id, payload.status.value)
        return entry_response_from_domain(stored.entry, stored.client_id)

    @app.get("/entries", response_model=EntriesListResponse)
    def list_entries(
        from_day: date = Query(alias="from"),
        to_day: date = Query(alias="to"),
        user_id: str = Depends(current_user),
    ) -> EntriesListResponse:
        stored_entries = storage.list_entries(user_id, from_day, to_day)
        domain_entries = [stored.entry for stored in stored_entries]
        summaries: list[DailySummaryResponse] = []
        cursor = from_day
        while cursor <= to_day:
            summaries.append(DailySummaryResponse.from_domain(summarize_day(cursor, domain_entries)))
            cursor += timedelta(days=1)
        return EntriesListResponse(
            entries=[
                entry_response_from_domain(stored.entry, stored.client_id)
                for stored in stored_entries
            ],
            summaries=summaries,
        )

    @app.get("/ambient-count", response_model=AmbientCountResponse)
    def ambient_count(at: datetime | None = None) -> AmbientCountResponse:
        moment = at or datetime.now(tz=UTC)
        count = AmbientCountGenerator(storage.ambient_config).count_at(moment)
        return AmbientCountResponse(
            count=count,
            generated_at=_format_utc(moment),
            ambient_copy=f"此刻也有 {count:,} 人也在拉屎",
            explanation="这是 Lafo 根据活跃趋势估算出来的陪伴数字。",
        )

    @app.get("/config/share-copy", response_model=ShareCopyResponse)
    def share_copy() -> ShareCopyResponse:
        return _share_copy()

    @app.get("/share/preview", response_model=SharePreviewResponse)
    def share_preview(
        day: date,
        at: datetime | None = None,
        user_id: str = Depends(current_user),
    ) -> SharePreviewResponse:
        stored_entries = storage.list_entries(user_id, day, day)
        summary = summarize_day(day, [stored.entry for stored in stored_entries])
        count_payload = ambient_count(at)
        copy = _share_copy()
        # 分享卡只暴露轻量状态，不带备注、精确时间、手机号或账号信息。
        return SharePreviewResponse(
            brand=copy.brand,
            emoji=copy.emoji,
            day=day,
            status=summary.display_status,
            title=_title_for_status(summary.display_status.value if summary.display_status else None),
            ambient_copy=count_payload.ambient_copy,
            footer=copy.footer,
        )

    return app


def _share_copy() -> ShareCopyResponse:
    return ShareCopyResponse(
        brand="Lafo",
        emoji="🚽💩",
        title="今天很认真地生活了",
        footer="今天拉了吗？",
        hidden_fields=["note", "exact_time", "phone", "account"],
    )


def _title_for_status(status_value: str | None) -> str:
    titles = {
        "smooth": "今天很顺，给自己一点掌声 😌",
        "hard": "今天有点难，但还是记录了 😬",
        "urgent": "急急的一天，也被 Lafo 接住了 💦",
        "none": "没拉也算认真记录 🫥",
    }
    return titles.get(status_value, "今天也有好好观察自己 🚽")


def _format_utc(moment: datetime) -> str:
    if moment.tzinfo is None:
        moment = moment.replace(tzinfo=UTC)
    return moment.astimezone(UTC).isoformat().replace("+00:00", "Z")
