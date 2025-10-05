//
//  PatternWeaknessCard.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI
import EnglishBrainAPI

struct PatternWeaknessCard: View {
    let pattern: PatternCard
    let onDrill: (String) -> Void

    private var trendIcon: String {
        switch pattern.trend {
        case .improving: return "arrow.up.right"
        case .stable: return "arrow.right"
        case .declining: return "arrow.down.right"
        }
    }

    private var trendColor: Color {
        switch pattern.trend {
        case .improving: return .ebSuccess
        case .stable: return .ebTextSecondary
        case .declining: return .ebError
        }
    }

    private var severityColor: Color {
        switch pattern.severity {
        case 1...2: return .ebSuccess
        case 3: return .ebWarning
        case 4...5: return .ebError
        default: return .ebTextSecondary
        }
    }

    var body: some View {
        Button(action: { onDrill(pattern.patternId) }) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    // Pattern label
                    Text(pattern.label)
                        .font(.ebH5)
                        .foregroundColor(.ebTextPrimary)

                    Spacer()

                    // Trend indicator
                    HStack(spacing: 4) {
                        Image(systemName: trendIcon)
                            .font(.system(size: 12))
                        Text(trendText)
                            .font(.ebCaption)
                    }
                    .foregroundColor(trendColor)
                }

                // Conquest rate
                HStack(spacing: 8) {
                    Text("정복률")
                        .font(.ebBodySmall)
                        .foregroundColor(.ebTextSecondary)

                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.ebDivider)
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(conquestColor)
                                .frame(width: geometry.size.width * pattern.conquestRate, height: 6)
                        }
                    }
                    .frame(height: 6)

                    Text("\(Int(pattern.conquestRate * 100))%")
                        .font(.ebLabelSmall)
                        .foregroundColor(.ebTextPrimary)
                        .frame(width: 40, alignment: .trailing)
                }

                // Stats
                HStack(spacing: 16) {
                    if let hintRate = pattern.hintRate {
                        StatBadge(
                            icon: "lightbulb.fill",
                            label: "힌트 사용",
                            value: "\(Int(hintRate * 100))%",
                            color: .ebInfo
                        )
                    }

                    if let firstTryRate = pattern.firstTryRate {
                        StatBadge(
                            icon: "target",
                            label: "첫 시도 성공",
                            value: "\(Int(firstTryRate * 100))%",
                            color: .ebSuccess
                        )
                    }

                    Spacer()

                    // Severity indicator
                    HStack(spacing: 4) {
                        ForEach(0..<pattern.severity, id: \.self) { _ in
                            Circle()
                                .fill(severityColor)
                                .frame(width: 6, height: 6)
                        }
                    }
                }

                // Action button
                HStack {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 14))
                    Text(pattern.recommendedAction.title)
                        .font(.ebLabel)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.ebPrimary)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.ebPrimary.opacity(0.1))
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.ebSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.ebDivider, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var trendText: String {
        switch pattern.trend {
        case .improving: return "개선 중"
        case .stable: return "유지 중"
        case .declining: return "주의 필요"
        }
    }

    private var conquestColor: Color {
        if pattern.conquestRate >= 0.7 {
            return .ebSuccess
        } else if pattern.conquestRate >= 0.4 {
            return .ebWarning
        } else {
            return .ebError
        }
    }
}

struct StatBadge: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            VStack(alignment: .leading, spacing: 0) {
                Text(label)
                    .font(.ebCaption)
                    .foregroundColor(.ebTextSecondary)
                Text(value)
                    .font(.ebLabelSmall)
                    .foregroundColor(.ebTextPrimary)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        PatternWeaknessCard(
            pattern: PatternCard(
                patternId: "p1",
                label: "과거시제 (+ed)",
                conquestRate: 0.45,
                trend: .declining,
                severity: 4,
                recommendedAction: HomeAction(
                    type: .dailySession,
                    title: "집중 드릴 시작",
                    deeplink: "/drill/p1"
                ),
                hintRate: 0.65,
                firstTryRate: 0.35
            ),
            onDrill: { _ in }
        )

        PatternWeaknessCard(
            pattern: PatternCard(
                patternId: "p2",
                label: "의문문 어순 (Do/Does)",
                conquestRate: 0.82,
                trend: .improving,
                severity: 2,
                recommendedAction: HomeAction(
                    type: .review,
                    title: "복습하기",
                    deeplink: "/review/p2"
                ),
                hintRate: 0.25,
                firstTryRate: 0.78
            ),
            onDrill: { _ in }
        )
    }
    .padding()
    .background(Color.ebBackground)
}
