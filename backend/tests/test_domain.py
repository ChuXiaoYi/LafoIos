from datetime import UTC, date, datetime

from lafo_backend.domain import (
    AmbientCountConfig,
    AmbientCountGenerator,
    PoopEntry,
    PoopStatus,
    summarize_day,
    summarize_month,
)


def test_summarize_day_counts_only_real_poop_entries() -> None:
    target_day = date(2026, 5, 10)
    entries = [
        PoopEntry(
            id="entry-1",
            user_id="user-1",
            timestamp=datetime(2026, 5, 10, 8, 0, tzinfo=UTC),
            status=PoopStatus.SMOOTH,
            note=None,
        ),
        PoopEntry(
            id="entry-2",
            user_id="user-1",
            timestamp=datetime(2026, 5, 10, 20, 0, tzinfo=UTC),
            status=PoopStatus.HARD,
            note="有点费劲",
        ),
        PoopEntry(
            id="entry-3",
            user_id="user-1",
            timestamp=datetime(2026, 5, 10, 21, 0, tzinfo=UTC),
            status=PoopStatus.NONE,
            note=None,
        ),
    ]

    summary = summarize_day(target_day, entries)

    assert summary.day == target_day
    assert summary.poop_count == 2
    assert summary.display_status == PoopStatus.HARD
    assert summary.has_explicit_none is True
    assert summary.is_unrecorded is False


def test_summarize_day_distinguishes_unrecorded_from_explicit_none() -> None:
    target_day = date(2026, 5, 10)

    unrecorded = summarize_day(target_day, [])
    explicit_none = summarize_day(
        target_day,
        [
            PoopEntry(
                id="entry-1",
                user_id="user-1",
                timestamp=datetime(2026, 5, 10, 23, 0, tzinfo=UTC),
                status=PoopStatus.NONE,
                note=None,
            )
        ],
    )

    assert unrecorded.is_unrecorded is True
    assert unrecorded.display_status is None
    assert explicit_none.is_unrecorded is False
    assert explicit_none.poop_count == 0
    assert explicit_none.display_status == PoopStatus.NONE


def test_summarize_month_includes_every_day_in_range() -> None:
    summaries = summarize_month(
        month=date(2026, 5, 1),
        entries=[
            PoopEntry(
                id="entry-1",
                user_id="user-1",
                timestamp=datetime(2026, 5, 2, 9, 30, tzinfo=UTC),
                status=PoopStatus.URGENT,
                note=None,
            )
        ],
    )

    assert len(summaries) == 31
    assert summaries[0].day == date(2026, 5, 1)
    assert summaries[0].is_unrecorded is True
    assert summaries[1].day == date(2026, 5, 2)
    assert summaries[1].display_status == PoopStatus.URGENT


def test_ambient_count_stays_in_configured_range_and_is_stable_per_minute() -> None:
    config = AmbientCountConfig(
        base_count=18000,
        min_count=12000,
        max_count=26000,
        jitter_range=500,
        hourly_curve={8: 1.1},
    )
    generator = AmbientCountGenerator(config)
    moment = datetime(2026, 5, 10, 8, 31, 12, tzinfo=UTC)

    first = generator.count_at(moment)
    second = generator.count_at(moment.replace(second=50))

    assert 12000 <= first <= 26000
    assert first == second
