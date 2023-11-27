//
//  AppSettingsRepository.swift
//  FitnessHealth
//
//  Created by Andrei Terentiev on 16.08.23.
//

import Foundation
import Foil
import SwiftUI
import HealthKit

final class AppSettingsRepository: NSObject, ObservableObject {
    @WrappedDefault(key: "darkModeSetting")
    var darkModeSetting: DarkModeSetting = .systemSetting {
        willSet {
            objectWillChange.send()
        }
    }
    
    
    @WrappedDefault(key: "temperatureSetting")
    var temperatureSetting: TemperatureSetting = .systemSetting {
        willSet {
            objectWillChange.send()
        }
    }
    
    @WrappedDefault(key: "distanceSetting")
    var distanceSetting: DistanceSetting = .systemSetting {
        willSet {
            objectWillChange.send()
        }
    }
}

extension AppSettingsRepository {
    
    enum DarkModeSetting: String, UserDefaultsSerializable, Hashable {
        case alwaysDark
        case alwaysLight
        case systemSetting
        
        var colorScheme: ColorScheme? {
            switch self {
            case .alwaysDark: .dark
            case .alwaysLight: .light
            case .systemSetting: nil
            }
        }
    }
    
    enum TemperatureSetting: String, UserDefaultsSerializable, Hashable {
        case alwaysF
        case alwaysC
        case systemSetting
    }
    
    enum DistanceSetting: String, UserDefaultsSerializable, Hashable {
        case alwayKm
        case alwayMi
        case systemSetting
        
        private func getDistanceUnitFromLocale() -> HKUnit{
            switch Locale.current.measurementSystem {
            case .metric, .uk: HKUnit.meterUnit(with: .kilo)
            case .us: HKUnit.mile()
            default: HKUnit.meterUnit(with: .kilo)
            }
        }
        
        var hkUnit: HKUnit {
            switch self {
            case .alwayKm: HKUnit.meterUnit(with: .kilo)
            case .alwayMi: HKUnit.mile()
            case .systemSetting: getDistanceUnitFromLocale()
            }
        }
        
        var availableSplits: [SplitInteractor.SplitType] {
            switch self.hkUnit {
            case HKUnit.meterUnit(with: .kilo):
                return [.fourHundredM, .eightHundredM, .oneK, .fiveK]
            case HKUnit.mile():
                return [.quarterMi, .halfMi, .oneMi]
            default:
                return [.fourHundredM, .eightHundredM, .oneK, .fiveK]
            }
        }
        
        var defaultSplit: SplitInteractor.SplitType {
            switch self.hkUnit {
            case HKUnit.meterUnit(with: .kilo):
                return .oneK
            case HKUnit.mile():
                return .oneMi
            default:
                return .oneK
            }
        }
    }
}
