//
//  RunListViewModel.swift
//  FitnessHealth
//
//  Created by Andrei Terentiev on 19.08.23.
//

import Foundation
import Factory
import HealthKit
import Combine
import CoreLocation
 
class RunListViewModel: ObservableObject {
    
    @Injected(\.healthKitStore) private var hkStore
    @Injected(\.healthKitAuthRepo) private var healthKitAuthRepo
    @Injected(\.workoutsRepo) private var workoutsRepo
    @Injected(\.appSettingsRepo) private var appSettingsRepo
    @Injected(\.measurementFormatService) private var measurementFormatService
        
    @Published var workouts: [HKWorkout] = []
    @Published var workoutMonths: [DateComponents] = []
    @Published var groupedWorkouts: [DateComponents: [HKWorkout]] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadAllWorkouts()
    }
    
    //MARK: - HealthKit Authorization Request Method
    func loadAllWorkouts() {
        Task {
            
            let bgWorkouts = await self.workoutsRepo.readWorkouts() ?? []
            await MainActor.run {
                var localWorkoutMonths: [DateComponents] = []
                var localGroupedWorkout: [DateComponents: [HKWorkout]] = [:]
                for workout in bgWorkouts {
                    let dateComponents = Calendar.current.dateComponents([.month, .year], from: workout.startDate)
                    
                    if localWorkoutMonths.last != dateComponents {
                        localWorkoutMonths.append(dateComponents)
                    }
                    
                    if localGroupedWorkout[dateComponents] == nil {
                        localGroupedWorkout[dateComponents] = [workout]
                    } else {
                        var temp = localGroupedWorkout[dateComponents]!
                        temp.append(workout)
                        localGroupedWorkout[dateComponents] = temp
                    }
                }
                
                

                self.workouts = bgWorkouts
                self.groupedWorkouts = localGroupedWorkout
                self.workoutMonths = localWorkoutMonths
            }
        }
    }
}
