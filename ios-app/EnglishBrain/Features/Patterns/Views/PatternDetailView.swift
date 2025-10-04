//
//  PatternDetailView.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI
import EnglishBrainAPI

struct PatternDetailView: View {
    @StateObject private var viewModel = PatternDetailViewModel()
    @State private var showReview = false
    let pattern: PatternConquest

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                patternHeaderView

                // Review CTA
                reviewButtonView

                // Stats Overview
                statsOverviewView

                // Conquest Rate Chart
                conquestRateChartView

                // Metrics
                metricsGrid

                // Recent Practice
                recentPracticeView

                Spacer(minLength: 32)
            }
            .padding()
        }
        .background(Color.ebBackground)
        .navigationTitle(pattern.label)
        .navigationBarTitleDisplayMode(.large)
        .fullScreenCover(isPresented: $showReview) {
            ReviewView(patternId: pattern.patternId, targetSentences: 6)
        }
    }

    // MARK: - Header

    private var patternHeaderView: some View {
        VStack(spacing: 16) {
            // Conquest Rate Ring
            ZStack {
                ProgressRing(
                    progress: pattern.conquestRate,
                    lineWidth: 12,
                    size: 120,
                    primaryColor: conquestColor(pattern.conquestRate)
                )

                VStack(spacing: 4) {
                    Text("\(Int(pattern.conquestRate * 100))%")
                        .font(.ebH2)
                        .foregroundColor(.ebTextPrimary)

                    Text("정복률")
                        .font(.ebCaption)
                        .foregroundColor(.ebTextSecondary)
                }
            }

            // Trend Badge
            HStack(spacing: 8) {
                Image(systemName: trendIcon(pattern.trend))
                    .font(.system(size: 14))
                Text(trendText(pattern.trend))
                    .font(.ebLabel)
            }
            .foregroundColor(trendColor(pattern.trend))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(trendColor(pattern.trend).opacity(0.1))
            )
        }
        .padding(.vertical)
    }

    // MARK: - Stats Overview

    private var statsOverviewView: some View {
        HStack(spacing: 16) {
            StatCard(
                icon: "target",
                value: "\(pattern.exposures)",
                label: "노출 횟수",
                color: .ebInfo
            )

            StatCard(
                icon: "exclamationmark.triangle.fill",
                value: "\(pattern.severity)",
                label: "난이도",
                color: severityColor(pattern.severity)
            )
        }
    }

    // MARK: - Conquest Rate Chart

    private var conquestRateChartView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("학습 진행도")
                .font(.ebH4)
                .foregroundColor(.ebTextPrimary)

            VStack(spacing: 8) {
                // Progress segments
                GeometryReader { geometry in
                    HStack(spacing: 4) {
                        // 0-40%: Red
                        Rectangle()
                            .fill(Color.ebError.opacity(pattern.conquestRate > 0 ? 1 : 0.3))
                            .frame(width: geometry.size.width * 0.4)

                        // 40-70%: Orange
                        Rectangle()
                            .fill(Color.ebWarning.opacity(pattern.conquestRate > 0.4 ? 1 : 0.3))
                            .frame(width: geometry.size.width * 0.3)

                        // 70-100%: Green
                        Rectangle()
                            .fill(Color.ebSuccess.opacity(pattern.conquestRate > 0.7 ? 1 : 0.3))
                            .frame(width: geometry.size.width * 0.3)
                    }
                }
                .frame(height: 12)
                .clipShape(RoundedRectangle(cornerRadius: 6))

                // Labels
                HStack {
                    Text("입문")
                        .font(.ebCaption)
                        .foregroundColor(.ebTextSecondary)

                    Spacer()

                    Text("중급")
                        .font(.ebCaption)
                        .foregroundColor(.ebTextSecondary)

                    Spacer()

                    Text("마스터")
                        .font(.ebCaption)
                        .foregroundColor(.ebTextSecondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.ebSurface)
        )
    }

    // MARK: - Metrics Grid

    private var metricsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("상세 지표")
                .font(.ebH4)
                .foregroundColor(.ebTextPrimary)

            VStack(spacing: 12) {
                if let hintRate = pattern.hintRate {
                    MetricRow(
                        icon: "lightbulb.fill",
                        label: "힌트 사용률",
                        value: "\(Int(hintRate * 100))%",
                        color: .ebInfo
                    )
                }

                if let firstTryRate = pattern.firstTryRate {
                    MetricRow(
                        icon: "target",
                        label: "1차 성공률",
                        value: "\(Int(firstTryRate * 100))%",
                        color: .ebSuccess
                    )
                }

                MetricRow(
                    icon: "chart.line.uptrend.xyaxis",
                    label: "평균 정복률",
                    value: "\(Int(pattern.conquestRate * 100))%",
                    color: .ebPrimary
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.ebSurface)
        )
    }

    // MARK: - Recent Practice

    private var recentPracticeView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("최근 연습")
                .font(.ebH4)
                .foregroundColor(.ebTextPrimary)

            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.ebTextSecondary)

                Text(timeAgoText(pattern.lastPracticedAt))
                    .font(.ebBody)
                    .foregroundColor(.ebTextPrimary)

                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.ebBackground)
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.ebSurface)
        )
    }

    // MARK: - Helpers

    private func conquestColor(_ rate: Double) -> Color {
        if rate >= 0.8 { return .ebSuccess }
        if rate >= 0.6 { return .ebWarning }
        return .ebError
    }

    private func trendIcon(_ trend: PatternConquest.Trend) -> String {
        switch trend {
        case .improving: return "arrow.up.right"
        case .stable: return "arrow.right"
        case .declining: return "arrow.down.right"
        }
    }

    private func trendText(_ trend: PatternConquest.Trend) -> String {
        switch trend {
        case .improving: return "개선 중"
        case .stable: return "안정"
        case .declining: return "하락"
        }
    }

    // MARK: - Review Button

    private var reviewButtonView: some View {
        PrimaryButton(
            title: "이 패턴 복습하기",
            action: { showReview = true }
        )
    }

    private func trendColor(_ trend: PatternConquest.Trend) -> Color {
        switch trend {
        case .improving: return .ebSuccess
        case .stable: return .ebTextSecondary
        case .declining: return .ebError
        }
    }

    private func severityColor(_ severity: Int) -> Color {
        switch severity {
        case 1...2: return .ebSuccess
        case 3: return .ebWarning
        default: return .ebError
        }
    }

    private func timeAgoText(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let hours = Int(interval / 3600)
        let days = hours / 24

        if days > 0 {
            return "\(days)일 전"
        } else if hours > 0 {
            return "\(hours)시간 전"
        } else {
            return "방금 전"
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(value)
                .font(.ebH3)
                .foregroundColor(.ebTextPrimary)

            Text(label)
                .font(.ebBodySmall)
                .foregroundColor(.ebTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.ebSurface)
        )
    }
}

struct MetricRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)

            Text(label)
                .font(.ebBody)
                .foregroundColor(.ebTextPrimary)

            Spacer()

            Text(value)
                .font(.ebLabel)
                .foregroundColor(color)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.ebBackground)
        )
    }
}

#Preview {
    NavigationView {
        PatternDetailView(
            pattern: PatternConquest(
                patternId: "p1",
                label: "과거시제 (+ed)",
                conquestRate: 0.65,
                severity: 3,
                exposures: 24,
                lastPracticedAt: Date().addingTimeInterval(-3600 * 5),
                trend: .improving,
                hintRate: 0.35,
                firstTryRate: 0.58
            )
        )
    }
}
