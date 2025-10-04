//
//  LevelTestViewModel.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import Foundation
import Combine
import UIKit
import EnglishBrainAPI

@MainActor
class LevelTestViewModel: ObservableObject {
    @Published var currentItemIndex = 0
    @Published var items: [LevelTestItem] = []
    @Published var slots: [SlotPosition] = []
    @Published var availableTokens: [TokenItem] = []
    @Published var hintLevel: HintLevel = .none
    @Published var attemptMetrics: [AttemptMetrics] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showFeedback = false
    @Published var isCorrect = false

    // Store completed attempts per item
    private var completedAttempts: [ItemAttemptData] = []

    var currentItem: LevelTestItem? {
        guard items.indices.contains(currentItemIndex) else { return nil }
        return items[currentItemIndex]
    }

    var progress: Double {
        guard !items.isEmpty else { return 0 }
        return Double(currentItemIndex) / Double(items.count)
    }

    init() {
        loadMockItems()
    }

    // MARK: - Mock Data (실제로는 API에서 가져옴)
    private func loadMockItems() {
        items = [
            LevelTestItem(
                id: "1",
                koreanSentence: "나는 영어를 공부한다",
                tokens: [
                    TokenItem(id: "1-1", text: "I", correctSlot: .subject),
                    TokenItem(id: "1-2", text: "study", correctSlot: .verb),
                    TokenItem(id: "1-3", text: "English", correctSlot: .object)
                ],
                correctOrder: [.subject, .verb, .object]
            ),
            LevelTestItem(
                id: "2",
                koreanSentence: "그녀는 매일 아침 커피를 마신다",
                tokens: [
                    TokenItem(id: "2-1", text: "She", correctSlot: .subject),
                    TokenItem(id: "2-2", text: "drinks", correctSlot: .verb),
                    TokenItem(id: "2-3", text: "coffee", correctSlot: .object),
                    TokenItem(id: "2-4", text: "every morning", correctSlot: .modifier)
                ],
                correctOrder: [.subject, .verb, .object, .modifier]
            ),
            // More items would be loaded from API...
        ]

        if let first = items.first {
            initializeSlots(for: first)
        }
    }

    private func initializeSlots(for item: LevelTestItem) {
        slots = item.correctOrder.map { SlotPosition(type: $0, token: nil) }
        availableTokens = item.tokens.shuffled()
        hintLevel = .none
        attemptMetrics.append(AttemptMetrics(
            startTime: Date(),
            endTime: nil,
            hintsUsed: 0,
            hintLevel: .none,
            isFirstTrySuccess: false,
            attemptCount: 0
        ))
    }

    // MARK: - Drag & Drop
    func placeToken(_ token: TokenItem, in slotIndex: Int) {
        // Remove token from current slot if already placed
        if let currentSlotIndex = slots.firstIndex(where: { $0.token?.id == token.id }) {
            slots[currentSlotIndex].token = nil
        }

        // Remove token from available tokens
        availableTokens.removeAll { $0.id == token.id }

        // Place token in new slot
        slots[slotIndex].token = token

        // Update attempt count
        if var currentMetrics = attemptMetrics.last {
            currentMetrics.attemptCount += 1
            attemptMetrics[attemptMetrics.count - 1] = currentMetrics
        }

        checkCompletion()
    }

    func removeToken(from slotIndex: Int) {
        guard let token = slots[slotIndex].token else { return }
        slots[slotIndex].token = nil
        availableTokens.append(token)
    }

    func useHint() {
        guard hintLevel.rawValue < 3 else { return }
        let newLevel = HintLevel(rawValue: hintLevel.rawValue + 1) ?? .none
        hintLevel = newLevel

        if var currentMetrics = attemptMetrics.last {
            currentMetrics.hintsUsed += 1
            currentMetrics.hintLevel = newLevel
            attemptMetrics[attemptMetrics.count - 1] = currentMetrics
        }

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    private func checkCompletion() {
        // Check if all slots are filled
        guard slots.allSatisfy({ $0.token != nil }) else { return }

        // Check if all are correct
        let allCorrect = slots.allSatisfy { $0.isCorrect }
        isCorrect = allCorrect

        // Update metrics
        if var currentMetrics = attemptMetrics.last {
            currentMetrics.endTime = Date()
            currentMetrics.isFirstTrySuccess = allCorrect && currentMetrics.attemptCount == slots.count && currentMetrics.hintsUsed == 0
            attemptMetrics[attemptMetrics.count - 1] = currentMetrics
        }

        // Show feedback
        showFeedback = true

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(allCorrect ? .success : .error)
    }

    func nextItem() {
        showFeedback = false

        // Save current item's attempt data before moving to next
        if let item = currentItem, let metrics = attemptMetrics.last {
            let selectedTokenIds = slots.compactMap { $0.token?.id }
            completedAttempts.append(ItemAttemptData(
                itemId: item.id,
                selectedTokenIds: selectedTokenIds,
                metrics: metrics
            ))
        }

        currentItemIndex += 1

        if let nextItem = currentItem {
            initializeSlots(for: nextItem)
        } else {
            // Test complete - submit results
            submitResults()
        }
    }

    func retryCurrentItem() {
        showFeedback = false
        if let current = currentItem {
            initializeSlots(for: current)
        }
    }

    // MARK: - API Submission
    func submitResults() {
        isLoading = true

        guard let firstAttempt = completedAttempts.first,
              let lastAttempt = completedAttempts.last else {
            isLoading = false
            return
        }

        // Prepare attempts data using stored per-item data
        let attempts: [LevelTestAttempt] = completedAttempts.map { attemptData in
            let timeSpentMs = Int(attemptData.metrics.duration * 1000)

            return LevelTestAttempt(
                itemId: attemptData.itemId,
                selectedTokenIds: attemptData.selectedTokenIds,
                timeSpentMs: timeSpentMs,
                hintsUsed: attemptData.metrics.hintsUsed
            )
        }

        let submission = LevelTestSubmission(
            attempts: attempts,
            startedAt: firstAttempt.metrics.startTime,
            completedAt: lastAttempt.metrics.endTime ?? Date()
        )

        // Real API call using OnboardingAPI
        OnboardingAPI.submitLevelTest(levelTestSubmission: submission) { [weak self] response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    print("❌ Level test submission failed: \(error)")
                } else if let result = response {
                    print("✅ Level test submitted successfully")
                    print("Recommended level: \(result.recommendedLevel)")
                    print("Confidence: \(result.confidence)")
                    print("Rationale: \(result.rationale)")
                    print("Next lesson ID: \(result.nextLessonId)")
                    // Navigate to next screen handled by OnboardingCoordinator
                }
            }
        }
    }

    // MARK: - Helper Structures

    struct ItemAttemptData {
        let itemId: String
        let selectedTokenIds: [String]
        let metrics: AttemptMetrics
    }
}
