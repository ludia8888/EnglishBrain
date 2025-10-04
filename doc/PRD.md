English Brain — PRD v2.0 (iOS • Swift/SwiftUI)

문서 버전: v2.0
문서 상태: Implementation-ready
오너: PM/Founder (시현님)
작성일: 2025-10-04 (KST)
최종 수정일: 2025-10-04 (KST) — Gamification & Retention 통합
타깃 플랫폼: iOS (Swift/SwiftUI) — Android(Kotlin)는 후속 페이즈

⸻

0. Executive Summary

English Brain는 한국어 화자의 **영어식 사고(SVO 중심)**를 체화시키는 인지 재구성 학습기다. 사용자는 한국어 예문을 보고 영어식 어순으로 토큰 블록을 드래그 앤 드롭하여 문장을 생성한다. 핵심 가치는 **문법 지식이 아닌 ‘생각 순서’**를 훈련하는 데 있으며, 일일 10–15분 루틴, 즉각 피드백, 패턴별 개인화 복습으로 **생성 능력(Output)**을 빠르게 끌어올린다.

⸻

1. 목표(Goals) & 비목표(Non-goals)

1.1 Goals
	1.	SVO 사고 전환: 초급–중급 한국어 화자가 영어 문장을 만들 때 동사→목적어 순서를 자동으로 떠올리도록 회로화.
	2.	습관 형성: 푸시 알림/스트릭/미션으로 7일 차 유지율 ≥ 35% 달성.
	3.	짧은 세션 성취감: 프로파일 기반 8–12분(기본) / 12–18분(심화) 내 12문장 완성 루프 제공, 세션 완료율 80% 이상.
	4.	개인화 복습: 사용자별 **오류 패턴(시간/빈도 부사, 관사, 전치사, 조동사)**을 자동 탐지·처방.

1.2 Non-goals
	•	종합 문법 강의/해설 앱 아님(텍스트 강의 X).
	•	원어민 발음·스피킹 교정 1:1 코칭 범위 바깥(후속 페이즈).

⸻

2. 성공 지표(KPIs)
	•	Activation: 온보딩 완료 + 첫 세션 체크포인트1 도달(72h 내) ≥ 60%.
	•	Retention: Day-1 ≥ 55%, Day-7 ≥ 35%(목표 45–50%), Day-14 ≥ 25%, Day-28 ≥ 18%.
	•	Session Completion: Phase 2 종료 기준 ≥ 80%, 전체 12문장 완료율 목표 88–92%.
	•	Avg Sentences/Session: ≥ 12(심화 세션은 12문장 유지, 난이도로 차별화).
	•	Pattern Quality: 정복률 상승(주간 Δ≥+10%p) + 힌트 의존도(세션당 ≤ 25%) + 최초 시도 정확도(≥ 60%).
	•	Push 성과: Open Rate ≥ 20%, Deep Action Rate(세션/복습 진입) ≥ 12%.
	•	Paywall Conv. (그로스 단계): 트라이얼→구독 전환 ≥ 4–6%.

⸻

2.5 행동심리학 기반 설계 원칙

English Brain의 리텐션 설계는 행동심리학 4대 원리에 기반합니다:

**Trigger → Action → Reward → Investment** (도파민 루프)

| 심리 원리 | 적용 메커니즘 | 구현 위치 |
|-----------|--------------|----------|
| **Loss Aversion** (손실 회피) | Streak Freeze (Brain Token으로 복구 가능) | Section 6.6 |
| **Progress Feedback** (진행 피드백) | 패턴 정복률 시각화, 주간 성장 그래프 | Section 6.4 |
| **Micro-commitment** (미시 목표) | 3단계 미션 체크포인트 (Warm-up → Focus → Cool-down) | Section 6.2 |
| **Variable Reward** (예측불가 보상) | Brain Burst 모드 (5세션당 1회 랜덤) | Section 6.8 (MVP+) |
| **Embodied Learning** (체화 학습) | 드래그 + 3중 피드백 (시각/청각/햅틱 동시) | Section 6.2 |

**핵심 설계 슬로건**:
> "지식이 아니라 회로를 강화하는 앱 — Think like English, not translate."

⸻

3. 타깃 & 페르소나
	•	Persona A (대학생/취준생, TOEIC 600–800): 독해는 되는데 말문이 막힘. 단어는 아는데 문장 생성이 약함. 하루 10분 투자.
	•	Persona B (직장인, 재도전러): 아침/출퇴근 5–10분 루틴. 푸시 알림과 스트릭이 동기.
	•	Persona C (학부모/교사): 규칙적인 패턴 훈련과 진행 리포트를 선호.

⸻

4. 핵심 가치/근거(Design Rationale)
	•	한국어(SOV)와 영어(SVO)의 어순 차가 생성 능력 병목.
	•	손 기반 조작(드래그) + 즉각 피드백은 절차기억을 강화(Embodied Learning).
	•	**오류 기반 강화학습(Error-driven)**과 **반복 간격(Spaced Repetition)**이 장기 기억 전이에 유리.

⸻

5. 사용자 여정(First-run → Daily → Review)
	1.	온보딩: 적응형 레벨 테스트(10문항) → 튜토리얼 1문장 체험 → 홈.
	2.	데일리 세션: 오늘의 목표(12문장/8–12분 또는 12–18분) → 문제 풀이(힌트/피드백) → 완료 리포트.
	3.	개인화 복습: 주간 오답 패턴 집중 코스(시간/빈도/관사/전치사/조동사 등).
	4.	레벨업: 레벨2(조동사), 레벨3(진행/완료), 레벨4(부정/의문), 레벨5(관계/분사) 순으로 해금.

⸻

6. 기능 요구사항(Functional Requirements)

6.1 온보딩/레벨 테스트
	•	한국어 문장 제시 + E-토큰 4–6개 제공(난이도에 따라 변동).
	•	드래그로 [S] [V] [O] [M] 슬롯 채우면 즉시 채점.
	•	첫 5문항은 고정 시드, 이후 5문항은 적응형(정확도/힌트 사용 기반)으로 출제.
	•	초기 추천 레벨은 10문항 점수 + 첫 2회 세션 성과를 합산해 확정.
	•	튜토리얼에서 힌트 단계(텍스트 → 슬롯 라벨) 표시.

수용 기준
	•	1초 내 오디오/진동/시각 피드백.
	•	오답 시 튕김 애니메이션(≤800ms) + 교정 메시지.

6.2 학습 세션(메인 루프)

**3단계 미션 구조** (Micro-commitment 설계)

세션은 3개 체크포인트로 분리하여 중간 이탈을 방지하고 완결감을 극대화합니다:

