//
//  ContentView.swift
//  mindful-minutes
//
//  Created by Nitin Misra on 12/7/2568 BE.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var dataCoordinator: MindfulDataCoordinator?

    var body: some View {
        Group {
            if let coordinator = dataCoordinator {
                TabView {
                    HomeView()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }

                    ProgressScreenView()
                        .tabItem {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("Progress")
                        }

                    SessionsView()
                        .tabItem {
                            Image(systemName: "figure.mind.and.body")
                            Text("Sessions")
                        }

                    SettingsView()
                        .tabItem {
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                }
                .environment(coordinator)
                .accentColor(.mindfulPrimary)
                .background(Color.mindfulBackground.ignoresSafeArea())
            } else {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.mindfulBackground.ignoresSafeArea())
            }
        }
        .onAppear {
            if dataCoordinator == nil {
                dataCoordinator = MindfulDataCoordinator(modelContext: modelContext)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [MeditationSession.self, UserProfile.self, Milestone.self], inMemory: true)
}
