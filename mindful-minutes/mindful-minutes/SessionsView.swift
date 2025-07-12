import SwiftUI

struct SessionsView: View {
    let mockSessions = [
        MockSession(date: Date(), duration: 900, type: "Mindfulness"),
        MockSession(date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), duration: 600, type: "Breathing"),
        MockSession(date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), duration: 1200, type: "Body Scan"),
        MockSession(date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(), duration: 480, type: "Mindfulness")
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: {}) {
                        Text("New Session")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.mindfulPrimary)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.mindfulPrimary)
                    }
                }
                .padding()
                
                List(mockSessions) { session in
                    SessionRow(session: session)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Sessions")
        }
    }
}

struct SessionRow: View {
    let session: MockSession
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.type)
                    .font(.headline)
                
                Text(session.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatDuration(session.duration))
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text("minutes")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        return "\(minutes)"
    }
}

struct MockSession: Identifiable {
    let id = UUID()
    let date: Date
    let duration: Int
    let type: String
}

#Preview {
    SessionsView()
}