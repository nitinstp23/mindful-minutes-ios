//
//  mindful_minutesApp.swift
//  mindful-minutes
//
//  Created by Nitin Misra on 12/7/2568 BE.
//

import SwiftUI
import SwiftData

@main
struct MindfulMinutesApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MeditationSession.self,
            UserProfile.self,
            Milestone.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    configureAppearance()
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func configureAppearance() {
        // Configure navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(Color.mindfulBackground)
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        
        // Configure tab bar appearance  
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.mindfulBackground)
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Configure segmented control appearance
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.mindfulPrimary)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        UISegmentedControl.appearance().backgroundColor = UIColor(Color.mindfulBackground)
        
        // Configure other UI elements
        UITableView.appearance().backgroundColor = UIColor(Color.mindfulBackground)
        UIScrollView.appearance().backgroundColor = UIColor(Color.mindfulBackground)
    }
}
