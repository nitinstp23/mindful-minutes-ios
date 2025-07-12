import SwiftUI

struct ProgressView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: MindfulSpacing.section) {
                    VStack(spacing: 16) {
                        Text("Streaks")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 20) {
                            MindfulCard {
                                VStack {
                                    Text("Current")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("7")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.mindfulPrimary)
                                    Text("days")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            
                            MindfulCard {
                                VStack {
                                    Text("Longest")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("14")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.mindfulSecondary)
                                    Text("days")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    
                    VStack(spacing: 16) {
                        Text("Weekly Progress")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        MindfulCard {
                            VStack {
                                Text("Chart placeholder")
                                    .foregroundColor(.secondary)
                                    .frame(height: 200)
                                
                                Text("125 minutes this week")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.mindfulPrimary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                    VStack(spacing: 16) {
                        Text("Monthly Overview")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        MindfulCard {
                            VStack {
                                Text("Calendar placeholder")
                                    .foregroundColor(.secondary)
                                    .frame(height: 150)
                                
                                Text("18 sessions this month")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.mindfulPrimary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Progress")
        }
    }
}

#Preview {
    ProgressView()
}