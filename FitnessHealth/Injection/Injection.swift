//
//  Injection.swift
//  FitnessHealth
//
//  Created by Andrei Terentiev on 12.08.23.
//

import Foundation
import Factory
import HealthKit

extension Container {
    //Singletons
    var healthKitStore: Factory<HKHealthStore> {
        Factory(self) { HKHealthStore() }
            .singleton
    }
    
    //Repositories
    var workoutsRepo: Factory<WorkoutsRespositoryProtocol> {
        Factory(self) { WorkoutsRespository() }
            .singleton
    }
    
    var hrZoneRepo: Factory<HeartRateZoneRepositoryProtocol> {
        Factory(self) { HeartRateZoneRepository() }
            .singleton
    }
    
    var healthKitAuthRepo: Factory<HealthKitAuthorizationRepositoryProtocol> {
        Factory(self) { HealthKitAuthorizationRepository() }
            .singleton
    }
    
    var appSettingsRepo: Factory<AppSettingsRepository> {
        Factory(self) {
            AppSettingsRepository()
        }
        .singleton
    }
    
    //services
    
    var measurementFormatService: Factory<MeasurementFormatServiceProtocol> {
        Factory(self) {
            MeasurementFormatService()
        }
        .singleton
    }
    
    //Interactors
    var splitInteractor: Factory<SplitInteractorProtocol> {
        Factory(self) {
            SplitInteractor()
        }
        .singleton
    }
}
