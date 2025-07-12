//
//  ContentView.swift
//  mindful-minutes
//
//  Created by Nitin Misra on 12/7/2568 BE.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
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
        .accentColor(.mindfulPrimary)
        .background(Color.mindfulBackground.ignoresSafeArea())
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
