
0) 시스템 상위 맵 (Bird’s-eye)
	•	입구: 온보딩(최초) / 홈(재방문) / 푸시·위젯·단축어 딥링크
	•	실시간 상태: Live Activity(ActivityKit)로 세션 진행 공유
	•	핵심 루프: 세션(3단계 미션) ↔ 결과 ↔ 개인화 복습(패턴 정복)
	•	리텐션 루프: 스트릭/Brain Token ↔ 개인화 푸시 ↔ 재방문
	•	보조 루프: 설정/프로필/결제(포스트-MVP)

⸻

1) 최초 실행 플로우 (First-Run / Activation)

Trigger
	•	앱 첫 실행

Flow
	1.	권한 프롬프트 준비: 알림 권한(지연 요청), 햅틱/사운드는 시스템 기본
	2.	Intro 슬라이드(스킵 가능): 핵심 가치 소개(“생각 순서 회로화”)
    3.	레벨 테스트(적응형 10문항)
	•	화면: K-문장 + 토큰 4~6개 + [S/V/O/M] 슬롯, 허용 순열/동의어 표기
	•	행동: 드래그→즉시 채점(3중 피드백), 힌트 단계별 가중치 적용
	•	시드 5문항(고정) → 적응형 5문항(정확도/힌트 사용/시간 기반 분기)
	•	결과: 점수 + 힌트율 + 최초시도 성공률 → 임시 레벨 산정(첫 2회 세션 이후 확정)
	4.	튜토리얼 1문장 체험
	•	힌트 단계 시연(텍스트 → 슬롯 라벨 → 후보 하이라이트)
	•	체크포인트 미니 축하(“예열 완료!”)
	5.	알림 권한 요청(지연 타이밍)
	•	타이밍: 튜토리얼 완료 직후(가치 인지 후)
	•	선택: 허용/거절(거절 시 위젯·단축어 온보딩 노출)
	6.	홈 진입
	•	“오늘의 목표 12문장 / 8–12분(기본)” CTA, 심화 사용자는 12–18분 배지 노출
	•	패턴 영역은 비어있고 “데이터 수집 중” 상태

Data
	•	/users/{uid}.profile: {provisionalLevel, timezone, prefs, tutorialDone}
	•	level_test_attempts(문항별 점수/힌트/시간), level_test_done 이벤트 로깅
	•	Intro/튜토리얼 완료 플래그

Design Rationale
	•	Activation 극대화(섹션 2, 6.1, 6.2), Micro-commitment 시연
	•	3문항보다 신뢰도 높은 적응형 10문항으로 초기 레벨 오차 ↓, 첫 세션 데이터와 결합해 보정

⸻

2) 재방문 기본 플로우 (Returning User → Home)

Trigger
	•	앱 아이콘/위젯/단축어/푸시로 열기

Flow
	1.	홈 대시보드
	•	상단: 오늘 목표(12문장), 진행도(0/12), 예상 소요 8–12분(기본) / 12–18분(심화)
	•	중앙: 패턴 정복 카드(상위 1~3개, 정복률/추세)
	•	하단: “바로 시작” / “패턴 복습” 탭(무료 유저는 추천 1개만 활성, 나머지는 Pro 라벨)
	2.	결정
	•	A) “바로 시작” → 데일리 세션(#3)
	•	B) “패턴 복습” → 개인화 복습(#5)
	•	C) 알림/스트릭 배지 탭 → Brain Token 안내(#6)

Data
	•	/users/{uid}.patterns, /users/{uid}.stats, /users/{uid}.plan 읽기
	•	app_open 이벤트

Design Rationale
	•	Progress Feedback로 즉시 동기 부여(섹션 6.4)
	•	무료/프로 경계선 명확화로 Paywall 경험과 일관성 유지

⸻

3) 데일리 학습 세션 플로우 (3단계 미션 루프)

Trigger
	•	홈의 “바로 시작” 또는 딥링크

