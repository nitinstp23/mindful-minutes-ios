import Foundation
import SwiftData

@Observable
class SessionRepository {
    private let modelContext: ModelContext
    private(set) var sessions: [MeditationSession] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadSessions()
    }
    
    // MARK: - Data Loading
    private func loadSessions() {
        let descriptor = FetchDescriptor<MeditationSession>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        do {
            sessions = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load sessions: \(error)")
            sessions = []
        }
    }
    
    // MARK: - CRUD Operations
    func addSession(_ session: MeditationSession) {
        modelContext.insert(session)
        sessions.insert(session, at: 0) // Add to beginning for newest first
        saveContext()
    }
    
    func updateSession(_ session: MeditationSession) {
        // SwiftData automatically tracks changes
        loadSessions() // Reload to reflect changes
        saveContext()
    }
    
    func deleteSession(_ session: MeditationSession) {
        modelContext.delete(session)
        sessions.removeAll { $0.id == session.id }
        saveContext()
    }
    
    // MARK: - Filtering
    func filteredSessions(by filter: SessionFilter, searchText: String = "") -> [MeditationSession] {
        let calendar = Calendar.current
        var filtered = sessions
        
        // Apply date/type filter
        switch filter {
        case .all:
            break
        case .today:
            filtered = filtered.filter { calendar.isDateInToday($0.date) }
        case .thisWeek:
            filtered = filtered.filter { 
                calendar.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear) 
            }
        case .thisMonth:
            filtered = filtered.filter { 
                calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) 
            }
        case .mindfulness, .breathing, .bodyScan, .lovingKindness, .focus, .movement, .sleep:
            filtered = filtered.filter { 
                $0.type.rawValue.lowercased().contains(filter.rawValue.lowercased()) 
            }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { session in
                session.type.rawValue.localizedCaseInsensitiveContains(searchText) ||
                session.notes.localizedCaseInsensitiveContains(searchText) ||
                session.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return filtered
    }
    
    // MARK: - Query Methods
    func todaysSessions() -> [MeditationSession] {
        let calendar = Calendar.current
        return sessions.filter { calendar.isDateInToday($0.date) }
    }
    
    func sessionsInDateRange(from startDate: Date, to endDate: Date) -> [MeditationSession] {
        return sessions.filter { session in
            session.date >= startDate && session.date <= endDate
        }
    }
    
    func sessionsByType(_ type: SessionType) -> [MeditationSession] {
        return sessions.filter { $0.type == type }
    }
    
    // MARK: - Private Helpers
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save session context: \(error)")
        }
    }
}