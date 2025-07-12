import Foundation

class ProgressCalculator {
    private let sessions: [MeditationSession]
    
    init(sessions: [MeditationSession]) {
        self.sessions = sessions
    }
    
    // MARK: - Basic Statistics
    var totalSessions: Int {
        sessions.count
    }
    
    var totalMinutes: Int {
        sessions.reduce(0) { $0 + $1.durationInMinutes }
    }
    
    var averageSessionDuration: Int {
        guard !sessions.isEmpty else { return 0 }
        return totalMinutes / totalSessions
    }
    
    // MARK: - Daily Progress
    func todaysMinutes() -> Int {
        let calendar = Calendar.current
        return sessions
            .filter { calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.durationInMinutes }
    }
    
    func todaysSessionCount() -> Int {
        let calendar = Calendar.current
        return sessions.filter { calendar.isDateInToday($0.date) }.count
    }
    
    // MARK: - Weekly Progress
    func weeklyProgress(goalMinutes: Int) -> (completed: Int, goal: Int, percentage: Double) {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.end ?? Date()
        
        let weekSessions = sessions.filter { session in
            session.date >= startOfWeek && session.date < endOfWeek
        }
        
        let completedMinutes = weekSessions.reduce(0) { $0 + $1.durationInMinutes }
        let percentage = goalMinutes > 0 ? Double(completedMinutes) / Double(goalMinutes) : 0.0
        
        return (completed: completedMinutes, goal: goalMinutes, percentage: min(percentage, 1.0))
    }
    
    func weeklyData() -> [(day: String, minutes: Int, isToday: Bool)] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) ?? Date()
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
            
            let dayMinutes = sessions
                .filter { $0.date >= dayStart && $0.date < dayEnd }
                .reduce(0) { $0 + $1.durationInMinutes }
            
            return (
                day: dayFormatter.string(from: date),
                minutes: dayMinutes,
                isToday: calendar.isDateInToday(date)
            )
        }
    }
    
    // MARK: - Monthly Progress
    func monthlyData() -> [(date: Date, minutes: Int, hasSession: Bool)] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
        let daysInMonth = calendar.range(of: .day, in: .month, for: Date())?.count ?? 30
        
        return (1...daysInMonth).map { day in
            let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) ?? Date()
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
            
            let dayMinutes = sessions
                .filter { $0.date >= dayStart && $0.date < dayEnd }
                .reduce(0) { $0 + $1.durationInMinutes }
            
            return (date: date, minutes: dayMinutes, hasSession: dayMinutes > 0)
        }
    }
    
    func monthlyMinutes() -> Int {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
        let endOfMonth = calendar.dateInterval(of: .month, for: Date())?.end ?? Date()
        
        return sessions
            .filter { $0.date >= startOfMonth && $0.date < endOfMonth }
            .reduce(0) { $0 + $1.durationInMinutes }
    }
}