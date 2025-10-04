//
//  LevelTestState.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import Foundation

enum SlotType: String, Codable {
    case subject = "S"
    case verb = "V"
    case object = "O"
    case modifier = "M"
}

struct TokenItem: Identifiable, Codable {
    let id: String
    let text: String
    let correctSlot: SlotType
    var currentSlot: SlotType?
    var isPlaced: Bool { currentSlot != nil }
}

struct SlotPosition: Identifiable {
    let id = UUID()
    let type: SlotType
    var token: TokenItem?
    var isCorrect: Bool { token?.correctSlot == type }
}

struct LevelTestItem: Identifiable, Codable {
    let id: String
    let koreanSentence: String
    let tokens: [TokenItem]
    let correctOrder: [SlotType]
}

enum HintLevel: Int {
    case none = 0
    case text = 1      // 한국어 텍스트 힌트
    case labels = 2    // S/V/O/M 슬롯 라벨 표시
    case highlight = 3 // 정답 슬롯 하이라이트

    var description: String {
        switch self {
        case .none: return "힌트 없음"
        case .text: return "텍스트 힌트"
        case .labels: return "슬롯 라벨"
        case .highlight: return "하이라이트"
        }
    }
}

struct AttemptMetrics {
    var startTime: Date
    var endTime: Date?
    var hintsUsed: Int
    var hintLevel: HintLevel
    var isFirstTrySuccess: Bool
    var attemptCount: Int

    var duration: TimeInterval {
        guard let end = endTime else { return Date().timeIntervalSince(startTime) }
        return end.timeIntervalSince(startTime)
    }
}
