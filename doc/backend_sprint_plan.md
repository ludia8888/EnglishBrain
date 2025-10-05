# Backend Sprint Plan — English Brain

> Scope: Backend engineers (Firebase + Cloud Functions + ancillary services). Derived from PRD v2.0, UserFlow, and OpenAPI 3.1 spec. All dates TBD; align with product milestones.

---

## Sprint 0 — Foundations & Environments
_Target: Week 0-1 / PRD M0_

_Refs: PRD §12 (Platforms & Backend stack), OpenAPI overview, UserFlow bird's-eye map._

- [ ] **Firebase Project Setup**
  - [ ] Create dedicated Firebase project(s) for dev/staging/prod; enable Firestore (native mode), Authentication, Cloud Functions, Cloud Storage, Cloud Scheduler.
  - [ ] Configure billing tier required for scheduled functions + long-lived exports (Blaze if necessary).
- [ ] **Repository & CI/CD**
  - [x] Initialize backend repo (TypeScript/Node for Cloud Functions) with linting (ESLint), formatting (Prettier), testing (Jest).
  - [x] Add GitHub Actions (or equivalent) for lint/test/deploy gating.
  - [ ] Store secrets in Firebase Functions config (`firebase functions:config:set`) or Secret Manager.
  - [x] CI checkpoint: run lint + tests on initial scaffolding before first push.
  - [ ] Git: initial commit `chore(backend): bootstrap firebase project` and push to remote.
- [ ] **Local Tooling**
  - [ ] Install Firebase CLI, emulators (auth, firestore, functions, pubsub).
  - [x] Write bootstrapped `firebase.json` & `firebaserc` for multi-environment use.
  - [x] Generate `.env.example` covering service account paths, admin SDK creds (for CI), and OpenAPI mock toggles.
- [ ] **OpenAPI Contract Alignment**
  - [ ] Create contract tests (Prism/Newman) that run against the emulator & staging URLs.
  - [ ] Lock down codegen snapshot of `doc/openapi.yaml`; track changes via PR.

## Sprint 1 — Auth, Profiles, & Home Summary
_Target: Week 1-2 / PRD M1_

_Refs: PRD §6.4(패턴 정복/홈 피드백), §6.6(습관화 개요), UserFlow §1–2 (온보딩/홈), OpenAPI `/users/me`, `/users/me/home`, `/users/me/widget-snapshot`._ 

- [ ] **Authentication Hooks**
  - [x] Confirm Firebase Auth providers (Email/Password, Apple, Google).
  - [x] Set up Cloud Function triggers for onboarding (e.g., user creation default stats).
  - [x] Add token verification middleware for HTTPS functions; integrate with OpenAPI security (Firebase Auth JWT).
  - [x] CI checkpoint: emulator test suite covering auth flows before merge.
  - [ ] Git: commit `feat(auth): add token middleware & onboarding trigger`.
- [ ] **Firestore Data Model (Users)**
  - [x] Design `users/{uid}` schema: profile, stats, flags, preferences (per PRD & OpenAPI `UserProfile`).
  - [x] Implement `GET /users/me`, `PATCH /users/me`, `GET /users/me/home`, `GET /users/me/widget-snapshot` using callable HTTPS functions or Express app inside Cloud Functions.
  - [x] Populate streak, brain tokens, recommended actions (stub logic until pattern analytics ready).
  - [x] CI checkpoint: deploy to emulator; contract tests (`GET /users/me`) run before PR.
  - [ ] Git: commit `feat(users): profile endpoints & home summary`.
- [ ] **Security Rules (MVP)**
  - [x] Define Firestore rules ensuring users can only read/write their documents.
  - [x] Add tests via `@firebase/rules-unit-testing` for user profile operations.

## Sprint 2 — Onboarding & Level Test
_Target: Week 2-3 / PRD M1_

_Refs: PRD §6.1(온보딩/레벨 테스트), UserFlow §1 (First-Run), OpenAPI `/level-tests`, `/users/me/tutorial-completions`._ 

