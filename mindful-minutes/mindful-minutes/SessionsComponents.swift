import SwiftUI

struct SessionGroup {
    let date: Date
    let sessions: [MeditationSession]
}

struct SessionRow: View {
    let session: MeditationSession

    var body: some View {
        HStack(spacing: MindfulSpacing.standard) {
            VStack {
                Image(systemName: session.sessionTypeIcon)
                    .font(.title2)
                    .foregroundColor(.mindfulPrimary)
                    .frame(width: 40, height: 40)
                    .background(Color.mindfulPrimary.opacity(0.1))
                    .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(session.type.rawValue)
                        .font(.headline)
                        .foregroundColor(.mindfulTextPrimary)

                    Spacer()

                    Text(session.formattedDuration)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.mindfulPrimary)
                }

                HStack {
                    Text(session.date, style: .time)
                        .font(.subheadline)
                        .foregroundColor(.mindfulTextSecondary)


                    Spacer()

                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(title)
                if count > 0 {
                    Text("(\(count))")
                        .font(.caption2)
                }
            }
            .font(.caption)
            .fontWeight(isSelected ? .semibold : .regular)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.mindfulPrimary : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .mindfulTextPrimary)
            .cornerRadius(16)
        }
    }
}

struct NewSessionView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack {
                Text("New Session Screen")
                    .font(.title)
                Text("Session creation form coming soon")
                    .foregroundColor(.mindfulTextSecondary)
            }
            .navigationTitle("New Session")
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