```
┌─────────────────────────────────────────────────┐
│ Phase 1: Warm-up (3문장, 2-3분)                 │
│ → 체크포인트 1: "두뇌 예열 완료! 🔥"            │
├─────────────────────────────────────────────────┤
│ Phase 2: Focus Zone (6문장, 6-8분)              │
│ → 체크포인트 2: "집중 모드 돌파! ⚡"            │
├─────────────────────────────────────────────────┤
│ Phase 3: Cool-down (3문장, 2-3분)               │
│ → 최종 리포트: "오늘의 회로 강화 완료! 🧠"      │
└─────────────────────────────────────────────────┘
```

**문제 구성**
	•	K-문장, 빈 슬롯(프레임), E-토큰 풀(정답 + 오답 디스트랙터).
	•	슬롯은 역할(S/V/O/M) + 세부 속성(시제, 수식어 타입)으로 정의하고, 허용 토큰/순열 세트를 포함해 동의 표현·부사 위치 변형을 초기 범위부터 허용.
	•	토큰 메타데이터에 동의어 그룹/형태소 변형을 명시하여 자동 교정 시 대체 표현을 안내(예: "a friend" ↔ "my friend").
	•	힌트 시스템 (사용자 레벨별 적응형):
		○	초급 사용자: 자동으로 1단계 힌트(영어식 순서 한글 힌트) 표시, 이후 단계 요청 시 제공.
		○	중급 사용자: 요청 시에만 힌트 제공. ①영어식 순서 한글 힌트 ②슬롯 라벨(S/V/O/M) ③정답 후보 하이라이트(레벨/쿨다운 제한).
		○	상급 사용자: 힌트 사용하지 않고 문제 해결 시 보너스 포인트 제공. 요청 시 힌트 이용 가능.
	•	세션 힌트 한도: Warm-up 1회, Focus 2회, Cool-down 1회(총 4회) 기본 제공. 초과 사용 시 점수 50% 감소 + 다음 세션 난이도 하향.
	•	힌트 단계별 가중치: 텍스트(-10%) → 슬롯 라벨(-20%) → 후보 하이라이트(-35%), 힌트를 사용하면 콤보 즉시 중단.

**3중 피드백 시스템** (Embodied Learning)

정답/오답 판정 시 즉시 3개 채널로 동시 피드백:

| 피드백 채널 | 정답 시 | 오답 시 | 콤보 시 |
|------------|---------|---------|---------|
| **시각** | 블록 파티클 효과 (≤200ms, 초록 불꽃) | 튕김 애니메이션 (≤800ms) | 화면 가장자리 빛 효과 |
| **청각** | "딩동" (볼륨 30%) | "툭" 경고음 (볼륨 30%) | 레이어링 사운드 (딩-동-딩) |
| **햅틱** | Light Impact | Medium Impact | Heavy Impact |

**채점/추측 제어**
	•	기본 가중치: 순서 60%, 형태(시제/관사/단복수) 25%, 위치 규칙(부사/전치사) 15%.
	•	최초 시도 성공 가중치: 첫 시도 성공 시 ×1.15, 두 번째 시도 ×0.95, 세 번째 시도부터 ×0.75.
	•	힌트 가중치는 "힌트 단계별 가중치" 표와 동일하게 곱연산, 콤보는 힌트 사용/오답 시 리셋.
	•	추측 드래그 억제: 동일 슬롯에 3회 이상 오답 시 타임아웃(2초) + 코칭 메시지 제공.

**수용 기준**
	•	평균 블록 드래그 지연 ≤ 16ms(60fps 체감).
	•	드래그 중 스케일 효과(1.1배), 햅틱 피드백 즉시 제공.
	•	파티클 효과 렌더링 ≤ 200ms, 60fps 유지.
	•	체크포인트 전환 애니메이션 ≤ 500ms.
	•	전체 세션 크래시율 ≤ 0.5%.

**세션 시간 정책**
	•	문장당 목표 30–45초, 힌트·재시도 포함 최대 60초.
	•	시도 2회 초과 시 다음 문장 권유(UX 카피: "이번 문장은 잠시 뒤에 다시 도전해요!").
	•	세션 하드캡 18분(심화 세션도 동일), 초과 시 요약 리포트로 자동 종료.

6.3 오답 교정/피드백
	•	잘못 배치된 블록은 자동 교체 애니메이션으로 올바른 상대 위치를 시연.
	•	강화된 텍스트 코칭: 설명 + 예시 제공.
		○	예: "영어는 동사 → 목적어 순서예요.\n      한국어: 일기를 썼다 → 영어: wrote a diary"

6.4 개인화 복습(패턴 코칭)

**패턴 정복 시스템** (Progress Feedback 설계)

오류 패턴을 "과제"가 아닌 "정복 대상"으로 리프레임하여 심리적 동기 강화:

**패턴 카드 UI**
```
┌──────────────────────────────────────┐
│ 🎯 전치사 정복률                     │
│ ████████░░ 75%                       │
│ "3일 연속 향상 중! 🔥"               │
│                                      │
│ 최근 오답: in/on/at 혼동 (5회)       │
│ [지금 복습하기] 버튼                 │
└──────────────────────────────────────┘
```

**패턴 추출 로직**
	•	최근 50문항을 지수 가중 이동 평균(EWMA, λ=0.2)으로 집계하여 상위 1–3 패턴을 도출.
	•	정복률 = EWMA(correct) × (1 − hint_rate)^α × (first_try_rate)^β (초기 α=0.5, β=0.5, 추후 ML로 튜닝).
	•	추세 분석: 상승(Δ≥+5%p) → "🔥", 정체(|Δ|<2%p) → "→", 하락(Δ≤−5%p) → "⚠️".

**미니 코스 추천**
	•	해당 패턴만 포함된 미니 코스(5–8문장) 자동 생성.
	•	난이도: 현재 정복률 기반 적응형 (75% 이상: 심화, 50% 미만: 기초).

**감정형 피드백 룰**

| 정복률 | 추세 | 피드백 메시지 |
|--------|------|--------------|
| ≥ 80% | 🔥 향상 | "완벽해요! 이 패턴은 이제 당신 것입니다 🏆" |
| 60-79% | 🔥 향상 | "You're on fire! 계속 이 속도로! 🔥" |
| 40-59% | → 정체 | "조금만 더 연습하면 돌파할 수 있어요 💪" |
| < 40% | ⚠️ 하락 | "괜찮아요, 어려운 패턴이에요. 오늘 다시 도전! 🌱" |

**학습 후 피드백**
	•	기존: "패턴 오답률 x% ↓"
	•	개선: "전치사 정복률 60% → 75% (+15%) 🎉\n평균보다 2배 빠른 성장!"
	•	주간 성장 그래프 표시 (꺾은선 그래프, 7일 추이).

