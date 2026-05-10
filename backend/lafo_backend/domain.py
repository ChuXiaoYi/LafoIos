from __future__ import annotations

from calendar import monthrange
from dataclasses import dataclass
from datetime import date, datetime, timedelta
from enum import StrEnum
from random import Random


class PoopStatus(StrEnum):
    SMOOTH = "smooth"
    HARD = "hard"
    URGENT = "urgent"
    NONE = "none"

    @property
    def is_poop(self) -> bool:
        return self is not PoopStatus.NONE


@dataclass(frozen=True)
class PoopEntry:
    id: str
    user_id: str
    timestamp: datetime
    status: PoopStatus
    note: str | None


@dataclass(frozen=True)
class DailySummary:
    day: date
    poop_count: int
    display_status: PoopStatus | None
    has_explicit_none: bool
    is_unrecorded: bool


@dataclass(frozen=True)
class AmbientCountConfig:
    base_count: int
    min_count: int
    max_count: int
    jitter_range: int
    hourly_curve: dict[int, float]


class AmbientCountGenerator:
    def __init__(self, config: AmbientCountConfig) -> None:
        self.config = config

    def count_at(self, moment: datetime) -> int:
        hour_multiplier = self.config.hourly_curve.get(moment.hour, 1.0)
        minute_bucket = moment.replace(second=0, microsecond=0)
        seed = int(minute_bucket.timestamp()) + self.config.base_count
        jitter = Random(seed).randint(-self.config.jitter_range, self.config.jitter_range)
        raw_count = round(self.config.base_count * hour_multiplier) + jitter
        return max(self.config.min_count, min(self.config.max_count, raw_count))


def summarize_day(day: date, entries: list[PoopEntry]) -> DailySummary:
    day_entries = sorted(
        [entry for entry in entries if entry.timestamp.date() == day],
        key=lambda entry: entry.timestamp,
    )
    if not day_entries:
        return DailySummary(
            day=day,
            poop_count=0,
            display_status=None,
            has_explicit_none=False,
            is_unrecorded=True,
        )

    poop_entries = [entry for entry in day_entries if entry.status.is_poop]
    explicit_none = any(entry.status is PoopStatus.NONE for entry in day_entries)

    # “没拉”是主动记录，不等于空白未记录；但它不计入排便次数。
    if poop_entries:
        display_status: PoopStatus | None = poop_entries[-1].status
    else:
        display_status = PoopStatus.NONE

    return DailySummary(
        day=day,
        poop_count=len(poop_entries),
        display_status=display_status,
        has_explicit_none=explicit_none,
        is_unrecorded=False,
    )


def summarize_month(month: date, entries: list[PoopEntry]) -> list[DailySummary]:
    days_in_month = monthrange(month.year, month.month)[1]
    first_day = date(month.year, month.month, 1)
    return [
        summarize_day(first_day + timedelta(days=offset), entries)
        for offset in range(days_in_month)
    ]
