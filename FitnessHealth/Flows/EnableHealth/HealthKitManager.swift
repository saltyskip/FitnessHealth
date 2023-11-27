//
//  HealthKitManager.swift
//  FitnessHealth
//
//  Created by Andrei Terentiev on 11.08.23.
//

import Foundation
import HealthKit
import Factory

class HealthKitManager {
    @Injected(\.healthKitStore) private var hkStore
    
    func readStepCount(forToday: Date, completion: @escaping (Double) -> Void) {
        guard let stepQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            
            completion(sum.doubleValue(for: HKUnit.count()))
        
        }
        
        hkStore.execute(query)
        
    }
    
    
    
    /*Method to get todays heart rate - this only reads data from health kit. */
     func getTodaysHeartRates() {
         let health: HKHealthStore = HKHealthStore()
         let heartRateUnit:HKUnit = HKUnit(from: "count/min")
         let heartRateType:HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
             var heartRateQuery:HKSampleQuery?
         
        //predicate
        let calendar = NSCalendar.current
        let now = NSDate().addingTimeInterval(-86400.0)
        let components = calendar.dateComponents([.year, .month, .day], from: now as Date)
        
        guard let startDate:NSDate = calendar.date(from: components) as NSDate? else { return }
        var dayComponent    = DateComponents()
        dayComponent.day    = 1
        let endDate:NSDate? = calendar.date(byAdding: dayComponent, to: startDate as Date) as NSDate?
        let predicate = HKQuery.predicateForSamples(withStart: startDate as Date, end: endDate as Date?, options: [])

        //descriptor
        let sortDescriptors = [
                                NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
                              ]
        
         heartRateQuery = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: 25, sortDescriptors: sortDescriptors, resultsHandler: { (query, results, error) in
            guard error == nil else { print("error"); return }
             debugPrint(results)
        }) //eo-query
        
        health.execute(heartRateQuery!)
     }//eom
    
}
