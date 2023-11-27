//
//  SettingsView.swift
//  FitnessHealth
//
//  Created by Andrei Terentiev on 16.08.23.
//

import Foundation
import SwiftUI
import Factory

struct SettingsView: View {
    @ObservedObject private var appSettingsrepo: AppSettingsRepository = Container.shared.appSettingsRepo()
    
    
    var body: some View {
        NavigationView {
               Form {
                   Section(header: Text("Preferences")) {
                       Picker("Dark Mode", selection: $appSettingsrepo.darkModeSetting) {
                           Text("System")
                               .tag(AppSettingsRepository.DarkModeSetting.systemSetting)
                           Text("Dark")
                               .tag(AppSettingsRepository.DarkModeSetting.alwaysDark)
                           Text("Light")
                               .tag(AppSettingsRepository.DarkModeSetting.alwaysLight)
                       }
                       
                       Picker("Temperature", selection: $appSettingsrepo.temperatureSetting) {
                           Text("System")
                               .tag(AppSettingsRepository.TemperatureSetting.systemSetting)
                           Text("Fahrenheit")
                               .tag(AppSettingsRepository.TemperatureSetting.alwaysF)
                           Text("Celsius")
                               .tag(AppSettingsRepository.TemperatureSetting.alwaysC)
                       }
                       
                       Picker("Distance", selection: $appSettingsrepo.distanceSetting) {
                           Text("System")
                               .tag(AppSettingsRepository.DistanceSetting.systemSetting)
                           Text("Miles")
                               .tag(AppSettingsRepository.DistanceSetting.alwayMi)
                           Text("Kilometers")
                               .tag(AppSettingsRepository.DistanceSetting.alwayKm)
                       }
                   }
               }
           }
    }
}
