import SwiftUI

struct SessionGroup {
    let date: Date
    let sessions: [MeditationSession]
}

struct SessionRow: View {
    let session: MeditationSession
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
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
                            .foregroundColor(.primary)

                        Spacer()

                        Text(session.formattedDuration)
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.mindfulPrimary)
                    }

                    HStack {
                        Text(session.date, style: .time)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        if !session.notes.isEmpty {
                            Image(systemName: "note.text")
                                .font(.caption)
                                .foregroundColor(.mindfulSecondary)
                        }

                        Spacer()

                        if !session.tags.isEmpty {
                            Text(session.tags.first ?? "")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.mindfulPrimary.opacity(0.1))
                                .foregroundColor(.mindfulPrimary)
                                .cornerRadius(4)
                        }
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 4)
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
                if !isEmpty {
                    Text("(\(count))")
                        .font(.caption2)
                }
            }
            .font(.caption)
            .fontWeight(isSelected ? .semibold : .regular)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.mindfulPrimary : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
    }

    private var isEmpty: Bool {
        count == 0
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
                    .foregroundColor(.secondary)
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
