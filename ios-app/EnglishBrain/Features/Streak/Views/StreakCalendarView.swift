//
//  StreakCalendarView.swift
//  EnglishBrain
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

struct StreakCalendarView: View {
    let currentStreak: Int
    let longestStreak: Int
    let completedDates: Set<Date> // Dates with completed sessions
    let freezeDates: Set<Date> // Dates with streak freeze

    @State private var selectedMonth = Date()

    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    var body: some View {
        VStack(spacing: 16) {
            headerView
            statsRow
            monthNavigator
            calendarGrid
        }
        .padding()
        .background(Color.ebCard)
        .cornerRadius(16)
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("연속 학습")
                    .font(.ebH4)
                    .foregroundColor(.ebTextPrimary)

                Text("매일 만나서 기록을 이어가요")
                    .font(.ebCaption)
                    .foregroundColor(.ebTextSecondary)
            }

            Spacer()

            Image(systemName: "flame.fill")
                .font(.system(size: 32))
                .foregroundColor(.ebWarning)
        }
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: 24) {
            statCard(
                title: "현재 연속",
                value: "\(currentStreak)",
                icon: "flame.fill",
                color: .ebWarning
            )

            statCard(
                title: "최고 기록",
                value: "\(longestStreak)",
                icon: "trophy.fill",
                color: .ebSuccess
            )
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(value)
                    .font(.ebH2)
            }
            .foregroundColor(color)

            Text(title)
                .font(.ebCaption)
                .foregroundColor(.ebTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Month Navigator

    private var monthNavigator: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.ebBody)
                    .foregroundColor(.ebPrimary)
            }

            Spacer()

            Text(dateFormatter.string(from: selectedMonth))
                .font(.ebH5)
                .foregroundColor(.ebTextPrimary)

            Spacer()

            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.ebBody)
                    .foregroundColor(isCurrentMonth ? .ebTextDisabled : .ebPrimary)
            }
            .disabled(isCurrentMonth)
        }
    }

    private var isCurrentMonth: Bool {
        calendar.isDate(selectedMonth, equalTo: Date(), toGranularity: .month)
    }

    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }

    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedMonth),
           !calendar.isDate(newDate, inSameDayAs: Date()) {
            selectedMonth = newDate
        }
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        VStack(spacing: 8) {
            weekdayHeaders

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        dayCell(for: date)
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
    }

    private var weekdayHeaders: some View {
        HStack(spacing: 0) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.ebCaption)
                    .foregroundColor(.ebTextSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        // Reorder to start with Sunday
        return symbols
    }

    private func dayCell(for date: Date) -> some View {
        let isCompleted = completedDates.contains(where: { calendar.isDate($0, inSameDayAs: date) })
        let isFrozen = freezeDates.contains(where: { calendar.isDate($0, inSameDayAs: date) })
        let isToday = calendar.isDateInToday(date)
        let isFuture = date > Date()

        return ZStack {
            Circle()
                .fill(cellBackgroundColor(isCompleted: isCompleted, isFrozen: isFrozen, isToday: isToday, isFuture: isFuture))

            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.ebSuccess)
            } else if isFrozen {
                Image(systemName: "snowflake")
                    .font(.system(size: 16))
                    .foregroundColor(.ebInfo)
            } else {
                Text("\(calendar.component(.day, from: date))")
                    .font(.ebBodySmall)
                    .foregroundColor(cellTextColor(isFuture: isFuture))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .overlay(
            isToday ?
                Circle()
                    .stroke(Color.ebPrimary, lineWidth: 2)
                : nil
        )
    }

    private func cellBackgroundColor(isCompleted: Bool, isFrozen: Bool, isToday: Bool, isFuture: Bool) -> Color {
        if isCompleted {
            return .ebSuccess.opacity(0.2)
        } else if isFrozen {
            return .ebInfo.opacity(0.2)
        } else if isFuture {
            return .ebDivider.opacity(0.3)
        } else {
            return .ebDivider.opacity(0.5)
        }
    }

    private func cellTextColor(isFuture: Bool) -> Color {
        isFuture ? .ebTextDisabled : .ebTextPrimary
    }

    // MARK: - Calendar Data

    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedMonth),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday,
              let range = calendar.range(of: .day, in: .month, for: selectedMonth) else {
            return []
        }

        var days: [Date?] = []

        // Add empty cells for days before the first of the month
        let emptyDays = (firstWeekday - calendar.firstWeekday + 7) % 7
        days.append(contentsOf: Array(repeating: nil, count: emptyDays))

        // Add actual days
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start) {
                days.append(date)
            }
        }

        return days
    }
}

// MARK: - Preview

struct StreakCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        let completedDates: Set<Date> = {
            let calendar = Calendar.current
            var dates = Set<Date>()
            for i in -7...0 {
                if let date = calendar.date(byAdding: .day, value: i, to: Date()) {
                    dates.insert(date)
                }
            }
            return dates
        }()

        let freezeDates: Set<Date> = {
            let calendar = Calendar.current
            var dates = Set<Date>()
            if let date = calendar.date(byAdding: .day, value: -3, to: Date()) {
                dates.insert(date)
            }
            return dates
        }()

        StreakCalendarView(
            currentStreak: 7,
            longestStreak: 15,
            completedDates: completedDates,
            freezeDates: freezeDates
        )
        .padding()
        .background(Color.ebBackground)
    }
}
