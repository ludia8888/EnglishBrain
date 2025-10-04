# Frontend Sprint Plan — English Brain (iOS · SwiftUI)

> Scope: iOS engineers. Swift 5.9+, SwiftUI, Combine, ActivityKit, WidgetKit. Derived from PRD v2.0, UserFlow, SDK (`sdk-swift/EnglishBrainAPI`) and backend sprint roadmap. Dates TBD.

---

## Sprint 0 — Environment & Architecture
_Target: Week 0-1 / PRD M0_

_Refs: PRD §12(플랫폼/기술), UserFlow Bird's-eye map, OpenAPI overview (auth/security)._ 

- [ ] **Tooling & Project Baseline**
  - [ ] Confirm Xcode 15+, Swift 5.9 toolchain, SwiftFormat/SwiftLint configs.
  - [ ] Regenerate Xcode project via `xcodegen generate`; ensure `project.yml` tracked.
  - [ ] Integrate generated SDK (`sdk-swift/EnglishBrainAPI`) via Swift Package (local path).
  - [ ] CI checkpoint: run `swift build` + unit tests (placeholder) before first commit.
  - [ ] Git: initial commit `chore(ios): bootstrap project` and push to remote.
- [ ] **App Architecture**
  - [ ] Finalize module structure (Features: Onboarding, Session, Review, Home, Settings, Widgets, Live Activity).
  - [ ] Configure dependency injection (e.g., `@MainActor` AppContainer / EnvironmentObjects) for services.
  - [ ] Establish networking layer wrappers around SDK (combine-friendly, cancellable, retry policy).
- [ ] **Design System & Styles**
  - [ ] Import typography, color tokens, spacing guidelines from design system.
  - [ ] Create reusable components: PrimaryButton, TagChip, Card, ProgressRing, FeedbackBanner.
  - [ ] Set up asset catalogs (3 feedback channels audio/haptic triggers placeholders).
- [ ] **Telemetry & Debug Utilities**
  - [ ] Implement logging facade (os_log + custom overlays) toggled by build configuration.
  - [ ] Add feature flags for mock vs live endpoints (point to Prism `localhost:3001`).

## Sprint 1 — Onboarding & Account Setup
_Target: Week 1-2 / PRD M1_

_Refs: PRD §6.1(온보딩/레벨 테스트), UserFlow §1, OpenAPI `/level-tests`, `/users/me/tutorial-completions`._

- [ ] **Launch & Intro**
  - [ ] Splash + intro carousel (skip-able) introducing "Think like English" value prop.
  - [ ] Permission primer screens before system dialogs (notifications/haptics optional).
  - [ ] CI checkpoint: UI tests for intro flow; snapshot acceptance.
  - [ ] Git: commit `feat(onboarding): intro carousel`.
- [ ] **Adaptive Level Test (10 items)**
  - [ ] Build `LevelTestView` with draggable tokens (SwiftUI DragTarget), slot states S/V/O/M.
  - [ ] Implement hint ladder (text → slot labels → highlight) with animations & haptic feedback per stage.
  - [ ] Track per-attempt metrics: time, hints used, first-try success; POST via `LevelTestsAPI`.
  - [ ] Add progress indicator, accessibility support (VoiceOver alternate controls).
  - [ ] CI checkpoint: unit tests for scoring view model; integration with mock API.
  - [ ] Git: commit `feat(onboarding): adaptive test UI`.
- [ ] **Tutorial & Flags**
  - [ ] Implement 1-sentence tutorial showcasing 3 feedback channels.
  - [ ] After tutorial, call `/users/me/tutorial-completions`; update local profile flags.
  - [ ] Delayed notification permission sheet (value-first).
- [ ] **Profile bootstrap**
  - [ ] Fetch `GET /users/me` to hydrate local store; map to `AppUser` model.
  - [ ] Persist timezone, locale, preferences (UserDefaults + Cloud sync).

## Sprint 2 — Home Dashboard & Navigation Shell
_Target: Week 2-4 / PRD M2_

_Refs: PRD §6.4(홈 피드백/패턴 카드), §6.6(Trigger 시스템), UserFlow §2, OpenAPI `/users/me`, `/users/me/home`, `/users/me/widget-snapshot`._

- [ ] **Home Screen**
  - [ ] Header: daily goal (12 sentences) with progress ring, time estimate badge (basic vs intensive tiers).
  - [ ] Pattern cards carousel (top 1–3) showing conquest rate, trend glyphs.
  - [ ] CTA row: "바로 시작" / "패턴 복습" (free vs pro gating) / Brain Token banner.
  - [ ] CI checkpoint: snapshot tests for home sections; Combine pipelines verified with mocks.
  - [ ] Git: commit `feat(home): dashboard shell`.