Flow
	1.	Phase 1: Warm-up(3문장, 2–3분)
	•	쉬운 난이도로 손을 푼다(초기 성공 경험)
	•	체크포인트 1 모달(🔥 예열 완료)
	2.	Phase 2: Focus Zone(6문장, 6–8분)
	•	주 난이도 + 콤보 보너스
	•	힌트 사용 시 감점·보너스 로직 반영
	•	체크포인트 2 모달(⚡ 집중 돌파)
	3.	Phase 3: Cool-down(3문장, 2–3분)
	•	난이도 소폭 하향, 성공적 마무리
	•	최종 리포트 모달(🧠 회로 강화 완료)
	4.	세션 시작 시 Live Activity 활성화(Phase 진행률/콤보/남은 문장 실시간 표시)

In-problem Interaction (각 문항 공통)
	•	드래그 → 즉시 채점(시각/청각/햅틱)
	•	틀린 배치 → 자동 교정 애니메이션 + 짧은 코칭
	•	콤보 3+ 달성 시 콤보 연출(빛 효과/사운드/햅틱), 힌트 사용/오답 시 콤보 리셋
	•	세션 힌트 한도 4회(Phase별 1/2/1) 표시, 초과 시 점수 50% 절삭 + 다음 세션 난이도 하향 안내
	•	동의어/위치 허용 규칙 안내(예: "a friend" ↔ "my friend"), 시도 3회 초과 시 2초 타임아웃

세션 종료 결과 화면
	•	정확도, 평균 소요, 콤보 최대치
	•	오늘 학습으로 어떤 패턴 정복률이 몇 %p 개선되었는지
	•	CTA: “복습 추천 시작” / “홈으로”
	•	Live Activity 종료/정리 통신(성공/실패 상태 보고)

오른쪽 상단 이탈 처리
	•	중도 이탈 시 체크포인트 기준 진행 저장(복귀 시 이어서)

Data
	•	/sessions/{sessionId} 생성/업데이트
	•	/attempts/{attemptId} 각 문항 로그
	•	/users/{uid}/session_checkpoints (Phase 완료 시 기록)
	•	/liveActivities/{id} 상태 업데이트, session_metrics{firstTryRate, hintRate}
	•	session_start, item_result, session_complete 텔레메트리

Acceptance(KPI 근거)
	•	Completion ≥ 80%(목표 88–92%), 평균 12문장(섹션 2)
	•	힌트 사용 ≤ 4회/세션, Live Activity 갱신 ≤ 5초 SLA

Design Rationale
	•	Micro-commitment + 3중 피드백(섹션 6.2), Embodied Learning
	•	Live Activity로 실시간 몰입 제공, 위젯은 진입/리마인더에 집중

⸻

4) 체크포인트·보상 플로우 (세션 내)

Trigger
	•	각 Phase 완료

Flow
	1.	Checkpoint Celebration
	•	아이콘 애니메이션 + 사운드 + 헤비 햅틱(≤1.5s)
	2.	보상/피드백
	•	현재 정확도/콤보 하이라이트
	•	다음 Phase 안내(예: “다음 6문장, 집중 구간”)
	3.	자동 전환
	•	1.5s 후 다음 Phase로 자연 전환(취소 시 홈)
	4.	Live Activity 업데이트(phaseStatus=completed, comboMax, accuracy)

Data
	•	/sessions/{sessionId}/phase_results append
	•	checkpoint_reached(선택) 로깅

Design Rationale
	•	중간 성취감 제공으로 이탈 최소화(섹션 6.2)

⸻

5) 개인화 복습 플로우 (패턴 정복)

Trigger
	•	세션 종료 CTA 또는 홈의 “패턴 복습”

Flow
	1.	패턴 카드 리스트
	•	상위 1~3개, 정복률(%) + 추세(🔥/→/⚠️), 무료는 1개 활성/나머지는 Pro 라벨
	2.	패턴 선택 → 미니 코스(5–8문장)
	•	정복률 기반 난이도 조절(≥75% 심화 / <50% 기초)
	•	동일 3중 피드백·체크포인트(1회)
	3.	복습 완료 시
	•	“정복률 60% → 75% (+15%)” 스타일 강화 피드백
	•	주간 성장 그래프 애니메이션(7일 추이)