6.5 레벨/커리큘럼
	•	레벨1: SVO + 시간/장소 1개.
	•	레벨2: 조동사(can/will), 빈도 부사 위치.
	•	레벨3: 진행형/현재완료(기초), 간접목적(to/for).
	•	레벨4: 부정/의문(생성 모드는 후순위), 전치사 2개 이상.
	•	레벨5: 관계절/분사구문(슬롯 세분화).
	•	토큰 수 가이드: 초급 3–5개, 중급 6–7개, 상급 7–8개(9개 이상은 MVP+).
	•	Modifier 슬롯(M)을 시간/장소/방법/빈도 서브 역할로 태깅, 위치 규칙을 세밀하게 피드백.

6.6 습관화(리텐션)

**Trigger 시스템 강화**

| Trigger 채널 | 기존 | 개선 |
|-------------|------|------|
| **푸시 알림** | 08:00 고정 | 개인화 시간대 + 전날 오답 패턴 기반 메시지 |
| **위젯 (WidgetKit)** | 실시간 진행도 표시 | 최근 동기화 기준 남은 문장/스트릭 현황 + CTA |
| **Live Activity (ActivityKit)** | 고려하지 않음 | 세션 진행 중 체크포인트/콤보 실시간 반영 |
| **단축어 (App Intents)** | "오늘의 훈련 시작" | Phase별 바로 진입 (Warm-up/Focus/Cool-down) |

**역할 분리 원칙**
	•	위젯은 iOS 타임라인/리로드 예산에 맞춰 30분 단위 스냅샷을 표시(진입/리마인더 중심).
	•	세션 중 실시간 상태는 Live Activity가 담당(Phase 진행률/콤보/남은 문장), ActivityKit 업데이트 토큰 활용.
	•	앱 진입 시 위젯 스냅샷은 최신 서버 데이터로 자동 동기화.

**푸시 알림 개인화 예시**
```
기본 메시지 (패턴 없음):
"오늘의 영어 사고 훈련 10분 🧠 지금 시작할까요?"

패턴 기반 메시지 (전날 전치사 오답):
"어제 '전치사'에서 막혔어요. 오늘 3분 복습? 🎯"

연속 달성 (스트릭 6일):
"6일 연속! 내일이면 Brain Token 획득 🔥"
```

**Streak Freeze (Brain Token)** — Loss Aversion 설계

스트릭이 끊길 위기 시 복구 메커니즘 제공:

```
┌─────────────────────────────────────┐
│ Brain Token 시스템                  │
├─────────────────────────────────────┤
│ 획득: 7일 연속 달성 → 1개          │
│ 사용: 1개 소모 → 스트릭 1일 복구   │
│ 최대 보유: 3개                      │
│ 구매: 불가 (성과 기반 보상만 제공) │
├─────────────────────────────────────┤
│ 현재 보유: ⚡⚡░ (2개)             │
│ 다음 획득까지: 3일 남음            │
└─────────────────────────────────────┘
```

**심리적 효과**:
- Duolingo 데이터: Streak Freeze 도입 후 장기 유지율 60%↑
- Loss aversion 완화: 스트릭이 끊겨도 "복구 가능"하다는 안정감

**스트릭/미션/보상**
	•	스트릭 마일스톤: 3·7·14·30일 보상 (칭호, Brain Token, 특별 테마).
	•	Brain Token은 학습 성과/출석 보상으로만 지급, 유료 판매/가챠 미도입.
	•	일일 미션: 3단계 체크포인트 완료 시 각각 보상.
	•	주간 목표: 5/7일 달성 시 보너스 포인트.
	•	오프라인 완료 시 보상은 서버 동기화 시점에 확정(UX 카피: "인터넷 연결 시 자동으로 반영돼요").

**위젯 & Live Activity 가이드**
```
┌──────────────────────┐
│ English Brain        │
│ 오늘 목표 12문장 중  │
│ 4문장 남았어요 🔥     │
│ 현재 스트릭: 5일      │
│ 다음 Brain Token: 2일 │
│                      │
│ [지금 시작하기]       │
└──────────────────────┘
```
	•	Live Activity 레이아웃: Phase 진행률, 콤보 상태, 남은 문장 수를 Dynamic Island/잠금화면에 표시.
	•	WidgetKit은 App Intent/TimelineProvider로 30분 간격 업데이트, Live Activity는 pushToken 기반 15초 SLA 목표.

**플랜 경계선 (Free vs Pro)**
	•	Free: 일 1회 데일리 세션 + 추천 패턴 복습 1개 + 기본 리포트.
	•	Pro: 무제한 세션, 전체 패턴 복습, 상세 리포트, 테마/효과, 스트릭 테마.
	•	Trial(7일): 데일리 세션 2회 + 전체 복습 + 성장 그래프 강조, 5일차/7일차 value moment 직후 페이월 노출.
	•	Paywall/홈/결과 화면에서 동일 기준으로 라벨링, Brain Token은 유료 판매하지 않음.

**단축어 (App Intents)**
	•	"오늘의 훈련 시작" → Warm-up부터 시작
	•	"복습 시작" → 패턴 복습 바로 진입
	•	"내 정복률 확인" → 패턴 대시보드로 이동

6.7 결제(포스트-MVP)
	•	7일 트라이얼 → 월/연 구독(StoreKit 2)
	•	프리: 일일 1세션 제한 / 프로: 무제한 + 패턴 복습 + 리포트
	•	영수증 서버 검증(Functions) 및 구독 상태 동기화

⸻

6.8 게이미피케이션 & 리텐션 설계

**MVP 범위 3단계 구분**

English Brain의 게이미피케이션 요소는 단계별로 도입하여 핵심 학습 루프 검증 후 확장합니다.

### MVP Core (Week 2-9) — 생존 필수 요소 ✅

**목표**: Day-7 Retention 35% 달성, Session Completion 80% 달성

| 기능 | 우선순위 | 예상 공수 | 구현 위치 |
|------|---------|----------|----------|
| **3단계 미션 구조** | P0 필수 | +3일 | Section 6.2 |
| **Streak Freeze (Brain Token)** | P0 필수 | +2일 | Section 6.6 |
| **3중 피드백 시스템** | P1 권장 | +4일 | Section 6.2 |
| **패턴 정복 시각화** | P1 권장 | +3일 | Section 6.4 |
| **감정형 피드백 룰** | P1 권장 | +1일 | Section 6.4 |

**총 추가 개발**: 약 13일 (2주) → M6를 Week 16으로 조정

### MVP+ (Week 10-12) — 차별화 요소 🎯

**목표**: Session Completion 80%→88%, 입소문 유도