- [ ] **Navigation Structure**
  - [ ] Implement tab/stack navigation using NavigationStack + deep link router.
  - [ ] Hook up quick actions (App Intents) to router entries.
  - [ ] Git: commit `feat(home): navigation router`.
- [ ] **Widget Snapshot Fetcher**
  - [ ] Integrate `GET /users/me/widget-snapshot`; share data to WidgetKit timeline (basic layout & placeholder).
- [ ] **Plan Awareness**
  - [ ] Display plan state (free/pro/trial) based on `users.me.stats.subscriptionStatus`.
  - [ ] Add paywall stub CTA linking to placeholder screen.

## Sprint 3 — Session Engine (3-step Mission Loop)
_Target: Week 4-6 / PRD M2_

_Refs: PRD §6.2(3단계 미션), §6.3(오답 교정), UserFlow §3–4, OpenAPI `/sessions`, `/sessions/{id}`, `/sessions/{id}/attempts`, `/sessions/{id}/checkpoints`._

- [ ] **Session Package Handling**
  - [ ] Call `POST /sessions` to obtain phases/items; cache locally with idempotency keys.
  - [ ] Build session state machine (Warm-up → Focus → Cool-down) with progress persistence.
  - [ ] CI checkpoint: unit tests for session state reducer; run UI tests for basic flow.
  - [ ] Git: commit `feat(session): engine skeleton`.
- [ ] **Token Drag & Feedback**
  - [ ] Implement drag interactions with real-time slot validation, spring animations, audio, haptics (light/medium/heavy).
  - [ ] Show hint usage counters (phase budgets), enforce cooldown, show penalty messaging.
  - [ ] Git: commit `feat(session): drag feedback system`.
- [ ] **Checkpoint Modals**
  - [ ] After each phase, show celebration view, send `POST /sessions/{id}/checkpoints`.
  - [ ] Provide continue/back-to-home options; auto-advance after 1.5s if untouched.
  - [ ] Git: commit `feat(session): checkpoint modals`.
- [ ] **Attempts Logging**
  - [ ] POST attempt payloads with placements, verdict, hint counts; handle offline queue.
  - [ ] Manage combo streak display (HUD) and resets on incorrect/hint usage.
- [ ] **Completion Summary**
  - [ ] Render session summary (accuracy, combos, hints, pattern impact), send `PATCH /sessions/{id}`.
  - [ ] Provide CTA to start recommended review.
  - [ ] CI checkpoint: snapshot test summary screen; verify analytics event fire.
  - [ ] Git: commit `feat(session): summary screen`.

## Sprint 4 — Personalization & Review Experience
_Target: Week 6-8 / PRD M3_

_Refs: PRD §6.4(패턴 정복, 검증 지표), UserFlow §5, OpenAPI `/patterns`, `/users/me/pattern-conquests`, `/reviews` suite._

- [ ] **Pattern Detail**
  - [ ] Create pattern dashboard displaying conquest rate, trend, hintRate/firstTryRate graphs.
  - [ ] Fetch `/users/me/pattern-conquests`; gracefully handle "데이터 수집 중" state.
  - [ ] Brain Map visualization (node-link view) for unlocked patterns; consume backend Brain Map feed.
  - [ ] Git: commit `feat(patterns): dashboard view`.
- [ ] **Review Launcher**
  - [ ] Trigger review plan creation (`POST /reviews`) from pattern cards and session summary.
  - [ ] Build review session UI (5–8 items) reusing session components with altered pacing.
  - [ ] CI checkpoint: UI tests for review loop; data mocks validated.
  - [ ] Git: commit `feat(review): mini-course flow`.
- [ ] **Progress Visualization**
  - [ ] Weekly growth chart (sparklines) & conquest delta messaging.
  - [ ] Badge animations for threshold crossings (>=80%, etc.).

## Sprint 5 — Habit Loop, Brain Tokens, Brain Burst
_Target: Week 8-10 / PRD M3-M4_

_Refs: PRD §6.6(스트릭/Brain Token), §6.8 Brain Burst (M4 표), UserFlow §6–8, OpenAPI `/streaks/freeze`, `/notifications/digest`, `/notifications/{id}/open`, `/live-activities`, `/purchases`, `/purchases/me`._

- [ ] **Streak & Brain Token UI**
  - [ ] Implement streak calendar, milestone badges, Brain Token inventory with usage flow (`POST /streaks/freeze`).
  - [ ] Offline queuing for streak freeze attempts; show pending state.
  - [ ] Git: commit `feat/habit): streak & brain token UI`.