- [x] **Level Test Content Handling**
  - [x] Set up `lessons/{lessonId}` collection or Cloud Storage JSON feed for level test, with import pipeline (Functions `importLessons`).
  - [x] Implement `POST /level-tests` function: accept 10-15 attempts, compute provisional level, record metrics.
  - [x] Store results in `level_tests/{submissionId}` and update `users/{uid}.provisionalLevel` + `flags.levelTestCompleted`.
  - [x] Firestore security rules: read-only `lessons/`, restricted `level_tests/` (own submissions only).
  - [x] Contract tests: emulator-backed tests for `/level-tests` endpoint with supertest.
  - [x] Rules tests: `@firebase/rules-unit-testing` coverage for lessons + level_tests collections.
  - [x] Documentation: README with endpoint spec, request/response examples, side effects.
  - [ ] Git: commit `feat(onboarding): level test submission pipeline`.
- [x] **Tutorial Completion & Flags**
  - [x] Provide `POST /users/me/tutorial-completions` to toggle tutorial flags, unlock personalization readiness.
  - [x] Emit analytics event (BigQuery export or GA) for onboarding funnel.
  - [x] Record `tutorial_completion` event with personalization metadata in `analytics_events` collection.
  - [x] Contract tests verify analytics event creation alongside profile updates.
  - [ ] **Optional**: Add TTL/retention strategy (Firestore TTL or nightly BigQuery export).
  - [ ] **Optional**: Add analytics for level test completion and first session start.
  - [ ] Git: commit `feat(onboarding): validation, rate limiting, and analytics`.
- [x] **Validation & Rate Limiting**
  - [x] Validate request payloads against OpenAPI schema (shared validators in `backend/src/validation/`).
  - [x] Rate limit level test submissions via Firestore counters (max 2 per 24h per user).
  - [x] Contract tests for validation errors and rate limit enforcement.
  - [ ] **Optional**: Optimize rate-limit counters with Firestore aggregates or Redis before production launch.

## Sprint 3 — Sessions, Attempts, Checkpoints
_Target: Week 4-6 / PRD M2_

_Refs: PRD §6.2(세션 3단계), §6.3(오답 교정), UserFlow §3–4, OpenAPI `/sessions`, `/sessions/{id}`, `/sessions/{id}/attempts`, `/sessions/{id}/checkpoints`._ 

- [ ] **Session Creation Pipeline**
  - [x] Define `sessions/{sessionId}` doc schema (phases, items, summary, status, mode).
  - [x] Implement `POST /sessions` to issue new session packages (with seeded deck from content service).
  - [ ] CI checkpoint: emulator integration test for session creation + Firestore rules.
  - [ ] Git: commit `feat(session): creation pipeline`.
- [ ] **In-Session Logging**
  - [x] Implement `POST /sessions/{sessionId}/attempts` + `POST /sessions/{sessionId}/checkpoints` endpoints; persist to `attempts/{attemptId}` with idempotency keys.
  - [x] Support query `GET /sessions/{sessionId}` and `GET /sessions/{sessionId}/attempts` with optional filtering.
  - [ ] CI checkpoint: run load test stub for attempt write throughput before deploy.
  - [ ] Git: commit `feat(session): attempt & checkpoint logging`.
- [ ] **Scoring & Combo Logic**
  - [x] Create `scoreAttempt` Cloud Function to compute accuracy, hints penalty, combo resets (matching PRD weights).
  - [x] Update `SessionSummary` when `PATCH /sessions/{sessionId}` invoked (completed/abandoned).
  - [ ] Git: commit `feat(session): scoring + summary updater`.
- [ ] **Security & Consistency**
  - [ ] Ensure Firestore rules prevent cross-user session access.
  - [ ] Implement transaction or `FieldValue.increment` for streak updates triggered via session completion.