| 기능 | 설명 | 구현 방식 |
|------|------|----------|
| **Variable Reward (Brain Burst)** | 5세션당 1회 랜덤으로 포인트 2배 모드 | 서버 사이드 확률 로직 |
| **히든 패턴 발견** | 10개 패턴 중 3개 숨김, 조건 달성 시 해금 | Firestore rules + UI 잠금 |
| **미니 Brain Map** | 5개 패턴 노드 시각화 (SVO→조동사→진행형→완료형→관계절) | SwiftUI Shapes + 애니메이션 |
| **주간 성장 리포트** | 7일 추이 꺾은선 그래프 + "평균보다 2배 빠른 성장!" | Charts framework |

**Brain Burst 예시**:
```
[랜덤 트리거]
"⚡ Brain Burst 활성화!
다음 문장 정답 시 포인트 2배 획득!"

[정답 시]
"+20 포인트 (Brain Burst 보너스!) 🔥"
```

### Post-MVP (Week 13+) — 확장 로드맵 🚀

**검증 후 도입 (MVP 데이터 기반 의사결정)**

| 기능 | 목적 | 복잡도 |
|------|------|--------|
| **Brain League** | 주간 리그, 친구 초대 (협업/경쟁) | High (소셜 인프라) |
| **AI 페르소나 코치** | LLM 기반 개인화 피드백 | Very High (LLM 비용) |
| **Brain Diary** | 학습 문장으로 일기 작성 (Output 연결) | Medium |
| **Neural Growth 3D** | 시냅스 시각화 (3D 메타포) | High (SceneKit) |
| **Challenge Mode** | 일일 전세계 동일 문장 챌린지 | Medium |

**제외 이유**:
- MVP는 **습관 형성 + 패턴 정복**에 집중
- 소셜/AI는 사용자 베이스 확보 후 도입 (네트워크 효과)
- 3D는 폴리싱 수준, ROI 불명확

⸻

7. 비기능 요구사항(Non-functional)
	•	콜드 스타트 ≤ 2.0s(중저가 기기 기준).
	•	세션 중 프레임 드랍 ≤ 3%(@60fps, ProMotion 120Hz 최적화 고려).
	•	오프라인 모드:
		○	세션 패키지는 GRDB.swift(SQLite 기반) 사용하여 사전 캐시 (Core Data보다 경량/빠름).
		○	세션 패키지 미리 다운로드하여 완전한 오프라인 학습 지원.
		○	채점 로컬/서버 하이브리드 모드.
	•	배터리: 20분 세션에서 < 3% 소모(중급 기기).

⸻

8. SwiftUI 구현 스케치(간단 의사코드)

### 8.1 세션 메인 뷰 (3단계 미션 구조)

```swift
struct SessionView: View {
  @StateObject private var viewModel: SessionViewModel
  @State private var currentPhase: SessionPhase = .warmup

  enum SessionPhase {
    case warmup, focus, cooldown

    var sentenceCount: Int {
      switch self {
      case .warmup, .cooldown: return 3
      case .focus: return 6
      }
    }

    var title: String {
      switch self {
      case .warmup: return "Warm-up 🔥"
      case .focus: return "Focus Zone ⚡"
      case .cooldown: return "Cool-down 🧠"
      }
    }
  }

  var body: some View {
    VStack(spacing: 16) {
      // 진행도 헤더
      ProgressHeaderView(phase: currentPhase,
                        completed: viewModel.completedCount,
                        total: currentPhase.sentenceCount)

      // 문제 영역
      ProblemView(viewModel: viewModel)

      // 체크포인트 완료 시 애니메이션
      if viewModel.isCheckpointReached {
        CheckpointCelebrationView(phase: currentPhase)
          .transition(.scale.combined(with: .opacity))
          .onAppear {
            HapticManager.impact(.heavy)
            AudioManager.play(.checkpoint)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
              moveToNextPhase()
            }
          }
      }
    }
  }

  private func moveToNextPhase() {
    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
      switch currentPhase {
      case .warmup: currentPhase = .focus
      case .focus: currentPhase = .cooldown
      case .cooldown: showFinalReport()
      }
    }
  }
}
```

### 8.2 문제 뷰 (드래그앤드롭 + 3중 피드백)

```swift
struct ProblemView: View {
  @ObservedObject var viewModel: SessionViewModel
  @State private var slots: [Slot] = [Slot(id:"S"), Slot(id:"V"), Slot(id:"O"), Slot(id:"T")]
  @State private var tokens: [Token] = Token.sampleShuffled()
  @State private var dragOffset: CGSize = .zero
  @State private var isValidDrop: Bool = false
  @State private var showParticles: Bool = false

  var body: some View {
    VStack(spacing: 16) {
      // 슬롯 영역
      HStack {
        ForEach(slots) { slot in
          SlotTileView(slot: slot)
            .dropDestination(for: Token.self) { items, _ in
              if let t = items.first { assign(token: t, to: slot) }
              return true
            }
        }
      }

      // 토큰 영역
      FlowLayout(spacing: 8) {
        ForEach(tokens) { t in
          TokenChipView(token: t)
            .draggable(t) {
              TokenChipView(token: t)
                .scaleEffect(1.1) // 드래그 중 시각적 피드백
                .onAppear {
                  HapticManager.impact(.light) // 드래그 시작 시 햅틱
                }
            }
        }
      }

      // 파티클 효과 레이어
      if showParticles {
        ParticleEffectView(type: .success)
          .transition(.opacity)
      }
    }
  }

  private func assign(token: Token, to slot: Slot) {
    slot.token = token

    if slots.allSatisfy({ $0.token != nil }) {
      let placed = slots.compactMap { $0.token?.label }
      let result = Scoring.evaluate(placed: placed, answer: viewModel.currentAnswer)

      // 3중 피드백 트리거
      triggerTripleFeedback(result: result)
    }
  }

  // 3중 피드백 시스템
  private func triggerTripleFeedback(result: ScoringResult) {
    if result.isCorrect {
      // 시각: 파티클 효과 (≤200ms)
      withAnimation(.easeOut(duration: 0.2)) {
        showParticles = true
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
        showParticles = false
      }

      // 청각: 정답 사운드
      AudioManager.play(.correct, volume: 0.3)

      // 햅틱: Light impact
      HapticManager.impact(.light)

      // 콤보 체크
      if viewModel.comboCount >= 3 {
        triggerComboFeedback()
      }
    } else {
      // 시각: 튕김 애니메이션
      withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
        // 슬롯 shake 애니메이션
      }

      // 청각: 오답 사운드
      AudioManager.play(.incorrect, volume: 0.3)

      // 햅틱: Medium impact
      HapticManager.impact(.medium)
    }
  }

  private func triggerComboFeedback() {
    // 시각: 화면 가장자리 빛 효과
    withAnimation(.easeInOut(duration: 0.5)) {
      // 테두리 글로우 효과
    }

    // 청각: 레이어링 사운드
    AudioManager.play(.combo, volume: 0.3)

    // 햅틱: Heavy impact
    HapticManager.impact(.heavy)
  }
}
```

