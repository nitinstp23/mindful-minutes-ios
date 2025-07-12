import SwiftUI

struct SessionGroup {
    let date: Date
    let sessions: [SessionItem]
}

struct SessionRow: View {
    let session: SessionItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: MindfulSpacing.standard) {
                VStack {
                    Image(systemName: sessionTypeIcon(session.type))
                        .font(.title2)
                        .foregroundColor(.mindfulPrimary)
                        .frame(width: 40, height: 40)
                        .background(Color.mindfulPrimary.opacity(0.1))
                        .cornerRadius(8)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(session.type)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Spacer()

                        Text(formatDuration(session.duration))
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

    private func sessionTypeIcon(_ type: String) -> String {
        switch type.lowercased() {
        case "mindfulness": return "figure.mind.and.body"
        case "breathing": return "lungs.fill"
        case "body scan": return "figure.walk"
        case "loving kindness": return "heart.fill"
        case "focus": return "target"
        default: return "figure.mind.and.body"
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        return "\(minutes) min"
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

struct SessionItem: Identifiable {
    let id: Int
    let date: Date
    let duration: Int
    let type: String
    let notes: String
    let tags: [String]
    let sessionNumber: Int
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