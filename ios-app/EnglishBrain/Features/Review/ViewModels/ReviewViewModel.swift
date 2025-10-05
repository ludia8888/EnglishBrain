//
//  ReviewViewModel.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import Foundation
import Combine
import EnglishBrainAPI

@MainActor
class ReviewViewModel: ObservableObject {
    @Published var reviewPlan: ReviewPlan?
    @Published var currentItemIndex = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isCompleted = false

    // Token interaction state
    @Published var availableTokens: [TokenDragItem] = []
    @Published var slots: [SlotItem] = []
    @Published var selectedTokenId: String?

    // Review metrics
    @Published var correctCount = 0
    @Published var totalAttempts = 0
    private var startTime: Date?
    private var sessionStartTime: Date?

    // Store per-item results for submission
    private var itemResults: [ItemResult] = []

    struct ItemResult {
        let itemId: String
        let isCorrect: Bool
        let timeSpent: TimeInterval
    }

    struct TokenDragItem: Identifiable, Equatable {
        let id: String
        let text: String
    }

    struct SlotItem: Identifiable {
        let id: String
        var token: TokenDragItem?
        let slotType: String
    }

    var currentItem: ReviewItem? {
        guard let plan = reviewPlan,
              currentItemIndex < plan.items.count else { return nil }
        return plan.items[currentItemIndex]
    }

    var progress: Double {
        guard let plan = reviewPlan, !plan.items.isEmpty else { return 0 }
        return Double(currentItemIndex) / Double(plan.items.count)
    }

    var remainingItems: Int {
        guard let plan = reviewPlan else { return 0 }
        return plan.items.count - currentItemIndex
    }

    // MARK: - API Integration

    func createReview(patternId: String? = nil, targetSentences: Int = 6) {
        isLoading = true
        errorMessage = nil

        let request = ReviewCreateRequest(
            trigger: .user,
            patternId: patternId,
            targetSentences: targetSentences
        )

        ReviewsAPI.createReview(reviewCreateRequest: request) { [weak self] response, error in
            Task { @MainActor [weak self] in
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    print("❌ Failed to create review: \(error)")
                } else if let plan = response {
                    self?.reviewPlan = plan
                    self?.currentItemIndex = 0
                    self?.sessionStartTime = Date()
                    self?.itemResults = []
                    self?.correctCount = 0
                    self?.totalAttempts = 0
                    self?.setupCurrentItem()

                    print("✅ Created review plan with \(plan.items.count) items")
                    print("Pattern ID: \(plan.patternId)")
                }
            }
        }
    }

    func setupCurrentItem() {
        guard let item = currentItem else { return }

        // Note: ReviewItem doesn't have frame/token data like SessionItem
        // We use the English reference text to create tokens for review
        // This is a limitation of the current API - ideally the backend would provide
        // pre-tokenized frame data for reviews as well
        let words = item.prompt.enReference.components(separatedBy: " ")
        availableTokens = words.enumerated().map { index, word in
            TokenDragItem(id: "token_\(index)", text: word)
        }.shuffled()

        // Create 4 slots (S/V/O/M pattern)
        slots = ["S", "V", "O", "M"].enumerated().map { index, type in
            SlotItem(id: "slot_\(index)", token: nil, slotType: type)
        }

        selectedTokenId = nil
        startTime = Date()
    }

    // MARK: - Token Interaction

    func selectToken(_ tokenId: String) {
        if selectedTokenId == tokenId {
            selectedTokenId = nil
        } else {
            selectedTokenId = tokenId
        }
    }

    func tapSlot(index: Int) {
        guard let tokenId = selectedTokenId,
              let token = availableTokens.first(where: { $0.id == tokenId }) else {
            return
        }

        // Remove from old slot if placed
        if let oldSlotIndex = slots.firstIndex(where: { $0.token?.id == tokenId }) {
            slots[oldSlotIndex].token = nil
        }

        // Place in new slot
        slots[index].token = token
        selectedTokenId = nil

        // Remove from available tokens
        availableTokens.removeAll { $0.id == tokenId }
    }

    func removeTokenFromSlot(index: Int) {
        guard let token = slots[index].token else { return }

        slots[index].token = nil
        availableTokens.append(token)
        availableTokens.sort { $0.id < $1.id }
    }

    func submitAnswer() {
        // Check if all slots filled
        guard slots.allSatisfy({ $0.token != nil }) else {
            return
        }

        guard let item = currentItem else { return }

        // Validate answer by comparing user's sentence with reference
        let userAnswer = slots.compactMap { $0.token?.text }.joined(separator: " ")
        let reference = item.prompt.enReference

        // Simple validation: normalize whitespace and compare
        let normalizedUser = userAnswer.trimmingCharacters(in: .whitespaces)
            .lowercased()
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        let normalizedReference = reference.trimmingCharacters(in: .whitespaces)
            .lowercased()
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)

        let isCorrect = normalizedUser == normalizedReference

        // Track metrics
        let timeSpent = startTime.map { Date().timeIntervalSince($0) } ?? 0
        itemResults.append(ItemResult(
            itemId: item.itemId,
            isCorrect: isCorrect,
            timeSpent: timeSpent
        ))

        totalAttempts += 1
        if isCorrect {
            correctCount += 1
        }

        print(isCorrect ? "✅ Correct answer" : "❌ Incorrect answer")
        print("User: \(normalizedUser)")
        print("Reference: \(normalizedReference)")

        // Move to next item
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            self?.nextItem()
        }
    }

    func nextItem() {
        guard let plan = reviewPlan else { return }

        if currentItemIndex < plan.items.count - 1 {
            currentItemIndex += 1
            setupCurrentItem()
        } else {
            // Review completed - submit results to backend
            submitReviewResults()
            isCompleted = true
        }
    }

    private func submitReviewResults() {
        guard let plan = reviewPlan else { return }

        let accuracy = totalAttempts > 0 ? Double(correctCount) / Double(totalAttempts) : 0.0
        let durationSeconds = sessionStartTime.map { Int(Date().timeIntervalSince($0)) } ?? 0

        let request = ReviewUpdateRequest(
            status: .completed,
            accuracy: accuracy,
            durationSeconds: durationSeconds,
            completedAt: Date(),
            patternImpact: nil // Backend will calculate this
        )

        isLoading = true

        ReviewsAPI.updateReview(reviewId: plan.reviewId, reviewUpdateRequest: request) { [weak self] response, error in
            Task { @MainActor [weak self] in
                self?.isLoading = false

                if let error = error {
                    print("❌ Failed to submit review results: \(error)")
                    // Don't show error to user - review is still completed locally
                    // Backend can retry or sync later
                } else if let updatedPlan = response {
                    print("✅ Review results submitted successfully")
                    print("Accuracy: \(accuracy)")
                    print("Duration: \(durationSeconds)s")
                    if let summary = updatedPlan.summary {
                        print("Completed at: \(summary.completedAt)")
                        if let deltaRate = summary.deltaConquestRate {
                            print("Delta conquest rate: \(deltaRate)")
                        }
                    }
                }
            }
        }
    }

    func reset() {
        reviewPlan = nil
        currentItemIndex = 0
        availableTokens = []
        slots = []
        selectedTokenId = nil
        correctCount = 0
        totalAttempts = 0
        itemResults = []
        startTime = nil
        sessionStartTime = nil
        isCompleted = false
        errorMessage = nil
    }
}
