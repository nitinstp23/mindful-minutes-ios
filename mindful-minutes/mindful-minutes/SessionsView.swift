import SwiftUI

struct SessionsView: View {
    @Environment(MindfulDataCoordinator.self) private var dataCoordinator
    @State private var selectedFilter: SessionFilter = .all
    @State private var showingNewSession = false
    @State private var showingFilterOptions = false
    @State private var searchText = ""
    @State private var selectedSession: MeditationSession?



    private var filteredSessions: [MeditationSession] {
        dataCoordinator.filteredSessions(by: selectedFilter, searchText: searchText)
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
            .navigationTitle("Sessions")
            .background(Color.mindfulBackground.ignoresSafeArea())
            .searchable(text: $searchText, prompt: "Search sessions...")
        }
        .sheet(isPresented: $showingNewSession) {
            NewSessionView()
        }
        .sheet(item: $selectedSession) { session in
            SessionDetailView(session: session)
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
        HStack {
            Spacer()

            HStack(spacing: MindfulSpacing.standard) {
                Button(action: { showingFilterOptions = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text(selectedFilter.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(.mindfulPrimary)
                }

                Button(action: exportSessions) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.mindfulPrimary)
                }
            }
        }
        .padding()
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
                        SessionRow(session: session) {
                            selectedSession = session
                        }
                    }
                } header: {
                    Text(formatSectionDate(group.date))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.mindfulPrimary)
                }
            }

            Section {
                MindfulFooter()
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(PlainListStyle())
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
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            MindfulButton(title: "View All Sessions", action: { selectedFilter = .all }, style: .primary)
                .frame(maxWidth: 200)

            MindfulFooter()

            Spacer()
        }
        .padding()
    }

    private var emptyStateMessage: String {
        if !searchText.isEmpty {
            return "Try adjusting your search terms or filters"
        } else if selectedFilter != .all {
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

    private func exportSessions() {
        // TODO: Implement session export
    }
}


#Preview {
    ContentView()
        .modelContainer(for: [MeditationSession.self, UserProfile.self, Milestone.self], inMemory: true)
}
