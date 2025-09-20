import Foundation
import SwiftUI

@Observable
class SessionCoordinator {
    // Session configuration
    var selectedHours: Int = 0
    var selectedMinutes: Int = 10
    var selectedWarmupSeconds: Int = 0
    var selectedType: SessionType = .mindfulness

    // Session state
    var isRunning = false
    var timeRemaining: Int = 600
    var sessionStartTime: Date?
    var sessionCompleted = false
    var timerFinished = false
    var showingDurationSelection = false

    // Timer
    private var timer: Timer?

    // Total duration
    var totalDuration: Int {
        (selectedHours * 3600) + (selectedMinutes * 60) + selectedWarmupSeconds
    }

    var isInWarmupPhase: Bool {
        guard selectedWarmupSeconds > 0 else { return false }
        return timeRemaining > (selectedHours * 3600 + selectedMinutes * 60)
    }

    // MARK: - Session Control

    func startSession() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        sessionStartTime = Date()
        timeRemaining = totalDuration
        isRunning = true
        startTimer()

        // No need for notifications with direct state observation
    }

    func pauseSession() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()

        isRunning = false
        stopTimer()
    }

    func resumeSession() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        isRunning = true
        startTimer()
    }

    func finishSession(dataCoordinator: MindfulDataCoordinator) {
        let successFeedback = UINotificationFeedbackGenerator()
        successFeedback.notificationOccurred(.success)

        // Save session when user explicitly chooses to finish
        guard let startTime = sessionStartTime else { return }
        let actualDuration = max(totalDuration - timeRemaining, 60) // Minimum 1 minute
        let session = MeditationSession(
            date: startTime,
            duration: TimeInterval(actualDuration),
            type: selectedType,
            isCompleted: true,
            startTime: startTime,
            endTime: Date()
        )
        dataCoordinator.addSession(session)

        stopTimer()
        isRunning = false
        sessionCompleted = true

        // No need for notifications with direct state observation
    }

    func discardSession() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()

        // No need for notifications with direct state observation
        resetSession()
    }

    func continueAfterSession() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()

        // Reset session state and navigate to Sessions tab
        resetSession()
        NotificationCenter.default.post(name: NSNotification.Name("NavigateToSessions"), object: nil)
    }

    func resetSession() {
        stopTimer()
        isRunning = false
        sessionStartTime = nil
        timeRemaining = totalDuration
        sessionCompleted = false
        timerFinished = false
    }

    // MARK: - Timer Management

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timerCompleted()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func timerCompleted() {
        let successFeedback = UINotificationFeedbackGenerator()
        successFeedback.notificationOccurred(.success)

        // Stop the timer and mark as finished to show Finish/Discard options
        stopTimer()
        isRunning = false
        timerFinished = true
    }

    // MARK: - Helper Functions

    func updateTimeRemaining() {
        if sessionStartTime == nil {
            timeRemaining = totalDuration
        }
    }

    func formatTotalDuration() -> String {
        return formatDurationString(selectedHours * 3600 + selectedMinutes * 60)
    }

    func formatDurationString(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    func formatTimeDisplay(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }

    func formatTimeForVoiceOver(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60

        var result = ""
        if hours > 0 {
            result += "\(hours) hour\(hours == 1 ? "" : "s") "
        }
        if minutes > 0 {
            result += "\(minutes) minute\(minutes == 1 ? "" : "s") "
        }
        if secs > 0 && hours == 0 {
            result += "\(secs) second\(secs == 1 ? "" : "s")"
        }

        return result.trimmingCharacters(in: .whitespaces)
    }

    var playButtonIcon: String {
        if sessionStartTime == nil || (!isRunning && !sessionCompleted) {
            return "play.fill"
        } else {
            return "pause.fill"
        }
    }

    var progressValue: Double {
        let elapsed = totalDuration - timeRemaining
        return Double(elapsed) / Double(totalDuration)
    }
}