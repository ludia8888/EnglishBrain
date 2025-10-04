//
//  HomeViewModel.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import Foundation
import EnglishBrainAPI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var homeSummary: HomeSummary?
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        loadHomeSummary()
    }

    func loadHomeSummary() {
        isLoading = true
        errorMessage = nil

        UsersAPI.getHomeSummary { [weak self] response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = error.userFriendlyMessage
                    print("❌ Failed to load home summary: \(error.detailedDescription)")
                } else if let summary = response {
                    self?.homeSummary = summary
                    print("✅ Home summary loaded")
                    print("Daily progress: \(summary.progress.sentencesCompleted)/\(summary.dailyGoal.sentences)")
                    print("Streak: \(summary.streak.current) days")
                    print("Brain Tokens: \(summary.brainTokens.available)")
                    print("Pattern cards: \(summary.patternCards.count)")
                }
            }
        }
    }

    func refresh() {
        loadHomeSummary()
    }

    var dailyProgress: Double {
        guard let summary = homeSummary else { return 0 }
        return Double(summary.progress.sentencesCompleted) / Double(summary.dailyGoal.sentences)
    }

    var isGoalComplete: Bool {
        guard let summary = homeSummary else { return false }
        return summary.progress.sentencesCompleted >= summary.dailyGoal.sentences
    }
}
