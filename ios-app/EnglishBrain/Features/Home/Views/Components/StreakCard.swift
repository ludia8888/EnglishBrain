//
//  StreakCard.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI
import EnglishBrainAPI

struct StreakCard: View {
    let streak: HomeSummaryStreak
    let brainTokens: HomeSummaryBrainTokens
    let onUseFreeze: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Streak display
            HStack(spacing: 12) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.ebWarning)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("\(streak.current)")
                            .font(.ebH2)
                            .foregroundColor(.ebTextPrimary)
                        Text("일 연속")
                            .font(.ebBody)
                            .foregroundColor(.ebTextSecondary)
                    }

                    Text("최고 기록 \(streak.longest)일")
                        .font(.ebBodySmall)
                        .foregroundColor(.ebTextSecondary)
                }

                Spacer()

                // Brain Tokens
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 14))
                        Text("\(brainTokens.available)")
                            .font(.ebLabel)
                    }
                    .foregroundColor(.ebPrimary)

                    if brainTokens.pending > 0 {
                        Text("곧 받을 토큰 +\(brainTokens.pending)")
                            .font(.ebCaption)
                            .foregroundColor(.ebInfo)
                    }
                }
            }

            // Freeze button (if eligible)
            if streak.freezeEligible && brainTokens.available > 0 {
                Divider()

                Button(action: onUseFreeze) {
                    HStack {
                        Image(systemName: "snowflake")
                            .font(.system(size: 16))
                        Text("하루 쉬기 (토큰 1개)")
                            .font(.ebLabel)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.ebInfo)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.ebSurface)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        StreakCard(
            streak: HomeSummaryStreak(current: 7, longest: 14, freezeEligible: true),
            brainTokens: HomeSummaryBrainTokens(available: 3, pending: 2),
            onUseFreeze: {}
        )

        StreakCard(
            streak: HomeSummaryStreak(current: 0, longest: 14, freezeEligible: false),
            brainTokens: HomeSummaryBrainTokens(available: 0, pending: 5),
            onUseFreeze: {}
        )
    }
    .padding()
    .background(Color.ebBackground)
}
