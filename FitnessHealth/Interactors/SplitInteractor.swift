//
//  SplitInteractor.swift
//  FitnessHealth
//
//  Created by Andrei Terentiev on 27.08.23.
//

import Foundation
import Combine
import HealthKit
import Factory

protocol SplitInteractorProtocol {
    func observeSplits(myWorkout: HKWorkout, splitType: SplitInteractor.SplitType) -> AnyPublisher<[SplitInteractor.Split], Error>
    func convertSampleToSplits(splits: [SplitInteractor.Split],
                               samples: [HKDiscreteQuantitySample],
                               sampleUnit: HKUnit) -> [SplitInteractor.SplitQuantity]
}

class SplitInteractor: SplitInteractorProtocol {
    @Injected(\.workoutsRepo) private var workoutsRepo
    @Injected(\.healthKitStore) private var hkStore

    //todo should have a unit configuration
    //would be goood to get this as a more configurable function
    // for various data types
    // make the split unit configurable to allow for km/mi spluts
    struct Split {
        var splitNumber: Int
        var splitDuration: TimeInterval
        var splitDistance: HKQuantity
        var splitStart: Date
        var splitEnd: Date
        var splitType: SplitType
    }
    
    struct SplitQuantity {
        var splitNumber: Int
        var splitValue: Double
    }
    
    enum SplitType: Identifiable {
        case fourHundredM
        case eightHundredM
        case oneK
        case fiveK
        case quarterMi
        case oneMi
        case halfMi
        
        var id: Self {
            return self
        }
        
        // prolly should be a formatted number
        // not a localized string resource
        var name: LocalizedStringResource {
            switch self {
            case .fourHundredM: return "400m"
            case .eightHundredM: return "800m"
            case .oneK: return "1k"
            case .fiveK: return "5k"
            case .quarterMi: return ".25mi"
            case .halfMi: return ".5mi"
            case .oneMi: return "1mi"
            }
        }
        
        var baseUnit: HKUnit {
            switch self {
            case .fourHundredM, .eightHundredM, .oneK, .fiveK: HKUnit.meter()
            case .quarterMi, .halfMi, .oneMi: HKUnit.foot()
            }
        }
        
        var baseUnitDistance: Double {
            switch self {
            case .fourHundredM: 400.0
            case .eightHundredM: 800.0
            case .oneK: 1000.0
            case .fiveK: 5000.0
            case .quarterMi: 1320.0
            case .halfMi: 2640.0
            case .oneMi: 5280.0
            }
        }
    }
    
    func observeSplits(myWorkout: HKWorkout, splitType: SplitType) -> AnyPublisher<[SplitInteractor.Split], Error> {
        return workoutsRepo
            .observeSamples(myWorkout: myWorkout, sampleType: .distance)
            .map { distances in
                guard let distanceSamples = distances as? [HKCumulativeQuantitySample], var splitStart = distances.first?.startDate else {
                    return []
                }
                var splits = [Split]()
                var cumulativeRunningDistance = 0.0
                var cumulativeRunningTime: TimeInterval = 0.0
                for (index, sample) in distanceSamples.enumerated() {
                    //TODO need to take into account units
                    let totalSampleDistance = sample.quantity.doubleValue(for: splitType.baseUnit)
                    let totalSampleDuration = (sample.endDate.timeIntervalSince1970 - sample.startDate.timeIntervalSince1970)
                    //split has ended during this sample
                    
                    if cumulativeRunningDistance + totalSampleDistance >= splitType.baseUnitDistance {
                        let splitDistanceRemainder = (cumulativeRunningDistance + totalSampleDistance) - splitType.baseUnitDistance
                        let remainderRatio = splitDistanceRemainder / totalSampleDuration
                        let timeRemainder = totalSampleDuration * remainderRatio
                        
                        cumulativeRunningDistance += totalSampleDistance - splitDistanceRemainder //should equal 1000
                        cumulativeRunningTime += totalSampleDuration - timeRemainder
                        
                        let split = Split(
                            splitNumber: splits.count + 1,
                            splitDuration: cumulativeRunningTime,
                            splitDistance: HKQuantity.init(unit: splitType.baseUnit, doubleValue: cumulativeRunningDistance),
                            splitStart: splitStart,
                            splitEnd: splitStart + cumulativeRunningTime,
                            splitType: splitType)
                        splits.append(split)
                        
                        splitStart = splitStart + cumulativeRunningTime
                        cumulativeRunningDistance = splitDistanceRemainder
                        cumulativeRunningTime = timeRemainder
                    } else {
                        cumulativeRunningDistance += totalSampleDistance
                        cumulativeRunningTime += totalSampleDuration
                    }
                    
                    //add the last split
                    if index == distanceSamples.endIndex - 1 {
                        let split = Split(
                            splitNumber: splits.count + 1,
                            splitDuration: cumulativeRunningTime,
                            splitDistance: HKQuantity.init(unit: splitType.baseUnit, doubleValue: cumulativeRunningDistance),
                            splitStart: splitStart,
                            splitEnd: splitStart + cumulativeRunningTime,
                            splitType: splitType)
                        splits.append(split)
                    }
                    
                }
                
                return splits
                
            }.eraseToAnyPublisher()
    }
    
    func convertSampleToSplits(splits: [SplitInteractor.Split],
                               samples: [HKDiscreteQuantitySample],
                               sampleUnit: HKUnit) -> [SplitInteractor.SplitQuantity] {
        var quantities = [Int: [HKDiscreteQuantitySample]]()
        for sample in samples {
            guard let split = splits.first(where: { split in
                sample.startDate >= split.splitStart && sample.endDate <= split.splitEnd
            }) else {
                //sample overlaps buckets or doesnt fit
                debugPrint("Dropping sample")
                continue
            }
            quantities[split.splitNumber, default: []].append(sample)
        }
        
        return quantities.map({ key, value in
            let averageValue = value
                .map { $0.averageQuantity.doubleValue(for: sampleUnit)}
                .reduce(0.0, +)
            / Double(value.count)
            
            return SplitQuantity(splitNumber: key,
                          splitValue: averageValue)
        })
    }
}
