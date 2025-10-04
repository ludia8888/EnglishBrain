//
//  DailyGoalCard.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI
import EnglishBrainAPI

struct DailyGoalCard: View {
    let dailyGoal: HomeSummaryDailyGoal
    let progress: HomeSummaryProgress
    let onTap: () -> Void

    private var progressValue: Double {
        Double(progress.sentencesCompleted) / Double(dailyGoal.sentences)
    }

    private var isComplete: Bool {
        progress.sentencesCompleted >= dailyGoal.sentences
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 20) {
                // Progress ring
                ZStack {
                    ProgressRing(
                        progress: progressValue,
                        lineWidth: 8,
                        size: 80,
                        primaryColor: isComplete ? .ebSuccess : .ebPrimary
                    )

                    VStack(spacing: 2) {
                        Text("\(progress.sentencesCompleted)")
                            .font(.ebH3)
                            .foregroundColor(.ebTextPrimary)
                        Text("/\(dailyGoal.sentences)")
                            .font(.ebCaption)
                            .foregroundColor(.ebTextSecondary)
                    }
                }

                // Info
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("오늘의 목표")
                            .font(.ebH4)
                            .foregroundColor(.ebTextPrimary)

                        if isComplete {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.ebSuccess)
                        }
                    }

                    Text("\(dailyGoal.sentences)문장 · \(dailyGoal.minutes)분")
                        .font(.ebBody)
                        .foregroundColor(.ebTextSecondary)

                    // Tier badge
                    HStack(spacing: 4) {
                        Image(systemName: tierIcon(dailyGoal.tier))
                            .font(.system(size: 12))
                        Text(tierLabel(dailyGoal.tier))
                            .font(.ebLabelSmall)
                    }
                    .foregroundColor(tierColor(dailyGoal.tier))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(tierColor(dailyGoal.tier).opacity(0.1))
                    )
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.ebTextSecondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.ebSurface)
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            )
        }
        .buttonStyle(.plain)
    }

    private func tierIcon(_ tier: HomeSummaryDailyGoal.Tier) -> String {
        switch tier {
        case .basic: return "figure.walk"
        case .intensive: return "flame.fill"
        }
    }

    private func tierLabel(_ tier: HomeSummaryDailyGoal.Tier) -> String {
        switch tier {
        case .basic: return "베이직"
        case .intensive: return "인텐시브"
        }
    }

    private func tierColor(_ tier: HomeSummaryDailyGoal.Tier) -> Color {
        switch tier {
        case .basic: return .ebInfo
        case .intensive: return .ebWarning
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        DailyGoalCard(
            dailyGoal: HomeSummaryDailyGoal(sentences: 12, minutes: 15, tier: .basic),
            progress: HomeSummaryProgress(sentencesCompleted: 7, minutesSpent: 8, lastSessionAt: Date()),
            onTap: {}
        )

        DailyGoalCard(
            dailyGoal: HomeSummaryDailyGoal(sentences: 12, minutes: 15, tier: .intensive),
            progress: HomeSummaryProgress(sentencesCompleted: 12, minutesSpent: 15, lastSessionAt: Date()),
            onTap: {}
        )
    }
    .padding()
    .background(Color.ebBackground)
}
