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
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showFeedback = false
    @Published var isCorrect = false

    // Store completed attempts per item
    private var completedAttempts: [ItemAttemptData] = []

    // Current item metrics (reset per item)
    private var currentMetrics: AttemptMetrics?

    // Haptic feedback generator (reusable for better performance)
    private let feedbackGenerator = UINotificationFeedbackGenerator()

    // Completion callback
    var onComplete: (() -> Void)?

    var currentItem: LevelTestItem? {
        guard items.indices.contains(currentItemIndex) else { return nil }
        return items[currentItemIndex]
    }

    var progress: Double {
        guard !items.isEmpty else { return 0 }
        // Use completed attempts count for accurate progress (0-based index + 1)
        return Double(completedAttempts.count) / Double(items.count)
    }

    init() {
        feedbackGenerator.prepare()
        loadMockItems()
    }

    // MARK: - Mock Data (TODO: Replace with API call GET /level-tests)
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
            LevelTestItem(
                id: "3",
                koreanSentence: "우리는 내일 영화를 볼 것이다",
                tokens: [
                    TokenItem(id: "3-1", text: "We", correctSlot: .subject),
                    TokenItem(id: "3-2", text: "will watch", correctSlot: .verb),
                    TokenItem(id: "3-3", text: "a movie", correctSlot: .object),
                    TokenItem(id: "3-4", text: "tomorrow", correctSlot: .modifier)
                ],
                correctOrder: [.subject, .verb, .object, .modifier]
            ),
            LevelTestItem(
                id: "4",
                koreanSentence: "그는 공원에서 달린다",
                tokens: [
                    TokenItem(id: "4-1", text: "He", correctSlot: .subject),
                    TokenItem(id: "4-2", text: "runs", correctSlot: .verb),
                    TokenItem(id: "4-3", text: "in the park", correctSlot: .modifier)
                ],
                correctOrder: [.subject, .verb, .modifier]
            ),
            LevelTestItem(
                id: "5",
                koreanSentence: "그들은 어제 박물관을 방문했다",
                tokens: [
                    TokenItem(id: "5-1", text: "They", correctSlot: .subject),
                    TokenItem(id: "5-2", text: "visited", correctSlot: .verb),
                    TokenItem(id: "5-3", text: "the museum", correctSlot: .object),
                    TokenItem(id: "5-4", text: "yesterday", correctSlot: .modifier)
                ],
                correctOrder: [.subject, .verb, .object, .modifier]
            ),
            LevelTestItem(
                id: "6",
                koreanSentence: "나는 책을 읽고 있다",
                tokens: [
                    TokenItem(id: "6-1", text: "I", correctSlot: .subject),
                    TokenItem(id: "6-2", text: "am reading", correctSlot: .verb),
                    TokenItem(id: "6-3", text: "a book", correctSlot: .object)
                ],
                correctOrder: [.subject, .verb, .object]
            ),
            LevelTestItem(
                id: "7",
                koreanSentence: "그녀는 친구들과 함께 저녁을 먹었다",
                tokens: [
                    TokenItem(id: "7-1", text: "She", correctSlot: .subject),
                    TokenItem(id: "7-2", text: "had", correctSlot: .verb),
                    TokenItem(id: "7-3", text: "dinner", correctSlot: .object),
                    TokenItem(id: "7-4", text: "with friends", correctSlot: .modifier)
                ],
                correctOrder: [.subject, .verb, .object, .modifier]
            ),
            LevelTestItem(
                id: "8",
                koreanSentence: "학생들은 교실에서 공부한다",
                tokens: [
                    TokenItem(id: "8-1", text: "Students", correctSlot: .subject),
                    TokenItem(id: "8-2", text: "study", correctSlot: .verb),
                    TokenItem(id: "8-3", text: "in the classroom", correctSlot: .modifier)
                ],
                correctOrder: [.subject, .verb, .modifier]
            ),
            LevelTestItem(
                id: "9",
                koreanSentence: "그는 매우 빠르게 달린다",
                tokens: [
                    TokenItem(id: "9-1", text: "He", correctSlot: .subject),
                    TokenItem(id: "9-2", text: "runs", correctSlot: .verb),
                    TokenItem(id: "9-3", text: "very fast", correctSlot: .modifier)
                ],
                correctOrder: [.subject, .verb, .modifier]
            ),
            LevelTestItem(
                id: "10",
                koreanSentence: "우리는 주말에 쇼핑을 갈 것이다",
                tokens: [
                    TokenItem(id: "10-1", text: "We", correctSlot: .subject),
                    TokenItem(id: "10-2", text: "will go", correctSlot: .verb),
                    TokenItem(id: "10-3", text: "shopping", correctSlot: .object),
                    TokenItem(id: "10-4", text: "on the weekend", correctSlot: .modifier)
                ],
                correctOrder: [.subject, .verb, .object, .modifier]
            )
        ]

        if let first = items.first {
            initializeSlots(for: first)
        }
    }

    private func initializeSlots(for item: LevelTestItem, isRetry: Bool = false) {
        slots = item.correctOrder.map { SlotPosition(type: $0, token: nil) }
        availableTokens = item.tokens.shuffled()

        if !isRetry {
            // New item - create new metrics
            hintLevel = .none
            currentMetrics = AttemptMetrics(
                startTime: Date(),
                endTime: nil,
                hintsUsed: 0,
                hintLevel: .none,
                isFirstTrySuccess: false,
                submissionCount: 0,
                tokenPlacementCount: 0
            )
        } else {
            // Retry - keep hint level and accumulated hint count
            // User keeps the hints they've already unlocked (labels/highlights remain visible)
            hintLevel = currentMetrics?.hintLevel ?? .none
            if var metrics = currentMetrics {
                // Don't reset submissionCount - track total attempts including retries
                metrics.tokenPlacementCount = 0  // Reset for new attempt
                metrics.endTime = nil  // Clear end time for retry
                // isFirstTrySuccess already false from previous attempt
                currentMetrics = metrics
            }
        }
    }

    // MARK: - Drag & Drop
    func placeToken(_ token: TokenItem, in slotIndex: Int) {
        // If token is already in another slot, remove it and add back to available
        if let currentSlotIndex = slots.firstIndex(where: { $0.token?.id == token.id }) {
            if let existingToken = slots[currentSlotIndex].token {
                slots[currentSlotIndex].token = nil
                // Only add back if not already in available (shouldn't happen, but safety check)
                if !availableTokens.contains(where: { $0.id == existingToken.id }) {
                    availableTokens.append(existingToken)
                }
            }
        }

        // If target slot already has a token, return it to available
        if let existingToken = slots[slotIndex].token {
            slots[slotIndex].token = nil
            if !availableTokens.contains(where: { $0.id == existingToken.id }) {
                availableTokens.append(existingToken)
            }
        }

        // Remove the new token from available tokens
        availableTokens.removeAll { $0.id == token.id }

        // Place token in target slot
        slots[slotIndex].token = token

        // Track token placement count (for analytics)
        currentMetrics?.tokenPlacementCount += 1

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

        currentMetrics?.hintsUsed += 1
        currentMetrics?.hintLevel = newLevel

        // Haptic feedback
        feedbackGenerator.notificationOccurred(.warning)
    }

    private func checkCompletion() {
        // Check if all slots are filled
        guard slots.allSatisfy({ $0.token != nil }) else { return }

        // Check if all are correct
        let allCorrect = slots.allSatisfy { $0.isCorrect }
        isCorrect = allCorrect

        // Update metrics - this is a submission attempt
        currentMetrics?.submissionCount += 1
        currentMetrics?.endTime = Date()

        // First try success = correct answer on first submission with no hints
        if let metrics = currentMetrics {
            currentMetrics?.isFirstTrySuccess = allCorrect &&
                                                metrics.submissionCount == 1 &&
                                                metrics.hintsUsed == 0
        }

        // Show feedback
        showFeedback = true

        // Haptic feedback
        feedbackGenerator.notificationOccurred(allCorrect ? .success : .error)
    }

    func nextItem() {
        showFeedback = false

        // Save current item's final attempt data (only called when correct)
        if let item = currentItem, let metrics = currentMetrics {
            let selectedTokenIds = slots.compactMap { $0.token?.id }

            // Verify this is actually a correct answer before saving
            guard slots.allSatisfy({ $0.isCorrect }) else {
                print("⚠️ Warning: nextItem() called but answer is not correct")
                return
            }

            completedAttempts.append(ItemAttemptData(
                itemId: item.id,
                selectedTokenIds: selectedTokenIds,
                metrics: metrics
            ))
        }

        currentItemIndex += 1

        if let nextItem = currentItem {
            initializeSlots(for: nextItem, isRetry: false)
        } else {
            // Test complete - submit results
            submitResults()
        }
    }

    func retryCurrentItem() {
        showFeedback = false
        if let current = currentItem {
            initializeSlots(for: current, isRetry: true)
        }
    }

    // MARK: - API Submission
    func submitResults() {
        isLoading = true

        // Validate we have completed attempts
        guard !completedAttempts.isEmpty else {
            print("❌ Error: No completed attempts to submit")
            errorMessage = "레벨 테스트 데이터가 없습니다"
            isLoading = false
            return
        }

        // Validate we have the expected number of items (should be 10)
        if completedAttempts.count != items.count {
            print("⚠️ Warning: Completed \(completedAttempts.count) items but expected \(items.count)")
        }

        guard let firstAttempt = completedAttempts.first,
              let lastAttempt = completedAttempts.last else {
            print("❌ Error: Missing first or last attempt")
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

        print("📤 Submitting level test with \(attempts.count) attempts")

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

                    // Notify completion to coordinator
                    self?.onComplete?()
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