## Sprint 4 — Personalization, Patterns & Reviews
_Target: Week 6-8 / PRD M3_

_Refs: PRD §6.4(패턴 정복), §6.5(커리큘럼), UserFlow §5, OpenAPI `/patterns`, `/users/me/pattern-conquests`, `/reviews` suite._

- [ ] **Pattern Aggregator**
  - [x] Implement EWMA-based aggregation logic & unit tests for pattern conquest metrics (per PRD formula).
  - [ ] Integrate scheduled/streaming job to compute conquest rates using Firestore data.
  - [ ] Write to `users/{uid}/pattern_conquest/{patternId}` with hint rate, first-try rate, trend flags.
  - [ ] Brain Map feed: expose curated pattern graph data (top 5 nodes, relationships) for UI visualization.
  - [ ] CI checkpoint: scheduler emulator test; ensure BigQuery export dry run.
  - [ ] Git: commit `feat(patterns): EWMA aggregator`.
- [ ] **Pattern APIs**
  - [x] Implement `GET /patterns` (static definitions from config).
  - [ ] Implement `GET /users/me/pattern-conquests` reading aggregated stats.
- [ ] **Review Plans**
  - [ ] Implement `POST /reviews` (auto/user-triggered) deriving item list from weakest patterns.
  - [ ] Support `GET /reviews`, `GET /reviews/{reviewId}`, `PATCH /reviews/{reviewId}` updates (accuracy, duration, pattern impact).
- [ ] **Recommendation Engine**
  - [ ] Build `recommendReview` Function invoked after session completion or via scheduler for daily recap push.

## Sprint 5 — Notifications, Streaks & Habit Loop
_Target: Week 8-10 / PRD M3-M4_

_Refs: PRD §6.6(습관화/푸시), §6.8 Brain Burst (Table §6.6 & M4), UserFlow §6–8, OpenAPI `/streaks/freeze`, `/notifications/digest`, `/notifications/{id}/open`, `/live-activities`, `/purchases`, `/purchases/me`._

- [ ] **Brain Token/Streak Services**
  - [ ] Implement `POST /streaks/freeze` consuming brain tokens with server-side validation (one per day cap, offline queue reconciliation).
  - [ ] Cron job to increment streak/day counters and grant tokens (server time authoritative).
- [ ] **Brain Burst (Variable Reward)**
  - [ ] Build server-side Brain Burst scheduler: activate once every 5 completed sessions (configurable), reset on missed day.
  - [ ] Persist Brain Burst state per user (`users/{uid}.stats.brainBurstEligibleAt`, `brainBurstActive`, history log).
  - [ ] Expose Brain Burst status via session creation response (flag + bonus multiplier) and emit analytics events.
  - [ ] Integrate with streak/brain token logic so Brain Burst does not grant duplicate rewards; ensure cooldown enforcement.
  - [ ] CI checkpoint: unit tests for scheduler edge cases (timezones, restarts).
  - [ ] Git: commit `feat(streaks): brain burst scheduler`.
- [ ] **Push Personalization**
  - [ ] Implement `scheduleDailyPush` Function: respect time zone, DND window (22:00–07:00), pattern focus.
  - [ ] Create Cloud Scheduler entry per user (consider Pub/Sub fan-out) or adopt Firestore queue processed hourly.
  - [ ] Implement `/notifications/digest` and `/notifications/{id}/open` to surface and track opens/deep actions.
- [ ] **Live Activities Bridge**
  - [ ] Provide `/live-activities` endpoints to register/update/remove ActivityKit tokens; integrate with APNs push for real-time updates.
 - [ ] **Purchases/Paywall API**
   - [ ] Implement `/purchases` (receipt validation) and `/purchases/me` endpoints; update user subscription status.
   - [ ] Connect with paywall triggers (session limit) and analytics.
   - [ ] CI checkpoint: StoreKit receipt mock tests before deploy.
   - [ ] Git: commit `feat(paywall): purchases endpoints`.

