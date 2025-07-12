import Foundation
import SwiftData

@Observable
class MilestoneManager {
    private let modelContext: ModelContext
    private(set) var milestones: [Milestone] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadMilestones()
        setupDefaultMilestones()
    }
    
    // MARK: - Data Loading
    private func loadMilestones() {
        let descriptor = FetchDescriptor<Milestone>(
            sortBy: [SortDescriptor(\.targetValue)]
        )
        do {
            milestones = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load milestones: \(error)")
            milestones = []
        }
    }
    
    private func setupDefaultMilestones() {
        if milestones.isEmpty {
            for defaultMilestone in Milestone.defaultMilestones {
                milestones.append(defaultMilestone)
                modelContext.insert(defaultMilestone)
            }
            saveContext()
        }
    }
    
    // MARK: - Progress Updates
    func updateProgress(
        totalSessions: Int,
        totalMinutes: Int,
        currentStreak: Int,
        longestStreak: Int,
        weeklyMinutes: Int,
        monthlyMinutes: Int
    ) {
        for milestone in milestones {
            let previousCompletion = milestone.isCompleted
            
            switch milestone.milestoneType {
            case .totalSessions:
                milestone.currentValue = totalSessions
            case .totalMinutes:
                milestone.currentValue = totalMinutes
            case .streak:
                milestone.currentValue = max(longestStreak, currentStreak)
            case .weeklyGoal:
                milestone.currentValue = weeklyMinutes
            case .monthlyGoal:
                milestone.currentValue = monthlyMinutes
            }
            
            // Check if milestone was just completed
            if !previousCompletion && milestone.currentValue >= milestone.targetValue {
                milestone.isCompleted = true
                milestone.completedDate = Date()
                // Could trigger celebration or notification here
                onMilestoneCompleted(milestone)
            }
            
            // If value decreased, unmark completion if needed
            if milestone.isCompleted && milestone.currentValue < milestone.targetValue {
                milestone.isCompleted = false
                milestone.completedDate = nil
            }
        }
        
        saveContext()
    }
    
    // MARK: - Milestone Queries
    func completedMilestones() -> [Milestone] {
        milestones.filter { $0.isCompleted }
    }
    
    func activeMilestones() -> [Milestone] {
        milestones
            .filter { !$0.isCompleted }
            .sorted { $0.targetValue < $1.targetValue }
    }
    
    func nextMilestone() -> Milestone? {
        activeMilestones().first
    }
    
    func recentlyCompleted(within days: Int = 7) -> [Milestone] {
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        return completedMilestones().filter { milestone in
            guard let completedDate = milestone.completedDate else { return false }
            return completedDate >= cutoffDate
        }
    }
    
    // MARK: - Milestone Management
    func addCustomMilestone(_ milestone: Milestone) {
        milestones.append(milestone)
        modelContext.insert(milestone)
        saveContext()
    }
    
    func deleteMilestone(_ milestone: Milestone) {
        milestones.removeAll { $0.id == milestone.id }
        modelContext.delete(milestone)
        saveContext()
    }
    
    // MARK: - Events
    private func onMilestoneCompleted(_ milestone: Milestone) {
        print("🎉 Milestone completed: \(milestone.title)")
        // Future: Send notification, trigger animation, etc.
    }
    
    // MARK: - Private Helpers
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save milestone context: \(error)")
        }
    }
}