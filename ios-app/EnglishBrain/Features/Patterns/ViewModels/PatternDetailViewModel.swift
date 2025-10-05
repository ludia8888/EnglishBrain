//
//  PatternDetailViewModel.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import Foundation
import Combine
import EnglishBrainAPI

@MainActor
class PatternDetailViewModel: ObservableObject {
    @Published var conquests: [PatternConquest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var dataCollectionState: DataCollectionState = .ready

    // Cached computed properties to prevent O(n log n) recalculation on every render
    @Published private(set) var weakPatterns: [PatternConquest] = []
    @Published private(set) var masteredPatterns: [PatternConquest] = []
    @Published private(set) var improvingPatterns: [PatternConquest] = []
    @Published private(set) var averageConquestRate: Double = 0
    @Published private(set) var totalExposures: Int = 0

    private var hasLoadedInitialData = false
    private var loadTask: Task<Void, Never>?

    enum DataCollectionState {
        case collecting
        case ready
    }

    func loadPatternConquestsIfNeeded() {
        guard !hasLoadedInitialData else { return }
        hasLoadedInitialData = true
        loadPatternConquests()
    }

    func loadPatternConquests() {
        // Cancel any existing load task to prevent race conditions
        loadTask?.cancel()

        loadTask = Task {
            isLoading = true
            errorMessage = nil

            await withCheckedContinuation { continuation in
                PatternsAPI.getPatternConquests { [weak self] response, error in
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
                            self.errorMessage = error.localizedDescription
                            print("❌ Failed to load pattern conquests: \(error)")
                        } else if let data = response {
                            self.conquests = data.patterns
                            self.dataCollectionState = data.patterns.isEmpty ? .collecting : .ready

                            // Cache computed properties ONCE after data load
                            self.categorizePatterns(data.patterns)

                            print("✅ Loaded \(data.patterns.count) pattern conquests")
                        }

                        continuation.resume()
                    }
                }
            }
        }
    }

    func refresh() {
        loadPatternConquests()
    }

    // MARK: - Pattern Categorization (O(n log n) cached computation)

    private func categorizePatterns(_ patterns: [PatternConquest]) {
        // Compute once and cache - prevents O(n log n) on every render
        weakPatterns = patterns
            .filter { $0.conquestRate < 0.6 }
            .sorted { $0.severity > $1.severity }

        masteredPatterns = patterns
            .filter { $0.conquestRate >= 0.8 }
            .sorted { $0.conquestRate > $1.conquestRate }

        improvingPatterns = patterns
            .filter { $0.trend == .improving }
            .sorted { $0.conquestRate > $1.conquestRate }

        averageConquestRate = patterns.isEmpty ? 0 : patterns.reduce(0.0) { $0 + $1.conquestRate } / Double(patterns.count)

        totalExposures = patterns.reduce(0) { $0 + $1.exposures }
    }

    deinit {
        loadTask?.cancel()
    }
}
