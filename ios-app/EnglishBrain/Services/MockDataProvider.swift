//
//  MockDataProvider.swift
//  EnglishBrain
//
//  Created by Codex on 10/5/25.
//

import Foundation
import EnglishBrainAPI

@MainActor
final class MockDataProvider {
    static let shared = MockDataProvider()

    private init() {}

    // Cache frequently reused fixtures so we keep derived state stable during a run
    private var cachedHomeSummary: HomeSummary?
    private var cachedSession: Session?

    func makeHomeSummary() -> HomeSummary {
        if let cachedHomeSummary {
            return cachedHomeSummary
        }

        let dailyGoal = HomeSummaryDailyGoal(sentences: 12, minutes: 15, tier: .basic)
        let progress = HomeSummaryProgress(
            sentencesCompleted: 7,
            minutesSpent: 9,
            lastSessionAt: Date().addingTimeInterval(-60 * 75)
        )
        let streak = HomeSummaryStreak(current: 6, longest: 18, freezeEligible: true)
        let brainTokens = HomeSummaryBrainTokens(available: 3, pending: 1)

        let actions: [HomeAction] = [
            HomeAction(
                type: .dailySession,
                title: "바로 오늘의 훈련 시작",
                subtitle: "12문장 목표까지 5문장 남았어요",
                deeplink: "/session/start"
            ),
            HomeAction(
                type: .review,
                title: "패턴 복습 진행",
                subtitle: "지난 3일간 약점 패턴 복습",
                deeplink: "/review/start",
                planRequired: .free
            ),
            HomeAction(
                type: .brainBurst,
                title: "Brain Burst 게이지 확인",
                subtitle: "다음 세션에서 2x 보너스가 대기중",
                deeplink: "/brain-burst"
            )
        ]

        let patternCards: [PatternCard] = [
            PatternCard(
                patternId: "pattern.svo.basic",
                label: "기본 SVO 어순",
                conquestRate: 0.62,
                trend: .declining,
                severity: 4,
                recommendedAction: actions[1],
                hintRate: 0.35,
                firstTryRate: 0.55
            ),
            PatternCard(
                patternId: "pattern.present-progressive",
                label: "현재진행형",
                conquestRate: 0.74,
                trend: .stable,
                severity: 3,
                recommendedAction: actions[0],
                hintRate: 0.18,
                firstTryRate: 0.68
            ),
            PatternCard(
                patternId: "pattern.question-tag",
                label: "부가의문문",
                conquestRate: 0.41,
                trend: .improving,
                severity: 5,
                recommendedAction: actions[1],
                hintRate: 0.44,
                firstTryRate: 0.39
            )
        ]

        let summary = HomeSummary(
            dailyGoal: dailyGoal,
            progress: progress,
            streak: streak,
            brainTokens: brainTokens,
            patternCards: patternCards,
            recommendedActions: actions
        )

        cachedHomeSummary = summary
        return summary
    }

