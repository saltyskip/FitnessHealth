//
//  HealthKitViewModel.swift
//  FitnessHealth
//
//  Created by Andrei Terentiev on 11.08.23.
//

import HealthKit
import Factory

class HealthKitViewModel: ObservableObject {
    
    @Injected(\.healthKitStore) private var hkStore
    @Injected(\.healthKitAuthRepo) private var healthKitAuthRepo
    
    private var healthKitManager = HealthKitManager()
    
    @Published var userStepCount = ""
    @Published var isAuthorized = false
    
    init() {
        getAuthorizationStatus()
    }
    
    //MARK: - HealthKit Authorization Request Method
    func getAuthorizationStatus() {
        Task {
            await healthKitAuthRepo.checkPerimissionStatus()
            self.isAuthorized = true
            readStepsTakenToday()
            self.healthKitManager.getTodaysHeartRates()
        }
    }
    
    //MARK: - Read User's Step Count
    func readStepsTakenToday() {
        healthKitManager.readStepCount(forToday: Date()) { step in
            if step != 0.0 {
                DispatchQueue.main.async {
                    self.userStepCount = String(format: "%.0f", step)
                }
            }
        }
    }
    
}
