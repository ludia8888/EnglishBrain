//
//  SessionState.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import Foundation
import EnglishBrainAPI

// MARK: - Session State Persistence

/// Persists session state to UserDefaults for app termination recovery
struct SessionStatePersistence {
    private static let sessionKey = "com.englishbrain.session.current"
    private static let progressKey = "com.englishbrain.session.progress"
    private static let attemptKey = "com.englishbrain.session.attempt"
    private static let statsKey = "com.englishbrain.session.stats"

    static func save(
        sessionId: UUID,
        progress: SessionProgress,
        attemptState: SessionAttemptState,
        combo: Int,
        totalCorrect: Int,
        totalAttempts: Int
    ) {
        let defaults = UserDefaults.standard

        // Save session ID
        defaults.set(sessionId.uuidString, forKey: sessionKey)

        // Save progress
        let progressData = encodeProgress(progress)
        defaults.set(progressData, forKey: progressKey)

        // Save attempt state
        if let attemptData = try? JSONEncoder().encode(attemptState) {
            defaults.set(attemptData, forKey: attemptKey)
        }

        // Save stats
        let stats = ["combo": combo, "totalCorrect": totalCorrect, "totalAttempts": totalAttempts]
        defaults.set(stats, forKey: statsKey)

        defaults.synchronize()
    }

    static func load() -> (sessionId: UUID, progress: SessionProgress, attemptState: SessionAttemptState, combo: Int, totalCorrect: Int, totalAttempts: Int)? {
        let defaults = UserDefaults.standard

        // Load session ID
        guard let sessionIdString = defaults.string(forKey: sessionKey),
              let sessionId = UUID(uuidString: sessionIdString) else {
            return nil
        }

        // Load progress
        guard let progressData = defaults.dictionary(forKey: progressKey),
              let progress = decodeProgress(progressData) else {
            return nil
        }

        // Load attempt state
        var attemptState = SessionAttemptState()
        if let attemptData = defaults.data(forKey: attemptKey),
           let decoded = try? JSONDecoder().decode(SessionAttemptState.self, from: attemptData) {
            attemptState = decoded
        }

        // Load stats
        let stats = defaults.dictionary(forKey: statsKey) ?? [:]
        let combo = stats["combo"] as? Int ?? 0
        let totalCorrect = stats["totalCorrect"] as? Int ?? 0
        let totalAttempts = stats["totalAttempts"] as? Int ?? 0

        return (sessionId, progress, attemptState, combo, totalCorrect, totalAttempts)
    }

    static func clear() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: sessionKey)
        defaults.removeObject(forKey: progressKey)
        defaults.removeObject(forKey: attemptKey)
        defaults.removeObject(forKey: statsKey)
        defaults.synchronize()
    }

    private static func encodeProgress(_ progress: SessionProgress) -> [String: Any] {
        switch progress {
        case .notStarted:
            return ["type": "notStarted"]
        case .inProgress(let phaseIndex, let itemIndex):
            return ["type": "inProgress", "phaseIndex": phaseIndex, "itemIndex": itemIndex]
        case .phaseComplete(let phaseIndex):
            return ["type": "phaseComplete", "phaseIndex": phaseIndex]
        case .sessionComplete:
            return ["type": "sessionComplete"]
        }
    }

    private static func decodeProgress(_ data: [String: Any]) -> SessionProgress? {
        guard let type = data["type"] as? String else { return nil }

        switch type {
        case "notStarted":
            return .notStarted
        case "inProgress":
            guard let phaseIndex = data["phaseIndex"] as? Int,
                  let itemIndex = data["itemIndex"] as? Int else { return nil }
            return .inProgress(phaseIndex: phaseIndex, itemIndex: itemIndex)
        case "phaseComplete":
            guard let phaseIndex = data["phaseIndex"] as? Int else { return nil }
            return .phaseComplete(phaseIndex: phaseIndex)
        case "sessionComplete":
            return .sessionComplete
        default:
            return nil
        }
    }
}

enum SessionProgress {
    case notStarted
    case inProgress(phaseIndex: Int, itemIndex: Int)
    case phaseComplete(phaseIndex: Int)
    case sessionComplete
}

struct SessionAttemptState: Codable {
    var selectedTokenIds: [String] = []
    var hintsUsed: Int = 0
    var startTime: Date = Date()
    var attemptCount: Int = 0
}

@MainActor
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
        saveState()
    }

    /// Attempt to restore previous session state
    func restoreStateIfAvailable() -> Bool {
        guard let savedState = SessionStatePersistence.load() else {
            return false
        }

        // Validate session ID matches current session
        guard let session = session, session.sessionId == savedState.sessionId else {
            SessionStatePersistence.clear()
            return false
        }

        // Restore state
        progress = savedState.progress
        attemptState = savedState.attemptState
        combo = savedState.combo
        totalCorrect = savedState.totalCorrect
        totalAttempts = savedState.totalAttempts

        updateCurrentPhaseAndItem()
        return true
    }

    private func saveState() {
        guard let session = session else { return }

        SessionStatePersistence.save(
            sessionId: session.sessionId,
            progress: progress,
            attemptState: attemptState,
            combo: combo,
            totalCorrect: totalCorrect,
            totalAttempts: totalAttempts
        )
    }

    func clearSavedState() {
        SessionStatePersistence.clear()
    }

    func moveToNextItem() {
        let nextItemIndex = currentItemIndex + 1

        if let phase = currentPhase, nextItemIndex >= phase.itemIds.count {
            // Phase complete
            progress = .phaseComplete(phaseIndex: currentPhaseIndex)
        } else {
            // Next item in same phase
            progress = .inProgress(phaseIndex: currentPhaseIndex, itemIndex: nextItemIndex)
            updateCurrentPhaseAndItem()
        }

        saveState()
    }

    func moveToNextPhase() {
        guard let session = session else { return }

        let nextPhaseIndex = currentPhaseIndex + 1

        if nextPhaseIndex >= session.phases.count {
            // Session complete - clear saved state
            progress = .sessionComplete
            currentPhase = nil
            currentItem = nil
            clearSavedState()
        } else {
            // Start next phase
            progress = .inProgress(phaseIndex: nextPhaseIndex, itemIndex: 0)
            updateCurrentPhaseAndItem()
            saveState()
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

        saveState()
    }

    func useHint() {
        attemptState.hintsUsed += 1
        saveState()
    }
}
