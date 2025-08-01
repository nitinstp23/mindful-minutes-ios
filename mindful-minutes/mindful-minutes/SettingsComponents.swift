import SwiftUI

struct SettingsIcon: View {
    let icon: String
    let color: Color

    var body: some View {
        Image(systemName: icon)
            .font(.title3)
            .foregroundColor(.white)
            .frame(width: 28, height: 28)
            .background(color)
            .cornerRadius(6)
    }
}

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack {
                Text("Profile Edit Screen")
                    .font(.title)
                    .foregroundColor(.mindfulTextPrimary)
                Text("Profile editing form coming soon")
                    .foregroundColor(.mindfulTextSecondary)
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DataExportView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack {
                Text("Data Export Screen")
                    .font(.title)
                    .foregroundColor(.mindfulTextPrimary)
                Text("Data export options coming soon")
                    .foregroundColor(.mindfulTextSecondary)
            }
            .navigationTitle("Export Data")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