Data
	•	/users/{uid}/pattern_conquest 업데이트
	•	review_start, item_result, review_complete 로깅
	•	review_metrics: conquestRate(EWMA), hintRate, firstTryRate

Design Rationale
	•	Error-driven 학습 + Spaced Repetition(섹션 6.4, 11.4, 11.5)
	•	정복률 = EWMA(correct) × (1 − hint_rate)^α × (first_try_rate)^β로 정의, 데이터 품질 확보

⸻

6) 스트릭 & Brain Token 플로우 (Loss Aversion)

Trigger
	•	하루 1세션 완료, 또는 미완료 시 다음날 앱 진입

Flow
	1.	스트릭 증가
	•	1일 1회 조건 충족 시 스트릭 +1
	•	마일스톤(3/7/14/30일) 보상: 칭호/토큰/테마
	2.	7일 달성 → Brain Token +1 (최대 3)
	•	보유량/다음 획득까지 D-day 표시
	3.	스트릭 끊김 감지
	•	다음날 앱 열 때 “어제 미완료” 탐지
	•	Brain Token 사용 팝업
	•	사용 시: 스트릭-1일 복구, 토큰-1
	•	미사용: 스트릭 리셋
	4.	토큰 고갈
	•	스토어/구독 혜택 대신 콘텐츠/테마 보상으로 유도, 토큰 직접 판매 금지
	5.	오프라인 완료
	•	보상은 서버 동기화 시점에 확정(UX: “인터넷 연결 시 자동 반영돼요” 토스트)

Data
	•	/users/{uid}/streak, /users/{uid}/brain_tokens
	•	streak_update, brain_token_used/earned, reward_pending(queueId, serverClock)

Design Rationale
	•	손실 회피 완충 + 안정감 제공(섹션 6.6)

⸻

7) 푸시 알림 → 딥링크 플로우 (Trigger 개인화)

Trigger
	•	스케줄러(Functions: scheduleDailyPush)
	•	규칙: 개인화 시간대 + 전날 패턴/스트릭 상태

Flow
	1.	메시지 템플릿 결정
	•	기본, 패턴 기반, 스트릭 강화, 격려/유머(A/B)
	•	Do-Not-Disturb(22:00~07:00 사용자 현지시간) 회피, 최근 학습 종료 후 45~90분 내 최적화
	2.	사용자 행동
	•	탭 → 딥링크:
	•	패턴 메시지면 해당 패턴 복습 화면으로 직행
	•	기본 메시지면 세션 Warm-up으로 직행
	3.	무응답
	•	동일일 재발송 없음(스팸 회피)
	•	위젯/단축어 노출 강화

Data
	•	/notifications/{id} 상태 업데이트
	•	push_sent, push_opened, push_ignored

Design Rationale
	•	Trigger-Action을 최소 마찰로 연결(섹션 6.6)

⸻

8) 위젯/단축어 플로우 (Frictionless Entry)

Trigger
	•	홈 화면 위젯 탭 / iOS 단축어 실행

Flow
	•	위젯(작은 사이즈): “오늘 목표 12문장 중 4문장 남음” → 세션으로(최근 스냅샷 기준)
	•	위젯(중간/큰): 스트릭/Brain Token 현황 + “복습 시작” CTA(실시간 X)
	•	Live Activity: 세션 진행률/콤보/남은 문장 실시간 표시
	•	단축어
	•	“오늘의 훈련 시작” → Warm-up
	•	“복습 시작” → 패턴 카드로
	•	“정복률 확인” → 패턴 대시보드

Data
	•	widget_snapshot{sentencesRemaining, streak, updatedAt}, shortcut_invoked, widget_tap, live_activity_started

Design Rationale
	•	진입 장벽 최소화로 빈번한 대표 행동 유도(섹션 6.6)
	•	위젯은 iOS 타임라인 예산 내 스냅샷, 실시간 몰입은 Live Activity로 분리

⸻

9) 세션 결과 → Paywall(포스트-MVP) 플로우

Trigger
	•	무료 플랜 한도 초과(일 1세션 초과 시 재시도)

