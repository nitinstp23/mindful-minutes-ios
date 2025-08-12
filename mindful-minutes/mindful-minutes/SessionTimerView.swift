import SwiftUI
import SwiftData
import Foundation

struct SessionTimerView: View {
    @Environment(MindfulDataCoordinator.self) private var dataCoordinator
    @Environment(\.dismiss) private var dismiss

    @State private var selectedHours: Int = 0
    @State private var selectedMinutes: Int = 10
    @State private var selectedWarmupSeconds: Int = 0
    @State private var selectedType: SessionType = .mindfulness
    @State private var isRunning = false
    @State private var timeRemaining: Int = 600
    @State private var timer: Timer?
    @State private var sessionStartTime: Date?
    @State private var notes: String = ""
    @State private var showingCompletionView = false
    @State private var showingDurationSelection = false

    private let warmupPresets = [0, 5, 10, 15, 30, 45, 60, 90, 120, 180, 240, 300] // 0s to 5m

    var body: some View {
        NavigationView {
            VStack(spacing: MindfulSpacing.section) {
                headerSection

                if !isRunning && sessionStartTime == nil {
                    setupSection
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale(scale: 0.8).combined(with: .opacity)
                        ))
                } else {
                    timerSection
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale(scale: 0.8).combined(with: .opacity)
                        ))
                }

                if sessionStartTime != nil && !isRunning {
                    sessionNotesSection
                        .transition(.scale.combined(with: .opacity))
                }

                Spacer()

                actionButtons
                    .transition(.scale.combined(with: .opacity))
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.3), value: isRunning)
            .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.3), value: sessionStartTime)
            .padding()
            .background(Color.mindfulBackground.ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear {
                updateTimeRemaining()
            }
        }
        .sheet(isPresented: $showingCompletionView) {
            SessionCompletionView(
                duration: totalDuration - timeRemaining,
                type: selectedType,
                onSave: saveSession
            )
        }
        .sheet(isPresented: $showingDurationSelection) {
            DurationSelectionView(
                selectedHours: $selectedHours,
                selectedMinutes: $selectedMinutes,
                selectedWarmupSeconds: $selectedWarmupSeconds,
                onSave: {
                    updateTimeRemaining()
                    showingDurationSelection = false
                },
                onCancel: {
                    showingDurationSelection = false
                }
            )
        }
        .onDisappear {
            stopTimer()
        }
    }

    private var headerSection: some View {
        HStack {
            Button("Cancel") {
                stopSession()
                dismiss()
            }
            .foregroundColor(.mindfulPrimary)

            Spacer()

            VStack(spacing: MindfulSpacing.small) {
                Text(isRunning ? "Meditating" : "New Session")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.mindfulTextPrimary)

                if !isRunning && sessionStartTime == nil {
                    Text("Start your mindful practice")
                        .font(.subheadline)
                        .foregroundColor(.mindfulTextSecondary)
                } else if isRunning {
                    Text(isInWarmupPhase ? "Warming up - prepare yourself" : "Stay present and focused")
                        .font(.subheadline)
                        .foregroundColor(.mindfulTextSecondary)
                } else {
                    Text("Session paused")
                        .font(.subheadline)
                        .foregroundColor(.mindfulTextSecondary)
                }
            }

            Spacer()

            // Invisible button for centering
            Button("Cancel") {
                // Do nothing
            }
            .foregroundColor(.mindfulPrimary)
            .opacity(0)
        }
        .padding(.horizontal, MindfulSpacing.standard)
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
                            .foregroundColor(.mindfulTextPrimary)
                        Spacer()

                        Button("Change") {
                            showingDurationSelection = true
                        }
                        .font(.subheadline)
                        .foregroundColor(.mindfulPrimary)
                    }

                    Button(action: {
                        showingDurationSelection = true
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: MindfulSpacing.small) {
                                Text(formatTotalDuration())
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.mindfulTextPrimary)

                                if selectedWarmupSeconds > 0 {
                                    Text("Includes \(formatWarmupTime(selectedWarmupSeconds)) warm up")
                                        .font(.caption)
                                        .foregroundColor(.mindfulTextSecondary)
                                }
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.mindfulTextSecondary)
                        }
                        .padding(.vertical, MindfulSpacing.small)
                        .padding(.horizontal, MindfulSpacing.standard)
                        .background(Color.mindfulBackground)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.mindfulSecondary.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            MindfulCard {
                VStack(alignment: .leading, spacing: MindfulSpacing.standard) {
                    HStack {
                        Image(systemName: "figure.mind.and.body")
                            .foregroundColor(.mindfulPrimary)
                        Text("Session Type")
                            .font(.headline)
                            .foregroundColor(.mindfulTextPrimary)
                        Spacer()
                    }

                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: MindfulSpacing.small) {
                                ForEach(SessionType.allCases, id: \.self) { type in
                                    SessionTypeCard(
                                        type: type,
                                        isSelected: selectedType == type,
                                        onTap: {
                                            let selectionFeedback = UISelectionFeedbackGenerator()
                                            selectionFeedback.selectionChanged()

                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                selectedType = type
                                                proxy.scrollTo(type, anchor: .center)
                                            }
                                        }
                                    )
                                    .id(type)
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        .onAppear {
                            // Scroll to initially selected type
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    proxy.scrollTo(selectedType, anchor: .center)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var timerSection: some View {
        VStack(spacing: MindfulSpacing.large) {
            MindfulCard {
                VStack(spacing: MindfulSpacing.large) {
                    // Session type header
                    VStack(spacing: MindfulSpacing.small) {
                        Image(systemName: getSessionIcon(for: selectedType))
                            .font(.title)
                            .foregroundColor(.mindfulPrimary)
                            .frame(width: 40, height: 40)
                            .background(Color.mindfulPrimary.opacity(0.1))
                            .cornerRadius(8)

                        Text(selectedType.displayName)
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.mindfulTextPrimary)
                    }

                    // Timer display with progress ring
                    ZStack {
                        // Progress ring background
                        Circle()
                            .stroke(Color.mindfulSecondary.opacity(0.2), lineWidth: 6)
                            .frame(width: progressRingSize, height: progressRingSize)

                        // Progress ring foreground
                        Circle()
                            .trim(from: 0, to: progressValue)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.mindfulPrimary, Color.mindfulSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .frame(width: progressRingSize, height: progressRingSize)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 1), value: progressValue)

                        // Breathing guide circle (gentle pulse when running)
                        if isRunning {
                            Circle()
                                .fill(Color.mindfulPrimary.opacity(0.1))
                                .frame(width: breathingCircleSize, height: breathingCircleSize)
                                .scaleEffect(isRunning ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: isRunning)
                        }

                        // Time display
                        VStack(spacing: MindfulSpacing.small) {
                            Text(formatTime(timeRemaining))
                                .font(.system(size: dynamicTimerFontSize, weight: .light, design: .monospaced))
                                .foregroundColor(.mindfulTextPrimary)
                                .accessibilityLabel("Time remaining: \(formatTimeForVoiceOver(timeRemaining))")
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)

                            if selectedWarmupSeconds > 0 && timeRemaining > (selectedHours * 3600 + selectedMinutes * 60) {
                                Text("Warming up...")
                                    .font(.caption)
                                    .foregroundColor(.mindfulSecondary)
                            } else {
                                Text("\(Int(progressValue * 100))% complete")
                                    .font(.caption)
                                    .foregroundColor(.mindfulTextSecondary)
                            }
                        }
                    }
                    .accessibilityLabel("Session progress")
                    .accessibilityValue("\(Int(progressValue * 100))% complete")

                    // Status indicator
                    if !isRunning && timeRemaining < totalDuration {
                        HStack(spacing: MindfulSpacing.small) {
                            Image(systemName: "pause.circle.fill")
                                .foregroundColor(.mindfulSecondary)
                            Text("Session paused")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.mindfulTextSecondary)
                        }
                        .padding(.horizontal, MindfulSpacing.standard)
                        .padding(.vertical, MindfulSpacing.small)
                        .background(Color.mindfulSecondary.opacity(0.1))
                        .cornerRadius(8)
                    } else if isRunning {
                        HStack(spacing: MindfulSpacing.small) {
                            Image(systemName: isInWarmupPhase ? "timer" : "play.circle.fill")
                                .foregroundColor(isInWarmupPhase ? .mindfulSecondary : .mindfulPrimary)
                            Text(isInWarmupPhase ? "Prepare yourself..." : "Focus on your breath")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(isInWarmupPhase ? .mindfulTextSecondary : .mindfulTextPrimary)
                        }
                        .padding(.horizontal, MindfulSpacing.standard)
                        .padding(.vertical, MindfulSpacing.small)
                        .background((isInWarmupPhase ? Color.mindfulSecondary : Color.mindfulPrimary).opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(.vertical, MindfulSpacing.standard)
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
        let elapsed = totalDuration - timeRemaining
        return Double(elapsed) / Double(totalDuration)
    }

    private var totalDuration: Int {
        let sessionDuration = selectedHours * 3600 + selectedMinutes * 60
        return sessionDuration + selectedWarmupSeconds
    }

    private var isInWarmupPhase: Bool {
        guard selectedWarmupSeconds > 0 else { return false }
        let sessionDuration = selectedHours * 3600 + selectedMinutes * 60
        return timeRemaining > sessionDuration
    }

    private var progressRingSize: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 250 : 200
    }

    private var dynamicTimerFontSize: CGFloat {
        let baseSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 60 : 48
        return baseSize
    }

    private var breathingCircleSize: CGFloat {
        progressRingSize * 0.6
    }

    // MARK: - Timer Functions

    private func startSession() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        sessionStartTime = Date()
        timeRemaining = totalDuration
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
        timeRemaining = totalDuration
    }

    private func updateTimeRemaining() {
        if sessionStartTime == nil {
            timeRemaining = totalDuration
        }
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

        let actualDuration = max(totalDuration - timeRemaining, 60) // Minimum 1 minute
        let session = MeditationSession(
            date: startTime,
            duration: TimeInterval(actualDuration),
            type: selectedType,
            notes: finalNotes.isEmpty ? notes : finalNotes,
            isCompleted: true,
            startTime: startTime,
            endTime: Date()
        )

        dataCoordinator.addSession(session)
        dismiss()
    }

    // MARK: - Helper Functions

    private func formatTotalDuration() -> String {
        return formatDurationString(selectedHours * 3600 + selectedMinutes * 60)
    }

    private func formatDurationString(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "0m"
        }
    }

    private func formatWarmupTime(_ seconds: Int) -> String {
        if seconds == 0 {
            return "None"
        } else if seconds < 60 {
            return "\(seconds)s"
        } else {
            let minutes = seconds / 60
            return "\(minutes)m"
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
    @State private var rating: Int = 0

    var body: some View {
        NavigationView {
            VStack(spacing: MindfulSpacing.section) {
                completionHeaderSection
                completionHeader
                sessionSummary
                sessionFeedback
                Spacer()
                saveButton
            }
            .padding()
            .background(Color.mindfulBackground.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    private var completionHeaderSection: some View {
        HStack {
            Spacer()

            VStack(spacing: MindfulSpacing.small) {
                Text("Session Complete")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.mindfulTextPrimary)

                Text("Well done on completing your practice")
                    .font(.subheadline)
                    .foregroundColor(.mindfulTextSecondary)
            }

            Spacer()

            Button("Skip") {
                onSave("", [])
            }
            .foregroundColor(.mindfulPrimary)
        }
        .padding(.horizontal, MindfulSpacing.standard)
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

                }
            }
        }
    }

    private var saveButton: some View {
        MindfulButton(
            title: "Save Session",
            action: {
                onSave(notes, [])
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

struct SessionTypeCard: View {
    let type: SessionType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: MindfulSpacing.small) {
                Image(systemName: getSessionIcon(for: type))
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .mindfulPrimary)
                    .frame(width: 32, height: 32)

                Text(type.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .mindfulTextPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 90, height: 80)
            .padding(MindfulSpacing.small)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.mindfulPrimary : Color.mindfulBackground)
                    .stroke(isSelected ? Color.mindfulPrimary : Color.mindfulSecondary.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
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

struct DurationSelectionView: View {
    @Binding var selectedHours: Int
    @Binding var selectedMinutes: Int
    @Binding var selectedWarmupSeconds: Int
    let onSave: () -> Void
    let onCancel: () -> Void

    private let warmupPresets = [0, 5, 10, 15, 30, 45, 60, 120, 180, 240, 300] // 0s to 5m

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: MindfulSpacing.large) {
                    headerSection
                    durationSection
                    warmupSection
                    Spacer(minLength: MindfulSpacing.large)
                }
                .padding(.horizontal, MindfulSpacing.standard)
                .padding(.vertical, MindfulSpacing.small)
            }
            .background(Color.mindfulBackground.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    private var headerSection: some View {
        HStack {
            Button("Cancel") {
                onCancel()
            }
            .foregroundColor(.mindfulPrimary)
            .font(.body)

            Spacer()

            VStack(spacing: 4) {
                Text("Duration")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.mindfulTextPrimary)
            }

            Spacer()

            Button("Save") {
                onSave()
            }
            .foregroundColor(.mindfulPrimary)
            .font(.body)
            .fontWeight(.semibold)
        }
        .padding(.horizontal, MindfulSpacing.standard)
    }

    private var durationSection: some View {
        MindfulCard {
            VStack(alignment: .leading, spacing: MindfulSpacing.standard) {
                HStack(alignment: .center, spacing: MindfulSpacing.standard) {
                    // Hours picker
                    VStack(spacing: MindfulSpacing.small) {
                        Text("Hours")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.mindfulTextPrimary)

                        Picker("Hours", selection: $selectedHours) {
                            ForEach(0...23, id: \.self) { hour in
                                Text("\(hour)")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.mindfulTextPrimary)
                                    .tag(hour)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 80, height: 140)
                        .clipped()
                    }
                    .frame(maxWidth: .infinity)

                    // Minutes picker
                    VStack(spacing: MindfulSpacing.small) {
                        Text("Minutes")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.mindfulTextPrimary)

                        Picker("Minutes", selection: $selectedMinutes) {
                            ForEach(0...59, id: \.self) { minute in
                                Text("\(minute)")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.mindfulTextPrimary)
                                    .tag(minute)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 80, height: 140)
                        .clipped()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private var warmupSection: some View {
        MindfulCard {
            VStack(alignment: .center, spacing: MindfulSpacing.standard) {
                VStack(spacing: MindfulSpacing.small) {
                    Text("Warm Up")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.mindfulTextPrimary)

                    Picker("Warm Up", selection: $selectedWarmupSeconds) {
                        ForEach(warmupPresets, id: \.self) { warmupTime in
                            Text(formatWarmupTime(warmupTime))
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.mindfulTextPrimary)
                                .tag(warmupTime)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 140)
                    .clipped()
                }
            }
        }
    }


    private func formatDurationString(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        if hours > 0 && minutes > 0 {
            return "\(hours)h\n\(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "0m"
        }
    }

    private func formatWarmupTime(_ seconds: Int) -> String {
        if seconds == 0 {
            return "None"
        } else if seconds < 60 {
            return "\(seconds)s"
        } else {
            let minutes = seconds / 60
            return "\(minutes)m"
        }
    }
}

#Preview {
    SessionTimerView()
        .modelContainer(for: [MeditationSession.self, UserProfile.self, Milestone.self], inMemory: true)
}
