//
//  WorkoutsRespository.swift
//  FitnessHealth
//
//  Created by Andrei Terentiev on 12.08.23.
//

import Foundation
import HealthKit
import Factory
import Combine
import CoreLocation

protocol WorkoutsRespositoryProtocol {
    func readWorkouts() async -> [HKWorkout]?
    func observeSamples(myWorkout: HKWorkout, sampleType: WorkoutsRespository.WorkoutSampleType) -> AnyPublisher<[HKSample], Error>
    func observeLocationData(for route: HKWorkoutRoute) -> AnyPublisher<[CLLocation], Error>
}

class WorkoutsRespository: WorkoutsRespositoryProtocol {
    @Injected(\.healthKitStore) private var hkStore
    
    
    enum WorkoutSampleType: Identifiable {
        var id: Self {
            return self
        }
    
        case heartRate
        case route
        case distance
        case verticalOscillation
        case groundContactTime
        case runningPower
        case runningSpeed
        case runningStrideLength
        
        var name: LocalizedStringResource {
            switch self {
            case .heartRate: return "Heart Rate"
            case .verticalOscillation: return "Vertical Oscillation"
            case .runningStrideLength: return "Running Stride Length"
            case .runningPower: return "Running Power"
            case .runningSpeed: return "Running Speed"
            default: fatalError()
            }
        }
        
        var defaultUnit: HKUnit {
            switch self {
            case .heartRate: HKUnit(from: "count/min")
            case .verticalOscillation: HKUnit.meterUnit(with: .centi)
            case .runningStrideLength: HKUnit.meter()
            case .runningPower: HKUnit.watt()
            case .runningSpeed: HKUnit(from: "m/s")
            default: fatalError()
            
            }
        }
    }
    
    func readWorkouts() async -> [HKWorkout]? {
        let running = HKQuery.predicateForWorkouts(with: .running)
        
        let samples = try! await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
            hkStore.execute(HKSampleQuery(sampleType: .workoutType(), predicate: running, limit: HKObjectQueryNoLimit,sortDescriptors: [.init(keyPath: \HKSample.startDate, ascending: false)], resultsHandler: { query, samples, error in
                if let hasError = error {
                    continuation.resume(throwing: hasError)
                    return
                }
                
                guard let samples = samples else {
                    fatalError("*** Invalid State: This can only fail if there was an error. ***")
                }
                
                continuation.resume(returning: samples)
            }))
        }
        
        guard let workouts = samples as? [HKWorkout] else {
            return nil
        }
        
