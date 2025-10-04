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

    // Offline queue
    @Published var pendingFreezeRequests: [StreakFreezeRequest] = []

    func freezeStreak(targetDate: Date, reason: StreakFreezeRequest.Reason?) {
        guard let tokens = brainTokens, tokens.available > 0 else {
            errorMessage = "Brain Token이 부족합니다"
            return
        }

        guard let currentStreak = streak, currentStreak.freezeEligible else {
            errorMessage = "스트릭 프리즈를 사용할 수 없습니다"
            return
        }

        freezeInProgress = true
        errorMessage = nil

        let request = StreakFreezeRequest(
            targetDate: targetDate,
            reason: reason
        )

        NotificationsAPI.createStreakFreeze(streakFreezeRequest: request) { [weak self] response, error in
            DispatchQueue.main.async {
                self?.freezeInProgress = false

                if let error = error {
                    // Add to offline queue
                    self?.pendingFreezeRequests.append(request)
                    self?.errorMessage = "오프라인 상태입니다. 연결되면 자동으로 처리됩니다."
                    print("❌ Failed to freeze streak: \(error)")
                } else if let response = response {
                    self?.showFreezeSuccess = true
                    // Update tokens count
                    if var tokens = self?.brainTokens {
                        tokens.available -= 1
                        self?.brainTokens = tokens
                    }
                    print("✅ Streak frozen successfully")
                    print("Remaining tokens: \(response.brainTokensRemaining)")
                }
            }
        }
    }

    func retryPendingFreezes() {
        guard !pendingFreezeRequests.isEmpty else { return }

        let requests = pendingFreezeRequests
        pendingFreezeRequests.removeAll()

        for request in requests {
            NotificationsAPI.createStreakFreeze(streakFreezeRequest: request) { [weak self] response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        // Re-add to queue if still failing
                        self?.pendingFreezeRequests.append(request)
                        print("❌ Retry failed: \(error)")
                    } else {
                        print("✅ Pending freeze request succeeded")
                    }
                }
            }
        }
    }

    func loadStreakData(from homeSummary: HomeSummary) {
        self.brainTokens = homeSummary.brainTokens
        self.streak = homeSummary.streak
    }
}
