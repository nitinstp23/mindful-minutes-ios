import Foundation
import SwiftData

@Observable
class MindfulDataCoordinator {
    let sessionRepository: SessionRepository
    let userProfileManager: UserProfileManager
    let milestoneManager: MilestoneManager
    
    private var progressCalculator: ProgressCalculator {
        ProgressCalculator(sessions: sessionRepository.sessions)
    }
    
    private var streakCalculator: StreakCalculator {
        StreakCalculator(sessions: sessionRepository.sessions)
    }
    
    init(modelContext: ModelContext) {
        self.sessionRepository = SessionRepository(modelContext: modelContext)
        self.userProfileManager = UserProfileManager(modelContext: modelContext)
        self.milestoneManager = MilestoneManager(modelContext: modelContext)
        
        // Update milestones with current progress
        updateMilestoneProgress()
    }
    
    // MARK: - Session Operations
    func addSession(_ session: MeditationSession) {
        sessionRepository.addSession(session)
        updateMilestoneProgress()
    }
    
    func updateSession(_ session: MeditationSession) {
        sessionRepository.updateSession(session)
        updateMilestoneProgress()
    }
    
    func deleteSession(_ session: MeditationSession) {
        sessionRepository.deleteSession(session)
        updateMilestoneProgress()
    }
    
    // MARK: - Progress Data Access
    var currentStreak: Int {
        streakCalculator.currentStreak
    }
    
    var longestStreak: Int {
        streakCalculator.longestStreak
    }
    
    var totalSessions: Int {
        progressCalculator.totalSessions
    }
    
    var totalMinutes: Int {
        progressCalculator.totalMinutes
    }
    
    var averageSessionDuration: Int {
        progressCalculator.averageSessionDuration
    }
    
    var todaysMinutes: Int {
        progressCalculator.todaysMinutes()
    }
    
    var todaysSessionCount: Int {
        progressCalculator.todaysSessionCount()
    }
    
    func weeklyProgress() -> (completed: Int, goal: Int, percentage: Double) {
        progressCalculator.weeklyProgress(goalMinutes: userProfileManager.weeklyGoalMinutes)
    }
    
    func weeklyData() -> [(day: String, minutes: Int, isToday: Bool)] {
        progressCalculator.weeklyData()
    }
    
    func monthlyData() -> [(date: Date, minutes: Int, hasSession: Bool)] {
        progressCalculator.monthlyData()
    }
    
    // MARK: - Session Access
    var allSessions: [MeditationSession] {
        sessionRepository.sessions
    }
    
    func filteredSessions(by filter: SessionFilter, searchText: String = "") -> [MeditationSession] {
        sessionRepository.filteredSessions(by: filter, searchText: searchText)
    }
    
    func todaysSessions() -> [MeditationSession] {
        sessionRepository.todaysSessions()
    }
    
    // MARK: - Milestone Access
    var activeMilestones: [Milestone] {
        milestoneManager.activeMilestones()
    }
    
    var completedMilestones: [Milestone] {
        milestoneManager.completedMilestones()
    }
    
    var nextMilestone: Milestone? {
        milestoneManager.nextMilestone()
    }
    
    func recentlyCompletedMilestones() -> [Milestone] {
        milestoneManager.recentlyCompleted()
    }
    
    // MARK: - User Profile Access
    var userProfile: UserProfile? {
        userProfileManager.userProfile
    }
    
    var weeklyGoalMinutes: Int {
        userProfileManager.weeklyGoalMinutes
    }
    
    func updateUserProfile(
        name: String? = nil,
        email: String? = nil,
        weeklyGoalMinutes: Int? = nil,
        preferredSessionDuration: Int? = nil,
        preferredSessionTypes: [SessionType]? = nil,
        notificationsEnabled: Bool? = nil,
        reminderTime: Date? = nil
    ) {
        userProfileManager.updateProfile(
            name: name,
            email: email,
            weeklyGoalMinutes: weeklyGoalMinutes,
            preferredSessionDuration: preferredSessionDuration,
            preferredSessionTypes: preferredSessionTypes,
            notificationsEnabled: notificationsEnabled,
            reminderTime: reminderTime
        )
        
        // Update milestones if weekly goal changed
        if weeklyGoalMinutes != nil {
            updateMilestoneProgress()
        }
    }
    
    // MARK: - Streak Helpers
    var isStreakActive: Bool {
        streakCalculator.isStreakActive()
    }
    
    var daysUntilStreakBreaks: Int? {
        streakCalculator.daysUntilStreakBreaks()
    }
    
    // MARK: - Demo Data Creation
    func createSampleData() {
        let calendar = Calendar.current
        let sampleSessions = [
            MeditationSession(
                date: Date(),
                duration: 900,
                type: .mindfulness,
                notes: "Great session today",
                tags: ["morning", "peaceful"],
                isCompleted: true
            ),
            MeditationSession(
                date: calendar.date(byAdding: .hour, value: -4, to: Date()) ?? Date(),
                duration: 600,
                type: .breathing,
                notes: "",
                tags: ["quick"],
                isCompleted: true
            ),
            MeditationSession(
                date: calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                duration: 1200,
                type: .bodyScan,
                notes: "Deep relaxation session",
                tags: ["evening", "relaxing"],
                isCompleted: true
            ),
            MeditationSession(
                date: calendar.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                duration: 480,
                type: .mindfulness,
                notes: "",
                tags: ["morning"],
                isCompleted: true
            ),
            MeditationSession(
                date: calendar.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                duration: 1800,
                type: .lovingKindness,
                notes: "Focused on compassion",
                tags: ["evening", "compassion"],
                isCompleted: true
            )
        ]
        
        for session in sampleSessions {
            addSession(session)
        }
    }
    
    // MARK: - Private Helpers
    private func updateMilestoneProgress() {
        let weeklyProgress = self.weeklyProgress()
        let monthlyMinutes = progressCalculator.monthlyMinutes()
        
        milestoneManager.updateProgress(
            totalSessions: totalSessions,
            totalMinutes: totalMinutes,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            weeklyMinutes: weeklyProgress.completed,
            monthlyMinutes: monthlyMinutes
        )
    }
}