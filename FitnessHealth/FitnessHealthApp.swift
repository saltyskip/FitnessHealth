//
//  FitnessHealthApp.swift
//  FitnessHealth
//
//  Created by Andrei Terentiev on 11.08.23.
//

import SwiftUI
import DesignSystem
import Factory

@main
struct FitnessHealthApp: App {
    @ObservedObject private var appSettingsrepo: AppSettingsRepository = Container.shared.appSettingsRepo()

    var healthVM = HealthKitViewModel()

    init() {
        DesignSystem.registerFonts()
        
        //remove line under navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                EnableHealthKitView()
                    .environmentObject(healthVM)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                Text("Hello World")
                    .tabItem {
                        Label("Health", systemImage: "heart")
                    }
                RunListView()
                    .tabItem {
                        Label("Fitness", systemImage: "figure.run")
                    }
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            .preferredColorScheme(appSettingsrepo.darkModeSetting.colorScheme)
        }
    }
}

