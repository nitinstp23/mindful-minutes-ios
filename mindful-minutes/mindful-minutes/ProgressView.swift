import SwiftUI

struct ProgressScreenView: View {
    @State private var currentStreak = 7
    @State private var longestStreak = 14
    @State private var totalSessions = 42
    @State private var totalMinutes = 840
    @State private var averageSession = 20
    @State private var selectedTimeframe: TimeFrame = .week

    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }

    // Sample data for charts
    private let weeklyData = [
        WeeklyChart.DayData(day: "Mon", minutes: 20, isToday: false),
        WeeklyChart.DayData(day: "Tue", minutes: 15, isToday: false),
        WeeklyChart.DayData(day: "Wed", minutes: 30, isToday: false),
        WeeklyChart.DayData(day: "Thu", minutes: 25, isToday: false),
        WeeklyChart.DayData(day: "Fri", minutes: 40, isToday: true),
        WeeklyChart.DayData(day: "Sat", minutes: 0, isToday: false),
        WeeklyChart.DayData(day: "Sun", minutes: 0, isToday: false)
    ]

    private let monthlyData: [MonthlyCalendar.DaySession] = {
        (1...30).map { day in
            let date = Calendar.current.date(from: DateComponents(year: 2024, month: 7, day: day)) ?? Date()
            let minutes = [0, 0, 5, 10, 15, 20, 25, 30, 35, 40].randomElement() ?? 0
            return MonthlyCalendar.DaySession(date: date, minutes: minutes, hasSession: minutes > 0)
        }
    }()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: MindfulSpacing.section) {
                    streaksSection
                    overallStatsSection
                    timeframePicker
                    chartsSection
                    milestonesSection

                    MindfulFooter()
                }
                .padding()
            }
            .navigationTitle("Progress")
            .background(Color.mindfulBackground.ignoresSafeArea())
        }
    }

    private var streaksSection: some View {
        VStack(spacing: MindfulSpacing.standard) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("Streaks")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: MindfulSpacing.standard) {
                MindfulCard {
                    VStack(spacing: MindfulSpacing.small) {
                        Image(systemName: "flame.fill")
                            .font(.title2)
                            .foregroundColor(.orange)

                        Text("Current")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("\(currentStreak)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.mindfulPrimary)

                        Text(currentStreak == 1 ? "day" : "days")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }

                MindfulCard {
                    VStack(spacing: MindfulSpacing.small) {
                        Image(systemName: "trophy.fill")
                            .font(.title2)
                            .foregroundColor(.yellow)

                        Text("Best")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("\(longestStreak)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.mindfulSecondary)

                        Text(longestStreak == 1 ? "day" : "days")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private var overallStatsSection: some View {
        MindfulCard {
            VStack(alignment: .leading, spacing: MindfulSpacing.standard) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.mindfulPrimary)
                    Text("Overall Statistics")
                        .font(.headline)
                    Spacer()
                }

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: MindfulSpacing.standard) {
                    statItem(title: "Total Sessions", value: "\(totalSessions)", icon: "figure.mind.and.body")
                    statItem(title: "Total Minutes", value: "\(totalMinutes)", icon: "clock.fill")
                    statItem(
                        title: "Average Session",
                        value: "\(averageSession) min",
                        icon: "chart.line.uptrend.xyaxis"
                    )
                    statItem(title: "This Month", value: "18 sessions", icon: "calendar")
                }
            }
        }
    }

    private func statItem(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.mindfulSecondary)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.mindfulPrimary)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, MindfulSpacing.small)
    }

    private var timeframePicker: some View {
        HStack {
            Text("Analytics")
                .font(.headline)

            Spacer()

            Picker("Timeframe", selection: $selectedTimeframe) {
                ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                    Text(timeframe.rawValue).tag(timeframe)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 180)
        }
    }

    private var chartsSection: some View {
        Group {
            switch selectedTimeframe {
            case .week:
                MindfulCard {
                    WeeklyChart(weeklyData: weeklyData, maxMinutes: 50)
                }
            case .month:
                MindfulCard {
                    MonthlyCalendar(monthData: monthlyData)
                }
            case .year:
                MindfulCard {
                    VStack(spacing: MindfulSpacing.standard) {
                        HStack {
                            Text("Yearly Overview")
                                .font(.headline)
                            Spacer()
                            Text("2024")
                                .font(.subheadline)
                                .foregroundColor(.mindfulPrimary)
                                .fontWeight(.medium)
                        }

                        Text("Year chart coming soon")
                            .foregroundColor(.secondary)
                            .frame(height: 120)

                        HStack {
                            Text("504 sessions this year")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.mindfulPrimary)
                            Spacer()
                        }
                    }
                }
            }
        }
    }

    private var milestonesSection: some View {
        MindfulCard {
            VStack(alignment: .leading, spacing: MindfulSpacing.standard) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Milestones")
                        .font(.headline)
                    Spacer()
                }

                VStack(spacing: MindfulSpacing.small) {
                    milestoneRow(title: "First Week", description: "Complete 7 days in a row", isCompleted: true)
                    milestoneRow(
                        title: "Consistent Meditator",
                        description: "Reach 30-day streak",
                        isCompleted: false,
                        progress: 7,
                        total: 30
                    )
                    milestoneRow(
                        title: "Mindful Hours",
                        description: "Meditate for 10 total hours",
                        isCompleted: false,
                        progress: 540,
                        total: 600
                    )
                    milestoneRow(
                        title: "Century Club",
                        description: "Complete 100 sessions",
                        isCompleted: false,
                        progress: 42,
                        total: 100
                    )
                }
            }
        }
    }

    private func milestoneRow(
        title: String,
        description: String,
        isCompleted: Bool,
        progress: Int = 0,
        total: Int = 0
    ) -> some View {
        HStack {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isCompleted ? .green : .gray)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isCompleted ? .secondary : .primary)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if !isCompleted && total > 0 {
                    ProgressView(value: Double(min(progress, total)), total: Double(total))
                        .progressViewStyle(LinearProgressViewStyle(tint: .mindfulPrimary))
                        .scaleEffect(x: 1, y: 0.8, anchor: .center)
                }
            }

            Spacer()

            if !isCompleted && total > 0 {
                Text("\(progress)/\(total)")
                    .font(.caption)
                    .foregroundColor(.mindfulPrimary)
                    .fontWeight(.medium)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ProgressScreenView()
}
