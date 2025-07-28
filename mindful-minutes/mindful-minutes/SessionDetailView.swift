import SwiftUI

struct SessionDetailView: View {
    let session: MeditationSession
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: MindfulSpacing.section) {
                    headerSection
                    statsSection
                    if !session.notes.isEmpty {
                        notesSection
                    }
                    actionsSection

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Session Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        // TODO: Navigate to edit session
                    }
                    .foregroundColor(.mindfulPrimary)
                }
            }
            .background(Color.mindfulBackground.ignoresSafeArea())
        }
        .alert("Delete Session", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                // TODO: Delete session
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this session? This action cannot be undone.")
        }
    }

    private var headerSection: some View {
        MindfulCard {
            VStack(spacing: MindfulSpacing.standard) {
                HStack {
                    Image(systemName: session.sessionTypeIcon)
                        .font(.title)
                        .foregroundColor(.mindfulPrimary)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.type.rawValue)
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text(session.date, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.mindfulTextSecondary)

                        Text(session.date, style: .time)
                            .font(.caption)
                            .foregroundColor(.mindfulTextSecondary)
                    }

                    Spacer()
                }

                Divider()

                HStack {
                    VStack {
                        Text("Duration")
                            .font(.caption)
                            .foregroundColor(.mindfulTextSecondary)
                        Text(session.formattedDuration)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.mindfulPrimary)
                    }
                    .frame(maxWidth: .infinity)

                    Divider()
                        .frame(height: 40)

                    VStack {
                        Text("Session #")
                            .font(.caption)
                            .foregroundColor(.mindfulTextSecondary)
                        Text("\(session.sessionNumber ?? 0)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.mindfulSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private var statsSection: some View {
        MindfulCard {
            VStack(alignment: .leading, spacing: MindfulSpacing.standard) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.mindfulPrimary)
                    Text("Session Statistics")
                        .font(.headline)
                    Spacer()
                }

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: MindfulSpacing.standard) {
                    statItem(title: "Heart Rate", value: "72 bpm", icon: "heart.fill")
                    statItem(title: "Focus Score", value: "85%", icon: "target")
                    statItem(title: "Breathing", value: "12/min", icon: "lungs.fill")
                    statItem(title: "Calm Level", value: "High", icon: "leaf.fill")
                }

                if !session.tags.isEmpty {
                    VStack(alignment: .leading, spacing: MindfulSpacing.small) {
                        Text("Tags")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 80))
                        ], spacing: 8) {
                            ForEach(session.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.mindfulPrimary.opacity(0.1))
                                    .foregroundColor(.mindfulPrimary)
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
        }
    }

    private var notesSection: some View {
        MindfulCard {
            VStack(alignment: .leading, spacing: MindfulSpacing.standard) {
                HStack {
                    Image(systemName: "note.text")
                        .foregroundColor(.mindfulPrimary)
                    Text("Session Notes")
                        .font(.headline)
                    Spacer()
                }

                Text(session.notes)
                    .font(.body)
                    .foregroundColor(.mindfulTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: MindfulSpacing.standard) {
            MindfulButton(title: "Repeat Session", action: repeatSession, style: .primary)

            HStack(spacing: MindfulSpacing.standard) {
                MindfulButton(title: "Share", action: shareSession, style: .secondary)

                Button("Delete") {
                    showDeleteAlert = true
                }
                .font(.headline)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.red, lineWidth: 1)
                )
            }
        }
    }

    private func statItem(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.mindfulSecondary)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.mindfulPrimary)

            Text(title)
                .font(.caption)
                .foregroundColor(.mindfulTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, MindfulSpacing.small)
    }

    private func repeatSession() {
        // TODO: Start a new session with same settings
    }

    private func shareSession() {
        // TODO: Share session details
    }
}

#Preview {
    let sampleSession = MeditationSession(
        date: Date(),
        duration: 900,
        type: .mindfulness,
        notes: "Today's session was particularly peaceful. I focused on breath awareness and managed to " +
               "maintain concentration for most of the session. Feeling much more centered and ready for the day ahead.",
        tags: ["morning", "peaceful", "focused"],
        sessionNumber: 42
    )

    ContentView()
        .modelContainer(for: [MeditationSession.self, UserProfile.self, Milestone.self], inMemory: true)
}
