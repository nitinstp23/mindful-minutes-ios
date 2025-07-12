import SwiftUI

struct HomeView: View {
    @State private var currentStreak = 7
    @State private var longestStreak = 14
    @State private var todayMinutes = 15
    @State private var todaySessions = 2
    @State private var weeklyGoal = 150
    @State private var weeklyProgress = 85
    
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
                    
                    MindfulFooter()
                }
                .padding()
            }
            .navigationTitle("Mindful Minutes")
            .background(Color.mindfulBackground.ignoresSafeArea())
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: MindfulSpacing.small) {
            Text("\(greetingText), Nitin")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Ready for your mindful moment?")
                .font(.subheadline)
                .foregroundColor(.secondary)
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
                    Spacer()
                }
                
                VStack(spacing: MindfulSpacing.small) {
                    HStack {
                        Text("Minutes meditated:")
                        Spacer()
                        Text("\(todayMinutes) min")
                            .fontWeight(.medium)
                            .foregroundColor(.mindfulPrimary)
                    }
                    
                    HStack {
                        Text("Sessions completed:")
                        Spacer()
                        Text("\(todaySessions)")
                            .fontWeight(.medium)
                            .foregroundColor(.mindfulPrimary)
                    }
                    
                    if todayMinutes > 0 {
                        HStack {
                            Text("Average session:")
                            Spacer()
                            Text("\(todayMinutes / max(todaySessions, 1)) min")
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
                    Spacer()
                }
                
                VStack(spacing: MindfulSpacing.small) {
                    HStack {
                        Text("Progress:")
                        Spacer()
                        Text("\(weeklyProgress) / \(weeklyGoal) min")
                            .fontWeight(.medium)
                            .foregroundColor(.mindfulPrimary)
                    }
                    
                    ProgressView(value: Double(min(weeklyProgress, weeklyGoal)), total: Double(weeklyGoal))
                        .progressViewStyle(LinearProgressViewStyle(tint: .mindfulPrimary))
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    
                    HStack {
                        Text("\(Int((Double(weeklyProgress) / Double(weeklyGoal)) * 100))% complete")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(weeklyGoal - weeklyProgress) min remaining")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                    Spacer()
                    Button("View All") {
                        viewHistory()
                    }
                    .font(.caption)
                    .foregroundColor(.mindfulPrimary)
                }
                
                VStack(spacing: MindfulSpacing.small) {
                    recentSessionRow(type: "Mindfulness", duration: 15, timeAgo: "2 hours ago")
                    recentSessionRow(type: "Breathing", duration: 10, timeAgo: "This morning")
                    recentSessionRow(type: "Body Scan", duration: 20, timeAgo: "Yesterday")
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
                Text(timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
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
}

#Preview {
    HomeView()
}
