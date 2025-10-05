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

    private var hasLoadedInitialData = false
    private var loadTask: Task<Void, Never>?

    func loadHomeSummaryIfNeeded() {
        guard !hasLoadedInitialData else { return }
        hasLoadedInitialData = true
        loadHomeSummary()
    }

    func loadHomeSummary() {
        // Cancel any existing load task to prevent race conditions
        loadTask?.cancel()

        if AppEnvironment.shared.usesMockData {
            loadTask = Task { @MainActor in
                isLoading = true
                errorMessage = nil

                try? await Task.sleep(nanoseconds: 200_000_000)
                guard !Task.isCancelled else { return }

                let summary = MockDataProvider.shared.makeHomeSummary()
                isLoading = false
                handleHomeSummaryLoaded(summary)
            }
            return
        }

        loadTask = Task { @MainActor in
            isLoading = true
            errorMessage = nil

            await withCheckedContinuation { continuation in
                UsersAPI.getHomeSummary { [weak self] response, error in
                    guard let self = self else {
                        continuation.resume()
                        return
                    }

                    Task { @MainActor in
                        // Check if task was cancelled
                        guard !Task.isCancelled else {
                            continuation.resume()
                            return
                        }

                        self.isLoading = false

                        if let error = error {
                            self.errorMessage = error.userFriendlyMessage
                            print("❌ Failed to load home summary: \(error.detailedDescription)")
                        } else if let summary = response {
                            self.handleHomeSummaryLoaded(summary)
                        }

                        continuation.resume()
                    }
                }
            }
        }
    }

    func refresh() {
        loadHomeSummary()
    }

    deinit {
        loadTask?.cancel()
    }

    var dailyProgress: Double {
        guard let summary = homeSummary else { return 0 }
        return Double(summary.progress.sentencesCompleted) / Double(summary.dailyGoal.sentences)
    }

    var isGoalComplete: Bool {
        guard let summary = homeSummary else { return false }
        return summary.progress.sentencesCompleted >= summary.dailyGoal.sentences
    }

    private func handleHomeSummaryLoaded(_ summary: HomeSummary) {
        homeSummary = summary
        print("✅ Home summary loaded")
        print("Daily progress: \(summary.progress.sentencesCompleted)/\(summary.dailyGoal.sentences)")
        print("Streak: \(summary.streak.current) days")
        print("Brain Tokens: \(summary.brainTokens.available)")
        print("Pattern cards: \(summary.patternCards.count)")
    }
}