        return workouts
    }
    
    func observeSamples(myWorkout: HKWorkout, sampleType: WorkoutsRespository.WorkoutSampleType) -> AnyPublisher<[HKSample], Error> {
        switch sampleType {
        case .distance: return self.observeDistanceData(myWorkout: myWorkout)
        case .heartRate: return self.observeHeartRateData(myWorkout: myWorkout)
        case .route: return self.observeRouteObject(myWorkout: myWorkout)
        case .verticalOscillation: return self.observeRunningVerticalOscillation(myWorkout: myWorkout)
        case .groundContactTime: return self.observeGroundContactTime(myWorkout: myWorkout)
        case .runningPower: return self.observeRunningPower(myWorkout: myWorkout)
        case .runningSpeed: return self.observeRunningSpeed(myWorkout: myWorkout)
        case .runningStrideLength: return self.observeRunningStrideLength(myWorkout: myWorkout)
        }
    }
    
    func observeLocationData(for route: HKWorkoutRoute) -> AnyPublisher<[CLLocation], Error>{
        let subject = PassthroughSubject<[CLLocation], Error>()
        
        // Create the route query.
        let query = HKWorkoutRouteQuery(route: route) { (query, locationsOrNil, done, errorOrNil) in
            
            // This block may be called multiple times.
            
            if let error = errorOrNil {
                subject.send(completion: .failure(error))
            }
            
            guard let locations = locationsOrNil else {
                fatalError("*** Invalid State: This can only fail if there was an error. ***")
            }
            
            
            
            subject.send(locations)
            
            if done {
                subject.send(completion: .finished)
            }
        }
        hkStore.execute(query)
        return subject.eraseToAnyPublisher()
    }
    
    private func observeRouteObject(myWorkout: HKWorkout) -> AnyPublisher<[HKSample], Error> {
        let subject = PassthroughSubject<[HKSample], Error>()
        
        let runningObjectQuery = HKQuery.predicateForObjects(from: myWorkout)
        
        
        let routeQuery = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: runningObjectQuery, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, anchor, error) in
            guard error == nil else {
                // Handle any errors here.
                fatalError("The initial query failed.")
            }
            
            subject.send(samples ?? [])
            
        }
        
        
        routeQuery.updateHandler = { (query, samples, deleted, anchor, error) in
            
            guard error == nil else {
                // Handle any errors here.
                fatalError("The update failed.")
            }
            
            subject.send(samples ?? [])
        }
        
        hkStore.execute(routeQuery)
        
        return subject.eraseToAnyPublisher()
    }
    
    private func observeHeartRateData(myWorkout: HKWorkout) -> AnyPublisher<[HKSample], Error> {
        let subject = PassthroughSubject<[HKSample], Error>()
        
        let runningObjectQuery = HKQuery.predicateForObjects(from: myWorkout)
        let heartRateQuantity = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        
        let heartRateQuery = HKAnchoredObjectQuery(type: heartRateQuantity, predicate: runningObjectQuery, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, anchor, error) in
            
            guard error == nil else {
                // Handle any errors here.
                fatalError("The initial query failed.")
            }
            
            debugPrint("Sending Samples")
            subject.send(samples ?? [])
        }
        
        heartRateQuery.updateHandler = { (query, samples, deleted, anchor, error) in
            
            guard error == nil else {
                // Handle any errors here.
                fatalError("The update failed.")
            }
            debugPrint("Sending Samples")
            subject.send(samples ?? [])
        }
        
        hkStore.execute(heartRateQuery)
        return subject.eraseToAnyPublisher()
    }
    
    private func observeDistanceData(myWorkout: HKWorkout) -> AnyPublisher<[HKSample], Error> {
        let subject = PassthroughSubject<[HKSample], Error>()
        
        let runningObjectQuery = HKQuery.predicateForObjects(from: myWorkout)
        let distanceQuantity = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
        let distanceQuery = HKSampleQuery(sampleType: distanceQuantity, predicate: runningObjectQuery, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            
            guard error == nil else {
                // Handle any errors here.
                fatalError("The initial query failed.")
            }
            
            debugPrint("Sending Samples")
            subject.send(samples ?? [])
        }
        
        hkStore.execute(distanceQuery)
        return subject.eraseToAnyPublisher()
    }
    
    private func observeRunningVerticalOscillation(myWorkout: HKWorkout) -> AnyPublisher<[HKSample], Error> {
        let subject = PassthroughSubject<[HKSample], Error>()
        
        let runningObjectQuery = HKQuery.predicateForObjects(from: myWorkout)
        let oscillationQuantity = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.runningVerticalOscillation)!
        let oscillationQuery = HKSampleQuery(sampleType: oscillationQuantity, predicate: runningObjectQuery, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            
            guard error == nil else {
                // Handle any errors here.
                fatalError("The initial query failed.")
            }
            
            debugPrint("Sending Samples")
            subject.send(samples ?? [])
        }
        
        hkStore.execute(oscillationQuery)
        return subject.eraseToAnyPublisher()
    }
    
    private func observeGroundContactTime(myWorkout: HKWorkout) -> AnyPublisher<[HKSample], Error> {
        let subject = PassthroughSubject<[HKSample], Error>()
        
        let runningObjectQuery = HKQuery.predicateForObjects(from: myWorkout)
        let runningGroundContactTimeQuantity = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.runningGroundContactTime)!
        let runningGroundContactTimeQuery = HKSampleQuery(sampleType: runningGroundContactTimeQuantity, predicate: runningObjectQuery, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            
            guard error == nil else {
                // Handle any errors here.
                fatalError("The initial query failed.")
            }
            
            debugPrint("Sending Samples")
            subject.send(samples ?? [])
        }
        
        hkStore.execute(runningGroundContactTimeQuery)
        return subject.eraseToAnyPublisher()
    }
    
    private func observeRunningPower(myWorkout: HKWorkout) -> AnyPublisher<[HKSample], Error> {
        let subject = PassthroughSubject<[HKSample], Error>()
        
        let runningObjectQuery = HKQuery.predicateForObjects(from: myWorkout)
        let runningPowerQuantity = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.runningPower)!
        let runningPowerQuery = HKSampleQuery(sampleType: runningPowerQuantity, predicate: runningObjectQuery, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            
            guard error == nil else {
                // Handle any errors here.
                fatalError("The initial query failed.")
            }
            
            debugPrint("Sending Samples")
            subject.send(samples ?? [])
        }
        
        hkStore.execute(runningPowerQuery)
        return subject.eraseToAnyPublisher()
    }
    
    private func observeRunningSpeed(myWorkout: HKWorkout) -> AnyPublisher<[HKSample], Error> {
        let subject = PassthroughSubject<[HKSample], Error>()
        
        let runningObjectQuery = HKQuery.predicateForObjects(from: myWorkout)
        let runningSpeedQuantity = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.runningSpeed)!
        let runningSpeedQuery = HKSampleQuery(sampleType: runningSpeedQuantity, predicate: runningObjectQuery, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            
            guard error == nil else {
                // Handle any errors here.
                fatalError("The initial query failed.")
            }
            
            debugPrint("Sending Samples")
            subject.send(samples ?? [])
        }
        
        hkStore.execute(runningSpeedQuery)
        return subject.eraseToAnyPublisher()
    }
    
    private func observeRunningStrideLength(myWorkout: HKWorkout) -> AnyPublisher<[HKSample], Error> {
        let subject = PassthroughSubject<[HKSample], Error>()
        
        let runningObjectQuery = HKQuery.predicateForObjects(from: myWorkout)
        let runningStrideLengthQuantity = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.runningStrideLength)!
        let runningStrideLengthQuery = HKSampleQuery(sampleType: runningStrideLengthQuantity, predicate: runningObjectQuery, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            
            guard error == nil else {
                // Handle any errors here.
                fatalError("The initial query failed.")
            }
            
            debugPrint("Sending Samples")
            subject.send(samples ?? [])
        }
        
        hkStore.execute(runningStrideLengthQuery)
        return subject.eraseToAnyPublisher()
    }
}

