# Lafo Local MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the existing Lafo iOS scaffold into a local-first SwiftUI MVP that matches `docs/lafo-mvp-local-prd.md`.

**Architecture:** Keep the existing single-target SwiftUI project and remove the login-gated product path from the app UX. Use `LafoStore` as the local application state boundary with JSON persistence in Application Support, derived statistics computed in memory, and SwiftUI views for Today, Calendar, Stats, Buddy, and Settings.

**Tech Stack:** SwiftUI, Foundation JSON persistence, UserNotifications, XCTest-compatible pure Swift logic where practical, Xcode build verification.

---

## File Structure

- `ios/LafoApp/Models.swift`: local MVP enums and records: `PoopRecord`, `PoopType`, `MoodType`, `PainLevel`, `UserSettings`, derived stat structs.
- `ios/LafoApp/LafoStore.swift`: local persistence, CRUD, statistics, reminder state, CSV export data generation, privacy acceptance, clear data.
- `ios/LafoApp/ContentView.swift`: onboarding gate and five-tab shell.
- `ios/LafoApp/HomeView.swift`: Today tab and quick record entry point.
- `ios/LafoApp/RecordView.swift`: record create/edit form.
- `ios/LafoApp/CalendarView.swift`: month calendar, day detail, edit/delete.
- `ios/LafoApp/StatsView.swift`: weekly/monthly statistics.
- `ios/LafoApp/BuddyView.swift`: pet progress, streak copy, unlocked states.
- `ios/LafoApp/SettingsView.swift`: reminders, export, privacy, disclaimer, clear data.
- `ios/LafoApp/LafoTheme.swift`: shared colors and button styles.
- `ios/README.md`: updated local MVP run and scope notes.
- `docs/lafo-mvp-operations.md`: launch, privacy, support, feedback, and metrics plan.
- `ios/Lafo.xcodeproj/project.pbxproj`: add new Swift files to the app target.

## Task 1: Product And Scope Alignment

**Files:**
- Modify: `README.md`
- Modify: `ios/README.md`

- [ ] **Step 1: Update project scope docs**

Replace old login/backend-first wording with a clear statement that the iOS MVP is local-first and does not require login or server sync.

- [ ] **Step 2: Verify scope language**

Run: `rg "登录|后端同步|手机号|Apple 登录|同拉人数" README.md ios/README.md docs/lafo-mvp-local-prd.md`

Expected: old login/backend wording appears only as non-goals or legacy notes, not as MVP required behavior.

## Task 2: Local Domain Model And Store

**Files:**
- Modify: `ios/LafoApp/Models.swift`
- Modify: `ios/LafoApp/LafoStore.swift`

- [ ] **Step 1: Define local data model**

Replace old check-in model with PRD-aligned fields: `id`, `createdAt`, `poopTime`, `poopType`, `mood`, `painLevel`, `note`, `updatedAt`.

- [ ] **Step 2: Implement local persistence**

Store records and settings as JSON in Application Support. If loading fails, keep the app usable with empty data and default settings.

- [ ] **Step 3: Implement CRUD and derived stats**

Add create, update, delete, day filtering, month summaries, week count, average, streak, common status, common time bucket, and month recorded days.

- [ ] **Step 4: Verify by build**

Run: `xcodebuild -project ios/Lafo.xcodeproj -scheme Lafo -destination generic/platform=iOS build`

Expected: build succeeds or reports environment-only simulator/cache limitations that do not come from Swift compile errors.

## Task 3: Core App Shell And Record Flow

**Files:**
- Modify: `ios/LafoApp/ContentView.swift`
- Modify: `ios/LafoApp/HomeView.swift`
- Create: `ios/LafoApp/RecordView.swift`
- Modify: `ios/Lafo.xcodeproj/project.pbxproj`

- [ ] **Step 1: Add onboarding and tab shell**

Show welcome, local privacy, and medical disclaimer until accepted. After acceptance show tabs: 今日、日历、趋势、伙伴、我的.

- [ ] **Step 2: Build Today tab**

Show pet/logo, greeting, large `我拉了 💩` button, today count, today summary, streak, and buddy feedback.

- [ ] **Step 3: Build create/edit record view**

Default time to now; require poop type; support optional mood, pain level, and note; save returns to Today and triggers success copy.

- [ ] **Step 4: Verify by build**

Run: `xcodebuild -project ios/Lafo.xcodeproj -scheme Lafo -destination generic/platform=iOS build`

Expected: no Swift compile errors.

## Task 4: Calendar, Stats, Buddy, Settings

**Files:**
- Create: `ios/LafoApp/CalendarView.swift`
- Create: `ios/LafoApp/StatsView.swift`
- Create: `ios/LafoApp/BuddyView.swift`
- Create: `ios/LafoApp/SettingsView.swift`
- Modify: `ios/Lafo.xcodeproj/project.pbxproj`

- [ ] **Step 1: Implement Calendar tab**

Month grid, previous/next month, per-day count marker, selected-day detail, edit and delete actions.

- [ ] **Step 2: Implement Stats tab**

Show the seven PRD stats with lightweight cards and non-medical summary copy.

- [ ] **Step 3: Implement Buddy tab**

Show Lafo 小肠肠, level, streak, unlocked states, and gentle copy for 0/3/7 day milestones.

- [ ] **Step 4: Implement Settings tab**

Reminder toggle/time/style, privacy policy, user agreement, medical disclaimer, CSV export text, and clear local data confirmation.

- [ ] **Step 5: Verify by build**

Run: `xcodebuild -project ios/Lafo.xcodeproj -scheme Lafo -destination generic/platform=iOS build`

Expected: no Swift compile errors.

## Task 5: Operations And Release Readiness

**Files:**
- Create: `docs/lafo-mvp-operations.md`

- [ ] **Step 1: Write launch plan**

Include audience, owner, channel, rollout steps, customer message, activation path, success metrics, guardrails, monitoring, feedback, FAQ, failure modes, escalation, rollback signal, and review cadence.

- [ ] **Step 2: Verify release wording**

Run: `rg "诊断|治疗|上传|登录|广告|医生" docs/lafo-mvp-operations.md docs/lafo-mvp-local-prd.md`

Expected: medical and privacy wording is explicit and non-diagnostic.

## Task 6: Final Verification

**Files:**
- Verify all modified files.

- [ ] **Step 1: Run iOS project listing**

Run: `xcodebuild -list -project ios/Lafo.xcodeproj`

Expected: scheme `Lafo` is present.

- [ ] **Step 2: Run iOS build**

Run: `xcodebuild -project ios/Lafo.xcodeproj -scheme Lafo -destination generic/platform=iOS build`

Expected: build succeeds.

- [ ] **Step 3: Run backend regression tests if backend remains in repo**

Run: `uv run pytest -q`

Expected: existing backend tests pass or any unrelated failure is reported separately.

## Self-Review

Spec coverage:
- Home, Record, Calendar, Stats, Buddy, Settings are covered by Tasks 3 and 4.
- Local privacy, no login, no cloud sync are covered by Tasks 1, 2, and 5.
- Reminder and export are covered by Task 4.
- Medical disclaimer and App Store readiness are covered by Task 5.

Known implementation constraint:
- The MVP can use JSON persistence instead of SwiftData to minimize project setup risk and keep all data local. SwiftData migration remains a later implementation option.
