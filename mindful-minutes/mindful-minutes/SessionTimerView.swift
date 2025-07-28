import SwiftUI
import SwiftData
import Foundation

struct SessionTimerView: View {
    @Environment(MindfulDataCoordinator.self) private var dataCoordinator
    @Environment(\.dismiss) private var dismiss

    @State private var selectedDuration: Int = 600 // 10 minutes default
    @State private var selectedType: SessionType = .mindfulness
    @State private var isRunning = false
    @State private var timeRemaining: Int = 600
    @State private var timer: Timer?
    @State private var sessionStartTime: Date?
    @State private var notes: String = ""
    @State private var tags: String = ""
    @State private var showingCompletionView = false

    private let durations = [300, 600, 900, 1200, 1800, 2400, 3600] // 5min to 1hour

    var body: some View {
        NavigationView {
            VStack(spacing: MindfulSpacing.section) {
                if !isRunning && sessionStartTime == nil {
                    setupSection
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .leading)),
                            removal: .opacity.combined(with: .move(edge: .trailing))
                        ))
                } else {
                    timerSection
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                }

                if sessionStartTime != nil && !isRunning {
                    sessionNotesSection
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Spacer()

                actionButtons
                    .transition(.opacity)
            }
            .animation(.easeInOut(duration: 0.4), value: isRunning)
            .animation(.easeInOut(duration: 0.4), value: sessionStartTime)
            .padding()
            .background(Color.mindfulBackground.ignoresSafeArea())
            .navigationTitle(isRunning ? "Meditating" : "New Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        stopSession()
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingCompletionView) {
            SessionCompletionView(
                duration: selectedDuration - timeRemaining,
                type: selectedType,
                onSave: saveSession
            )
        }
        .onDisappear {
            stopTimer()
        }
    }

    private var setupSection: some View {
        VStack(spacing: MindfulSpacing.large) {
            MindfulCard {
                VStack(alignment: .leading, spacing: MindfulSpacing.standard) {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.mindfulPrimary)
                        Text("Duration")
                            .font(.headline)
                        Spacer()
                    }

                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: UIDevice.current.userInterfaceIdiom == .pad ? 4 : 3),
                        spacing: MindfulSpacing.small
                    ) {
                        ForEach(durations, id: \.self) { duration in
                            Button(
                                action: {
                                    let selectionFeedback = UISelectionFeedbackGenerator()
                                    selectionFeedback.selectionChanged()

                                    selectedDuration = duration
                                    timeRemaining = duration
                                },
                                label: {
                                Text(formatDuration(duration))
                                    .font(.body)
                                    .foregroundColor(selectedDuration == duration ? .white : .mindfulPrimary)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedDuration == duration ? Color.mindfulPrimary : Color.clear)
                                            .stroke(Color.mindfulPrimary, lineWidth: 1)
                                    )
                                    .scaleEffect(selectedDuration == duration ? 1.05 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: selectedDuration)
                                }
                            )
                            .accessibilityLabel("Duration \(formatDuration(duration))")
                            .accessibilityHint(selectedDuration == duration ? "Currently selected" : "Tap to select this duration")
                        }
                    }
                }
            }

            MindfulCard {
                VStack(alignment: .leading, spacing: MindfulSpacing.standard) {
                    HStack {
                        Image(systemName: "figure.mind.and.body")
                            .foregroundColor(.mindfulPrimary)
                        Text("Session Type")
                            .font(.headline)
                        Spacer()
                    }

                    Picker("Session Type", selection: $selectedType) {
                        ForEach(SessionType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: getSessionIcon(for: type))
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 120)
                }
            }
        }
    }

    private var timerSection: some View {
        VStack(spacing: MindfulSpacing.large) {
            MindfulCard {
                VStack(spacing: MindfulSpacing.standard) {
                    Image(systemName: getSessionIcon(for: selectedType))
                        .font(.title)
                        .foregroundColor(.mindfulPrimary)

                    Text(selectedType.displayName)
                        .font(.headline)
                        .foregroundColor(.mindfulTextSecondary)

                    Text(formatTime(timeRemaining))
                        .font(.system(size: dynamicTimerFontSize, weight: .light, design: .monospaced))
                        .foregroundColor(.mindfulPrimary)
                        .accessibilityLabel("Time remaining: \(formatTimeForVoiceOver(timeRemaining))")
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)

                    // Progress ring
                    ZStack {
                        Circle()
                            .stroke(Color.mindfulSecondary.opacity(0.3), lineWidth: 8)
                            .frame(width: progressRingSize, height: progressRingSize)

                        Circle()
                            .trim(from: 0, to: progressValue)
                            .stroke(Color.mindfulPrimary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: progressRingSize, height: progressRingSize)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 1), value: progressValue)
                    }
                    .accessibilityLabel("Session progress")
                    .accessibilityValue("\(Int(progressValue * 100))% complete")

                    if !isRunning && timeRemaining < selectedDuration {
                        Text("Session paused")
                            .font(.caption)
                            .foregroundColor(.mindfulTextSecondary)
                    }
                }
                .padding(.vertical)
            }
        }
    }

    private var sessionNotesSection: some View {
        MindfulCard {
            VStack(alignment: .leading, spacing: MindfulSpacing.standard) {
                HStack {
                    Image(systemName: "note.text")
                        .foregroundColor(.mindfulPrimary)
                    Text("Session Notes")
                        .font(.headline)
                    Spacer()
                }

                TextField("How did your session go?", text: $notes, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)

                TextField("Tags (comma separated)", text: $tags)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: MindfulSpacing.standard) {
            if sessionStartTime == nil {
                MindfulButton(
                    title: "Start Session",
                    action: {
                        startSession()
                    },
                    style: .primary
                )
            } else if isRunning {
                HStack(spacing: MindfulSpacing.standard) {
                    MindfulButton(
                        title: "Pause",
                        action: {
                            pauseSession()
                        },
                        style: .secondary
                    )

                    MindfulButton(
                        title: "Finish",
                        action: {
                            finishSession()
                        },
                        style: .primary
                    )
                }
            } else {
                HStack(spacing: MindfulSpacing.standard) {
                    MindfulButton(
                        title: "Resume",
                        action: {
                            resumeSession()
                        },
                        style: .secondary
                    )

                    MindfulButton(
                        title: "Finish",
                        action: {
                            finishSession()
                        },
                        style: .primary
                    )
                }
            }
        }
    }

    private var progressValue: Double {
        let elapsed = selectedDuration - timeRemaining
        return Double(elapsed) / Double(selectedDuration)
    }

    private var progressRingSize: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 250 : 200
    }

    private var dynamicTimerFontSize: CGFloat {
        let baseSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 60 : 48
        return baseSize
    }

    // MARK: - Timer Functions

    private func startSession() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        sessionStartTime = Date()
        isRunning = true
        startTimer()
    }

    private func pauseSession() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()

        isRunning = false
        stopTimer()
    }

    private func resumeSession() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        isRunning = true
        startTimer()
    }

    private func finishSession() {
        let successFeedback = UINotificationFeedbackGenerator()
        successFeedback.notificationOccurred(.success)

        stopTimer()
        isRunning = false
        showingCompletionView = true
    }

    private func stopSession() {
        stopTimer()
        isRunning = false
        sessionStartTime = nil
        timeRemaining = selectedDuration
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                finishSession()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func saveSession(finalNotes: String, finalTags: [String]) {
        guard let startTime = sessionStartTime else { return }

        let actualDuration = max(selectedDuration - timeRemaining, 60) // Minimum 1 minute
        let session = MeditationSession(
            date: startTime,
            duration: TimeInterval(actualDuration),
            type: selectedType,
            notes: finalNotes.isEmpty ? notes : finalNotes,
            tags: finalTags.isEmpty ?
                tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } :
                finalTags,
            isCompleted: true,
            startTime: startTime,
            endTime: Date()
        )

        dataCoordinator.addSession(session)
        dismiss()
    }

    // MARK: - Helper Functions

    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(remainingMinutes)m"
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

    private func formatTimeForVoiceOver(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        if minutes > 0 && remainingSeconds > 0 {
            return "\(minutes) minute\(minutes == 1 ? "" : "s") and \(remainingSeconds) second\(remainingSeconds == 1 ? "" : "s")"
        } else if minutes > 0 {
            return "\(minutes) minute\(minutes == 1 ? "" : "s")"
        } else {
            return "\(remainingSeconds) second\(remainingSeconds == 1 ? "" : "s")"
        }
    }

    private func getSessionIcon(for type: SessionType) -> String {
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

struct SessionCompletionView: View {
    let duration: Int
    let type: SessionType
    let onSave: (String, [String]) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var notes: String = ""
    @State private var tags: String = ""
    @State private var rating: Int = 0

    var body: some View {
        NavigationView {
            VStack(spacing: MindfulSpacing.section) {
                completionHeader
                sessionSummary
                sessionFeedback
                Spacer()
                saveButton
            }
            .padding()
            .background(Color.mindfulBackground.ignoresSafeArea())
            .navigationTitle("Session Complete")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        onSave("", [])
                    }
                }
            }
        }
    }

    private var completionHeader: some View {
        VStack(spacing: MindfulSpacing.standard) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.mindfulPrimary)

            Text("Great job!")
                .font(.title2)
                .fontWeight(.medium)

            Text("You completed a \(formatDuration(duration)) \(type.displayName.lowercased()) session")
                .font(.body)
                .foregroundColor(.mindfulTextSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var sessionSummary: some View {
        MindfulCard {
            VStack(spacing: MindfulSpacing.small) {
                HStack {
                    Text("Session Summary")
                        .font(.headline)
                    Spacer()
                }

                HStack {
                    Text("Duration:")
                    Spacer()
                    Text(formatDuration(duration))
                        .fontWeight(.medium)
                        .foregroundColor(.mindfulPrimary)
                }

                HStack {
                    Text("Type:")
                    Spacer()
                    Text(type.displayName)
                        .fontWeight(.medium)
                        .foregroundColor(.mindfulPrimary)
                }

                HStack {
                    Text("Date:")
                    Spacer()
                    Text(Date().formatted(date: .abbreviated, time: .shortened))
                        .fontWeight(.medium)
                        .foregroundColor(.mindfulPrimary)
                }
            }
        }
    }

    private var sessionFeedback: some View {
        VStack(spacing: MindfulSpacing.standard) {
            MindfulCard {
                VStack(alignment: .leading, spacing: MindfulSpacing.standard) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.mindfulPrimary)
                        Text("How was your session?")
                            .font(.headline)
                        Spacer()
                    }

                    HStack {
                        ForEach(1...5, id: \.self) { star in
                            Button(
                                action: {
                                    rating = star
                                },
                                label: {
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .font(.title2)
                                    .foregroundColor(star <= rating ? .yellow : .gray)
                                }
                            )
                        }
                        Spacer()
                    }
                }
            }

            MindfulCard {
                VStack(alignment: .leading, spacing: MindfulSpacing.standard) {
                    HStack {
                        Image(systemName: "note.text")
                            .foregroundColor(.mindfulPrimary)
                        Text("Session Notes")
                            .font(.headline)
                        Spacer()
                    }

                    TextField("How did your session go?", text: $notes, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)

                    TextField("Tags (comma separated)", text: $tags)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
        }
    }

    private var saveButton: some View {
        MindfulButton(
            title: "Save Session",
            action: {
                let tagArray = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                onSave(notes, tagArray)
            },
            style: .primary
        )
    }

    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        if minutes < 60 {
            return "\(minutes) minute\(minutes == 1 ? "" : "s")"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours) hour\(hours == 1 ? "" : "s")"
            } else {
                return "\(hours) hour\(hours == 1 ? "" : "s") " +
                       "\(remainingMinutes) minute\(remainingMinutes == 1 ? "" : "s")"
            }
        }
    }
}

#Preview {
    SessionTimerView()
        .modelContainer(for: [MeditationSession.self, UserProfile.self, Milestone.self], inMemory: true)
}
