//
//  SessionViewModel.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import Foundation
import Combine
import UIKit
import EnglishBrainAPI

@MainActor
class SessionViewModel: ObservableObject {
    @Published var stateManager = SessionStateManager()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showCheckpoint = false
    @Published var showCompletion = false
    @Published var showBrainBurst = false
    @Published var brainBurst: BrainBurstState?

    // Slot management
    @Published var slots: [SlotItem] = []
    @Published var availableTokens: [TokenDragItem] = []
    @Published var selectedTokenId: String?

    // Haptic generators (reusable for better performance)
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let notificationGenerator = UINotificationFeedbackGenerator()

    // Cancellable delayed actions using Swift Concurrency (prevents race conditions)
    private var submitDelayTask: Task<Void, Never>?

    // Cancellables for network requests
    private var cancellables = Set<AnyCancellable>()
    private var createSessionTask: Task<Void, Never>?
    private let sessionEngine: SessionEngine

    init(sessionEngine: SessionEngine = SessionEngine()) {
        self.sessionEngine = sessionEngine
    }

    struct SlotItem: Identifiable {
        let id: String
        var token: TokenDragItem?
        let slotType: String // S, V, O, M, etc.
    }

    struct TokenDragItem: Identifiable, Hashable {
        let id: String
        let text: String
        let isCorrect: Bool? = nil
    }

    deinit {
        // Cancel all pending work to prevent crashes
        submitDelayTask?.cancel()
        createSessionTask?.cancel()
        cancellables.forEach { $0.cancel() }
    }

    // MARK: - Session Lifecycle

