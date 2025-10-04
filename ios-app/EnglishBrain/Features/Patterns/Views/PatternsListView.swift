//
//  PatternsListView.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI
import EnglishBrainAPI

struct PatternsListView: View {
    @StateObject private var viewModel = PatternDetailViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color.ebBackground.ignoresSafeArea()

                if viewModel.isLoading && viewModel.conquests.isEmpty {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if viewModel.dataCollectionState == .collecting {
                    dataCollectingView
                } else if !viewModel.conquests.isEmpty {
                    contentView
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(errorMessage)
                }
            }
            .navigationTitle("패턴 정복")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.loadPatternConquests()
            }
            .refreshable {
                viewModel.refresh()
            }
        }
    }

    // MARK: - Content View

    private var contentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Summary Stats
                summaryStatsView

                // Weak Patterns
                if !viewModel.weakPatterns.isEmpty {
                    patternSection(
                        title: "약점 패턴",
                        icon: "exclamationmark.triangle.fill",
                        color: .ebError,
                        patterns: viewModel.weakPatterns
                    )
                }

                // Improving Patterns
                if !viewModel.improvingPatterns.isEmpty {
                    patternSection(
                        title: "개선 중인 패턴",
                        icon: "arrow.up.right",
                        color: .ebSuccess,
                        patterns: viewModel.improvingPatterns
                    )
                }

                // Mastered Patterns
                if !viewModel.masteredPatterns.isEmpty {
                    patternSection(
                        title: "마스터한 패턴",
                        icon: "star.fill",
                        color: .ebWarning,
                        patterns: viewModel.masteredPatterns
                    )
                }

                Spacer(minLength: 32)
            }
            .padding()
        }
    }

    // MARK: - Summary Stats

    private var summaryStatsView: some View {
        VStack(spacing: 16) {
            // Overall Progress
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("전체 평균 정복률")
                        .font(.ebLabel)
                        .foregroundColor(.ebTextSecondary)

                    Text("\(Int(viewModel.averageConquestRate * 100))%")
                        .font(.ebH2)
                        .foregroundColor(.ebTextPrimary)
                }

                Spacer()

                ProgressRing(
                    progress: viewModel.averageConquestRate,
                    lineWidth: 8,
                    size: 80,
                    primaryColor: .ebPrimary
                )
            }

            Divider()

            // Stats Grid
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("\(viewModel.conquests.count)")
                        .font(.ebH3)
                        .foregroundColor(.ebTextPrimary)

                    Text("학습 패턴")
                        .font(.ebBodySmall)
                        .foregroundColor(.ebTextSecondary)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    Text("\(viewModel.totalExposures)")
                        .font(.ebH3)
                        .foregroundColor(.ebTextPrimary)

                    Text("총 노출")
                        .font(.ebBodySmall)
                        .foregroundColor(.ebTextSecondary)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    Text("\(viewModel.masteredPatterns.count)")
                        .font(.ebH3)
                        .foregroundColor(.ebSuccess)

                    Text("마스터")
                        .font(.ebBodySmall)
                        .foregroundColor(.ebTextSecondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.ebSurface)
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        )
    }

    // MARK: - Pattern Section

    private func patternSection(title: String, icon: String, color: Color, patterns: [PatternConquest]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)

                Text(title)
                    .font(.ebH4)
                    .foregroundColor(.ebTextPrimary)

                Spacer()

                Text("\(patterns.count)")
                    .font(.ebLabel)
                    .foregroundColor(.ebTextSecondary)
            }

            ForEach(patterns, id: \.patternId) { pattern in
                NavigationLink(destination: PatternDetailView(pattern: pattern)) {
                    PatternConquestRow(pattern: pattern)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Data Collecting View

    private var dataCollectingView: some View {
        VStack(spacing: 24) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.ebInfo)

            Text("데이터 수집 중")
                .font(.ebH3)
                .foregroundColor(.ebTextPrimary)

            Text("더 많은 세션을 완료하면\n개인화된 패턴 분석을 볼 수 있어요")
                .font(.ebBody)
                .foregroundColor(.ebTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            PrimaryButton(title: "세션 시작하기", action: {
                // Navigate to session
            })
            .frame(width: 200)
        }
        .padding()
    }

    // MARK: - Error View

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.ebError)

            Text("데이터를 불러올 수 없습니다")
                .font(.ebH4)
                .foregroundColor(.ebTextPrimary)

            Text(message)
                .font(.ebBody)
                .foregroundColor(.ebTextSecondary)
                .multilineTextAlignment(.center)

            PrimaryButton(title: "다시 시도", action: viewModel.refresh)
                .frame(width: 200)
        }
        .padding()
    }
}

// MARK: - Pattern Conquest Row

struct PatternConquestRow: View {
    let pattern: PatternConquest

    var body: some View {
        HStack(spacing: 16) {
            // Conquest indicator
            ZStack {
                Circle()
                    .stroke(Color.ebDivider, lineWidth: 4)
                    .frame(width: 50, height: 50)

                Circle()
                    .trim(from: 0, to: pattern.conquestRate)
                    .stroke(conquestColor, lineWidth: 4)
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))

                Text("\(Int(pattern.conquestRate * 100))")
                    .font(.ebLabelSmall)
                    .foregroundColor(.ebTextPrimary)
            }

            // Pattern info
            VStack(alignment: .leading, spacing: 4) {
                Text(pattern.label)
                    .font(.ebLabel)
                    .foregroundColor(.ebTextPrimary)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: trendIcon)
                            .font(.system(size: 10))
                        Text(trendText)
                            .font(.ebCaption)
                    }
                    .foregroundColor(trendColor)

                    Text("\(pattern.exposures)회 노출")
                        .font(.ebCaption)
                        .foregroundColor(.ebTextSecondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.ebTextSecondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.ebSurface)
        )
    }

    private var conquestColor: Color {
        if pattern.conquestRate >= 0.8 { return .ebSuccess }
        if pattern.conquestRate >= 0.6 { return .ebWarning }
        return .ebError
    }

    private var trendIcon: String {
        switch pattern.trend {
        case .improving: return "arrow.up.right"
        case .stable: return "arrow.right"
        case .declining: return "arrow.down.right"
        }
    }

    private var trendText: String {
        switch pattern.trend {
        case .improving: return "개선"
        case .stable: return "유지"
        case .declining: return "하락"
        }
    }

    private var trendColor: Color {
        switch pattern.trend {
        case .improving: return .ebSuccess
        case .stable: return .ebTextSecondary
        case .declining: return .ebError
        }
    }
}

#Preview {
    PatternsListView()
}
