import Foundation
import SwiftData

@Model
final class MeditationSession {
    var id: UUID
    var date: Date
    var duration: TimeInterval // in seconds
    var type: SessionType
    var notes: String
    var isCompleted: Bool
    var startTime: Date?
    var endTime: Date?
    var sessionNumber: Int?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        duration: TimeInterval = 0,
        type: SessionType = .mindfulness,
        notes: String = "",
        isCompleted: Bool = false,
        startTime: Date? = nil,
        endTime: Date? = nil,
        sessionNumber: Int? = nil
    ) {
        self.id = id
        self.date = date
        self.duration = duration
        self.type = type
        self.notes = notes
        self.isCompleted = isCompleted
        self.startTime = startTime
        self.endTime = endTime
        self.sessionNumber = sessionNumber
    }

    var durationInMinutes: Int {
        Int(duration / 60)
    }

    var formattedDuration: String {
        let minutes = Int(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        if seconds == 0 {
            return "\(minutes) min"
        } else {
            return "\(minutes):\(String(format: "%02d", seconds))"
        }
    }

    var sessionTypeIcon: String {
        switch type {
        case .mindfulness: return "figure.mind.and.body"
        case .breathing: return "lungs.fill"
        case .bodyScan: return "figure.walk"
        case .lovingKindness: return "heart.fill"
        case .focus: return "target"
        case .movement: return "figure.yoga"
        case .sleep: return "moon.fill"
        case .custom: return "circle.grid.3x3.fill"
        }
    }
}

enum SessionType: String, CaseIterable, Codable {
    case mindfulness = "Mindfulness"
    case breathing = "Breathing"
    case bodyScan = "Body Scan"
    case lovingKindness = "Metta"
    case focus = "Focus"
    case movement = "Movement"
    case sleep = "Sleep"
    case custom = "Custom"

    var displayName: String {
        self.rawValue
    }
}

@Model
final class UserProfile {
    var id: UUID
    var name: String
    var email: String
    var joinDate: Date
    var weeklyGoalMinutes: Int
    var preferredSessionDuration: Int // in minutes
    var preferredSessionTypes: [SessionType]
    var notificationsEnabled: Bool
    var reminderTime: Date
    var streakStartDate: Date?

    init(
        id: UUID = UUID(),
        name: String = "",
        email: String = "",
        joinDate: Date = Date(),
        weeklyGoalMinutes: Int = 150,
        preferredSessionDuration: Int = 10,
        preferredSessionTypes: [SessionType] = [.mindfulness],
        notificationsEnabled: Bool = true,
        reminderTime: Date = Calendar.current.date(
            from: DateComponents(hour: 9, minute: 0)
        ) ?? Date(),
        streakStartDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.joinDate = joinDate
        self.weeklyGoalMinutes = weeklyGoalMinutes
        self.preferredSessionDuration = preferredSessionDuration
        self.preferredSessionTypes = preferredSessionTypes
        self.notificationsEnabled = notificationsEnabled
        self.reminderTime = reminderTime
        self.streakStartDate = streakStartDate
    }
}

@Model
final class Milestone {
    var id: UUID
    var title: String
    var details: String
    var targetValue: Int
    var currentValue: Int
    var isCompleted: Bool
    var completedDate: Date?
    var milestoneType: MilestoneType

    init(
        id: UUID = UUID(),
        title: String,
        details: String,
        targetValue: Int,
        currentValue: Int = 0,
        isCompleted: Bool = false,
        completedDate: Date? = nil,
        milestoneType: MilestoneType
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.isCompleted = isCompleted
        self.completedDate = completedDate
        self.milestoneType = milestoneType
    }

    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(Double(currentValue) / Double(targetValue), 1.0)
    }

    var progressText: String {
        "\(currentValue)/\(targetValue)"
    }
}

enum MilestoneType: String, CaseIterable, Codable {
    case streak = "Streak"
    case totalSessions = "Total Sessions"
    case totalMinutes = "Total Minutes"
    case weeklyGoal = "Weekly Goal"
    case monthlyGoal = "Monthly Goal"

    var icon: String {
        switch self {
        case .streak: return "flame.fill"
        case .totalSessions: return "figure.mind.and.body"
        case .totalMinutes: return "clock.fill"
        case .weeklyGoal: return "calendar.badge.clock"
        case .monthlyGoal: return "calendar"
        }
    }
}

// MARK: - Default Milestones
extension Milestone {
    static let defaultMilestones: [Milestone] = [
        Milestone(
            title: "First Steps",
            details: "Complete your first meditation session",
            targetValue: 1,
            milestoneType: .totalSessions
        ),
        Milestone(
            title: "First Week",
            details: "Complete 7 days in a row",
            targetValue: 7,
            milestoneType: .streak
        ),
        Milestone(
            title: "Dedicated Practitioner",
            details: "Complete 25 meditation sessions",
            targetValue: 25,
            milestoneType: .totalSessions
        ),
        Milestone(
            title: "Mindful Hours",
            details: "Meditate for 10 total hours",
            targetValue: 600, // 10 hours in minutes
            milestoneType: .totalMinutes
        ),
        Milestone(
            title: "Consistent Meditator",
            details: "Reach a 30-day streak",
            targetValue: 30,
            milestoneType: .streak
        ),
        Milestone(
            title: "Century Club",
            details: "Complete 100 meditation sessions",
            targetValue: 100,
            milestoneType: .totalSessions
        ),
        Milestone(
            title: "Meditation Master",
            details: "Meditate for 50 total hours",
            targetValue: 3000, // 50 hours in minutes
            milestoneType: .totalMinutes
        )
    ]
}