### 8.3 체크포인트 축하 뷰

```swift
struct CheckpointCelebrationView: View {
  let phase: SessionView.SessionPhase

  var body: some View {
    VStack(spacing: 16) {
      // 아이콘 애니메이션
      Text(phase == .warmup ? "🔥" : phase == .focus ? "⚡" : "🧠")
        .font(.system(size: 80))
        .scaleEffect(animating ? 1.2 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.6).repeatCount(3), value: animating)

      // 메시지
      Text(getMessage())
        .font(.title2.bold())
        .foregroundStyle(.primary)

      Text(getSubMessage())
        .font(.body)
        .foregroundStyle(.secondary)
    }
    .padding(32)
    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    .onAppear {
      animating = true
    }
  }

  private func getMessage() -> String {
    switch phase {
    case .warmup: return "두뇌 예열 완료!"
    case .focus: return "집중 모드 돌파!"
    case .cooldown: return "오늘의 회로 강화 완료!"
    }
  }

  @State private var animating = false
}
```

### 8.4 파티클 효과 (정답 시)

```swift
struct ParticleEffectView: View {
  enum EffectType {
    case success, combo
  }

  let type: EffectType
  @State private var particles: [Particle] = []

  struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGVector
    var scale: CGFloat
    var opacity: Double
  }

  var body: some View {
    Canvas { context, size in
      for particle in particles {
        var path = Path()
        path.addEllipse(in: CGRect(x: particle.position.x, y: particle.position.y,
                                   width: 8 * particle.scale, height: 8 * particle.scale))
        context.fill(path, with: .color(.green.opacity(particle.opacity)))
      }
    }
    .onAppear {
      generateParticles()
      animateParticles()
    }
  }

  private func generateParticles() {
    particles = (0..<20).map { _ in
      Particle(
        position: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2),
        velocity: CGVector(dx: .random(in: -200...200), dy: .random(in: -200...200)),
        scale: .random(in: 0.5...1.5),
        opacity: 1.0
      )
    }
  }

  private func animateParticles() {
    Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
      particles = particles.map { particle in
        var p = particle
        p.position.x += p.velocity.dx * 0.016
        p.position.y += p.velocity.dy * 0.016
        p.opacity -= 0.05
        return p
      }

      if particles.allSatisfy({ $0.opacity <= 0 }) {
        timer.invalidate()
      }
    }
  }
}
```

⸻

9. 정보구조(IA) & 화면 목록
	•	Auth/Onboarding: Splash, Intro Slides, Level Test, Tutorial.
	•	Home: 오늘의 목표, 최근 기록, 빠른 시작.
	•	Session: 문제/힌트/피드백, 진행도.
	•	Result: 정답률, 스트릭, 패턴 분석.
	•	Review: 패턴 코스 선택/완료.
	•	Profile/Settings: 레벨, 푸시, 언어, 결제.
	•	Paywall(후속): 플랜 비교, 혜택, 트라이얼.

⸻

10. 데이터 모델(초안)

10.1 레슨/문항(JSON)

{
  "id": "lesson_0001",
  "k_sentence": "나는 오늘 일기를 적었다",
  "roles": [
    {"text": "나는", "role": "S"},
    {"text": "일기를", "role": "O"},
    {"text": "적었다", "role": "V", "tense": "past"},
    {"text": "오늘", "role": "T"}
  ],
  "frame": ["S", "V", "O", "T"],
  "e_tokens_answer": ["I", "wrote", "a diary", "today"],
  "e_tokens_pool": ["I", "wrote", "a diary", "today", "the", "yesterday"],
  "hints": {
    "k_reordered_like_en": "나는 적었다 일기를 오늘",
    "rules": [
      "영어는 S-V-O 기본", "시간 부사는 문장 끝 우선"
    ]
  },
  "level": 1,
  "tags": ["time_adverb"],
  "lang": "ko-KR"
}

10.2 Firestore(제안)

/users/{uid}
  profile: {level, streak, timezone, prefs}
  stats: {totalSessions, accuracy, minutes}
  patterns: {time_adverb: {...}, article: {...}}
/sessions/{sessionId}
  {uid, startedAt, completedAt, level, items: [...], score}
/attempts/{attemptId}
  {uid, lessonId, placedTokens:[...], score, errors:[...], ts}
/lessons/{lessonId}
  {...(위 JSON)}
/reviews/{reviewId}
  {uid, pattern, queue:[lessonIds], progress}
/notifications/{id}
  {uid, type, scheduledAt, status}
/purchases/{uid}
  {plan, startedAt, renewedAt, status}

⸻

10.3 게이미피케이션 데이터 모델

**Firestore 확장 컬렉션**

```
/users/{uid}/brain_tokens
  {
    count: 2,                    // 현재 보유 개수
    maxCount: 3,                 // 최대 보유 제한
    earnedHistory: [
      {timestamp: "2025-10-01T09:00:00Z", reason: "7day_streak"},
      {timestamp: "2025-09-24T09:00:00Z", reason: "7day_streak"}
    ],
    usedHistory: [
      {timestamp: "2025-09-28T22:00:00Z", restoredStreakDate: "2025-09-28"}
    ]
  }

/users/{uid}/session_checkpoints
  {
    sessionId: "sess_001",
    phase: "warmup",             // warmup | focus | cooldown
    completedAt: "2025-10-04T10:15:00Z",
    sentencesCompleted: 3,
    accuracy: 0.85,
    avgTimePerSentence: 18.5     // 초
  }

/users/{uid}/pattern_conquest
  {
    patternId: "time_adverb",
    conquestRate: 0.75,          // 최근 10문항 정답률
    trend: "up",                 // up | stable | down
    trendDays: 3,                // 연속 향상/하락 일수
    recentAttempts: [
      {lessonId: "lesson_042", correct: true, ts: "..."},
      {lessonId: "lesson_038", correct: false, ts: "..."},
      // ... 최근 10개
    ],
    weeklyGrowth: [
      {date: "2025-09-28", rate: 0.60},
      {date: "2025-09-29", rate: 0.65},
      {date: "2025-09-30", rate: 0.70},
      // ... 7일
    ],
    lastReviewedAt: "2025-10-03T14:00:00Z",
    nextReviewDue: "2025-10-05T09:00:00Z"  // Spaced Repetition
  }

/users/{uid}/combo_stats
  {
    currentCombo: 5,
    maxCombo: 12,
    maxComboDate: "2025-10-02",
    comboBreaks: 3               // 총 콤보 끊김 횟수
  }

/sessions/{sessionId}/phase_results
  {
    phase: "focus",
    startedAt: "2025-10-04T10:15:00Z",
    completedAt: "2025-10-04T10:23:00Z",
    sentenceResults: [
      {lessonId: "lesson_015", correct: true, timeMs: 18500, hints: 0},
      {lessonId: "lesson_022", correct: false, timeMs: 32000, hints: 2},
      // ... 6개 (Focus Zone)
    ],
    accuracy: 0.83,
    avgTime: 22.3
  }

/gamification_events/{eventId}
  {
    type: "brain_burst",
    userId: "uid",
    triggeredAt: "2025-10-04T11:00:00Z",
    sessionId: "sess_005",
    sentenceId: "lesson_088",
    bonusPoints: 20,
    userReaction: "completed"    // completed | skipped | failed
  }
```

