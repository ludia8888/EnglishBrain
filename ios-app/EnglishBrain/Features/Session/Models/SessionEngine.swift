//
//  SessionEngine.swift
//  EnglishBrain
//
//  Lightweight skeleton for heavy session computations.
//  Use this actor to offload CPU-bound validation or scoring from ViewModels.
//

import Foundation

actor SessionEngine {
    struct ValidationInput {
        let selectedTokenIds: [String]
        let correctSequence: [String]
    }

    func validatePlacement(_ input: ValidationInput) async -> Bool {
        // Placeholder for future heavy work (n-gram checks, fuzzy matching, etc.)
        // Kept trivial for now to avoid behavior changes.
        return input.selectedTokenIds == input.correctSequence
    }
}