    func makeSession(mode: SessionCreateRequest.Mode) -> Session {
        if let cachedSession {
            return cachedSession
        }

        let sessionId = UUID()
        let startedAt = Date()
        let expiresAt = startedAt.addingTimeInterval(60 * 60)

        func makeItem(
            id: String,
            korean: String,
            english: String,
            sequence: [(String, FrameToken.Role)]
        ) -> SessionItem {
            func slotLabel(for role: FrameToken.Role) -> String {
                switch role {
                case .s: return "주어"
                case .v: return "동사"
                case .o: return "목적어"
                case .m: return "부가"
                }
            }

            let tokens = sequence.enumerated().map { index, tuple in
                FrameToken(tokenId: "\(id)-\(index)", display: tuple.0, role: tuple.1)
            }

            let correctIds = tokens.map { $0.tokenId }

            let slots = sequence.enumerated().map { index, tuple -> FrameSlot in
                let slotRole = FrameSlot.Role(rawValue: tuple.1.rawValue) ?? .s
                let isOptional = tuple.1 == .m || (tuple.1 == .o && index > 1)
                return FrameSlot(role: slotRole, label: slotLabel(for: tuple.1), _optional: isOptional)
            }

            let hints = [
                Hint(order: 0, type: .text, content: "주어-동사-목적어 순서로 문장을 완성해보세요"),
                Hint(order: 1, type: .slotLabel, content: "동사 위치를 먼저 채워보세요")
            ]

            return SessionItem(
                itemId: id,
                prompt: ItemPrompt(ko: korean, enReference: english),
                frame: ItemFrame(slots: slots),
                tokens: tokens,
                distractors: nil,
                correctSequence: correctIds,
                patternTags: ["pattern.svo.basic"],
                difficultyBand: .core,
                hints: hints,
                scoring: ScoringRules(basePoints: 10, comboBonus: 3, hintPenalty: 2)
            )
        }

        let items: [SessionItem] = [
            makeItem(
                id: "session-item-1",
                korean: "나는 매일 영어를 공부해.",
                english: "I study English every day.",
                sequence: [("I", .s), ("study", .v), ("English", .o), ("every", .m), ("day", .m)]
            ),
            makeItem(
                id: "session-item-2",
                korean: "그녀는 지금 저녁을 만들고 있어.",
                english: "She is cooking dinner now.",
                sequence: [("She", .s), ("is", .v), ("cooking", .v), ("dinner", .o), ("now", .m)]
            ),
            makeItem(
                id: "session-item-3",
                korean: "우리는 어제 새 패턴을 배웠어.",
                english: "We learned a new pattern yesterday.",
                sequence: [("We", .s), ("learned", .v), ("a", .o), ("new", .o), ("pattern", .o), ("yesterday", .m)]
            ),
            makeItem(
                id: "session-item-4",
                korean: "그들은 자주 서로 영어로 이야기해.",
                english: "They often talk to each other in English.",
                sequence: [("They", .s), ("often", .m), ("talk", .v), ("to", .o), ("each", .o), ("other", .o), ("in", .m), ("English", .m)]
            ),
            makeItem(
                id: "session-item-5",
                korean: "나는 오늘 Brain Burst를 열었어!",
                english: "I unlocked a Brain Burst today!",
                sequence: [("I", .s), ("unlocked", .v), ("a", .o), ("Brain", .o), ("Burst", .o), ("today", .m)]
            )
        ]

        let warmUpIds = Array(items.prefix(2)).map { $0.itemId }
        let focusIds = Array(items.dropFirst(2).prefix(2)).map { $0.itemId }
        let coolDownIds = Array(items.suffix(1)).map { $0.itemId }

        let phases: [SessionPhase] = [
            SessionPhase(
                phaseId: "phase-warm-up",
                label: "워밍업",
                phaseType: .warmUp,
                order: 0,
                targetSentences: warmUpIds.count,
                targetDurationSeconds: 5 * 60,
                itemIds: warmUpIds,
                comboRules: SessionPhaseComboRules(base: 10, bonusPerStreak: 2),
                checkpointStatus: CheckpointStatus(reached: false, accuracy: nil, combosMax: nil, completedAt: nil),
                hintBudget: 2
            ),
            SessionPhase(
                phaseId: "phase-focus",
                label: "집중",
                phaseType: .focus,
                order: 1,
                targetSentences: focusIds.count,
                targetDurationSeconds: 7 * 60,
                itemIds: focusIds,
                comboRules: SessionPhaseComboRules(base: 12, bonusPerStreak: 3),
                checkpointStatus: CheckpointStatus(reached: false, accuracy: nil, combosMax: nil, completedAt: nil),
                hintBudget: 2
            ),
            SessionPhase(
                phaseId: "phase-cool-down",
                label: "마무리",
                phaseType: .coolDown,
                order: 2,
                targetSentences: coolDownIds.count,
                targetDurationSeconds: 3 * 60,
                itemIds: coolDownIds,
                comboRules: SessionPhaseComboRules(base: 8, bonusPerStreak: 2),
                checkpointStatus: CheckpointStatus(reached: false, accuracy: nil, combosMax: nil, completedAt: nil),
                hintBudget: 1
            )
        ]

        let session = Session(
            sessionId: sessionId,
            mode: mode.rawValue,
            status: .active,
            startedAt: startedAt,
            expiresAt: expiresAt,
            source: .offline,
            phases: phases,
            items: items,
            summary: nil,
            brainBurst: BrainBurstState(active: false, multiplier: 1, eligibleAt: nil, sessionsUntilActivation: 1),
            liveActivity: nil
        )

        cachedSession = session
        return session
    }

    func makeLevelTestResult() -> LevelTestResult {
        LevelTestResult(
            recommendedLevel: 3,
            confidence: 0.78,
            rationale: "모의 데이터 기반 추천 레벨",
            nextLessonId: "lesson.mock-001",
            unlocksReview: true,
            needsSessionCalibration: false
        )
    }
}
