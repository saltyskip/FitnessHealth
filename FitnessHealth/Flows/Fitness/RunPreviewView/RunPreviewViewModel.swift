//
//  RunPreviewViewModel.swift
//  FitnessHealth
//
//  Created by Andrei Terentiev on 12.08.23.
//

import Foundation
import Factory
import HealthKit
import Combine
import CoreLocation
 
class RunPreviewViewModel: ObservableObject {
    
    @Injected(\.healthKitStore) private var hkStore
    @Injected(\.healthKitAuthRepo) private var healthKitAuthRepo
    @Injected(\.workoutsRepo) private var workoutsRepo
    @Injected(\.appSettingsRepo) private var appSettingsRepo
    @Injected(\.measurementFormatService) private var measurementFormatService
    
    private var healthKitManager = HealthKitManager()
    @Published var distance: String = ""
    @Published var pace: String = ""
    @Published var time: String = ""
    @Published var calories: String = ""
    @Published var heartRate: String = ""
    @Published var coordinates: [CLLocationCoordinate2D] = []
    
    
    @Published var workout: HKWorkout

    
    private var cancellables = Set<AnyCancellable>()
    
    init(workout: HKWorkout) {
        self.workout = workout
        observeWorkout()
        observeRoute()
    }
    
    
    private let requiredStats = [
        HKQuantityTypeIdentifier.distanceWalkingRunning,
        HKQuantityTypeIdentifier.activeEnergyBurned,
        HKQuantityTypeIdentifier.heartRate,
        HKQuantityTypeIdentifier.runningSpeed
    ]
    
    func observeRoute() {
        workoutsRepo.observeSamples(myWorkout: workout, sampleType: .route)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .flatMap { samples in
                let workout = samples.first! as! HKWorkoutRoute
                return self.workoutsRepo.observeLocationData(for: workout)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { value in
                self.coordinates.append(contentsOf: value.map { coordinate in
                    coordinate.coordinate
                })
            }).store(in: &cancellables)
    }
    
    func observeWorkout() {
        $workout
            .combineLatest(appSettingsRepo.$distanceSetting)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .map { (workout, distanceSetting) -> (distance: String, pace: String, time: String) in
                var distance = ""
                var pace = ""
                var time = ""
                
                let allStats = workout.allStatistics
                var identifierDict: [HKQuantityTypeIdentifier: HKStatistics] = [:]
                
                for key in allStats.keys {
                    let identifier = HKQuantityTypeIdentifier(rawValue: key.identifier)
                    if self.requiredStats.contains(identifier) {
                        identifierDict[identifier] = allStats[key]
                    }
                }
                
                let distanceQuantity = identifierDict[HKQuantityTypeIdentifier.distanceWalkingRunning]?
                    .sumQuantity()?
                    .doubleValue(for: distanceSetting.hkUnit)
                let paceQuantity = workout.duration / distanceQuantity!
                distance = self.measurementFormatService
                    .formatUnit(distanceQuantity ?? 0.0, unit: distanceSetting.hkUnit)
                
                let paceFormatter = DateComponentsFormatter()
                paceFormatter.allowedUnits = [.minute, .second ]
                paceFormatter.zeroFormattingBehavior = .dropLeading
                
                pace = paceFormatter.string(from: paceQuantity) ?? ""
                
                let timeFormatter = DateComponentsFormatter()
                timeFormatter.allowedUnits = [.hour, .minute, .second ]
                timeFormatter.zeroFormattingBehavior = .dropLeading
                time = timeFormatter.string(from: workout.duration) ?? ""
                
                return (distance, pace, time)
            }
            .receive(on: DispatchQueue.main)
            .sink { distance, pace, time in
                self.distance = distance
                self.pace = pace
                self.time = time
            }
            .store(in: &cancellables)
    }
}
