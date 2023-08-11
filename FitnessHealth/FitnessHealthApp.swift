//
//  FitnessHealthApp.swift
//  FitnessHealth
//
//  Created by Andrei Terentiev on 11.08.23.
//

import SwiftUI
import SwiftData

@main
struct FitnessHealthApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Item.self)
    }
}
