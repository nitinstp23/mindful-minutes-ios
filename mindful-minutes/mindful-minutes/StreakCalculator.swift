import Foundation

class StreakCalculator {
    private let sessions: [MeditationSession]
    
    init(sessions: [MeditationSession]) {
        self.sessions = sessions
    }
    
    // MARK: - Current Streak
    var currentStreak: Int {
        guard !sessions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var currentDate = today
        
        while true {
            let hasSessionOnDate = sessions.contains { session in
                calendar.isDate(session.date, inSameDayAs: currentDate)
            }
            
            if hasSessionOnDate {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                // Allow one day gap for today if it's the first day being checked
                if streak == 0 && calendar.isDateInToday(currentDate) {
                    currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
                    continue
                }
                break
            }
        }
        
        return streak
    }
    
    // MARK: - Longest Streak
    var longestStreak: Int {
        guard !sessions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sortedSessions = sessions.sorted { $0.date < $1.date }
        var maxStreak = 0
        var currentStreak = 0
        var lastDate: Date?
        
        for session in sortedSessions {
            let sessionDate = calendar.startOfDay(for: session.date)
            
            if let last = lastDate {
                let daysDiff = calendar.dateComponents([.day], from: last, to: sessionDate).day ?? 0
                
                if daysDiff == 1 {
                    // Consecutive day
                    currentStreak += 1
                } else if daysDiff == 0 {
                    // Same day, don't increment
                    continue
                } else {
                    // Gap in streak
                    maxStreak = max(maxStreak, currentStreak)
                    currentStreak = 1
                }
            } else {
                // First session
                currentStreak = 1
            }
            
            lastDate = sessionDate
        }
        
        return max(maxStreak, currentStreak)
    }
    
    // MARK: - Streak Analysis
    func streakHistory() -> [(date: Date, hasSession: Bool)] {
        guard !sessions.isEmpty else { return [] }
        
        let calendar = Calendar.current
        let earliestSession = sessions.min { $0.date < $1.date }?.date ?? Date()
        let startDate = calendar.startOfDay(for: earliestSession)
        let today = calendar.startOfDay(for: Date())
        
        var history: [(date: Date, hasSession: Bool)] = []
        var currentDate = startDate
        
        while currentDate <= today {
            let hasSession = sessions.contains { session in
                calendar.isDate(session.date, inSameDayAs: currentDate)
            }
            
            history.append((date: currentDate, hasSession: hasSession))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return history
    }
    
    func isStreakActive() -> Bool {
        let calendar = Calendar.current
        
        // Check if there's a session today
        let hasSessionToday = sessions.contains { calendar.isDateInToday($0.date) }
        if hasSessionToday {
            return true
        }
        
        // Check if there's a session yesterday (streak can continue tomorrow)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let hasSessionYesterday = sessions.contains { 
            calendar.isDate($0.date, inSameDayAs: yesterday) 
        }
        
        return hasSessionYesterday
    }
    
    func daysUntilStreakBreaks() -> Int? {
        if isStreakActive() {
            let calendar = Calendar.current
            let hasSessionToday = sessions.contains { calendar.isDateInToday($0.date) }
            return hasSessionToday ? nil : 1 // 1 day to maintain streak if no session today
        }
        return 0 // Streak already broken
    }
}