**로컬 캐시 (GRDB.swift)**

```sql
-- Brain Tokens (오프라인 사용 대비)
CREATE TABLE brain_tokens (
  user_id TEXT PRIMARY KEY,
  count INTEGER,
  max_count INTEGER,
  earned_json TEXT,              -- JSON array
  used_json TEXT,                -- JSON array
  synced_at INTEGER
);

-- Session Checkpoints (로컬 진행 추적)
CREATE TABLE session_checkpoints (
  id TEXT PRIMARY KEY,
  session_id TEXT,
  phase TEXT,                    -- warmup | focus | cooldown
  completed_at INTEGER,
  sentences_completed INTEGER,
  accuracy REAL,
  avg_time REAL,
  synced INTEGER DEFAULT 0
);

-- Pattern Conquest (오프라인 분석)
CREATE TABLE pattern_conquest (
  pattern_id TEXT PRIMARY KEY,
  conquest_rate REAL,
  trend TEXT,
  trend_days INTEGER,
  recent_attempts_json TEXT,     -- JSON array
  weekly_growth_json TEXT,       -- JSON array
  last_reviewed_at INTEGER,
  next_review_due INTEGER,
  synced_at INTEGER
);
```

**데이터 동기화 전략**
- 세션 종료 시 Firestore에 일괄 업로드
- 오프라인 모드: GRDB에 저장 → 온라인 복귀 시 동기화
- 충돌 해결: 서버 타임스탬프 우선 (last-write-wins)

⸻

11. 알고리즘/로직

11.1 한국어 → 역할 태깅(Heuristics, MVP)
	•	S(주어): 체언+주격(이/가) 또는 화제표지(은/는) 우선.
	•	O(목적): 체언+목적격(을/를).
	•	T(시간): 오늘/어제/내일/매일/주말/월요일/3시/아침… 사전.
	•	L(장소): ~에서/~에(장소).
	•	V(동사): 용언 어간+어미(었/고 있다/겠다).
	•	Adj/Adv: 매우/아주/자주/종종/보통/빨리/천천히 등.

모호 시: 룰 우선 + 편집기 수기 검수(초기 500문항).

11.2 프레임 빌드
	•	기본: S → V → O → (M: T/L/Adv)
	•	레벨2: 빈도부사는 조동사 뒤/일반동사 앞(예: often).
	•	레벨3: 진행(be V-ing), 현재완료(have p.p.) 도입.
	•	레벨3~4: 간접목적(to/for), 전치사 2개 조합.

11.3 채점(Partial Credit)
	•	순서(60%): 상대 순서 일치(예: V가 O 앞).
	•	형태(25%): 시제/관사/단복수(초급은 정답 토큰 묶음으로 완화).
	•	위치(15%): 시간/빈도/장소 등 부사/전치사구의 위치 규칙.

11.4 간격 반복(Spaced Repetition)
	•	기본 큐: SM-2 변형 / 에빙하우스 계수 기반.
	•	성능 지표(Q=0–5)로 다음 복습 간격 업데이트.
	•	패턴별 큐(예: time_adverb 전용) 병행.

11.5 개인화 패턴 추출
	•	errors[]에서 규칙 태그 집계 → 최근 50문항 가중 이동 평균.
	•	상위 1–3 규칙을 Review 코스에 자동 주입.

⸻

12. 기술 설계(아키텍처)

12.1 클라이언트(iOS — Swift/SwiftUI)
	•	UI 프레임워크: SwiftUI (+ 필요 시 UIKit 혼용)
	•	상태관리: Observable/State/Environment + Combine (선택: TCA)
	•	드래그앤드롭:
		○	SwiftUI draggable/dropDestination, DragGesture 커스텀
		○	드래그 중 스케일 효과(1.1배) 및 햅틱 피드백 즉시 제공
		○	드래그 상태 추적(@State dragOffset, isValidDrop)으로 실시간 시각적 피드백
	•	애니메이션: withAnimation, Transaction
	•	햅틱/사운드: UIImpactFeedbackGenerator, AVAudioPlayer
	•	오프라인 캐시: GRDB.swift (SQLite 기반, Core Data보다 경량/성능 우수)
		○	세션 패키지 미리 다운로드
		○	로컬 채점 + 서버 동기화 하이브리드 모드
		○	스키마: sessions, attempts, checkpoints, outbox + idempotency_key, server_clock_snapshot 컬럼 포함
	•	Live Activity: ActivityKit, PushToken 등록(APNs) + 15초 SLA 업데이트, 세션 시작 시 activityAttributes 발급
	•	딥링크 상태 복원: NavigationPath/SceneStorage + App Router로 Warm-up/패턴 페이지 즉시 복원
	•	위젯/단축어: WidgetKit, App Intents (파라미터: entryPoint, patternId)
	•	알림: UNUserNotificationCenter(로컬), APNs/FCM(원격)
	•	결제: StoreKit 2
	•	분석: Firebase Analytics / Amplitude iOS SDK

12.2 백엔드(Firebase 우선)
	•	Auth: Email/Apple/Google(OAuth)
	•	Firestore: 사용자/세션/시도/패턴/레슨
	•	Functions: scoreAttempt, recommendReview, scheduleDailyPush, importLessons
		○	scheduleDailyPush는 사용자 타임존/Do-Not-Disturb(22:00~07:00) 룰 준수 + 가장 최근 학습 시점 기반

12.3 보안/권한
	•	Firestore Rules: attempts.uid == request.auth.uid
	•	최소권한 원칙, PII 분리, 결제 영수증 서버 검증

⸻

13. 콘텐츠 제작 파이프라인
	1.	저자 가이드: 문장 길이(6–10단어), 단어 빈도, 규칙 태그 표준.
	2.	에디터(스프레드시트) → JSON 변환 스크립트 → importLessons.
	3.	샘플 세트: 레벨1 200문항, 레벨2 200문항(베타 목표 400).

스프레드시트 컬럼 예:
id | k_sentence | roles(S/O/V/T/L/Adv) | frame | e_tokens_answer | e_tokens_pool | level | tags

⸻

14. UX 세부(상태/빈도/카피)

