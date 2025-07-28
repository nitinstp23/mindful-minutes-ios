import SwiftUI
import UserNotifications

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var reminderTime = Date()
    @State private var selectedTheme: AppTheme = .system
    @State private var selectedTextSize: TextSize = .medium
    @State private var weeklyGoal = 150
    @State private var soundEnabled = true
    @State private var hapticFeedbackEnabled = true
    @State private var showingProfileEdit = false
    @State private var showingDataExport = false

    enum AppTheme: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"
    }

    enum TextSize: String, CaseIterable {
        case small = "Small"
        case medium = "Medium"
        case large = "Large"
        case extraLarge = "Extra Large"
    }

    var body: some View {
        NavigationView {
            List {
                profileSection
                goalsSection
                preferencesSection
                notificationsSection
                accessibilitySection
                dataSection
                supportSection
                aboutSection

                Section {
                    MindfulFooter()
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }
            .navigationTitle("Settings")
            .background(Color.mindfulBackground.ignoresSafeArea())
        }
        .sheet(isPresented: $showingProfileEdit) {
            ProfileEditView()
        }
        .sheet(isPresented: $showingDataExport) {
            DataExportView()
        }
    }

    private var profileSection: some View {
        Section("Profile") {
            Button(action: { showingProfileEdit = true }) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(.mindfulPrimary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Nitin Misra")
                            .font(.headline)
                            .foregroundColor(.mindfulTextPrimary)

                        Text("nitin@example.com")
                            .font(.subheadline)
                            .foregroundColor(.mindfulTextSecondary)

                        Text("Member since December 2024")
                            .font(.caption)
                            .foregroundColor(.mindfulPrimary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.mindfulTextSecondary)
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private var goalsSection: some View {
        Section("Goals & Targets") {
            HStack {
                SettingsIcon(icon: "target", color: .mindfulPrimary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Weekly Goal")
                        .font(.body)
                    Text("\(weeklyGoal) minutes per week")
                        .font(.subheadline)
                        .foregroundColor(.mindfulTextSecondary)
                }

                Spacer()

                Stepper("", value: $weeklyGoal, in: 50...500, step: 25)
                    .labelsHidden()
            }

            NavigationLink(destination: EmptyView()) {
                HStack {
                    SettingsIcon(icon: "calendar.badge.clock", color: .mindfulSecondary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Session Reminders")
                            .font(.body)
                        Text("Set custom schedules")
                            .font(.subheadline)
                            .foregroundColor(.mindfulTextSecondary)
                    }
                }
            }
        }
    }

    private var preferencesSection: some View {
        Section("Preferences") {
            HStack {
                SettingsIcon(icon: "paintbrush.fill", color: .mindfulPrimary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Appearance")
                        .font(.body)
                    Text(selectedTheme.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.mindfulTextSecondary)
                }

                Spacer()

                Picker("Theme", selection: $selectedTheme) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }

            HStack {
                SettingsIcon(icon: "textformat.size", color: .mindfulSecondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Text Size")
                        .font(.body)
                    Text(selectedTextSize.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.mindfulTextSecondary)
                }

                Spacer()

                Picker("Text Size", selection: $selectedTextSize) {
                    ForEach(TextSize.allCases, id: \.self) { size in
                        Text(size.rawValue).tag(size)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }

            HStack {
                SettingsIcon(icon: "speaker.wave.2.fill", color: .blue)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Sound Effects")
                        .font(.body)
                    Text("Bell chimes and ambient sounds")
                        .font(.subheadline)
                        .foregroundColor(.mindfulTextSecondary)
                }

                Spacer()

                Toggle("", isOn: $soundEnabled)
                    .labelsHidden()
            }

            HStack {
                SettingsIcon(icon: "iphone.radiowaves.left.and.right", color: .purple)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Haptic Feedback")
                        .font(.body)
                    Text("Vibration for interactions")
                        .font(.subheadline)
                        .foregroundColor(.mindfulTextSecondary)
                }

                Spacer()

                Toggle("", isOn: $hapticFeedbackEnabled)
                    .labelsHidden()
            }
        }
    }

    private var notificationsSection: some View {
        Section("Notifications") {
            HStack {
                SettingsIcon(icon: "bell.fill", color: .orange)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Reminders")
                        .font(.body)
                    Text(notificationsEnabled ? "Enabled" : "Disabled")
                        .font(.subheadline)
                        .foregroundColor(.mindfulTextSecondary)
                }

                Spacer()

                Toggle("", isOn: $notificationsEnabled)
                    .labelsHidden()
            }

            if notificationsEnabled {
                HStack {
                    SettingsIcon(icon: "clock.fill", color: .mindfulPrimary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Reminder Time")
                            .font(.body)
                        Text(reminderTime, style: .time)
                            .font(.subheadline)
                            .foregroundColor(.mindfulTextSecondary)
                    }

                    Spacer()

                    DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
            }

            NavigationLink(destination: EmptyView()) {
                HStack {
                    SettingsIcon(icon: "app.badge.fill", color: .red)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Notification Settings")
                            .font(.body)
                        Text("Customize all notifications")
                            .font(.subheadline)
                            .foregroundColor(.mindfulTextSecondary)
                    }
                }
            }
        }
    }

    private var accessibilitySection: some View {
        Section("Accessibility") {
            NavigationLink(destination: EmptyView()) {
                HStack {
                    SettingsIcon(icon: "accessibility", color: .mindfulPrimary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Accessibility Options")
                            .font(.body)
                        Text("VoiceOver, high contrast")
                            .font(.subheadline)
                            .foregroundColor(.mindfulTextSecondary)
                    }
                }
            }

            NavigationLink(destination: EmptyView()) {
                HStack {
                    SettingsIcon(icon: "eye.fill", color: .blue)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Reduce Motion")
                            .font(.body)
                        Text("Minimize animations")
                            .font(.subheadline)
                            .foregroundColor(.mindfulTextSecondary)
                    }
                }
            }
        }
    }

    private var dataSection: some View {
        Section("Data & Privacy") {
            Button(action: { showingDataExport = true }) {
                HStack {
                    SettingsIcon(icon: "square.and.arrow.up", color: .mindfulSecondary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Export Data")
                            .font(.body)
                            .foregroundColor(.mindfulTextPrimary)
                        Text("Download your meditation data")
                            .font(.subheadline)
                            .foregroundColor(.mindfulTextSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.mindfulTextSecondary)
                }
            }
            .buttonStyle(PlainButtonStyle())

            NavigationLink(destination: EmptyView()) {
                HStack {
                    SettingsIcon(icon: "icloud.fill", color: .blue)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("iCloud Sync")
                            .font(.body)
                        Text("Backup and sync across devices")
                            .font(.subheadline)
                            .foregroundColor(.mindfulTextSecondary)
                    }
                }
            }

            NavigationLink(destination: EmptyView()) {
                HStack {
                    SettingsIcon(icon: "hand.raised.fill", color: .purple)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Privacy Settings")
                            .font(.body)
                        Text("Data usage and permissions")
                            .font(.subheadline)
                            .foregroundColor(.mindfulTextSecondary)
                    }
                }
            }
        }
    }

    private var supportSection: some View {
        Section("Support") {
            NavigationLink(destination: EmptyView()) {
                HStack {
                    SettingsIcon(icon: "questionmark.circle.fill", color: .mindfulPrimary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Help & FAQ")
                            .font(.body)
                        Text("Common questions and answers")
                            .font(.subheadline)
                            .foregroundColor(.mindfulTextSecondary)
                    }
                }
            }

            NavigationLink(destination: EmptyView()) {
                HStack {
                    SettingsIcon(icon: "envelope.fill", color: .blue)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Contact Support")
                            .font(.body)
                        Text("Get help from our team")
                            .font(.subheadline)
                            .foregroundColor(.mindfulTextSecondary)
                    }
                }
            }

            Button(action: rateApp) {
                HStack {
                    SettingsIcon(icon: "star.fill", color: .yellow)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Rate Mindful Minutes")
                            .font(.body)
                            .foregroundColor(.mindfulTextPrimary)
                        Text("Share your experience")
                            .font(.subheadline)
                            .foregroundColor(.mindfulTextSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.mindfulTextSecondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                SettingsIcon(icon: "info.circle.fill", color: .mindfulPrimary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("App Version")
                        .font(.body)
                    Text("1.0.0 (Build 42)")
                        .font(.subheadline)
                        .foregroundColor(.mindfulTextSecondary)
                }
            }

            NavigationLink(destination: EmptyView()) {
                HStack {
                    SettingsIcon(icon: "doc.text.fill", color: .gray)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Privacy Policy")
                            .font(.body)
                        Text("How we protect your data")
                            .font(.subheadline)
                            .foregroundColor(.mindfulTextSecondary)
                    }
                }
            }

            NavigationLink(destination: EmptyView()) {
                HStack {
                    SettingsIcon(icon: "doc.text.fill", color: .gray)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Terms of Service")
                            .font(.body)
                        Text("Usage terms and conditions")
                            .font(.subheadline)
                            .foregroundColor(.mindfulTextSecondary)
                    }
                }
            }

            NavigationLink(destination: EmptyView()) {
                HStack {
                    SettingsIcon(icon: "heart.fill", color: .red)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Acknowledgments")
                            .font(.body)
                        Text("Open source libraries and credits")
                            .font(.subheadline)
                            .foregroundColor(.mindfulTextSecondary)
                    }
                }
            }
        }
    }

    private func rateApp() {
        // TODO: Open App Store rating
    }
}

#Preview {
    SettingsView()
}
