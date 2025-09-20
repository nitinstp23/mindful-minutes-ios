import SwiftUI
import SwiftData
import Foundation

struct SessionTimerView: View {
    @Environment(MindfulDataCoordinator.self) private var dataCoordinator
    @Bindable var sessionCoordinator: SessionCoordinator

    private let warmupPresets = [0, 5, 10, 15, 30, 45, 60, 90, 120, 180, 240, 300] // 0s to 5m

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
        .onDisappear {
            // Stop timer if view disappears
        }
    }

    private var headerSection: some View {
        VStack(spacing: MindfulSpacing.small) {
            if !sessionCoordinator.isRunning && sessionCoordinator.sessionStartTime == nil {
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
        .padding(.horizontal, MindfulSpacing.standard)
    }

    private var setupSection: some View {
        VStack(spacing: MindfulSpacing.section) {
            durationSection
            sessionTypeSection
        }
    }

    private var durationSection: some View {
        MindfulCard {
            VStack(alignment: .leading, spacing: MindfulSpacing.standard) {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.mindfulPrimary)
                    Text("Duration")
                        .font(.headline)
                        .foregroundColor(.mindfulTextPrimary)
                    Spacer()
                }

                Button(action: {
                    sessionCoordinator.showingDurationSelection = true
                }) {
                    HStack {
                        Text(sessionCoordinator.formatTotalDuration())
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.mindfulTextPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.mindfulTextSecondary)
                    }
                    .padding()
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private var sessionTypeSection: some View {
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

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: MindfulSpacing.small), count: 3), spacing: MindfulSpacing.small) {
                    ForEach(SessionType.allCases.prefix(6), id: \.self) { type in
                        SessionTypeCard(
                            type: type,
                            isSelected: sessionCoordinator.selectedType == type,
                            onTap: {
                                sessionCoordinator.selectedType = type
                            }
                        )
                    }
                }
            }
        }
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
                    MindfulButton(
                        title: "Continue",
                        action: { sessionCoordinator.continueAfterSession() },
                        style: .primary
                    )
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
                    HStack(spacing: MindfulSpacing.section) {
                        // Discard button (borderless link style)
                        Button(action: { sessionCoordinator.discardSession() }) {
                            Text("Discard")
                                .font(.headline)
                                .foregroundColor(.mindfulTextSecondary)
                        }

                        // Finish button
                        MindfulButton(
                            title: "Finish",
                            action: { sessionCoordinator.finishSession(dataCoordinator: dataCoordinator) },
                            style: .primary
                        )
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