import SwiftUI

struct HomeView: View {
    @Environment(MindfulDataCoordinator.self) private var dataCoordinator
    @State private var showingSessionTimer = false

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: MindfulSpacing.section) {
                    headerSection
                    todayProgressSection
                    weeklyOverviewSection
                    recentSessionsSection
                }
                .padding()
            }
            .background(Color.mindfulBackground.ignoresSafeArea())
        }
    }

    private var headerSection: some View {
        VStack(spacing: MindfulSpacing.small) {
            Text("\(greetingText), Nitin")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.mindfulTextPrimary)

            Text("Track your meditation journey 🪷")
                .font(.subheadline)
                .foregroundColor(.mindfulTextSecondary)
        }
        .padding(.top)
    }

    private var todayProgressSection: some View {
        MindfulCard {
            VStack(alignment: .leading, spacing: MindfulSpacing.standard) {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(.mindfulPrimary)
                    Text("Today's Progress")
                        .font(.headline)
                        .foregroundColor(.mindfulTextPrimary)
                    Spacer()
                }

                VStack(spacing: MindfulSpacing.small) {
                    HStack {
                        Text("Minutes meditated:")
                            .foregroundColor(.mindfulTextPrimary)
                        Spacer()
                        Text("\(dataCoordinator.todaysMinutes) min")
                            .fontWeight(.medium)
                            .foregroundColor(.mindfulPrimary)
                    }

                    HStack {
                        Text("Sessions completed:")
                            .foregroundColor(.mindfulTextPrimary)
                        Spacer()
                        Text("\(dataCoordinator.todaysSessionCount)")
                            .fontWeight(.medium)
                            .foregroundColor(.mindfulPrimary)
                    }

                    if dataCoordinator.todaysMinutes > 0 {
                        HStack {
                            Text("Average session:")
                                .foregroundColor(.mindfulTextPrimary)
                            Spacer()
                            Text("\(dataCoordinator.todaysMinutes / max(dataCoordinator.todaysSessionCount, 1)) min")
                                .fontWeight(.medium)
                                .foregroundColor(.mindfulSecondary)
                        }
                    }
                }
            }
        }
    }

    private var weeklyOverviewSection: some View {
        MindfulCard {
            VStack(alignment: .leading, spacing: MindfulSpacing.standard) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(.mindfulPrimary)
                    Text("Weekly Goal")
                        .font(.headline)
                        .foregroundColor(.mindfulTextPrimary)
                    Spacer()
                }

                VStack(spacing: MindfulSpacing.small) {
                    HStack {
                        Text("Progress:")
                            .foregroundColor(.mindfulTextPrimary)
                        Spacer()
                        let progress = dataCoordinator.weeklyProgress()
                        Text("\(progress.completed) / \(progress.goal) min")
                            .fontWeight(.medium)
                            .foregroundColor(.mindfulPrimary)
                    }

                    ProgressView(value: dataCoordinator.weeklyProgress().percentage)
                        .progressViewStyle(LinearProgressViewStyle(tint: .mindfulPrimary))
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)

                    HStack {
                        Text("\(Int(dataCoordinator.weeklyProgress().percentage * 100))% complete")
                            .font(.caption)
                            .foregroundColor(.mindfulTextSecondary)
                        Spacer()
                        let weeklyProgress = dataCoordinator.weeklyProgress()
                        Text("\(max(0, weeklyProgress.goal - weeklyProgress.completed)) min remaining")
                            .font(.caption)
                            .foregroundColor(.mindfulTextSecondary)
                    }
                }
            }
        }
    }

    private var recentSessionsSection: some View {
        MindfulCard {
            VStack(alignment: .leading, spacing: MindfulSpacing.standard) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.mindfulPrimary)
                    Text("Recent Sessions")
                        .font(.headline)
                        .foregroundColor(.mindfulTextPrimary)
                    Spacer()
                    Button("View All") {
                        viewHistory()
                    }
                    .font(.caption)
                    .foregroundColor(.mindfulPrimary)
                }

                VStack(spacing: MindfulSpacing.small) {
                    let recentSessions = Array(dataCoordinator.allSessions.prefix(3))
                    if recentSessions.isEmpty {
                        Text("No sessions yet")
                            .font(.subheadline)
                            .foregroundColor(.mindfulTextSecondary)
                            .padding(.vertical)
                    } else {
                        ForEach(recentSessions, id: \.id) { session in
                            recentSessionRow(
                                type: session.type.rawValue,
                                duration: session.durationInMinutes,
                                timeAgo: formatTimeAgo(session.date)
                            )
                        }
                    }
                }
            }
        }
    }

    private func recentSessionRow(type: String, duration: Int, timeAgo: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(type)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.mindfulTextPrimary)
                Text(timeAgo)
                    .font(.caption)
                    .foregroundColor(.mindfulTextSecondary)
            }

            Spacer()

            Text("\(duration) min")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.mindfulSecondary)
        }
        .padding(.vertical, 2)
    }

    private func viewHistory() {
        // TODO: Navigate to sessions tab
    }

    private func formatTimeAgo(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            let hours = calendar.dateComponents([.hour], from: date, to: now).hour ?? 0
            let minutes = calendar.dateComponents([.minute], from: date, to: now).minute ?? 0

            if hours > 0 {
                return "\(hours) hour\(hours == 1 ? "" : "s") ago"
            } else if minutes > 0 {
                return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
            } else {
                return "Just now"
            }
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
}

#Preview {
    HomeView()
}
