import Foundation

// MARK: - Session Filter
enum SessionFilter: String, CaseIterable {
    case all = "All"
    case today = "Today"
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case mindfulness = "Mindfulness"
    case breathing = "Breathing"
    case bodyScan = "Body Scan"
    case lovingKindness = "Metta"
    case focus = "Focus"
    case movement = "Movement"
    case sleep = "Sleep"

    var sessionType: SessionType? {
        switch self {
        case .mindfulness: return .mindfulness
        case .breathing: return .breathing
        case .bodyScan: return .bodyScan
        case .lovingKindness: return .lovingKindness
        case .focus: return .focus
        case .movement: return .movement
        case .sleep: return .sleep
        default: return nil
        }
    }
}
