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
            VStack(spacing: 0) {
                headerSection
                
                List {
                    profileSection
                    notificationsSection
                    supportSection
                    aboutSection
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .background(Color.mindfulBackground.ignoresSafeArea())
            }
            .navigationBarHidden(true)
            .background(Color.mindfulBackground.ignoresSafeArea())
        }
        .sheet(isPresented: $showingProfileEdit) {
            ProfileEditView()
        }
        .sheet(isPresented: $showingDataExport) {
            DataExportView()
        }
    }

    private var headerSection: some View {
        VStack(spacing: MindfulSpacing.small) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.mindfulTextPrimary)

            Text("Customize your meditation experience")
                .font(.subheadline)
                .foregroundColor(.mindfulTextSecondary)
        }
        .padding(.top)
        .padding(.horizontal)
        .padding(.bottom, MindfulSpacing.small)
    }

    private var profileSection: some View {
        Section(header: Text("Profile").foregroundColor(.mindfulTextPrimary)) {
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
            .listRowBackground(Color.clear)
        }
    }

    private var notificationsSection: some View {
        Section(header: Text("Notifications").foregroundColor(.mindfulTextPrimary)) {
            HStack {
                SettingsIcon(icon: "bell.fill", color: .orange)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Reminders")
                        .font(.body)
                        .foregroundColor(.mindfulTextPrimary)
                    Text(notificationsEnabled ? "Enabled" : "Disabled")
                        .font(.subheadline)
                        .foregroundColor(.mindfulTextSecondary)
                }

                Spacer()

                Toggle("", isOn: $notificationsEnabled)
                    .labelsHidden()
            }
            .listRowBackground(Color.clear)

            if notificationsEnabled {
                HStack {
                    SettingsIcon(icon: "clock.fill", color: .mindfulPrimary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Reminder Time")
                            .font(.body)
                            .foregroundColor(.mindfulTextPrimary)
                        Text(reminderTime, style: .time)
                            .font(.subheadline)
                            .foregroundColor(.mindfulTextSecondary)
                    }

                    Spacer()

                    DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                .listRowBackground(Color.clear)
            }
        }
    }

    private var supportSection: some View {
        Section(header: Text("Support").foregroundColor(.mindfulTextPrimary)) {
            NavigationLink(destination: EmptyView()) {
                HStack {
                    SettingsIcon(icon: "questionmark.circle.fill", color: .mindfulPrimary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Help & FAQ")
                            .font(.body)
                            .foregroundColor(.mindfulTextPrimary)
                        Text("Common questions and answers")
                            .font(.subheadline)
                            .foregroundColor(.mindfulTextSecondary)
                    }
                }
            }
            .listRowBackground(Color.clear)
        }
    }

    private var aboutSection: some View {
        Section(header: Text("About").foregroundColor(.mindfulTextPrimary)) {
            HStack {
                SettingsIcon(icon: "info.circle.fill", color: .mindfulPrimary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("App Version")
                        .font(.body)
                        .foregroundColor(.mindfulTextPrimary)
                    Text("1.0.0 (Build 42)")
                        .font(.subheadline)
                        .foregroundColor(.mindfulTextSecondary)
                }
            }
            .listRowBackground(Color.clear)

            NavigationLink(destination: EmptyView()) {
                HStack {
                    SettingsIcon(icon: "doc.text.fill", color: .gray)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Privacy Policy")
                            .font(.body)
                            .foregroundColor(.mindfulTextPrimary)
                        Text("How we protect your data")
                            .font(.subheadline)
                            .foregroundColor(.mindfulTextSecondary)
                    }
                }
            }
            .listRowBackground(Color.clear)

            NavigationLink(destination: EmptyView()) {
                HStack {
                    SettingsIcon(icon: "doc.text.fill", color: .gray)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Terms of Service")
                            .font(.body)
                            .foregroundColor(.mindfulTextPrimary)
                        Text("Usage terms and conditions")
                            .font(.subheadline)
                            .foregroundColor(.mindfulTextSecondary)
                    }
                }
            }
            .listRowBackground(Color.clear)

            NavigationLink(destination: EmptyView()) {
                HStack {
                    SettingsIcon(icon: "heart.fill", color: .red)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Acknowledgments")
                            .font(.body)
                            .foregroundColor(.mindfulTextPrimary)
                        Text("Open source libraries and credits")
                            .font(.subheadline)
                            .foregroundColor(.mindfulTextSecondary)
                    }
                }
            }
            .listRowBackground(Color.clear)
        }
    }
}

#Preview {
    SettingsView()
}
