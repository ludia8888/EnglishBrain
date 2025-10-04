# 🔴 프론트엔드 코드 리뷰 - 치명적 문제 리스트

## Sprint 0-3 전체 코드 시니어 개발자 리뷰 결과

### ⚠️ Severity Levels
- 🔴 **CRITICAL**: 프로덕션 배포 불가, 즉시 수정 필요
- 🟡 **WARNING**: 프로덕션 위험, 가능한 빨리 수정
- 🔵 **INFO**: 개선 권장, 기술 부채

---

## 🔴 CRITICAL Issues

### Issue #1: API Configuration 보안 위험
**파일**: `ios-app/EnglishBrain/Services/APIConfiguration.swift:20-24`

**문제**:
```swift
EnglishBrainAPIAPI.basePath = "http://127.0.0.1:3001"  // ❌ 하드코딩
EnglishBrainAPIAPI.customHeaders = [
    "Authorization": "Bearer mock-dev-token"  // ❌ Mock token 하드코딩
]
```

**왜 치명적인가?**:
1. **프로덕션 작동 불가**: localhost URL로는 실제 서버 연결 불가
2. **앱 리젝 위험**: App Store Review에서 하드코딩된 token 발견 시 리젝
3. **환경 구분 없음**: Dev/Staging/Production 전환 불가능
4. **스레드 안전성 없음**: `customHeaders` dictionary 동시 접근 시 crash

**수정 방법**:
```swift
enum Environment {
    case development
    case staging
    case production

    var baseURL: String {
        switch self {
        case .development: return "http://127.0.0.1:3001"
        case .staging: return "https://staging-api.englishbrain.app"
        case .production: return "https://api.englishbrain.app"
        }
    }
}

class APIConfiguration {
    #if DEBUG
    static let environment: Environment = .development
    #else
    static let environment: Environment = .production
    #endif

    private let queue = DispatchQueue(label: "com.englishbrain.api-config")
    private var _customHeaders: [String: String] = [:]

    var customHeaders: [String: String] {
        get { queue.sync { _customHeaders } }
        set { queue.async(flags: .barrier) { self._customHeaders = newValue } }
    }
}
```

---

### Issue #2: LevelTestViewModel Mock 데이터 하드코딩
**파일**: `ios-app/EnglishBrain/Features/Onboarding/ViewModels/LevelTestViewModel.swift:54-160`

**문제**:
```swift
private func loadMockItems() {
    items = [
        LevelTestItem(id: "1", koreanSentence: "나는 영어를 공부한다", ...),
        // ... 10개 문항 모두 하드코딩 (100+ 라인)
    ]
}
```

**왜 치명적인가?**:
1. **PRD 위반**: "적응형 10문항" 구현 불가 - 사용자 레벨에 맞는 문제 제공 불가
2. **백엔드 무용지물**: 서버의 adaptive algorithm이 작동하지 않음
3. **콘텐츠 업데이트 불가**: 문제 추가/수정 시 앱 업데이트 필요
4. **개인화 불가능**: 모든 사용자가 동일한 문제 풀음

**수정 방법**:
```swift
func loadLevelTest() {
    isLoading = true

    OnboardingAPI.getLevelTest { [weak self] response, error in
        DispatchQueue.main.async {
            self?.isLoading = false

            if let error = error {
                self?.errorMessage = error.localizedDescription
                // Fallback to cached items or show error
            } else if let levelTest = response {
                self?.items = levelTest.items.map { apiItem in
                    LevelTestItem(
                        id: apiItem.itemId,
                        koreanSentence: apiItem.prompt.ko,
                        // ... map from API model
                    )
                }
            }
        }
    }
}
```

---

### Issue #3: SessionViewModel Race Condition
**파일**: `ios-app/EnglishBrain/Features/Session/ViewModels/SessionViewModel.swift:173-181`

**문제**:
```swift
if isCorrect {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
        self?.moveToNextItem()  // ❌ 타이머 참조 없음, 취소 불가
    }
}
```

**왜 치명적인가?**:
1. **다중 제출 버그**: 사용자가 빠르게 여러 번 submit하면 타이머 중복 실행
2. **상태 불일치**: delay 중 다른 액션 시 undefined behavior
3. **메모리 누수**: 타이머 cleanup 불가

**수정 방법**:
```swift
class SessionViewModel: ObservableObject {
    private var submitDelayWorkItem: DispatchWorkItem?

    func submitAnswer() {
        // ... validation

        // Cancel any pending submission
        submitDelayWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            if isCorrect {
                self?.moveToNextItem()
            } else {
                self?.clearAllSlots()
            }
        }

        submitDelayWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    deinit {
        submitDelayWorkItem?.cancel()
    }
}
```

---

### Issue #4: OnboardingViewModel 에러 처리 부족
**파일**: `ios-app/EnglishBrain/Features/Onboarding/ViewModels/OnboardingViewModel.swift:72-76`

**문제**:
```swift
if let error = error {
    self?.errorMessage = error.localizedDescription
    print("❌ Tutorial completion failed: \(error)")
    // Still proceed to complete step for better UX
    self?.currentStep = .complete  // ❌ 실패해도 진행
}
```

**왜 치명적인가?**:
1. **데이터 불일치**: 서버에 온보딩 미완료인데 클라이언트는 완료 상태
2. **재시도 불가**: 에러 발생 시 사용자가 다시 시도할 방법 없음
3. **추적 불가**: 분석 데이터가 부정확해짐

**수정 방법**:
```swift
if let error = error {
    self?.errorMessage = error.localizedDescription

    // Show retry UI instead of proceeding
    self?.showRetryAlert = true

    // Log for analytics
    Analytics.logError("onboarding_completion_failed", error: error)

    // DO NOT proceed - stay on current step
}
```

---

## 🟡 WARNING Issues

### Issue #5: HomeViewModel 불필요한 프로퍼티
**파일**: `ios-app/EnglishBrain/Features/Home/ViewModels/HomeViewModel.swift:18`

**문제**:
```swift
private var cancellables = Set<AnyCancellable>()  // ❌ 사용되지 않음
```

**영향**: 미미하지만 불필요한 메모리 사용

---

## 🔵 INFO: 개선 권장

### Issue #6: 에러 메시지 사용자 친화성
**전역 문제**: 모든 ViewModel에서 `error.localizedDescription` 직접 노출

**문제**:
- 기술적 에러 메시지가 사용자에게 그대로 보임
- "The request timed out" → 사용자가 이해하기 어려움

**권장**:
```swift
extension Error {
    var userFriendlyMessage: String {
        switch self {
        case let urlError as URLError:
            switch urlError.code {
            case .notConnectedToInternet:
                return "인터넷 연결을 확인해주세요"
            case .timedOut:
                return "서버 응답이 지연되고 있어요. 잠시 후 다시 시도해주세요"
            default:
                return "일시적인 오류가 발생했어요"
            }
        default:
            return "문제가 발생했어요. 다시 시도해주세요"
        }
    }
}
```

---

## 📊 통계

- **총 파일 검토**: 30+ Swift files
- **Critical Issues**: 4개
- **Warning Issues**: 1개
- **Info Issues**: 1개

## 🎯 우선순위

### 즉시 수정 필요 (이번 주)
1. Issue #1: API Configuration 환경 분리
2. Issue #2: LevelTest API 통합
3. Issue #3: SessionViewModel race condition

### 다음 스프린트
4. Issue #4: 에러 처리 개선
5. Issue #5, #6: 코드 정리

---

**리뷰 완료일**: 2025-10-04
**리뷰어**: Senior iOS Developer (via Claude Code)
