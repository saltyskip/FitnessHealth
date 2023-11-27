//
//  HeartRateZoneInteractor.swift
//  FitnessHealth
//
//  Created by Andrei Terentiev on 16.09.23.
//

import Foundation
import Factory
import HealthKit
import Combine

protocol HeartRateZoneRepositoryProtocol {
    func setHeartRateZones()
    func observeHeartRateZones() -> AnyPublisher<HeartRateZoneRepository.HeartRateZones, Error>
    func observeMaxRecordedHeartRate() -> AnyPublisher<HKQuantity, Error>
    func getRestingHeartRate() -> AnyPublisher<HKQuantity, Error>
}

//Heart rate zones will be configured using karvonen method

class HeartRateZoneRepository: HeartRateZoneRepositoryProtocol {
    @Injected(\.healthKitStore) private var hkStore

    enum DomainError: LocalizedError {
        case noAgeFound
        case noRestingHeartRate
        
        var failureReason: LocalizedStringResource? {
            switch self {
            case .noAgeFound: "Age in HealthKit is required to calculate heart rate zones"
            case .noRestingHeartRate: "Resting heart rate in HealthKit not found"
            }
        }
        
        var errorDescription: LocalizedStringResource? {
            return "HealthKit Error"
        }
    }
    
    struct HeartRateZones {
        var zone1: HeartRateZone
        var zone2: HeartRateZone
        var zone3: HeartRateZone
        var zone4: HeartRateZone
        var zone5: HeartRateZone
            
        struct HeartRateZone {
            var min: Double
            var max: Double
        }
        
        //Karvonen method
        init(maxHeartRate: HKQuantity, restingHeartRate: HKQuantity) {
            let mHR = maxHeartRate.doubleValue(for: HKUnit(from: "count/min"))
            let rHR = restingHeartRate.doubleValue(for: HKUnit(from: "count/min"))
            self.zone1 = HeartRateZone(min: 0, max: ((mHR - rHR) * 0.6) + rHR )
            self.zone2 = HeartRateZone(min: ((mHR - rHR) * 0.6) + rHR, max: ((mHR - rHR) * 0.7) + rHR)
            self.zone3 = HeartRateZone(min: ((mHR - rHR) * 0.7) + rHR, max: ((mHR - rHR) * 0.8) + rHR)
            self.zone4 = HeartRateZone(min: ((mHR - rHR) * 0.8) + rHR, max: ((mHR - rHR) * 0.9) + rHR)
            self.zone5 = HeartRateZone(min: ((mHR - rHR) * 0.9) + rHR, max: Double.greatestFiniteMagnitude)
        }
    }
    
    
    func observeHeartRateZones() -> AnyPublisher<HeartRateZones, Error> {
        return observeMaxRecordedHeartRate()
            .zip(getRestingHeartRate())
            .map { maxHR, restingHR in
                return HeartRateZones(maxHeartRate: maxHR, restingHeartRate: restingHR)
            }
            .eraseToAnyPublisher()
    }
    
    func setHeartRateZones() {
        //
    }
    
    // Precondition to have age set in health kit
    // Otherwise you might get weird heart rate values
    // Use 220 - age heuristic or max recored which ever is greater
    // probably should be time locked to past six months for max heart rate
    func observeMaxRecordedHeartRate() -> AnyPublisher<HKQuantity, Error> {
        let subject = PassthroughSubject<HKQuantity, Error>()
        guard let dob = try? hkStore.dateOfBirthComponents(), let dobYear = dob.year else {
            return Fail(error: DomainError.noAgeFound).eraseToAnyPublisher()
        }
        
        let currentYear = Calendar.current.component(.year, from: Date())
        let age = currentYear - dobYear
        
        
        //calculated max heart rate for hr zones is only valid for six months
        let startDate = Calendar.current.date(byAdding: .month, value: -6, to: Date())!
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())
        
        /// Create sample type for the heart rate
        let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: queryPredicate, options: .discreteMax) { (query, samples, error) in
            if let error = error {
                subject.send(completion: .failure(error))
                return
            }
            
                        
            let maxHeartRateEstimation = HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: 220.0 - Double(age))
            
            guard let maxQuantity = samples?.maximumQuantity() else {
                subject.send(maxHeartRateEstimation)
                subject.send(completion: .finished)
                return
            }
            
            if maxHeartRateEstimation.doubleValue(for: HKUnit(from: "count/min")) > maxQuantity.doubleValue(for: HKUnit(from: "count/min")) {
                subject.send(maxHeartRateEstimation)
            } else {
                subject.send(maxQuantity)
            }
            subject.send(completion: .finished)
        }

        hkStore.execute(query)
        return subject.eraseToAnyPublisher()
    }
    
    func getRestingHeartRate() -> AnyPublisher<HKQuantity, Error> {
        let subject = PassthroughSubject<HKQuantity, Error>()
        
        //resting heart rate for hr zones is only valid for six months
        let startDate = Calendar.current.date(byAdding: .month, value: -6, to: Date())!
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.restingHeartRate)!
        let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())
        
        /// Create sample type for the heart rate
        let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: queryPredicate, options: .discreteAverage) { (query, samples, error) in
            if let error = error {
                subject.send(completion: .failure(error))
                return
            }
            
            guard let averageQuantity = samples?.averageQuantity() else {
                subject.send(completion: .failure(DomainError.noRestingHeartRate))
                return
            }
            
            subject.send(averageQuantity)
            subject.send(completion: .finished)
        }

        hkStore.execute(query)
        return subject.eraseToAnyPublisher()
    }
}
