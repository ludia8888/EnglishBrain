//
//  SessionState.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import Foundation
import EnglishBrainAPI

enum SessionProgress {
    case notStarted
    case inProgress(phaseIndex: Int, itemIndex: Int)
    case phaseComplete(phaseIndex: Int)
    case sessionComplete
}

struct SessionAttemptState {
    var selectedTokenIds: [String] = []
    var hintsUsed: Int = 0
    var startTime: Date = Date()
    var attemptCount: Int = 0
}

class SessionStateManager: ObservableObject {
    @Published var session: Session?
    @Published var progress: SessionProgress = .notStarted
    @Published var currentPhase: SessionPhase?
    @Published var currentItem: SessionItem?
    @Published var attemptState: SessionAttemptState = SessionAttemptState()
    @Published var combo: Int = 0
    @Published var totalCorrect: Int = 0
    @Published var totalAttempts: Int = 0

    var currentPhaseIndex: Int {
        switch progress {
        case .inProgress(let phaseIndex, _), .phaseComplete(let phaseIndex):
            return phaseIndex
        default:
            return 0
        }
    }

    var currentItemIndex: Int {
        switch progress {
        case .inProgress(_, let itemIndex):
            return itemIndex
        default:
            return 0
        }
    }

    var isPhaseComplete: Bool {
        guard let phase = currentPhase else { return false }
        return currentItemIndex >= phase.itemIds.count
    }

    var isSessionComplete: Bool {
        guard let session = session else { return false }
        return currentPhaseIndex >= session.phases.count
    }

    func loadSession(_ session: Session) {
        self.session = session
        self.progress = .inProgress(phaseIndex: 0, itemIndex: 0)
        updateCurrentPhaseAndItem()
    }

    func moveToNextItem() {
        guard let session = session else { return }

        let nextItemIndex = currentItemIndex + 1

        if let phase = currentPhase, nextItemIndex >= phase.itemIds.count {
            // Phase complete
            progress = .phaseComplete(phaseIndex: currentPhaseIndex)
        } else {
            // Next item in same phase
            progress = .inProgress(phaseIndex: currentPhaseIndex, itemIndex: nextItemIndex)
            updateCurrentPhaseAndItem()
        }
    }

    func moveToNextPhase() {
        guard let session = session else { return }

        let nextPhaseIndex = currentPhaseIndex + 1

        if nextPhaseIndex >= session.phases.count {
            // Session complete
            progress = .sessionComplete
            currentPhase = nil
            currentItem = nil
        } else {
            // Start next phase
            progress = .inProgress(phaseIndex: nextPhaseIndex, itemIndex: 0)
            updateCurrentPhaseAndItem()
        }
    }

    private func updateCurrentPhaseAndItem() {
        guard let session = session else { return }
        guard session.phases.indices.contains(currentPhaseIndex) else {
            currentPhase = nil
            currentItem = nil
            return
        }

        let phase = session.phases[currentPhaseIndex]
        currentPhase = phase

        guard phase.itemIds.indices.contains(currentItemIndex) else {
            currentItem = nil
            return
        }

        let itemId = phase.itemIds[currentItemIndex]
        currentItem = session.items.first { $0.itemId == itemId }

        // Reset attempt state for new item
        attemptState = SessionAttemptState()
    }

    func recordAttempt(selectedTokenIds: [String], isCorrect: Bool) {
        attemptState.selectedTokenIds = selectedTokenIds
        attemptState.attemptCount += 1
        totalAttempts += 1

        if isCorrect {
            totalCorrect += 1
            combo += 1
        } else {
            combo = 0
        }
    }

    func useHint() {
        attemptState.hintsUsed += 1
    }
}