    func startSession(mode: SessionCreateRequest.Mode = .daily) {
        // Cancel any existing session creation request
        createSessionTask?.cancel()

        isLoading = true
        errorMessage = nil

        if AppEnvironment.shared.usesMockData {
            createSessionTask = Task { @MainActor [weak self] in
                try? await Task.sleep(nanoseconds: 250_000_000)
                guard let self = self, !Task.isCancelled else { return }
                let session = MockDataProvider.shared.makeSession(mode: mode)
                self.isLoading = false
                self.handleSessionLoaded(session)
                self.createSessionTask = nil
            }
            return
        }

        let request = SessionCreateRequest(mode: mode, entryPoint: "home")

        // Create a cancellable work item
        SessionsAPI.createSession(sessionCreateRequest: request) { [weak self] response, error in
            Task { @MainActor [weak self] in
                guard let self = self else { return }

                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("❌ Failed to create session: \(error)")
                } else if let session = response {
                    self.handleSessionLoaded(session)
                }

                // Clear pending task reference
                self.createSessionTask = nil
            }
        }
    }

    private func handleSessionLoaded(_ session: Session) {
        print("✅ Session loaded: \(session.sessionId)")
        print("Phases: \(session.phases.count)")
        print("Items: \(session.items.count)")

        if let burst = session.brainBurst, burst.active {
            brainBurst = burst
            showBrainBurst = true
            print("🧠⚡ Brain Burst activated! Multiplier: \(burst.multiplier)x")
        } else {
            brainBurst = session.brainBurst
            showBrainBurst = false
        }

        stateManager.loadSession(session)
        loadCurrentItem()
    }

    private func loadCurrentItem() {
        guard let item = stateManager.currentItem else { return }

        // Prepare haptic generators for upcoming interactions
        impactGenerator.prepare()
        notificationGenerator.prepare()

        // Initialize slots based on frame
        let frameSlots = item.frame.slots.enumerated().map { (index, slot) in
            (index: index, slot: slot)
        }.sorted(by: { $0.index < $1.index })

        slots = frameSlots.map { pair in
            SlotItem(id: UUID().uuidString, token: nil, slotType: pair.slot.role.rawValue)
        }

        // Shuffle tokens + distractors
        var allTokens = item.tokens
        if let distractors = item.distractors {
            allTokens.append(contentsOf: distractors)
        }

        availableTokens = allTokens.shuffled().map { token in
            TokenDragItem(id: token.tokenId, text: token.display)
        }

        selectedTokenId = nil
    }

    // MARK: - Drag & Drop (Tap-based for simulator)

    func selectToken(_ tokenId: String) {
        selectedTokenId = tokenId
    }

    func placeTokenInSlot(_ slotIndex: Int) {
        guard let tokenId = selectedTokenId,
              let token = availableTokens.first(where: { $0.id == tokenId }),
              slots.indices.contains(slotIndex) else {
            return
        }

        // Remove from previous slot if exists
        if let previousSlotIndex = slots.firstIndex(where: { $0.token?.id == tokenId }) {
            slots[previousSlotIndex].token = nil
        }

        // Remove from available
        availableTokens.removeAll { $0.id == tokenId }

        // Place in slot
        slots[slotIndex].token = token

        // Deselect
        selectedTokenId = nil

        // Haptic feedback
        impactGenerator.impactOccurred()

        checkCompletion()
    }

    func removeTokenFromSlot(_ slotIndex: Int) {
        guard slots.indices.contains(slotIndex),
              let token = slots[slotIndex].token else {
            return
        }

        slots[slotIndex].token = nil
        availableTokens.append(token)

        impactGenerator.impactOccurred()
    }

    private func checkCompletion() {
        // Check if all slots filled
        guard slots.allSatisfy({ $0.token != nil }) else { return }

        // Get selected sequence
        let selectedTokenIds = slots.compactMap { $0.token?.id }

        // Check correctness using SessionEngine (off-main heavy logic)
        guard let correctSequence = stateManager.currentItem?.correctSequence else { return }
        let validationInput = SessionEngine.ValidationInput(
            selectedTokenIds: selectedTokenIds,
            correctSequence: correctSequence
        )

        Task { [weak self] in
            guard let self = self else { return }
            let isCorrect = await self.sessionEngine.validatePlacement(validationInput)
            await self.handleCompletionResult(isCorrect: isCorrect, selectedTokenIds: selectedTokenIds)
        }
    }

    private func handleCompletionResult(isCorrect: Bool, selectedTokenIds: [String]) {
        // Record attempt
        stateManager.recordAttempt(selectedTokenIds: selectedTokenIds, isCorrect: isCorrect)

        // Haptic & audio feedback
        notificationGenerator.notificationOccurred(isCorrect ? .success : .error)

        // Cancel any pending delayed action to prevent race conditions
        submitDelayTask?.cancel()

        if isCorrect {
            // Show success, move to next item after delay
            submitDelayTask = Task { @MainActor [weak self] in
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard let self = self, !Task.isCancelled else { return }
                self.moveToNextItem()
            }
        } else {
            // Show error feedback, allow retry
            submitDelayTask = Task { @MainActor [weak self] in
                try? await Task.sleep(nanoseconds: 500_000_000)
                guard let self = self, !Task.isCancelled else { return }
                self.clearAllSlots()
            }
        }
    }

    private func clearAllSlots() {
        for i in slots.indices {
            if let token = slots[i].token {
                availableTokens.append(token)
                slots[i].token = nil
            }
        }
    }

    func useHint() {
        stateManager.useHint()

        // Show next correct token placement
        guard let correctSequence = stateManager.currentItem?.correctSequence else { return }

        // Find first unfilled slot
        for (slotIndex, slot) in slots.enumerated() {
            if slot.token == nil, correctSequence.indices.contains(slotIndex) {
                let correctTokenId = correctSequence[slotIndex]

                // Highlight the correct token
                if availableTokens.contains(where: { $0.id == correctTokenId }) {
                    selectedTokenId = correctTokenId
                }
                break
            }
        }

        notificationGenerator.notificationOccurred(.warning)
    }

    // MARK: - Navigation

    private func moveToNextItem() {
        stateManager.moveToNextItem()

        if stateManager.isPhaseComplete {
            // Show checkpoint
            showCheckpoint = true
        } else {
            // Load next item
            loadCurrentItem()
        }
    }

    func completePhaseCheckpoint() {
        showCheckpoint = false
        stateManager.moveToNextPhase()

        if stateManager.isSessionComplete {
            // Show session completion
            showCompletion = true
        } else {
            // Load next phase
            loadCurrentItem()
        }
    }

    func exitSession() {
        // TODO: Save progress, mark as abandoned
        stateManager.session = nil
        stateManager.progress = .notStarted
    }
}
