import SwiftUI

struct WeeklyChart: View {
    let weeklyData: [DayData]
    let maxMinutes: Int

    struct DayData {
        let day: String
        let minutes: Int
        let isToday: Bool
    }

    var body: some View {
        VStack(spacing: MindfulSpacing.standard) {
            HStack {
                Text("Weekly Progress")
                    .font(.headline)
                Spacer()
                Text("\(weeklyData.reduce(0) { $0 + $1.minutes }) min total")
                    .font(.subheadline)
                    .foregroundColor(.mindfulPrimary)
                    .fontWeight(.medium)
            }

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(weeklyData.enumerated()), id: \.offset) { _, dayData in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(dayData.isToday ? Color.mindfulPrimary : Color.mindfulSecondary.opacity(0.7))
                            .frame(
                                width: 32,
                                height: max(4, CGFloat(dayData.minutes) / CGFloat(maxMinutes) * 120)
                            )
                            .animation(.easeInOut(duration: 0.5), value: dayData.minutes)

                        Text(dayData.day)
                            .font(.caption2)
                            .foregroundColor(dayData.isToday ? .mindfulPrimary : .secondary)
                            .fontWeight(dayData.isToday ? .semibold : .regular)
                    }
                }
            }
            .frame(height: 140)

            HStack {
                Text("0 min")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(maxMinutes) min")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    let sampleData = [
        WeeklyChart.DayData(day: "Mon", minutes: 20, isToday: false),
        WeeklyChart.DayData(day: "Tue", minutes: 15, isToday: false),
        WeeklyChart.DayData(day: "Wed", minutes: 30, isToday: false),
        WeeklyChart.DayData(day: "Thu", minutes: 25, isToday: false),
        WeeklyChart.DayData(day: "Fri", minutes: 40, isToday: true),
        WeeklyChart.DayData(day: "Sat", minutes: 0, isToday: false),
        WeeklyChart.DayData(day: "Sun", minutes: 0, isToday: false)
    ]

    MindfulCard {
        WeeklyChart(weeklyData: sampleData, maxMinutes: 50)
    }
    .padding()
}
