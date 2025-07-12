import SwiftUI

struct MonthlyCalendar: View {
    let monthData: [DaySession]
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    struct DaySession {
        let date: Date
        let minutes: Int
        let hasSession: Bool
    }

    private var currentMonth: Date {
        monthData.first?.date ?? Date()
    }

    private var weeks: [[DaySession?]] {
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? Date()
        let endOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.end ?? Date()

        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: startOfMonth)?.start ?? startOfMonth

        var weeks: [[DaySession?]] = []
        var currentWeek: [DaySession?] = []
        var currentDate = startOfWeek

        while currentDate < endOfMonth {
            if calendar.isDate(currentDate, equalTo: currentMonth, toGranularity: .month) {
                let daySession = monthData.first { calendar.isDate($0.date, inSameDayAs: currentDate) }
                currentWeek.append(daySession)
            } else {
                currentWeek.append(nil)
            }

            if currentWeek.count == 7 {
                weeks.append(currentWeek)
                currentWeek = []
            }

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        if !currentWeek.isEmpty {
            while currentWeek.count < 7 {
                currentWeek.append(nil)
            }
            weeks.append(currentWeek)
        }

        return weeks
    }

    var body: some View {
        VStack(spacing: MindfulSpacing.standard) {
            HStack {
                Text("Monthly Overview")
                    .font(.headline)
                Spacer()
                Text(dateFormatter.string(from: currentMonth))
                    .font(.subheadline)
                    .foregroundColor(.mindfulPrimary)
                    .fontWeight(.medium)
            }

            VStack(spacing: 4) {
                HStack {
                    ForEach(Array(["S", "M", "T", "W", "T", "F", "S"].enumerated()), id: \.offset) { _, dayLetter in
                        Text(dayLetter)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }

                ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                    HStack(spacing: 2) {
                        ForEach(Array(week.enumerated()), id: \.offset) { _, daySession in
                            if let daySession = daySession {
                                DayCell(daySession: daySession)
                            } else {
                                Color.clear
                                    .frame(height: 32)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }

            HStack(spacing: MindfulSpacing.standard) {
                legendItem(color: .mindfulPrimary, text: "High activity (20+ min)")
                legendItem(color: .mindfulSecondary.opacity(0.6), text: "Some activity (1-19 min)")
                legendItem(color: .gray.opacity(0.3), text: "No activity")
            }
            .font(.caption2)
        }
    }

    private func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
                .foregroundColor(.secondary)
        }
    }
}

struct DayCell: View {
    let daySession: MonthlyCalendar.DaySession
    private let calendar = Calendar.current

    private var dayNumber: String {
        String(calendar.component(.day, from: daySession.date))
    }

    private var cellColor: Color {
        if !daySession.hasSession {
            return .gray.opacity(0.2)
        } else if daySession.minutes >= 20 {
            return .mindfulPrimary
        } else {
            return .mindfulSecondary.opacity(0.6)
        }
    }

    private var textColor: Color {
        if daySession.minutes >= 20 {
            return .white
        } else {
            return .primary
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(cellColor)
                .frame(height: 32)

            Text(dayNumber)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(textColor)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    let sampleData = (1...30).map { day in
        let date = Calendar.current.date(from: DateComponents(year: 2024, month: 7, day: day)) ?? Date()
        let minutes = [0, 5, 10, 15, 20, 25, 30].randomElement() ?? 0
        return MonthlyCalendar.DaySession(date: date, minutes: minutes, hasSession: minutes > 0)
    }

    MindfulCard {
        MonthlyCalendar(monthData: sampleData)
    }
    .padding()
}
