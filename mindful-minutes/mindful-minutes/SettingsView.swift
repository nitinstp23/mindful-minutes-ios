import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Profile") {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.mindfulPrimary)
                        VStack(alignment: .leading) {
                            Text("Nitin Misra")
                                .font(.headline)
                            Text("nitin@example.com")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Preferences") {
                    SettingsRow(icon: "bell.fill", title: "Notifications", subtitle: "Daily reminders")
                    SettingsRow(icon: "moon.fill", title: "Dark Mode", subtitle: "System")
                    SettingsRow(icon: "textformat.size", title: "Text Size", subtitle: "Medium")
                }
                
                Section("Data") {
                    SettingsRow(icon: "square.and.arrow.up", title: "Export Data", subtitle: "Download your sessions")
                    SettingsRow(icon: "icloud.fill", title: "Sync", subtitle: "iCloud backup")
                }
                
                Section("Support") {
                    SettingsRow(icon: "questionmark.circle.fill", title: "Help & FAQ", subtitle: nil)
                    SettingsRow(icon: "envelope.fill", title: "Contact Support", subtitle: nil)
                    SettingsRow(icon: "star.fill", title: "Rate App", subtitle: nil)
                }
                
                Section("About") {
                    SettingsRow(icon: "info.circle.fill", title: "App Version", subtitle: "1.0.0")
                    SettingsRow(icon: "doc.text.fill", title: "Privacy Policy", subtitle: nil)
                    SettingsRow(icon: "doc.text.fill", title: "Terms of Service", subtitle: nil)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.mindfulPrimary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    SettingsView()
}