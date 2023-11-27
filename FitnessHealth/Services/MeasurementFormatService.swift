//
//  MeasurementFormatService.swift
//  FitnessHealth
//
//  Created by Andrei Terentiev on 19.08.23.
//

import Foundation
import HealthKit

protocol MeasurementFormatServiceProtocol {
    func formatUnit(_ value: Double, unit: HKUnit) -> String
}

class MeasurementFormatService: MeasurementFormatServiceProtocol {
    private var measurementFormatter =  MeasurementFormatter()
    
    init() {
        measurementFormatter.numberFormatter.maximumFractionDigits = 2
    }
    
    func formatUnit(_ value: Double, unit: HKUnit) -> String {
        measurementFormatter.string(from: Measurement(value: value, unit: Unit(symbol: unit.unitString)))
    }
}