Flow
	1.	결과 화면에서 혜택 비교 노출
	•	프로: 무제한 세션, 패턴 복습, 리포트
	2.	7일 트라이얼 시작 → 결제(StoreKit 2)
	•	성공: /purchases/{uid} 생성, 상태 동기화
	•	실패/취소: 무료로 유지, 다음 유도 포인트 저장

Data
	•	paywall_view, trial_start, purchase_success/fail

Design Rationale
	•	가치 체험 후 전환(섹션 6.7)

⸻

10) 오프라인/복귀/에러 플로우 (Resilience)

Trigger
	•	네트워크 불안정, 앱 크래시, 백그라운드 복귀

Flow
	1.	오프라인 감지
	•	세션 패키지/채점 로컬(Grdb) 경로로 자동 전환
	•	결과는 로컬에 큐잉(UX: “인터넷 연결 시 자동으로 저장돼요”) 토스트
	2.	복귀
	•	가장 최근 체크포인트부터 이어하기 다이얼로그
	3.	충돌 해결
	•	서버 타임스탬프 우선(last-write-wins)로 머지
	4.	크래시 후 재실행
	•	세션 복구 카드(Phase/정확도/남은 문장) CTA

Data
	•	GRDB 테이블: session_checkpoints, attempts, outbox(idempotency_key, serverClockSnapshot)
	•	sync_success/fail, app_recover 로깅, reward_pending 처리

Design Rationale
	•	60fps 유지·세션 완주율 보호(섹션 7, 20)

⸻

11) 텔레메트리 & 개인화 루프 (Product Brain)

Trigger
	•	모든 핵심 이벤트 후

Flow
	1.	실시간 로깅
	•	item_result{errors[], hintUsed, firstTry} 기반 패턴/정확도 집계
	2.	상위 패턴 1–3개 산출
	•	최근 50문항 EWMA, 정복률 공식(EWMA × (1−hint_rate)^α × (first_try_rate)^β) 적용
	3.	홈·푸시·복습 추천 동기화
	•	패턴 카드 업데이트, 개인화 메시지·큐 생성

Data
	•	/users/{uid}/pattern_conquest, /reviews/{reviewId}, /session_metrics/{sessionId}
	•	pattern_update, recommend_review(Functions), telemetry_event(session_first_try_rate, hint_rate)

Design Rationale
	•	“패턴 히트맵 = 제품의 뇌”(최종 메모)

⸻

12) 가장 중요한 분기/엣지 케이스 요약
	•	세션 중 힌트 4회 초과 → 점수 50% 절삭 + 다음 세션 난이도 하향 안내
	•	정답 다양성 → 토큰 메타데이터 허용 집합 기반, 미매칭 발생 시 QA 툴로 즉시 리포트
	•	스트릭 깨짐 + 토큰 0개 → Brain Token 미판매 안내 + 다음 학습 추천, 위젯/단축어 노출 강화
	•	저사양·발열 → “효과 절약 모드” 자동 전환(애니메이션·파티클 감소)
	•	앱 크래시/Live Activity 중단 → 복귀 시 최근 체크포인트 복원 + Live Activity 재등록
	•	알림 비허용 → 위젯 온보딩 및 홈 상단 스케줄러 카드로 대체 Trigger

⸻

13) 플로우–데이터–KPI 매핑(핵심만)

플로우	핵심 데이터 쓰기	KPI 기여
온보딩/튜토리얼	profile.provisionalLevel / level_test_attempts / tutorial_done	Activation(온보딩 + 체크포인트1 ≥60%)
세션 3단계	sessions / attempts / checkpoints / session_metrics(firstTryRate, hintRate)	Completion ≥80%(Phase2), 최초시도 정확도 60%↑
패턴 복습	pattern_conquest / review_metrics(EWMA)	정복률 Δ≥+10%p, 힌트 의존도 25%↓
스트릭/토큰	streak / brain_tokens / reward_pending	Day-7 Retention 35→45%, Brain Token 사용률 60%
푸시/딥링크	notifications / push_* / deep_action	Open ≥20%, Deep Action ≥12%
오프라인 복구	GRDB outbox(idempotency_key) → sync_queue	Completion 유지/크래시프리 ≥99.5%
