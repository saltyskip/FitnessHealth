//
//  HealthKitAuthorizationRepository.swift
//  FitnessHealth
//
//  Created by Andrei Terentiev on 12.08.23.
//

import Foundation
import HealthKit
import Factory

protocol HealthKitAuthorizationRepositoryProtocol {
    func checkPerimissionStatus() async
}

class HealthKitAuthorizationRepository: HealthKitAuthorizationRepositoryProtocol {
    @Injected(\.healthKitStore) private var hkStore

    func checkPerimissionStatus() async {
        let requestedReadPerms: Set = [
            .workoutType(),
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKSeriesType.activitySummaryType(),
            HKSeriesType.workoutRoute(),
            HKSeriesType.workoutType(),
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.restingHeartRate)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.runningSpeed)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.runningPower)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.runningStrideLength)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.runningVerticalOscillation)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.runningGroundContactTime)!,
        ]
        
        let requestedWritePerms: Set = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        ]
        
        if HKHealthStore.isHealthDataAvailable() {
            try! await withCheckedThrowingContinuation{ (continuation: CheckedContinuation<Void, Error>) in hkStore.requestAuthorization(toShare: requestedWritePerms, read: requestedReadPerms) { success, error in
                    if success {
                        continuation.resume()
                        return
                    } else if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                }
            }
        }
    }
}
