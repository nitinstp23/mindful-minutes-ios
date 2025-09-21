import SwiftUI
import SwiftData
import Foundation

enum AmbientSound: String, CaseIterable {
    case none = "None"
    case rain = "Rain"
    case forest = "Forest"
    case ocean = "Ocean"
    case whitenoise = "White Noise"

    var displayName: String {
        return self.rawValue
    }

    var iconName: String {
        switch self {
        case .none: return "speaker.slash"
        case .rain: return "cloud.rain"
        case .forest: return "tree"
        case .ocean: return "water.waves"
        case .whitenoise: return "speaker.wave.2"
        }
    }
}

struct SessionTimerView: View {
    @Environment(MindfulDataCoordinator.self) private var dataCoordinator
    @Bindable var sessionCoordinator: SessionCoordinator

    private let warmupPresets = [0, 5, 10, 15, 30, 45, 60, 90, 120, 180, 240, 300] // 0s to 5m

    // Additional session options
    @State private var selectedAmbientSound: AmbientSound = .none
    @State private var startBellEnabled: Bool = true
    @State private var endingBellEnabled: Bool = true
    @State private var showingSessionTypeSelection = false

    var body: some View {
        VStack(spacing: MindfulSpacing.section) {
            headerSection

            if !sessionCoordinator.isRunning && sessionCoordinator.sessionStartTime == nil {
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

            // Spacing between timer and action buttons
            Spacer()
                .frame(minHeight: 40, maxHeight: 80)

            actionButtons
                .transition(.scale.combined(with: .opacity))
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.3), value: sessionCoordinator.isRunning)
        .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.3), value: sessionCoordinator.sessionStartTime)
        .padding()
        .padding(.bottom, (sessionCoordinator.isRunning || sessionCoordinator.sessionCompleted) ? 40 : 20) // More space when tab bar is hidden
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mindfulBackground.ignoresSafeArea(.all))
        .onAppear {
            sessionCoordinator.updateTimeRemaining()
        }
        .sheet(isPresented: $sessionCoordinator.showingDurationSelection) {
            DurationSelectionView(
                selectedHours: $sessionCoordinator.selectedHours,
                selectedMinutes: $sessionCoordinator.selectedMinutes,
                selectedWarmupSeconds: $sessionCoordinator.selectedWarmupSeconds,
                onSave: {
                    sessionCoordinator.updateTimeRemaining()
                    sessionCoordinator.showingDurationSelection = false
                },
                onCancel: {
                    sessionCoordinator.showingDurationSelection = false
                }
            )
        }
        .sheet(isPresented: $showingSessionTypeSelection) {
            SessionTypeSelectionView(
                selectedType: $sessionCoordinator.selectedType,
                onSave: {
                    showingSessionTypeSelection = false
                },
                onCancel: {
                    showingSessionTypeSelection = false
                }
            )
        }
        .onDisappear {
            // Stop timer if view disappears
        }
    }

    private var headerSection: some View {
        VStack(spacing: MindfulSpacing.small) {
            if !sessionCoordinator.isRunning && sessionCoordinator.sessionStartTime == nil {
                Text("New Session")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.mindfulTextPrimary)

                Text("Start your mindful practice")
                    .font(.subheadline)
                    .foregroundColor(.mindfulTextSecondary)
            } else if sessionCoordinator.isRunning {
                Text(sessionCoordinator.isInWarmupPhase ? "Prepare yourself" : "Stay present and focused")
                    .font(.subheadline)
                    .foregroundColor(.mindfulTextSecondary)
            } else if sessionCoordinator.timerFinished {
                Text("You completed \(sessionCoordinator.formatTotalDuration())")
                    .font(.subheadline)
                    .foregroundColor(.mindfulTextSecondary)
            } else {
                Text("Paused")
                    .font(.subheadline)
                    .foregroundColor(.mindfulTextSecondary)
            }
        }
        .padding(.horizontal, MindfulSpacing.small)
        .padding(.top, MindfulSpacing.large)
    }

    private var setupSection: some View {
        VStack(spacing: 0) {
            // Main options container
            VStack(spacing: 0) {
                // Duration row
                SessionOptionRow(
                    icon: "clock",
                    title: "Duration",
                    value: sessionCoordinator.formatTotalDuration(),
                    action: {
                        sessionCoordinator.showingDurationSelection = true
                    }
                )

                Divider()
                    .padding(.leading, 56)

                // Session Type row
                SessionOptionRow(
                    icon: "figure.mind.and.body",
                    title: "Session Type",
                    value: sessionCoordinator.selectedType.displayName,
                    action: {
                        showingSessionTypeSelection = true
                    }
                )

                Divider()
                    .padding(.leading, 56)

                // Ambient Sound row
                SessionOptionRow(
                    icon: selectedAmbientSound.iconName,
                    title: "Ambient Sound",
                    value: selectedAmbientSound.displayName,
                    action: {
                        // Will add sound selection later
                    }
                )

                Divider()
                    .padding(.leading, 56)

                // Start Bell row
                SessionOptionRow(
                    icon: "bell",
                    title: "Start Bell",
                    value: startBellEnabled ? "On" : "Off",
                    action: {
                        startBellEnabled.toggle()
                    }
                )

                Divider()
                    .padding(.leading, 56)

                // Ending Bell row
                SessionOptionRow(
                    icon: "bell.badge",
                    title: "Ending Bell",
                    value: endingBellEnabled ? "On" : "Off",
                    action: {
                        endingBellEnabled.toggle()
                    }
                )
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .padding(.horizontal, MindfulSpacing.standard)
    }


    private var timerSection: some View {
        VStack(spacing: MindfulSpacing.section) {
            sessionTypeDisplay
            progressRing
        }
    }

    private var sessionTypeDisplay: some View {
        VStack(spacing: MindfulSpacing.small) {
            Image(systemName: getSessionIcon(for: sessionCoordinator.selectedType))
                .font(.system(size: 40))
                .foregroundColor(.mindfulPrimary)
                .frame(width: 60, height: 60)
                .background(Color.mindfulPrimary.opacity(0.1))
                .cornerRadius(12)

            Text(sessionCoordinator.selectedType.displayName)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.mindfulTextPrimary)
        }
    }

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color.mindfulPrimary.opacity(0.2), lineWidth: 8)
                .frame(width: 200, height: 200)

            Circle()
                .trim(from: 0, to: sessionCoordinator.progressValue)
                .stroke(Color.mindfulPrimary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1), value: sessionCoordinator.progressValue)

            VStack(spacing: 8) {
                Text(sessionCoordinator.formatTimeDisplay(sessionCoordinator.timeRemaining))
                    .font(.system(size: 32, weight: .medium, design: .monospaced))
                    .foregroundColor(.mindfulTextPrimary)
                    .accessibilityLabel("Time remaining: \(sessionCoordinator.formatTimeForVoiceOver(sessionCoordinator.timeRemaining))")
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                if sessionCoordinator.selectedWarmupSeconds > 0 && sessionCoordinator.timeRemaining > (sessionCoordinator.selectedHours * 3600 + sessionCoordinator.selectedMinutes * 60) {
                    Text("Warming up...")
                        .font(.caption)
                        .foregroundColor(.mindfulSecondary)
                } else {
                    Text("\(Int(sessionCoordinator.progressValue * 100))% complete")
                        .font(.caption)
                        .foregroundColor(.mindfulTextSecondary)
                }
            }
        }
        .accessibilityLabel("Session progress")
        .accessibilityValue("\(Int(sessionCoordinator.progressValue * 100))% complete")
    }

    private var actionButtons: some View {
        VStack(spacing: 0) {
            // Primary button area - always fixed height and position
            VStack {
                if sessionCoordinator.sessionCompleted {
                    // Session completed: Continue button
                    Button(action: {
                        sessionCoordinator.continueAfterSession()
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.mindfulPrimary)
                            .fontWeight(.semibold)
                    }
                    .frame(minWidth: 80)
                } else if sessionCoordinator.timerFinished {
                    // Timer finished: No primary button, only secondary buttons below
                    Color.clear
                } else {
                    // Play/Pause button (for setup, running, or paused states)
                    Button(action: {
                        if sessionCoordinator.sessionStartTime == nil {
                            sessionCoordinator.startSession()
                        } else if sessionCoordinator.isRunning {
                            sessionCoordinator.pauseSession()
                        } else {
                            sessionCoordinator.resumeSession()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.mindfulPrimary)
                                .frame(width: 80, height: 80)
                                .shadow(color: .mindfulPrimary.opacity(0.3), radius: 8, x: 0, y: 4)

                            Image(systemName: sessionCoordinator.playButtonIcon)
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(PlayButtonStyle())
                }
            }
            .frame(height: 100) // Fixed height container for primary button

            // Secondary button area - always fixed height, content appears/disappears
            VStack {
                if sessionCoordinator.sessionStartTime != nil && !sessionCoordinator.isRunning && !sessionCoordinator.sessionCompleted {
                    // Finish and Discard buttons (only visible when paused)
                    HStack(spacing: 0) {
                        Spacer()

                        // Discard button
                        Button(action: { sessionCoordinator.discardSession() }) {
                            Text("Discard")
                                .font(.headline)
                                .foregroundColor(.mindfulTextSecondary)
                        }
                        .frame(minWidth: 80)

                        Spacer()

                        // Separator
                        Text("|")
                            .font(.headline)
                            .foregroundColor(.mindfulTextSecondary.opacity(0.5))

                        Spacer()

                        // Finish button
                        Button(action: { sessionCoordinator.finishSession(dataCoordinator: dataCoordinator) }) {
                            Text("Finish")
                                .font(.headline)
                                .foregroundColor(.mindfulPrimary)
                                .fontWeight(.semibold)
                        }
                        .frame(minWidth: 80)

                        Spacer()
                    }
                    .padding(.top, MindfulSpacing.section)
                } else {
                    // Empty space to maintain layout consistency
                    Color.clear
                }
            }
            .frame(height: 80) // Fixed height container for secondary buttons
        }
    }

    // MARK: - Helper Functions

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

struct SessionOptionRow: View {
    let icon: String
    let title: String
    let value: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: MindfulSpacing.standard) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.mindfulPrimary)
                    .frame(width: 24, height: 24)

                // Title
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.mindfulTextPrimary)
                    .multilineTextAlignment(.leading)

                Spacer()

                // Value
                Text(value)
                    .font(.body)
                    .foregroundColor(.mindfulTextSecondary)
                    .multilineTextAlignment(.trailing)

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.mindfulTextSecondary.opacity(0.6))
            }
            .padding(.horizontal, MindfulSpacing.small)
            .padding(.vertical, 12)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SessionTypeCard: View {
    let type: SessionType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: getSessionIcon(for: type))
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .mindfulPrimary)

                Text(type.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .mindfulTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.mindfulPrimary : Color.mindfulBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
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

struct PlayButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct DurationSelectionView: View {
    @Binding var selectedHours: Int
    @Binding var selectedMinutes: Int
    @Binding var selectedWarmupSeconds: Int
    let onSave: () -> Void
    let onCancel: () -> Void

    private let warmupPresets = [0, 5, 10, 15, 30, 45, 60, 120, 180, 240, 300] // 0s to 5m

    private var isDurationValid: Bool {
        selectedHours > 0 || selectedMinutes > 0
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: MindfulSpacing.small) {
                    headerSection
                    durationSection
                    warmupSection
                }
                .padding()
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
            .foregroundColor(isDurationValid ? .mindfulPrimary : .mindfulTextSecondary)
            .font(.body)
            .fontWeight(.semibold)
            .disabled(!isDurationValid)
            .opacity(isDurationValid ? 1.0 : 0.6)
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

struct SessionTypeSelectionView: View {
    @Binding var selectedType: SessionType
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: MindfulSpacing.standard) {
                    headerSection
                    sessionTypeGrid
                    Spacer(minLength: MindfulSpacing.standard)
                }
                .padding(.horizontal, MindfulSpacing.small)
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
                Text("Session Type")
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

    private var sessionTypeGrid: some View {
        MindfulCard {
            VStack(alignment: .leading, spacing: MindfulSpacing.standard) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: MindfulSpacing.small), count: 3), spacing: MindfulSpacing.small) {
                    ForEach(SessionType.allCases, id: \.self) { type in
                        SessionTypeCard(
                            type: type,
                            isSelected: selectedType == type,
                            onTap: {
                                selectedType = type
                            }
                        )
                    }
                }
            }
        }
    }
}