# Lafo MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first working Lafo project inside `/Users/chuxiaoyi/Documents/vibeCoding/Lafo`, with a tested backend API and an iOS SwiftUI source scaffold for the confirmed MVP.

**Architecture:** Use a Python FastAPI backend for login stubs, poop entry sync, ambient count, and share copy config. Use a SwiftUI iOS source scaffold that mirrors the product flow: login, home, check-in, success, share card. Keep persistence replaceable: in-memory backend storage for the first scaffold, local iOS state for UI wiring, and clear seams for database and real auth providers.

**Tech Stack:** Python 3.14, FastAPI, Pydantic, pytest, SwiftUI.

---

## File Structure

- `pyproject.toml`: backend dependency and test configuration.
- `README.md`: project entrypoint, run/test instructions, known local limitations.
- `backend/lafo_backend/domain.py`: status enum, entry model, daily summary logic, ambient count generator.
- `backend/lafo_backend/storage.py`: in-memory users, sessions, entries, config storage.
- `backend/lafo_backend/schemas.py`: request/response schemas.
- `backend/lafo_backend/app.py`: FastAPI routes and Chinese operational logs.
- `backend/tests/test_domain.py`: TDD coverage for trend and ambient rules.
- `backend/tests/test_api.py`: TDD coverage for login, entries, sync, ambient count, config.
- `ios/LafoApp/LafoApp.swift`: SwiftUI app entry.
- `ios/LafoApp/Models.swift`: client-side models matching backend concepts.
- `ios/LafoApp/LafoStore.swift`: observable state for login, check-in, summaries, ambient count.
- `ios/LafoApp/ContentView.swift`: login and main navigation.
- `ios/LafoApp/HomeView.swift`: today summary and trend calendar.
- `ios/LafoApp/CheckInView.swift`: emoji check-in flow.
- `ios/LafoApp/ShareCardView.swift`: share-card UI source view.
- `ios/README.md`: how to create/open an Xcode project from the scaffold.

## Task 1: Backend Project Scaffold

**Files:**
- Create: `pyproject.toml`
- Create: `README.md`
- Create: `backend/lafo_backend/__init__.py`
- Create: `backend/tests/__init__.py`

- [ ] **Step 1: Write project metadata and dependencies**

Create `pyproject.toml` with FastAPI, pytest, and httpx so API tests can use FastAPI's TestClient.

- [ ] **Step 2: Add project README**

Document how to run `uv sync`, `uv run pytest`, and `uv run uvicorn lafo_backend.app:create_app --factory --reload`.

- [ ] **Step 3: Run dependency sync**

Run: `uv sync`
Expected: dependencies install successfully.

## Task 2: Domain Rules with TDD

**Files:**
- Create: `backend/tests/test_domain.py`
- Create: `backend/lafo_backend/domain.py`

- [ ] **Step 1: Write failing tests for daily summary**

Tests must prove:
- multiple same-day poop entries count correctly;
- `none` does not count as poop;
- unrecorded and explicit none are distinguishable;
- latest poop status wins the day display.

- [ ] **Step 2: Run domain tests and verify RED**

Run: `uv run pytest backend/tests/test_domain.py -q`
Expected: failure because `lafo_backend.domain` does not exist.

- [ ] **Step 3: Implement domain model**

Implement `PoopStatus`, `PoopEntry`, `DailySummary`, `summarize_day`, `summarize_month`, and `AmbientCountGenerator`.

- [ ] **Step 4: Run domain tests and verify GREEN**

Run: `uv run pytest backend/tests/test_domain.py -q`
Expected: all domain tests pass.

## Task 3: Backend API with TDD

**Files:**
- Create: `backend/tests/test_api.py`
- Create: `backend/lafo_backend/schemas.py`
- Create: `backend/lafo_backend/storage.py`
- Create: `backend/lafo_backend/app.py`

- [ ] **Step 1: Write failing API tests**

Tests must prove:
- Apple login returns a session token;
- phone code verify returns a session token;
- creating entries requires auth;
- entries can be created and listed by date range;
- ambient count returns backend-generated count and cute copy;
- share config returns remote copy;
- share defaults do not expose note or exact time.

- [ ] **Step 2: Run API tests and verify RED**

Run: `uv run pytest backend/tests/test_api.py -q`
Expected: failure because API modules or endpoints do not exist.

- [ ] **Step 3: Implement storage, schemas, and app routes**

Use in-memory storage for the scaffold. Add Chinese logs for auth, entry creation, sync, and ambient fallback paths. Do not log phone numbers, notes, tokens, or verification codes.

- [ ] **Step 4: Run API tests and verify GREEN**

Run: `uv run pytest backend/tests/test_api.py -q`
Expected: all API tests pass.

## Task 4: iOS SwiftUI Source Scaffold

**Files:**
- Create: `ios/LafoApp/LafoApp.swift`
- Create: `ios/LafoApp/Models.swift`
- Create: `ios/LafoApp/LafoStore.swift`
- Create: `ios/LafoApp/ContentView.swift`
- Create: `ios/LafoApp/HomeView.swift`
- Create: `ios/LafoApp/CheckInView.swift`
- Create: `ios/LafoApp/ShareCardView.swift`
- Create: `ios/README.md`

- [ ] **Step 1: Add Swift models**

Create status, entry, summary, and auth state models aligned with backend naming.

- [ ] **Step 2: Add observable store**

Implement in-memory login, check-in, daily summaries, ambient count, and share card state. Include Chinese comments for `none` vs unrecorded and ambient count semantics.

- [ ] **Step 3: Add SwiftUI views**

Implement login screen, home screen, check-in sheet, success feedback, and share-card source view with cute copy and `🚽💩` brand expression.

- [ ] **Step 4: Add iOS README**

Document that Xcode project generation/build requires accepting the local Xcode license first.

## Task 5: Verification and Handoff

**Files:**
- Verify all created files.

- [ ] **Step 1: Run backend test suite**

Run: `uv run pytest -q`
Expected: all backend tests pass.

- [ ] **Step 2: Check Python import path**

Run: `uv run python -c "from lafo_backend.app import create_app; app = create_app(); print(app.title)"`
Expected: prints `Lafo Backend`.

- [ ] **Step 3: Attempt iOS toolchain verification**

Run: `xcodebuild -version`
Expected in current environment: blocked until Xcode license is accepted.

- [ ] **Step 4: Report verification honestly**

Report backend test evidence, import evidence, and iOS build limitation.

## Self-Review

Spec coverage:
- Login: covered by API tests and iOS login scaffold.
- Backend: covered by FastAPI routes and tests.
- Entries: covered by domain and API tests.
- Ambient count: covered by generator and API tests.
- Cute copy: covered by share config and UI source.
- No social/medical scope: preserved by no social routes and no diagnostic code.

Known limitation:
- The iOS scaffold is source-level until a local Xcode project can be generated and built after the Xcode license is accepted.
