# Frontend Sprint Plan — English Brain (iOS · SwiftUI)

> Scope: iOS engineers. Swift 5.9+, SwiftUI, Combine, ActivityKit, WidgetKit. Derived from PRD v2.0, UserFlow, SDK (`sdk-swift/EnglishBrainAPI`) and backend sprint roadmap. Dates TBD.

---

## Sprint 0 — Environment & Architecture ✅
_Target: Week 0-1 / PRD M0_

_Refs: PRD §12(플랫폼/기술), UserFlow Bird's-eye map, OpenAPI overview (auth/security)._

- [x] **Tooling & Project Baseline**
  - [x] Confirm Xcode 15+, Swift 5.9 toolchain, SwiftFormat/SwiftLint configs.
  - [x] Regenerate Xcode project via `xcodegen generate`; ensure `project.yml` tracked.
  - [x] Integrate generated SDK (`sdk-swift/EnglishBrainAPI`) via Swift Package (local path).
  - [x] CI checkpoint: run `swift build` + unit tests (placeholder) before first commit.
  - [x] Git: initial commit `chore(ios): bootstrap project` and push to remote.
- [x] **App Architecture**
  - [x] Finalize module structure (Features: Onboarding, Session, Review, Home, Settings, Widgets, Live Activity).
  - [x] Configure dependency injection (e.g., `@MainActor` AppContainer / EnvironmentObjects) for services.
  - [x] Establish networking layer wrappers around SDK (combine-friendly, cancellable, retry policy).
- [x] **Design System & Styles**
  - [x] Import typography, color tokens, spacing guidelines from design system.
  - [x] Create reusable components: PrimaryButton, TagChip, Card, ProgressRing, FeedbackBanner.
  - [x] Set up asset catalogs (3 feedback channels audio/haptic triggers placeholders).
- [x] **Telemetry & Debug Utilities**
  - [x] Implement logging facade (os_log + custom overlays) toggled by build configuration.
  - [x] Add feature flags for mock vs live endpoints (point to Prism `localhost:3001`).

## Sprint 1 — Onboarding & Account Setup ✅
_Target: Week 1-2 / PRD M1_

_Refs: PRD §6.1(온보딩/레벨 테스트), UserFlow §1, OpenAPI `/level-tests`, `/users/me/tutorial-completions`._

- [x] **Launch & Intro**
  - [x] Splash + intro carousel (skip-able) introducing "Think like English" value prop.
  - [x] Permission primer screens before system dialogs (notifications/haptics optional).
  - [x] CI checkpoint: UI tests for intro flow; snapshot acceptance.
  - [x] Git: commit `feat(onboarding): intro carousel`.
- [x] **Adaptive Level Test (10 items)**
  - [x] Build `LevelTestView` with draggable tokens (SwiftUI DragTarget), slot states S/V/O/M.
  - [x] Implement hint ladder (text → slot labels → highlight) with animations & haptic feedback per stage.
  - [x] Track per-attempt metrics: time, hints used, first-try success; POST via `OnboardingAPI.submitLevelTest`.
  - [x] Add progress indicator, accessibility support (VoiceOver alternate controls).
  - [x] CI checkpoint: unit tests for scoring view model; integration with mock API.
  - [x] Git: commit `feat(onboarding): adaptive test UI`.
- [x] **Tutorial & Flags**
  - [x] Implement 1-sentence tutorial showcasing 3 feedback channels (audio, visual, haptic).
  - [x] After tutorial, call `/users/me/tutorial-completions`; update local profile flags.
  - [x] Delayed notification permission sheet (value-first).
- [ ] **Profile bootstrap**
  - [ ] Fetch `GET /users/me` to hydrate local store; map to `AppUser` model.
  - [ ] Persist timezone, locale, preferences (UserDefaults + Cloud sync).

**Implementation Notes (2025-10-04):**
- ✅ Created complete Design System with Colors, Typography, PrimaryButton, ProgressRing
- ✅ Built IntroCarouselView with 4-page value proposition flow
- ✅ Implemented LevelTestView with drag-and-drop tokens, S/V/O/M slot system, FlowLayout
- ✅ Added 3-level hint ladder: text hints → slot labels → slot highlighting with haptic feedback
- ✅ Created TutorialView demonstrating 3 feedback channels (visual/audio/haptic)
- ✅ Implemented NotificationPermissionView with delayed permission request
- ✅ Integrated OnboardingAPI.submitLevelTest with LevelTestAttempt metrics
- ✅ Built OnboardingCoordinator for state management across onboarding flow
- ✅ Updated deployment target to iOS 16.0 for Layout protocol support
- 📂 Architecture: Features/Onboarding/{Views,ViewModels,Models}, DesignSystem/{Tokens,Components}

## Sprint 2 — Home Dashboard & Navigation Shell ✅
_Target: Week 2-4 / PRD M2_

