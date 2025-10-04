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

    enum DataCollectionState {
        case collecting
        case ready
    }

    func loadPatternConquests() {
        isLoading = true
        errorMessage = nil

        PatternsAPI.getPatternConquests { [weak self] response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    print("❌ Failed to load pattern conquests: \(error)")
                } else if let data = response {
                    self?.conquests = data.patterns
                    self?.dataCollectionState = data.patterns.isEmpty ? .collecting : .ready

                    print("✅ Loaded \(data.patterns.count) pattern conquests")
                }
            }
        }
    }

    func refresh() {
        loadPatternConquests()
    }

    // MARK: - Computed Properties

    var weakPatterns: [PatternConquest] {
        conquests
            .filter { $0.conquestRate < 0.6 }
            .sorted { $0.severity > $1.severity }
    }

    var masteredPatterns: [PatternConquest] {
        conquests
            .filter { $0.conquestRate >= 0.8 }
            .sorted { $0.conquestRate > $1.conquestRate }
    }

    var improvingPatterns: [PatternConquest] {
        conquests
            .filter { $0.trend == .improving }
            .sorted { $0.conquestRate < $1.conquestRate }
    }

    var averageConquestRate: Double {
        guard !conquests.isEmpty else { return 0 }
        return conquests.reduce(0.0) { $0 + $1.conquestRate } / Double(conquests.count)
    }

    var totalExposures: Int {
        conquests.reduce(0) { $0 + $1.exposures }
    }
}