- [ ] **Brain Burst Presentation**
  - [ ] Surface Brain Burst activation (lightning animation, bonus indicator) from session payload.
  - [ ] Apply bonus multipliers to scoring visuals; handle cooldown messaging.
  - [ ] Log analytics events (client) mirroring backend.
  - [ ] CI checkpoint: animation performance (profiling) before release; ensure analytics instrumentation tests.
  - [ ] Git: commit `feat/habit): brain burst UI`.
- [ ] **Notifications & Deep Links**
  - [ ] Render notification digest (pattern, streak, encouragement) and map deep links into router.
  - [ ] Track opens (`POST /notifications/{id}/open`) and optional dismissal reasons.
  - [ ] Git: commit `feat/habit): notification digest`.
- [ ] **Live Activity Integration**
  - [ ] Register Live Activity at session start (`POST /live-activities`); update checkpoints & combos; end gracefully.
  - [ ] Handle ActivityKit push updates & fallback for unsupported devices.

## Sprint 6 — Widgets, Shortcuts, Paywall
_Target: Week 9-11 / PRD M4_

_Refs: PRD §6.6(위젯/단축어), §6.7(paywall), UserFlow §8–9, OpenAPI `/users/me/widget-snapshot`, `/notifications` APIs, `/purchases`, `/purchases/me`._

- [ ] **WidgetKit**
  - [ ] Build small/medium widgets showing remaining sentences, streak, next token; refresh via timeline (`widget_snapshot`).
  - [ ] Support lock screen widget if feasible (limited info).
  - [ ] CI checkpoint: Widget snapshot tests via `xcrun simctl`; ensure timeline refresh works.
  - [ ] Git: commit `feat(widget): daily snapshot`.
- [ ] **App Intents & Siri Shortcuts**
  - [ ] Provide intents: "오늘의 훈련 시작", "패턴 복습", "정복률 확인".
  - [ ] Test invocation from Shortcuts app & voice.
  - [ ] Git: commit `feat(shortcuts): app intents`.
- [ ] **Paywall & Plan Flow (post-MVP)**
  - [ ] Implement paywall screen referencing plan benefits (free vs pro); integrate StoreKit 2 trial flow.
  - [ ] Surface plan banners post-session when limit exceeded.
  - [ ] Connect with `/purchases` & `/purchases/me` endpoints; handle receipt submission success/error states.
  - [ ] Git: commit `feat(paywall): purchase integration`.

## Sprint 7 — Offline, Resilience & Polish
_Target: Week 11-13 / PRD M5-M6_

_Refs: PRD §10(데이터 모델/오프라인), §18(텔레메트리), §20(리스크), UserFlow §10–13, OpenAPI `/sync/sessions`, `/telemetry/events`, privacy endpoints._

- [ ] **Offline Mode**
  - [ ] Integrate GRDB caches for session packages, attempts, checkpoints; sync via `POST /sync/sessions`.
  - [ ] Show offline banners, queued sync indicators.
  - [ ] CI checkpoint: offline simulation tests (disable network); ensure queued sync flush.
  - [ ] Git: commit `feat(resilience): offline mode`.
- [ ] **Error Recovery**
  - [ ] Implement resume flows after crash/back, using `session_checkpoints` data.
  - [ ] Provide fallback screens for API errors (retry, contact support).
  - [ ] Git: commit `feat(resilience): recovery flows`.
- [ ] **Performance & Accessibility**
  - [ ] Optimize animations (ensure 60fps), reduce particle intensity on low-power.
  - [ ] Complete accessibility pass: VoiceOver labels, Dynamic Type, reduce motion toggles.
  - [ ] CI checkpoint: run accessibility audits & Instruments profiling before sign-off.
  - [ ] Git: commit `chore(polish): perf & accessibility`.
- [ ] **QA & Launch Readiness**
  - [ ] UITests covering onboarding, session, review, streak flows.
  - [ ] Snapshot tests for key views.
  - [ ] Final bug bash + App Store submission checklist.
  - [ ] Final CI pipeline (UITests + snapshots) green; tag release `ios-v1.0.0` and push tag.

---

## Cross-Cutting Checklists

- [ ] **State Management**
  - [ ] Central store for user profile/stats; ensure consistency after background updates.
  - [ ] Implement feature flagging (mock vs prod APIs) and environment switching UI (dev builds).
- [ ] **Analytics & Telemetry**
  - [ ] Inject analytics service (Firebase Analytics + custom) across flows; mirror backend event names.
  - [ ] Ensure session/attempt/review events carry pattern IDs, hint counts, Brain Burst flags.
- [ ] **Design Collaboration**
  - [ ] Weekly review with design for motion/a11y acceptance.
  - [ ] Maintain component library documentation (Figma ↔ implementation parity).
- [ ] **Code Quality**
  - [ ] Enforce SwiftLint rules; add Danger or SwiftFormat script in CI.
  - [ ] PR template referencing sprint checklist items.
