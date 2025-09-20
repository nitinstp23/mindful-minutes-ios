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
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if let coordinator = dataCoordinator {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                                .foregroundColor(.mindfulTextPrimary)
                        }
                        .tag(0)

                    ProgressScreenView()
                        .tabItem {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("Progress")
                                .foregroundColor(.mindfulTextPrimary)
                        }
                        .tag(1)

                    // New Session Tab (Center)
                    SessionTimerView()
                        .tabItem {
                            Image(systemName: "plus.circle.fill")
                            Text("New Session")
                                .foregroundColor(.mindfulTextPrimary)
                        }
                        .tag(2)

                    SessionsView()
                        .tabItem {
                            Image(systemName: "figure.mind.and.body")
                            Text("Sessions")
                                .foregroundColor(.mindfulTextPrimary)
                        }
                        .tag(3)

                    SettingsView()
                        .tabItem {
                            Image(systemName: "gear")
                            Text("Settings")
                                .foregroundColor(.mindfulTextPrimary)
                        }
                        .tag(4)
                }
                .environment(coordinator)
                .accentColor(.mindfulPrimary)
                .background(Color.mindfulBackground.ignoresSafeArea())
            } else {
                ProgressView("Loading...")
                    .foregroundColor(.mindfulTextPrimary)
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