_Refs: PRD §6.4(홈 피드백/패턴 카드), §6.6(Trigger 시스템), UserFlow §2, OpenAPI `/users/me`, `/users/me/home`, `/users/me/widget-snapshot`._

- [x] **Home Screen**
  - [x] Header: daily goal (12 sentences) with progress ring, time estimate badge (basic vs intensive tiers).
  - [x] Pattern cards carousel (top 1–3) showing conquest rate, trend glyphs.
  - [x] CTA row: "바로 시작" / "패턴 복습" (free vs pro gating) / Brain Token banner.
  - [x] CI checkpoint: snapshot tests for home sections; Combine pipelines verified with mocks.
  - [x] Git: commit `feat(home): dashboard shell`.
- [ ] **Navigation Structure**
  - [ ] Implement tab/stack navigation using NavigationStack + deep link router.
  - [ ] Hook up quick actions (App Intents) to router entries.
  - [ ] Git: commit `feat(home): navigation router`.
- [ ] **Widget Snapshot Fetcher**
  - [ ] Integrate `GET /users/me/widget-snapshot`; share data to WidgetKit timeline (basic layout & placeholder).
- [ ] **Plan Awareness**
  - [ ] Display plan state (free/pro/trial) based on `users.me.stats.subscriptionStatus`.
  - [ ] Add paywall stub CTA linking to placeholder screen.

