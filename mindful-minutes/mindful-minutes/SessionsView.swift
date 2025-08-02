import SwiftUI

struct SessionsView: View {
    @Environment(MindfulDataCoordinator.self) private var dataCoordinator
    @State private var selectedFilter: SessionFilter = .all
    @State private var showingFilterOptions = false

    private var filteredSessions: [MeditationSession] {
        dataCoordinator.filteredSessions(by: selectedFilter)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
                filterSection

                if filteredSessions.isEmpty {
                    emptyStateView
                } else {
                    sessionsList
                }
            }
            .navigationBarHidden(true)
            .background(Color.mindfulBackground.ignoresSafeArea())
        }
        .actionSheet(isPresented: $showingFilterOptions) {
            ActionSheet(
                title: Text("Filter Sessions"),
                buttons: SessionFilter.allCases.map { filter in
                    .default(Text(filter.rawValue)) {
                        selectedFilter = filter
                    }
                } + [.cancel()]
            )
        }
    }

    private var headerSection: some View {
        VStack(spacing: MindfulSpacing.small) {
            Text("Your Sessions")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.mindfulTextPrimary)

            Text("Review your meditation history")
                .font(.subheadline)
                .foregroundColor(.mindfulTextSecondary)
        }
        .padding(.top)
        .padding(.horizontal)
        .padding(.bottom, MindfulSpacing.small)
    }

    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MindfulSpacing.small) {
                ForEach(SessionFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isSelected: selectedFilter == filter,
                        count: getFilterCount(filter)
                    ) {
                        selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, MindfulSpacing.small)
    }

    private var sessionsList: some View {
        List {
            ForEach(groupSessionsByDate(filteredSessions), id: \.date) { group in
                Section {
                    ForEach(group.sessions) { session in
                        SessionRow(session: session)
                        .listRowBackground(Color.clear)
                    }
                } header: {
                    Text(formatSectionDate(group.date))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.mindfulPrimary)
                }
            }

        }
        .listStyle(PlainListStyle())
        .scrollContentBackground(.hidden)
        .background(Color.mindfulBackground)
    }

    private var emptyStateView: some View {
        VStack(spacing: MindfulSpacing.section) {
            Spacer()

            Image(systemName: "figure.mind.and.body")
                .font(.system(size: 60))
                .foregroundColor(.mindfulPrimary.opacity(0.5))

            VStack(spacing: MindfulSpacing.small) {
                Text("No sessions found")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(emptyStateMessage)
                    .font(.body)
                    .foregroundColor(.mindfulTextSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()
    }

    private var emptyStateMessage: String {
        if selectedFilter != .all {
            return "No sessions match the current filter"
        } else {
            return "Your mindfulness journey sessions will appear here"
        }
    }

    private func getFilterCount(_ filter: SessionFilter) -> Int {
        dataCoordinator.filteredSessions(by: filter).count
    }

    private func groupSessionsByDate(_ sessions: [MeditationSession]) -> [SessionGroup] {
        let grouped = Dictionary(grouping: sessions) { session in
            Calendar.current.startOfDay(for: session.date)
        }

        return grouped
            .map { date, sessions in
                SessionGroup(date: date, sessions: sessions.sorted { $0.date > $1.date })
            }
            .sorted { $0.date > $1.date }
    }

    private func formatSectionDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else {
            formatter.dateFormat = "MMMM d, yyyy"
            return formatter.string(from: date)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [MeditationSession.self, UserProfile.self, Milestone.self], inMemory: true)
}