**도파민 최적화 피드백 타이밍 테이블**

| 이벤트 | 시각 피드백 | 청각 피드백 | 햅틱 피드백 | 타이밍 (ms) |
|--------|-----------|-----------|-----------|------------|
| **드래그 시작** | 블록 스케일 1.1배 | 없음 | Light Impact | 0 (즉시) |
| **정답** | 파티클 효과 (초록 불꽃) | "딩동" (볼륨 30%) | Light Impact | ≤ 200 |
| **오답** | 튕김 애니메이션 | "툭" 경고음 (볼륨 30%) | Medium Impact | ≤ 800 |
| **콤보 (3+ 연속)** | 화면 가장자리 빛 효과 | 레이어링 사운드 | Heavy Impact | ≤ 500 |
| **체크포인트 완료** | 전체 화면 축하 모달 | 성취 사운드 | Heavy Impact | 1500 (지속) |
| **Brain Burst 트리거** | 번개 효과 + 텍스트 | "파워업" 사운드 | Heavy Impact | ≤ 300 |
| **패턴 정복 향상** | 진행바 애니메이션 | "레벨업" 사운드 | Medium Impact | ≤ 600 |

**카피 톤 가이드라인**
- **비난 금지**: "틀렸어요" → "조금만 더!"
- **교정형**: "영어는 동사가 먼저 와요" ✅
- **감정 지원**: "괜찮아요, 어려운 패턴이에요" ✅
- **성장 강조**: "어제보다 18% 빨라졌어요!" ✅

**푸시 알림 메시지 변형 (A/B 테스트)**

| 타입 | 메시지 예시 | 의도 |
|------|------------|------|
| **기본** | "오늘의 영어 사고 훈련 10분 🧠 지금 시작할까요?" | 중립적 리마인더 |
| **패턴 기반** | "어제 '전치사'에서 막혔어요. 오늘 3분 복습? 🎯" | 개인화 + 성취 욕구 |
| **스트릭 강화** | "6일 연속! 내일이면 Brain Token 획득 🔥" | Loss aversion |
| **격려** | "3일 만에 정복률 +25%! 오늘도 도전? 💪" | Progress feedback |
| **유머** | "당신의 영어 뇌가 심심해해요 😴 깨워주세요!" | Playful tone |

**사운드 에셋 목록**
```
correct.wav         // 정답 "딩동" (440Hz, 0.3초)
incorrect.wav       // 오답 "툭" (낮은 톤, 0.2초)
combo.wav           // 콤보 레이어링 (3개 음 겹침, 0.5초)
checkpoint.wav      // 체크포인트 성취 (상승 멜로디, 1.5초)
brain_burst.wav     // Brain Burst 파워업 (전자음, 0.8초)
level_up.wav        // 패턴 정복 향상 (벨 소리, 0.6초)
```

**햅틱 강도 가이드**
- Light Impact: 드래그, 정답 (10–15ms)
- Medium Impact: 오답, 패턴 향상 (15–20ms)
- Heavy Impact: 콤보, 체크포인트, Brain Burst (20–30ms)
	•	기기 Capability 체크(Core Haptics 지원 여부) 후 미지원 단말 또는 무음/집중모드에서는 시각 피드백만 노출.
	•	무음 모드/배터리 세이브 상태 감지 시 자연스럽게 사운드/햅틱을 축소하고, 설정 > 환경설정에서 사용자가 수동으로 조정 가능.

⸻

15. 접근성(A11y)
	•	큰 터치 타겟(≥ 44pt), 대비 준수, 색맹 Safe 팔레트.
	•	진동/사운드 강도 조절.
	•	스크린리더 레이블: 슬롯/토큰 역할 설명.
	•	VoiceOver/스위치 컨트롤 모드에서는 토큰 리스트 + 슬롯 토글 방식으로 동등 과업 수행 가능하도록 설계.

⸻

16. 개인정보/컴플라이언스
	•	최소 수집 원칙: Email, OAuth ID, 닉네임, 학습 통계만 저장(PII 분리 스토리지 적용).
	•	학습 로그(세션/시도)는 24개월 보관 후 익명화, 사용자는 언제든 삭제/내보내기 요청 가능.
	•	삭제 플로우: 설정 > 개인정보에서 "데이터 삭제"(즉시 비활성 + 30일내 물리 삭제), "데이터 다운로드"(72시간 내 링크) 제공.
	•	한국 개인정보보호법(PIPA) 준수, 만 14세 미만 보호자 동의 수집.
	•	구독 결제: 영수증 서버 검증, 환불 정책 고지.
	•	안티 치트: attempts 로그에 client_started_at/server_received_at/latency 기록, 비정상 패턴 탐지 시 세션 플래그.

⸻

17. 품질/테스트 전략
	•	유닛: 채점 함수, 스케줄러, 힌트 로직.
	•	스냅샷/골든: SwiftUI 뷰 상태, 드래그 인터랙션.
	•	통합: 세션 흐름(12문장) 성공률.
	•	베타: 100명 클로즈드(2주) → 설문/행동 데이터.

⸻

18. 텔레메트리 이벤트 스키마(예)
	•	app_open, level_test_done{score, level}
	•	session_start{level, theme}, item_result{lessonId, correct, timeMs, errors:[...]}
	•	hint_used{stage}
	•	session_complete{accuracy, minutes, comboMax}
	•	pattern_update{top:[...]}
	•	review_complete{pattern, deltaError}
	•	streak_update{days}
	•	(후속) paywall_view, trial_start, purchase_success.

⸻

19. 릴리즈 계획 & 마일스톤 (게이미피케이션 통합 버전)

**총 개발 기간: 16주 (기존 14주 + 게이미피케이션 2주)**

### M0 (Week 0–1): 기반 구축
- 스켈레톤 앱, 네비게이션, 디자인 토큰
- GRDB.swift 데이터베이스 스키마 설계
- Firebase 프로젝트 초기 설정

### M1 (Week 2–4): 핵심 학습 루프
- 드래그앤드롭 코어 (SwiftUI draggable/dropDestination)
- 채점 v1 (순서 60%, 형태 25%, 위치 15%)
- 온보딩/레벨 테스트 (10문항 적응형) + 튜토리얼 (1문장 체험)

### M2 (Week 5–7): 세션 & 게이미피케이션 Core (P0)
- **3단계 미션 구조** (Warm-up → Focus → Cool-down) ✅ P0
- **3중 피드백 시스템** (시각/청각/햅틱 동시) ✅ P1
  - 파티클 효과 (정답 시 ≤200ms)
  - 콤보 피드백 (3+ 연속)
  - 체크포인트 축하 모달
- 힌트 시스템 v1 (3단계, 레벨별 적응형)
- 결과 화면 (정답률, 콤보, 시간)
- 로컬 캐시 (GRDB) + 오프라인 모드

