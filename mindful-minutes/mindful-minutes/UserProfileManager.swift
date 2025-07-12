import Foundation
import SwiftData

@Observable
class UserProfileManager {
    private let modelContext: ModelContext
    private(set) var userProfile: UserProfile?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadUserProfile()
    }
    
    // MARK: - Data Loading
    private func loadUserProfile() {
        let descriptor = FetchDescriptor<UserProfile>()
        do {
            let profiles = try modelContext.fetch(descriptor)
            userProfile = profiles.first
            if userProfile == nil {
                createDefaultUserProfile()
            }
        } catch {
            print("Failed to load user profile: \(error)")
            createDefaultUserProfile()
        }
    }
    
    private func createDefaultUserProfile() {
        userProfile = UserProfile(
            name: "Mindful User",
            email: "user@mindfulminutes.com"
        )
        if let profile = userProfile {
            modelContext.insert(profile)
            saveContext()
        }
    }
    
    // MARK: - Profile Management
    func updateProfile(
        name: String? = nil,
        email: String? = nil,
        weeklyGoalMinutes: Int? = nil,
        preferredSessionDuration: Int? = nil,
        preferredSessionTypes: [SessionType]? = nil,
        notificationsEnabled: Bool? = nil,
        reminderTime: Date? = nil
    ) {
        guard let profile = userProfile else { return }
        
        if let name = name { profile.name = name }
        if let email = email { profile.email = email }
        if let weeklyGoal = weeklyGoalMinutes { profile.weeklyGoalMinutes = weeklyGoal }
        if let duration = preferredSessionDuration { profile.preferredSessionDuration = duration }
        if let types = preferredSessionTypes { profile.preferredSessionTypes = types }
        if let notifications = notificationsEnabled { profile.notificationsEnabled = notifications }
        if let reminder = reminderTime { profile.reminderTime = reminder }
        
        saveContext()
    }
    
    func updateStreakStartDate(_ date: Date?) {
        userProfile?.streakStartDate = date
        saveContext()
    }
    
    // MARK: - Profile Queries
    var weeklyGoalMinutes: Int {
        userProfile?.weeklyGoalMinutes ?? 150
    }
    
    var preferredSessionDuration: Int {
        userProfile?.preferredSessionDuration ?? 10
    }
    
    var notificationsEnabled: Bool {
        userProfile?.notificationsEnabled ?? true
    }
    
    var reminderTime: Date {
        userProfile?.reminderTime ?? Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    }
    
    var memberSince: String {
        guard let joinDate = userProfile?.joinDate else { return "" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return "Member since \(formatter.string(from: joinDate))"
    }
    
    var daysSinceMember: Int {
        guard let joinDate = userProfile?.joinDate else { return 0 }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: joinDate, to: Date())
        return components.day ?? 0
    }
    
    // MARK: - Settings Helpers
    func toggleNotifications() {
        userProfile?.notificationsEnabled.toggle()
        saveContext()
    }
    
    func setWeeklyGoal(_ minutes: Int) {
        userProfile?.weeklyGoalMinutes = max(50, min(minutes, 500)) // Clamp between 50-500
        saveContext()
    }
    
    func addPreferredSessionType(_ type: SessionType) {
        guard let profile = userProfile else { return }
        
        if !profile.preferredSessionTypes.contains(type) {
            profile.preferredSessionTypes.append(type)
            saveContext()
        }
    }
    
    func removePreferredSessionType(_ type: SessionType) {
        userProfile?.preferredSessionTypes.removeAll { $0 == type }
        saveContext()
    }
    
    // MARK: - Private Helpers
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save user profile context: \(error)")
        }
    }
}