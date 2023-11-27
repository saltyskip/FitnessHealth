//
//  HealthKitReadableNames.swift
//  FitnessHealth
//
//  Created by Andrei Terentiev on 12.08.23.
//

import Foundation
import HealthKit

extension HKQuantityTypeIdentifier {
    var displayName: LocalizedStringResource {
        switch self {
        case HKQuantityTypeIdentifier.stepCount:
            return "Step Count"
        case HKQuantityTypeIdentifier.runningGroundContactTime:
            return "Ground Contact Time"
        case HKQuantityTypeIdentifier.runningPower:
            return "Running Power"
        case HKQuantityTypeIdentifier.activeEnergyBurned:
            return "Active Energy Burned"
        case HKQuantityTypeIdentifier.basalEnergyBurned:
            return "Basal Energy Burned"
        case HKQuantityTypeIdentifier.runningVerticalOscillation:
            return "Vertical Oscillation"
        case HKQuantityTypeIdentifier.runningSpeed:
            return "Running Speed"
        case HKQuantityTypeIdentifier.runningStrideLength:
            return "Stride Length"
        case HKQuantityTypeIdentifier.distanceWalkingRunning:
            return "Distance"
        case HKQuantityTypeIdentifier.heartRate:
            return "Heart Rate"
        default:
            return ""
        }
    }
}

extension HKWorkout: Identifiable {
    
}