**예상 추가 개발**: +7일 (3단계 미션 3일, 파티클 효과 4일)

### M3 (Week 8–9): 패턴 정복 & Streak Freeze (P0/P1)
- **패턴 정복 시스템** (Progress Feedback) ✅ P1
  - 패턴 카드 UI (정복률 75%, 추세 🔥)
  - 주간 성장 그래프 (꺾은선, 7일 추이)
  - **감정형 피드백 룰** (4개 등급별 메시지) ✅ P1
- **Streak Freeze (Brain Token)** ✅ P0
  - 7일 연속 → 1개 획득
  - 1개 소모 → 1일 복구
  - 최대 보유 3개
- 패턴 로깅/리뷰 v1
- 스트릭/미션/주간 목표
- 푸시 알림 (개인화 시간대 + 패턴 기반 메시지)
- 분석 SDK (Firebase Analytics)

**예상 추가 개발**: +4일 (패턴 UI 3일, Brain Token 로직 1일 - 감정형 피드백은 정적 메시지로 +1일 이미 포함)

### M4 (Week 10–11): MVP+ 차별화 & 콘텐츠
- **Brain Burst 모드** (Variable Reward) ✅ P2
  - 5세션당 1회 랜덤 트리거
  - 포인트 2배 보너스
- **미니 Brain Map** (패턴 노드 시각화) ✅ P2
  - 5개 패턴: SVO → 조동사 → 진행형 → 완료형 → 관계절
- 베타 콘텐츠 400문항 (레벨1 200 + 레벨2 200)
- QA/크래시 안정화
- 위젯 (WidgetKit) + 단축어 (App Intents)

**예상 추가 개발**: +2일 (Brain Burst 서버 로직 1일, Brain Map UI 1일)

### M5 (Week 12–13): Closed Beta
- Closed Beta 100명 (2주)
- 설문 + 행동 데이터 수집
- **핵심 검증 지표**:
  - Day-7 Retention 목표: 45–50% (기존 35%)
  - Session Completion 목표: 88–92% (기존 80%)
  - Brain Token 사용률 ≥ 60%
  - 패턴 정복 카드 클릭률 ≥ 40%
- 데이터 기반 튜닝 (피드백 타이밍, 체크포인트 메시지 등)

**기간 연장**: Week 12 → Week 12–13 (베타 기간 동일, 게이미피케이션 분석 추가)

### M6 (Week 14–16): 폴리싱 & Soft Launch
- 폴리싱 (애니메이션 최적화, 사운드 밸런싱)
- 성능 최적화 (60fps 유지, 파티클 효과 최적화)
- Soft Launch (국내 TestFlight/내부테스트)
- 최종 QA (크래시프리 세션율 ≥99.5%)

**기간 연장**: Week 13–14 → Week 14–16 (폴리싱 1주 추가)

⸻

**마일스톤별 게이미피케이션 요소 요약**

| 마일스톤 | 게이미피케이션 기능 | 우선순위 | 추가 공수 |
|---------|-------------------|---------|----------|
| M2 | 3단계 미션, 3중 피드백 | P0 + P1 | +7일 |
| M3 | 패턴 정복, Streak Freeze, 감정형 피드백 | P0 + P1 | +4일 |
| M4 | Brain Burst, Brain Map | P2 | +2일 |
| **총계** | | | **+13일 (약 2주)** |

⸻

20. 리스크 & 완화
	•	정답 다양성: 동의 표현/부사 위치 다양성 → 토큰 메타데이터 기반 허용 집합을 운영하고, QA 도구로 예외 입력을 수집해 주기적 업데이트.
	•	콘텐츠 스케일: 수기 제작 비용 → 저자 가이드/템플릿/반자동 태깅 툴.
	•	과도한 난이도 변동: 적응 난이도(오답률 기반 토큰 수/디스트랙터 조절).
	•	성능/발열:
		○	드래그앤드롭 애니메이션 최적화 (60fps 유지).
		○	GRDB.swift 사용으로 I/O 성능 개선.
		○	저사양 기기에서 애니메이션 효과 감소 모드.

⸻

21. 오픈 이슈(Open Questions)
	•	동형/유의 표현 허용 범위('a friend' vs 'my friend') 정책.
	•	리뷰 코스 길이(5 vs 8문장) AB 테스트 필요.
	•	힌트 시스템 적응형 레벨 분류 기준(초/중/상급) - 정답률/세션수 기반 자동 조정 로직.

⸻

22. 샘플 콘텐츠 세트(발췌)

Level 1 — 시간 부사
	•	K: 나는 어제 친구를 만났다
A: I / met / a friend / yesterday
Pool: [I, met, a friend, yesterday, the friend, my friend]
	•	K: 그녀는 오늘 점심을 먹었다
A: She / ate / lunch / today
Pool: [She, ate, lunch, today, a lunch, the lunch]

Level 2 — 조동사/빈도
	•	K: 그는 보통 아침에 운동한다
A: He / usually / exercises / in the morning
Pool: [He, usually, exercises, in the morning, exercise]

⸻

23. Firestore Rules(스니펫)

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
    match /attempts/{id} {
      allow create: if request.auth != null && request.resource.data.uid == request.auth.uid;
      allow read: if request.auth != null && resource.data.uid == request.auth.uid;
    }
    match /lessons/{lessonId} {
      allow read: if true; 
      allow write: if false; 
    }
  }
}


⸻

24. QA 체크리스트(발췌)
	•	온보딩 적응형 10문항: 초기 5문항 로딩 < 500ms, 추가 5문항 패치 < 300ms.
	•	드래그 히트 영역 오차 < 8pt
	•	힌트 버튼 3단계 순차 동작
	•	세션 이탈 후 복귀 시 진행 복원
	•	오프라인 모드에서 1세션 완료 가능
	•	패턴 분석 카드 1–3개 노출
	•	Live Activity 업데이트 지연 ≤ 5초, 위젯 스냅샷 갱신 ≤ 30분
	•	크래시프리 세션율 ≥ 99.5%

⸻

25. 용어집(Glossary)
	•	K-토큰: 한국어 띄어쓰기 단위(옵션: 조사 분리).
	•	E-토큰: 영어 생성 단위(lemma+기능).
	•	Frame: [S, V, O, M] 슬롯 구조.
	•	Pattern: 규칙군(시간/빈도/관사/전치사/조동사…).

⸻

최종 메모
	•	MVP 범위 고정: 레벨1–2, 콘텐츠 400문항, 채점 v1, 리뷰 v1.
	•	핵심 품질: 드래그 반응성, 오답 교정 애니메이션, 세션 루프 완결감.
	•	데이터: 패턴 히트맵이 곧 제품의 뇌. 수집·가시화에 공 들일 것.
