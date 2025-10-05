//
//  ProfileView.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @StateObject private var streakViewModel = StreakViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    userSection

                    // Streak Calendar
                    streakCalendarSection

                    // Brain Token Inventory
                    BrainTokenInventoryView(viewModel: streakViewModel)
                        .padding(.horizontal)

                    settingsSection

                    Spacer(minLength: 32)
                }
                .padding(.top)
            }
            .background(Color.ebBackground)
            .navigationTitle("프로필")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - User Section

    private var userSection: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.ebPrimary)

            VStack(alignment: .leading, spacing: 4) {
                Text("학습자")
                    .font(.ebH4)
                    .foregroundColor(.ebTextPrimary)

                Text("성장 중")
                    .font(.ebBody)
                    .foregroundColor(.ebTextSecondary)
            }
            .padding(.leading, 12)

            Spacer()
        }
        .padding()
        .background(Color.ebCard)
        .cornerRadius(16)
        .padding(.horizontal)
    }

    // MARK: - Streak Calendar

    private var streakCalendarSection: some View {
        StreakCalendarView(
            currentStreak: streakViewModel.streak?.current ?? 0,
            longestStreak: streakViewModel.streak?.longest ?? 0,
            completedDates: sampleCompletedDates,
            freezeDates: []
        )
        .padding(.horizontal)
    }

    // Sample data for calendar
    private var sampleCompletedDates: Set<Date> {
        let calendar = Calendar.current
        var dates = Set<Date>()
        // Add last 7 days as completed
        for i in -7...0 {
            if let date = calendar.date(byAdding: .day, value: i, to: Date()) {
                dates.insert(date)
            }
        }
        return dates
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(spacing: 16) {
            sectionHeader("학습 설정")

            VStack(spacing: 12) {
                settingRow(icon: "target", title: "일일 목표", action: {})
                settingRow(icon: "bell.fill", title: "알림", action: {})
            }

            sectionHeader("앱 정보")

            VStack(spacing: 12) {
                settingRow(icon: "book.fill", title: "앱 사용 가이드", action: {})
                settingRow(icon: "info.circle", title: "앱 정보", action: {})
            }

            sectionHeader("")

            VStack(spacing: 12) {
                settingRow(
                    icon: "arrow.counterclockwise",
                    title: "튜토리얼 다시 보기",
                    action: {
                        hasCompletedOnboarding = false
                    }
                )
            }
        }
        .padding(.horizontal)
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.ebLabel)
                .foregroundColor(.ebTextSecondary)
            Spacer()
        }
        .padding(.leading, 4)
    }

    private func settingRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.ebPrimary)
                    .frame(width: 32)

                Text(title)
                    .font(.ebBody)
                    .foregroundColor(.ebTextPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.ebTextSecondary)
            }
            .padding()
            .background(Color.ebCard)
            .cornerRadius(12)
        }
    }
}

#Preview {
    ProfileView()
}
