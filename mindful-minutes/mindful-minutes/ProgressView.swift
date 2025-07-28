import SwiftUI

struct ProgressScreenView: View {
    @Environment(MindfulDataCoordinator.self) private var dataCoordinator
    @State private var selectedTimeframe: TimeFrame = .week

    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }

    private var weeklyData: [WeeklyChart.DayData] {
        dataCoordinator.weeklyData().map { item in
            WeeklyChart.DayData(day: item.day, minutes: item.minutes, isToday: item.isToday)
        }
    }

    private var monthlyData: [MonthlyCalendar.DaySession] {
        dataCoordinator.monthlyData().map { item in
            MonthlyCalendar.DaySession(date: item.date, minutes: item.minutes, hasSession: item.hasSession)
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: MindfulSpacing.section) {
                    streaksSection
                    overallStatsSection
                    timeframePicker
                    chartsSection
                    milestonesSection
                }
                .padding()
            }
            .navigationTitle("Your Progress")
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
                    .foregroundColor(.mindfulTextPrimary)
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
                            .foregroundColor(.mindfulTextSecondary)

                        Text("\(dataCoordinator.currentStreak)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.mindfulPrimary)

                        Text(dataCoordinator.currentStreak == 1 ? "day" : "days")
                            .font(.caption)
                            .foregroundColor(.mindfulTextSecondary)
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
                            .foregroundColor(.mindfulTextSecondary)

                        Text("\(dataCoordinator.longestStreak)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.mindfulSecondary)

                        Text(dataCoordinator.longestStreak == 1 ? "day" : "days")
                            .font(.caption)
                            .foregroundColor(.mindfulTextSecondary)
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
                        .foregroundColor(.mindfulTextPrimary)
                    Spacer()
                }

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: MindfulSpacing.standard) {
                    statItem(
                        title: "Total Sessions",
                        value: "\(dataCoordinator.totalSessions)",
                        icon: "figure.mind.and.body"
                    )
                    statItem(title: "Total Minutes", value: "\(dataCoordinator.totalMinutes)", icon: "clock.fill")
                    statItem(
                        title: "Average Session",
                        value: "\(dataCoordinator.averageSessionDuration) min",
                        icon: "chart.line.uptrend.xyaxis"
                    )
                    statItem(
                        title: "This Month",
                        value: "\(dataCoordinator.monthlyData().filter { $0.hasSession }.count) sessions",
                        icon: "calendar"
                    )
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
                .foregroundColor(.mindfulTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, MindfulSpacing.small)
    }

    private var timeframePicker: some View {
        HStack {
            Text("Analytics")
                .font(.headline)
                .foregroundColor(.mindfulTextPrimary)

            Spacer()

            Picker("Timeframe", selection: $selectedTimeframe) {
                ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                    Text(timeframe.rawValue)
                        .foregroundColor(.mindfulTextPrimary)
                        .tag(timeframe)
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
                    WeeklyChart(weeklyData: weeklyData, maxMinutes: weeklyData.map { $0.minutes }.max() ?? 50)
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
                                .foregroundColor(.mindfulTextPrimary)
                            Spacer()
                            Text("2024")
                                .font(.subheadline)
                                .foregroundColor(.mindfulPrimary)
                                .fontWeight(.medium)
                        }

                        Text("Year chart coming soon")
                            .foregroundColor(.mindfulTextSecondary)
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
                        .foregroundColor(.mindfulTextPrimary)
                    Spacer()
                }

                VStack(spacing: MindfulSpacing.small) {
                    ForEach(Array(dataCoordinator.activeMilestones.prefix(4)), id: \.id) { milestone in
                        milestoneRow(
                            title: milestone.title,
                            description: milestone.details,
                            isCompleted: milestone.isCompleted,
                            progress: milestone.currentValue,
                            total: milestone.targetValue
                        )
                    }
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
                    .foregroundColor(isCompleted ? .mindfulTextSecondary : .mindfulTextPrimary)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.mindfulTextSecondary)

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
