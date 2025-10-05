//
//  StreakViewModel.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import Foundation
import Combine
import EnglishBrainAPI

@MainActor
class StreakViewModel: ObservableObject {
    @Published var brainTokens: HomeSummaryBrainTokens?
    @Published var streak: HomeSummaryStreak?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showFreezeSuccess = false
    @Published var freezeInProgress = false

    // Offline queue with deduplication tracking
    @Published var pendingFreezeRequests: Set<StreakFreezeRequest> = []

    private var freezeTask: Task<Void, Never>?
    private var retryTask: Task<Void, Never>?

    func freezeStreak(targetDate: Date, reason: StreakFreezeRequest.Reason?) {
        guard let tokens = brainTokens, tokens.available > 0 else {
            errorMessage = "Brain Token이 부족합니다"
            return
        }

        guard let currentStreak = streak, currentStreak.freezeEligible else {
            errorMessage = "스트릭 프리즈를 사용할 수 없습니다"
            return
        }

        // Cancel any existing freeze task
        freezeTask?.cancel()

        freezeTask = Task {
            freezeInProgress = true
            errorMessage = nil

            let request = StreakFreezeRequest(
                targetDate: targetDate,
                reason: reason
            )

            await withCheckedContinuation { continuation in
                NotificationsAPI.createStreakFreeze(streakFreezeRequest: request) { [weak self] response, error in
                    guard let self = self else {
                        continuation.resume()
                        return
                    }

                    Task { @MainActor in
                        guard !Task.isCancelled else {
                            continuation.resume()
                            return
                        }

                        self.freezeInProgress = false

                        if let error = error {
                            // Add to offline queue with deduplication
                            self.pendingFreezeRequests.insert(request)
                            self.errorMessage = "오프라인 상태입니다. 연결되면 자동으로 처리됩니다."
                            print("❌ Failed to freeze streak: \(error)")
                        } else if let response = response {
                            self.showFreezeSuccess = true
                            // Update tokens count
                            if var tokens = self.brainTokens {
                                tokens.available -= 1
                                self.brainTokens = tokens
                            }
                            print("✅ Streak frozen successfully")
                            print("Remaining tokens: \(response.brainTokensRemaining)")
                        }

                        continuation.resume()
                    }
                }
            }
        }
    }

    func retryPendingFreezes() {
        guard !pendingFreezeRequests.isEmpty else { return }

        // Cancel any existing retry task
        retryTask?.cancel()

        retryTask = Task {
            // Process up to 5 requests at a time to prevent flooding
            let requestsToRetry = Array(pendingFreezeRequests.prefix(5))

            await withTaskGroup(of: (StreakFreezeRequest, Bool).self) { group in
                for request in requestsToRetry {
                    group.addTask {
                        await withCheckedContinuation { continuation in
                            NotificationsAPI.createStreakFreeze(streakFreezeRequest: request) { response, error in
                                let success = error == nil
                                continuation.resume(returning: (request, success))
                            }
                        }
                    }
                }

                for await (request, success) in group {
                    guard !Task.isCancelled else { break }

                    await MainActor.run {
                        if success {
                            // Remove from queue on success
                            self.pendingFreezeRequests.remove(request)
                            print("✅ Pending freeze request succeeded")
                        } else {
                            print("❌ Retry failed for request")
                        }
                    }
                }
            }
        }
    }

    func loadStreakData(from homeSummary: HomeSummary) {
        self.brainTokens = homeSummary.brainTokens
        self.streak = homeSummary.streak
    }

    deinit {
        freezeTask?.cancel()
        retryTask?.cancel()
    }
}