**Implementation Notes (2025-10-04):**
- ✅ Built HomeViewModel with UsersAPI.getHomeSummary integration
- ✅ Created DailyGoalCard with ProgressRing, tier badges (basic/intensive), completion state
- ✅ Implemented StreakCard showing current/longest streak, Brain Tokens, freeze eligibility
- ✅ Built PatternWeaknessCard with conquest rate, trend indicators, severity levels, stats badges
- ✅ Designed HomeView with ScrollView, pull-to-refresh, error states
- ✅ Added ActionCard component for recommended actions (daily-session, review, brain-burst, widget, tutorial)
- ✅ Created APIConfiguration service with mock Bearer token for Prism
- ✅ Configured Prism mock server with auth headers (http://127.0.0.1:3001)
- 📂 Architecture: Features/Home/{Views,ViewModels,Components}, Services/APIConfiguration

## Sprint 3 — Session Engine (3-step Mission Loop) ✅
_Target: Week 4-6 / PRD M2_

_Refs: PRD §6.2(3단계 미션), §6.3(오답 교정), UserFlow §3–4, OpenAPI `/sessions`, `/sessions/{id}`, `/sessions/{id}/attempts`, `/sessions/{id}/checkpoints`._

- [x] **Session Package Handling**
  - [x] Call `POST /sessions` to obtain phases/items; cache locally with idempotency keys.
  - [x] Build session state machine (Warm-up → Focus → Cool-down) with progress persistence.
  - [x] CI checkpoint: unit tests for session state reducer; run UI tests for basic flow.
  - [x] Git: commit `feat(session): engine skeleton`.
- [x] **Token Tap & Feedback** (Simulator-friendly)
  - [x] Implement tap-to-select interactions with slot placement, haptics (light/medium/heavy).
  - [x] Show hint usage counters (phase budgets), enforce cooldown, show penalty messaging.
  - [x] Git: commit `feat(session): tap feedback system`.
- [x] **Checkpoint Modals**
  - [x] After each phase, show celebration view.
  - [x] Provide continue/back-to-home options.
  - [x] Git: commit `feat(session): checkpoint modals`.
- [x] **Attempts Logging**
  - [x] Record attempt metrics with placements, verdict, hint counts.
  - [x] Manage combo streak display (HUD) and resets on incorrect/hint usage.
- [x] **Completion Summary**
  - [x] Render session summary (accuracy, combos), completion modal.
  - [x] Provide CTA to return to home.
  - [x] Git: commit `feat(session): summary screen`.

**Implementation Notes (2025-10-04):**
- ✅ Built SessionStateManager for phase/item navigation and progress tracking
- ✅ Created SessionViewModel with SessionsAPI.createSession integration
- ✅ Implemented SessionView with 3-phase flow (warm-up/focus/cool-down)
- ✅ Added tap-to-select token interaction (simulator-friendly alternative to drag-and-drop)
- ✅ Built checkpoint modal with phase completion celebration
- ✅ Implemented completion modal with session summary
- ✅ Added combo tracking, hint budget management, haptic feedback
- ✅ Connected Home → Session flow via fullScreenCover
- ✅ Phase indicators with color-coded UI (warm-up=orange, focus=blue, cool-down=teal)
- 📂 Architecture: Features/Session/{Views,ViewModels,Models}

## Sprint 4 — Personalization & Review Experience ✅
_Target: Week 6-8 / PRD M3_

_Refs: PRD §6.4(패턴 정복, 검증 지표), UserFlow §5, OpenAPI `/patterns`, `/users/me/pattern-conquests`, `/reviews` suite._

- [x] **Pattern Detail**
  - [x] Create pattern dashboard displaying conquest rate, trend, hintRate/firstTryRate graphs.
  - [x] Fetch `/users/me/pattern-conquests`; gracefully handle "데이터 수집 중" state.
  - [x] Git: commit `feat(patterns): dashboard view`.
- [x] **Tab Navigation**
  - [x] Implement MainTabView with Home/Patterns/Profile tabs
  - [x] Create ProfileView with settings and onboarding reset
- [x] **Review Launcher**
  - [x] Trigger review plan creation (`POST /reviews`) from pattern cards and session summary.
  - [x] Build review session UI (5–8 items) reusing session components with altered pacing.
  - [x] CI checkpoint: Build verified, review flow tested in simulator.
  - [x] Git: commit `feat(review): mini-course flow`.
- [ ] **Progress Visualization**
  - [ ] Brain Map visualization (node-link view) for unlocked patterns; consume backend Brain Map feed.
  - [ ] Weekly growth chart (sparklines) & conquest delta messaging.
  - [ ] Badge animations for threshold crossings (>=80%, etc.).

**Implementation Notes (2025-10-04):**
- ✅ Built PatternDetailViewModel with PatternsAPI.getPatternConquests integration
- ✅ Created PatternDetailView with conquest rate visualization, stats cards, metrics grid
- ✅ Implemented PatternsListView categorizing patterns as weak/improving/mastered
- ✅ Added data collection state handling for new users
- ✅ Built MainTabView with Home/Patterns/Profile navigation
- ✅ Created ProfileView with user info, learning settings, app info sections
- ✅ Updated ContentView to use MainTabView root navigation
- ✅ Fixed API response properties (data.patterns instead of data.conquests)
- ✅ Created ReviewViewModel with ReviewsAPI.createReview integration
- ✅ Built ReviewView with tap-to-select token interaction, completion summary
- ✅ Added review launcher from HomeView pattern weakness cards
- ✅ Added review button to PatternDetailView
- ✅ Added review CTA to SessionView completion modal
- ✅ Extended design system with ebCard and ebTextTertiary colors
- 📂 Architecture: Features/Patterns/{Views,ViewModels}, Features/Profile/Views, Features/Review/{Views,ViewModels}, App/MainTabView

## Sprint 5 — Habit Loop, Brain Tokens, Brain Burst
_Target: Week 8-10 / PRD M3-M4_

_Refs: PRD §6.6(스트릭/Brain Token), §6.8 Brain Burst (M4 표), UserFlow §6–8, OpenAPI `/streaks/freeze`, `/notifications/digest`, `/notifications/{id}/open`, `/live-activities`, `/purchases`, `/purchases/me`._

- [x] **Streak & Brain Token UI**
  - [x] Implement streak calendar, milestone badges, Brain Token inventory with usage flow (`POST /streaks/freeze`).
  - [x] Offline queuing for streak freeze attempts; show pending state.
  - [x] Git: commit `feat(streak): streak & brain token UI`.
- [ ] **Brain Burst Presentation**
  - [ ] Surface Brain Burst activation (lightning animation, bonus indicator) from session payload.
  - [ ] Apply bonus multipliers to scoring visuals; handle cooldown messaging.
  - [ ] Log analytics events (client) mirroring backend.
  - [ ] CI checkpoint: animation performance (profiling) before release; ensure analytics instrumentation tests.
  - [ ] Git: commit `feat(habit): brain burst UI`.
- [ ] **Notifications & Deep Links**
  - [ ] Render notification digest (pattern, streak, encouragement) and map deep links into router.
  - [ ] Track opens (`POST /notifications/{id}/open`) and optional dismissal reasons.
  - [ ] Git: commit `feat(habit): notification digest`.
- [ ] **Live Activity Integration**
  - [ ] Register Live Activity at session start (`POST /live-activities`); update checkpoints & combos; end gracefully.
  - [ ] Handle ActivityKit push updates & fallback for unsupported devices.

**Implementation Notes (2025-10-04):**
- ✅ Created StreakCalendarView with monthly calendar grid, completed/frozen date indicators
- ✅ Built BrainTokenInventoryView with token counts, freeze sheet UI, reason selection
- ✅ Implemented StreakViewModel with NotificationsAPI.createStreakFreeze integration
- ✅ Added offline queue for streak freeze requests with automatic retry mechanism
- ✅ Updated ProfileView with streak calendar and Brain Token inventory sections
- ✅ Integrated freeze eligibility checks and pending request indicators
- 📂 Architecture: Features/Streak/{Views,ViewModels}

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
