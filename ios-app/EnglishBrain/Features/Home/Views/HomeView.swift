//
//  HomeView.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI
import EnglishBrainAPI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showSession = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.ebBackground.ignoresSafeArea()

                if viewModel.isLoading && viewModel.homeSummary == nil {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if let summary = viewModel.homeSummary {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header
                            headerView

                            // Daily Goal Card
                            DailyGoalCard(
                                dailyGoal: summary.dailyGoal,
                                progress: summary.progress,
                                onTap: {
                                    showSession = true
                                }
                            )
                            .padding(.horizontal)

                            // Streak & Brain Tokens
                            StreakCard(
                                streak: summary.streak,
                                brainTokens: summary.brainTokens,
                                onUseFreeze: {
                                    print("Use streak freeze")
                                }
                            )
                            .padding(.horizontal)

                            // Pattern Weakness Cards
                            if !summary.patternCards.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("약점 패턴")
                                        .font(.ebH4)
                                        .foregroundColor(.ebTextPrimary)
                                        .padding(.horizontal)

                                    VStack(spacing: 12) {
                                        ForEach(summary.patternCards.prefix(3), id: \.patternId) { pattern in
                                            PatternWeaknessCard(
                                                pattern: pattern,
                                                onDrill: { patternId in
                                                    print("Start drill for pattern: \(patternId)")
                                                }
                                            )
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }

                            // Recommended Actions
                            if !summary.recommendedActions.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("추천 활동")
                                        .font(.ebH4)
                                        .foregroundColor(.ebTextPrimary)
                                        .padding(.horizontal)

                                    VStack(spacing: 12) {
                                        ForEach(summary.recommendedActions, id: \.deeplink) { action in
                                            ActionCard(action: action)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }

                            Spacer(minLength: 32)
                        }
                        .padding(.top, 16)
                    }
                    .refreshable {
                        viewModel.refresh()
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(.ebError)

                        Text("데이터를 불러올 수 없습니다")
                            .font(.ebH4)
                            .foregroundColor(.ebTextPrimary)

                        Text(errorMessage)
                            .font(.ebBody)
                            .foregroundColor(.ebTextSecondary)
                            .multilineTextAlignment(.center)

                        PrimaryButton(title: "다시 시도", action: viewModel.refresh)
                            .frame(width: 200)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showSession) {
                SessionView()
            }
        }
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("English Brain")
                    .font(.ebH3)
                    .foregroundColor(.ebTextPrimary)

                if let summary = viewModel.homeSummary {
                    Text(greetingMessage(summary))
                        .font(.ebBody)
                        .foregroundColor(.ebTextSecondary)
                }
            }

            Spacer()

            // Profile button
            Button(action: {
                print("Open profile")
            }) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.ebPrimary)
            }
        }
        .padding(.horizontal)
    }

    private func greetingMessage(_ summary: HomeSummary) -> String {
        if summary.progress.sentencesCompleted >= summary.dailyGoal.sentences {
            return "🎉 오늘의 목표를 달성했어요!"
        } else {
            let remaining = summary.dailyGoal.sentences - summary.progress.sentencesCompleted
            return "오늘 \(remaining)문장 남았어요"
        }
    }
}

struct ActionCard: View {
    let action: HomeAction

    private var typeIcon: String {
        switch action.type {
        case .dailySession: return "play.circle.fill"
        case .review: return "arrow.counterclockwise.circle.fill"
        case .brainBurst: return "sparkles"
        case .widget: return "square.grid.2x2"
        case .tutorial: return "book.circle.fill"
        }
    }

    private var typeColor: Color {
        switch action.type {
        case .dailySession: return .ebPrimary
        case .review: return .ebInfo
        case .brainBurst: return .ebWarning
        case .widget: return .ebSuccess
        case .tutorial: return .ebTextSecondary
        }
    }

    var body: some View {
        Button(action: {
            print("Action tapped: \(action.deeplink)")
        }) {
            HStack(spacing: 16) {
                Image(systemName: typeIcon)
                    .font(.system(size: 28))
                    .foregroundColor(typeColor)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(typeColor.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(action.title)
                            .font(.ebLabel)
                            .foregroundColor(.ebTextPrimary)

                        if let planRequired = action.planRequired, planRequired == .pro {
                            Text("PRO")
                                .font(.ebCaption)
                                .foregroundColor(.ebWarning)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.ebWarning.opacity(0.1))
                                )
                        }
                    }

                    if let subtitle = action.subtitle {
                        Text(subtitle)
                            .font(.ebBodySmall)
                            .foregroundColor(.ebTextSecondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.ebTextSecondary)
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
}

#Preview {
    HomeView()
}
