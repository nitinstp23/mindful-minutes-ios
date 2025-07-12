import SwiftUI

struct SessionsView: View {
    @State private var selectedFilter: SessionFilter = .all
    @State private var showingNewSession = false
    @State private var showingFilterOptions = false
    @State private var searchText = ""
    @State private var selectedSession: SessionItem?
    
    enum SessionFilter: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case mindfulness = "Mindfulness"
        case breathing = "Breathing"
        case bodyScan = "Body Scan"
    }
    
    private let mockSessions = [
        SessionItem(id: 1, date: Date(), duration: 900, type: "Mindfulness", notes: "Great session today", tags: ["morning", "peaceful"], sessionNumber: 42),
        SessionItem(id: 2, date: Calendar.current.date(byAdding: .hour, value: -4, to: Date()) ?? Date(), duration: 600, type: "Breathing", notes: "", tags: ["quick"], sessionNumber: 41),
        SessionItem(id: 3, date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), duration: 1200, type: "Body Scan", notes: "Deep relaxation session", tags: ["evening", "relaxing"], sessionNumber: 40),
        SessionItem(id: 4, date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), duration: 480, type: "Mindfulness", notes: "", tags: ["morning"], sessionNumber: 39),
        SessionItem(id: 5, date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(), duration: 1800, type: "Loving Kindness", notes: "Focused on compassion", tags: ["evening", "compassion"], sessionNumber: 38),
        SessionItem(id: 6, date: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(), duration: 300, type: "Breathing", notes: "", tags: ["quick", "work"], sessionNumber: 37)
    ]
    
    private var filteredSessions: [SessionItem] {
        let filtered = mockSessions.filter { session in
            switch selectedFilter {
            case .all:
                return true
            case .today:
                return Calendar.current.isDateInToday(session.date)
            case .thisWeek:
                return Calendar.current.isDate(session.date, equalTo: Date(), toGranularity: .weekOfYear)
            case .thisMonth:
                return Calendar.current.isDate(session.date, equalTo: Date(), toGranularity: .month)
            case .mindfulness, .breathing, .bodyScan:
                return session.type.lowercased().contains(selectedFilter.rawValue.lowercased())
            }
        }
        
        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { session in
                session.type.localizedCaseInsensitiveContains(searchText) ||
                session.notes.localizedCaseInsensitiveContains(searchText) ||
                session.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
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
        switch filter {
        case .all:
            return mockSessions.count
        case .today:
            return mockSessions.filter { Calendar.current.isDateInToday($0.date) }.count
        case .thisWeek:
            return mockSessions.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear) }.count
        case .thisMonth:
            return mockSessions.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) }.count
        case .mindfulness, .breathing, .bodyScan:
            return mockSessions.filter { $0.type.lowercased().contains(filter.rawValue.lowercased()) }.count
        }
    }
    
    private func groupSessionsByDate(_ sessions: [SessionItem]) -> [SessionGroup] {
        let grouped = Dictionary(grouping: sessions) { session in
            Calendar.current.startOfDay(for: session.date)
        }
        
        return grouped.map { date, sessions in
            SessionGroup(date: date, sessions: sessions.sorted { $0.date > $1.date })
        }.sorted { $0.date > $1.date }
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

struct SessionGroup {
    let date: Date
    let sessions: [SessionItem]
}

struct SessionRow: View {
    let session: SessionItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: MindfulSpacing.standard) {
                VStack {
                    Image(systemName: sessionTypeIcon(session.type))
                        .font(.title2)
                        .foregroundColor(.mindfulPrimary)
                        .frame(width: 40, height: 40)
                        .background(Color.mindfulPrimary.opacity(0.1))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(session.type)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(formatDuration(session.duration))
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.mindfulPrimary)
                    }
                    
                    HStack {
                        Text(session.date, style: .time)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if !session.notes.isEmpty {
                            Image(systemName: "note.text")
                                .font(.caption)
                                .foregroundColor(.mindfulSecondary)
                        }
                        
                        Spacer()
                        
                        if !session.tags.isEmpty {
                            Text(session.tags.first ?? "")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.mindfulPrimary.opacity(0.1))
                                .foregroundColor(.mindfulPrimary)
                                .cornerRadius(4)
                        }
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 4)
    }
    
    private func sessionTypeIcon(_ type: String) -> String {
        switch type.lowercased() {
        case "mindfulness": return "figure.mind.and.body"
        case "breathing": return "lungs.fill"
        case "body scan": return "figure.walk"
        case "loving kindness": return "heart.fill"
        case "focus": return "target"
        default: return "figure.mind.and.body"
        }
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        return "\(minutes) min"
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(title)
                if !isEmpty {
                    Text("(\(count))")
                        .font(.caption2)
                }
            }
            .font(.caption)
            .fontWeight(isSelected ? .semibold : .regular)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.mindfulPrimary : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
    }
}

struct SessionItem: Identifiable {
    let id: Int
    let date: Date
    let duration: Int
    let type: String
    let notes: String
    let tags: [String]
    let sessionNumber: Int
}

struct NewSessionView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("New Session Screen")
                    .font(.title)
                Text("Session creation form coming soon")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("New Session")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SessionsView()
}
