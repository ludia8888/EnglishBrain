//
//  Typography.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

extension Font {
    // MARK: - Headings
    static let ebH1 = Font.system(size: 32, weight: .bold)
    static let ebH2 = Font.system(size: 28, weight: .bold)
    static let ebH3 = Font.system(size: 24, weight: .semibold)
    static let ebH4 = Font.system(size: 20, weight: .semibold)
    static let ebH5 = Font.system(size: 18, weight: .medium)

    // MARK: - Body
    static let ebBodyLarge = Font.system(size: 17, weight: .regular)
    static let ebBody = Font.system(size: 15, weight: .regular)
    static let ebBodySmall = Font.system(size: 13, weight: .regular)

    // MARK: - Labels
    static let ebLabel = Font.system(size: 14, weight: .medium)
    static let ebLabelSmall = Font.system(size: 12, weight: .medium)

    // MARK: - Special
    static let ebButton = Font.system(size: 16, weight: .semibold)
    static let ebCaption = Font.system(size: 11, weight: .regular)
}
