//
//  RunDetailViewModel.swift
//  FitnessHealth
//
//  Created by Andrei Terentiev on 20.08.23.
//

import Foundation

import Foundation
import Factory
import HealthKit
import Combine
import CoreLocation
 
class RunDetailViewModel: ObservableObject {
    
    @Injected(\.healthKitStore) private var hkStore
    @Injected(\.healthKitAuthRepo) private var healthKitAuthRepo
    @Injected(\.workoutsRepo) private var workoutsRepo
    @Injected(\.splitInteractor) private var splitInteractor
    @Injected(\.appSettingsRepo) private var appSettingsRepo
    @Injected(\.hrZoneRepo) private var hrZoneRepo
    @Injected(\.measurementFormatService) private var measurementFormatService
    
    @Published var distance: String = ""
    @Published var pace: String = ""
    @Published var time: String = ""
    @Published var calories: String = ""
    @Published var heartRate: String = ""
    @Published var coordinates: [MapPoint] = []
    
    @Published private var workout: HKWorkout
    @Published var selectedSplit: SplitInteractor.SplitType = .oneK
    //@Published var heartRates: [HKDiscreteQuantitySample] = []
    @Published var allDataSamples: [WorkoutsRespository.WorkoutSampleType: [HKDiscreteQuantitySample]] = [:]
    @Published var splits: [SplitDisplay] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    struct SplitDisplay: Identifiable {
        let id: String = UUID().uuidString
        let splitNumber: Int
        let pace: TimeInterval
        let heartRate: Double
    }
    
    struct MapPoint: Identifiable {
        let id: String = UUID().uuidString
        var coordinate: CLLocationCoordinate2D
        var timeStamp: Date
    }
    
    init(workout: HKWorkout) {
        self.workout = workout
        self.selectedSplit = appSettingsRepo.distanceSetting.defaultSplit
        observeWorkout()
        observeRoute()
        observeSplitType()
        observeSplits()
        observeMaxHeartRate()
    }
    
    
    private let requiredStats = [
        HKQuantityTypeIdentifier.distanceWalkingRunning,
        HKQuantityTypeIdentifier.activeEnergyBurned,
        HKQuantityTypeIdentifier.heartRate,
        HKQuantityTypeIdentifier.runningSpeed
    ]
    
    func observeSplitType() {
        //can probably combine this in the upstream
        appSettingsRepo.$distanceSetting
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { distanceSetting in
                self.selectedSplit = distanceSetting.defaultSplit
            }).store(in: &cancellables)
    }
    
    func observeRoute() {
        workoutsRepo.observeSamples(myWorkout: workout, sampleType: .route)
            .flatMap { samples in
                let workout = samples.first! as! HKWorkoutRoute
                return self.workoutsRepo.observeLocationData(for: workout)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { value in
                self.coordinates.append(contentsOf: value.map { coordinate in
                    let mp = MapPoint(coordinate: coordinate.coordinate,
                             timeStamp: coordinate.timestamp)
                    return mp
                })
            }).store(in: &cancellables)
    }
    
    private func observeSamples() -> AnyPublisher<[WorkoutsRespository.WorkoutSampleType: [HKDiscreteQuantitySample]], Error> {
            [workoutsRepo.observeSamples(myWorkout: workout, sampleType: .heartRate),
             workoutsRepo.observeSamples(myWorkout: workout, sampleType: .verticalOscillation),
             workoutsRepo.observeSamples(myWorkout: workout, sampleType: .runningStrideLength),
             workoutsRepo.observeSamples(myWorkout: workout, sampleType: .runningPower),
             workoutsRepo.observeSamples(myWorkout: workout, sampleType: .runningSpeed)]
            .zip()
            .map { values in
                var allDataSamples: [WorkoutsRespository.WorkoutSampleType: [HKDiscreteQuantitySample]] = [:]
                guard let heartRateSamples = values[0] as? [HKDiscreteQuantitySample],
                        let vOscs = values[1] as? [HKDiscreteQuantitySample],
                        let sLengths = values[2] as? [HKDiscreteQuantitySample],
                        let rPower = values[3] as? [HKDiscreteQuantitySample],
                        let rSpeed = values[4] as? [HKDiscreteQuantitySample] else {
                    return [:]
                }
                
                allDataSamples = [
                    .heartRate: heartRateSamples,
                    .verticalOscillation: vOscs,
                    .runningStrideLength: sLengths,
                    .runningPower: rPower,
                    .runningSpeed: rSpeed
                ]
                return allDataSamples
            }
            .eraseToAnyPublisher()
    }
    
    func observeSplits() {
        $selectedSplit
            .flatMap { splitType in
                return self.splitInteractor
                    .observeSplits(myWorkout: self.workout, splitType: splitType)
                    .zip(self.observeSamples())
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] splits, samples in
                guard let self = self, let splitType = splits.first?.splitType else {
                    return
                }
    
                  
                let heartRateSplits = self.splitInteractor.convertSampleToSplits(splits: splits,
                                                                                 samples: samples[.heartRate] ?? [],
                                                                                 sampleUnit: HKUnit(from: "count/min"))
                
                self.allDataSamples = samples
                
                self.splits = splits.map { split in
                    SplitDisplay(splitNumber: split.splitNumber,
                                 pace: split.splitDuration / (split.splitDistance.doubleValue(for: splitType.baseUnit) / splitType.baseUnitDistance),
                                 heartRate: heartRateSplits.first { heartRate in split.splitNumber == heartRate.splitNumber}?.splitValue ?? 0.0)
                }
                debugPrint(self.splits)
            })
            .store(in: &cancellables)
    }
    
    func observeMaxHeartRate() {
        hrZoneRepo
            .observeHeartRateZones()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { error in
                
            }, receiveValue: { heartRateZones in
                debugPrint(heartRateZones)
            })
            .store(in: &cancellables)
    }
    
    func observeWorkout() {
        $workout
            .combineLatest(appSettingsRepo.$distanceSetting)
            .receive(on: DispatchQueue.main)
            .sink { workout, distanceSetting in
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
                
                self.distance = self.measurementFormatService
                    .formatUnit(distanceQuantity ?? 0.0, unit: distanceSetting.hkUnit)
                
                //set up formatter for pace
                let paceFormatter = DateComponentsFormatter()
                paceFormatter.allowedUnits = [.minute, .second ]
                paceFormatter.zeroFormattingBehavior = .dropLeading
                
                self.pace = paceFormatter.string(from: paceQuantity) ?? ""
                
                
                //set up formatter for pace
                let timeFormatter = DateComponentsFormatter()
                timeFormatter.allowedUnits = [.hour, .minute, .second ]
                timeFormatter.zeroFormattingBehavior = .dropLeading
                self.time = timeFormatter.string(from: workout.duration) ?? ""
             
            }
            .store(in: &cancellables)
    }
}

extension HKDiscreteQuantitySample: Identifiable {
    
}
