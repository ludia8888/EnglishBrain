//
//  Colors.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

extension Color {
    // MARK: - Primary Colors
    static let ebPrimary = Color(hex: "4A90E2")
    static let ebPrimaryDark = Color(hex: "357ABD")
    static let ebPrimaryLight = Color(hex: "7BB3F0")

    // MARK: - Semantic Colors
    static let ebSuccess = Color(hex: "4CAF50")
    static let ebWarning = Color(hex: "FF9800")
    static let ebError = Color(hex: "F44336")
    static let ebInfo = Color(hex: "2196F3")

    // MARK: - Neutral Colors
    static let ebBackground = Color(hex: "F5F7FA")
    static let ebSurface = Color.white
    static let ebTextPrimary = Color(hex: "212121")
    static let ebTextSecondary = Color(hex: "757575")
    static let ebTextDisabled = Color(hex: "BDBDBD")
    static let ebDivider = Color(hex: "E0E0E0")

    // MARK: - Feedback Colors (for 3-channel system)
    static let ebFeedbackAudio = Color(hex: "9C27B0")
    static let ebFeedbackVisual = Color(hex: "00BCD4")
    static let ebFeedbackHaptic = Color(hex: "FF5722")

    // MARK: - Pattern Slot Colors
    static let ebSlotSubject = Color(hex: "E91E63")
    static let ebSlotVerb = Color(hex: "3F51B5")
    static let ebSlotObject = Color(hex: "4CAF50")
    static let ebSlotModifier = Color(hex: "FF9800")

    // MARK: - Helper
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