## Sprint 6 — Telemetry, Offline Sync & Analytics
_Target: Week 9-11 / PRD M4_

_Refs: PRD §10(데이터 모델), §18(텔레메트리), §10 오프라인 요구, UserFlow §10–11, OpenAPI `/telemetry/events`, `/sync/sessions`._

- [ ] **Telemetry Endpoint**
  - [ ] Implement `POST /telemetry/events` storing batched events (BigQuery via Firestore → Dataflow or Cloud Pub/Sub).
  - [ ] Validate event schemas and throttle ingestion per-user.
  - [ ] CI checkpoint: run contract tests on telemetry schema; ensure Pub/Sub emulator coverage.
  - [ ] Git: commit `feat(telemetry): ingestion pipeline`.
- [ ] **Offline Sync**
  - [ ] Implement `POST /sync/sessions` merging offline session, attempt, checkpoint data; resolve conflicts per PRD (server timestamp precedence).
  - [ ] Record `pendingRewards` resolution queue for offline completions.
  - [ ] Git: commit `feat(sync): offline session merge`.
- [ ] **Reporting & Dashboards**
  - [ ] Export pattern/streak metrics to BigQuery; build Looker Studio dashboards for KPI tracking (activation, retention, completion).

## Sprint 7 — Privacy, Compliance & Launch Hardening
_Target: Week 11-13 / PRD M4-M6_

_Refs: PRD §16(개인정보/컴플라이언스), §20(리스크), OpenAPI `/users/me/data-deletion-requests`, `/users/me/data-export-requests`._

- [ ] **Data Requests**
  - [ ] Implement `/users/me/data-deletion-requests` (queue job, mark `flags.dataDeletionScheduled`, disable account immediately, purge in ≤30 days).
  - [ ] Implement `/users/me/data-export-requests` generating export archive ≤72h (signed URL delivery, `flags.dataExportRequestedAt`).
  - [ ] Add admin tooling to monitor request queues.
  - [ ] CI checkpoint: staged dry-run of deletion/export tasks; confirm alerting in place.
  - [ ] Git: commit `feat(privacy): data deletion & export pipelines`.
- [ ] **Auditing & Logging**
  - [ ] Enable Cloud Logging retention, add structured logs for each endpoint, integrate with Error Reporting.
  - [ ] Ensure Firestore rules and Cloud Functions enforce PII separation.
- [ ] **Performance & Load**
  - [ ] Run load tests (e.g., k6 hitting endpoints) up to expected DAU; confirm Firestore indexes and quotas.
  - [ ] Optimize cold start by configuring min instances for latency-critical functions.
- [ ] **Release Checklist**
  - [ ] Pen-test (auth bypass, injection, rate limits).
  - [ ] Confirm monitoring alerts (latency, error rate, scheduler failures).
  - [ ] Sign-off meeting with product/QA before soft launch.
  - [ ] Final CI run against staging; tag release (e.g., `backend-v1.0.0`) and push tag.

---

## Cross-Cutting Checklists

- [ ] **Documentation**
  - [ ] Maintain API docs in `doc/openapi.yaml`; auto-publish Swagger/Redoc.
  - [ ] Keep runbooks for incident response (how to rotate Firebase keys, redeploy functions, handle push outage).
- [ ] **Testing Strategy**
  - [ ] Unit tests per function (Jest + firestore emulator).
  - [ ] Integration tests hitting emulator suite via Newman/Prism.
  - [ ] Contract tests in CI to prevent OpenAPI regressions.
- [ ] **Data Quality**
  - [ ] Backfill scripts for content imports, pattern recalculation, streak repair.
  - [ ] Alerts on data anomalies (e.g., hint_rate > 1, streak freeze misuse).
- [ ] **Security**
  - [ ] Implement Firestore rules regression tests.
  - [ ] Enable App Check if feasible for client-side calls.
  - [ ] Regularly rotate service-account keys; document SOP.
