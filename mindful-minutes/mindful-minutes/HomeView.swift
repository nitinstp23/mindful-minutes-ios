import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: MindfulSpacing.section) {
                    VStack(spacing: 8) {
                        Text("Good morning, Nitin")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Ready for your mindful moment?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    MindfulCard {
                        VStack(spacing: 16) {
                            Text("Current Streak")
                                .font(.headline)
                            
                            Text("7")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.mindfulPrimary)
                            
                            Text("days")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    MindfulButton(title: "Start Session", action: {}, style: .primary)
                    
                    MindfulCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Today's Progress")
                                .font(.headline)
                            
                            HStack {
                                Text("Minutes meditated:")
                                Spacer()
                                Text("15 min")
                                    .fontWeight(.medium)
                                    .foregroundColor(.mindfulPrimary)
                            }
                            
                            HStack {
                                Text("Sessions completed:")
                                Spacer()
                                Text("2")
                                    .fontWeight(.medium)
                                    .foregroundColor(.mindfulPrimary)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Mindful Minutes")
        }
    }
}

#Preview {
    HomeView()
}