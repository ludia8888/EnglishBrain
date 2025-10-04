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
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    print("❌ Failed to create review: \(error)")
                } else if let plan = response {
                    self?.reviewPlan = plan
                    self?.currentItemIndex = 0
                    self?.setupCurrentItem()

                    print("✅ Created review plan with \(plan.items.count) items")
                    print("Pattern ID: \(plan.patternId)")
                }
            }
        }
    }

    func setupCurrentItem() {
        guard let item = currentItem else { return }

        // Note: ReviewItem doesn't have frame data like SessionItem
        // We'll need to generate tokens from the prompt for review
        // For now, create placeholder tokens
        let words = item.prompt.ko.components(separatedBy: " ")
        availableTokens = words.enumerated().map { index, word in
            TokenDragItem(id: "token_\(index)", text: word)
        }.shuffled()

        // Create 4 slots (S/V/O/M pattern)
        slots = ["S", "V", "O", "M"].enumerated().map { index, type in
            SlotItem(id: "slot_\(index)", token: nil, slotType: type)
        }

        selectedTokenId = nil
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

        // Simplified scoring for review
        let isCorrect = true // TODO: Actual validation logic

        totalAttempts += 1
        if isCorrect {
            correctCount += 1
        }

        // Move to next item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.nextItem()
        }
    }

    func nextItem() {
        guard let plan = reviewPlan else { return }

        if currentItemIndex < plan.items.count - 1 {
            currentItemIndex += 1
            setupCurrentItem()
        } else {
            isCompleted = true
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
        isCompleted = false
        errorMessage = nil
    }
}
