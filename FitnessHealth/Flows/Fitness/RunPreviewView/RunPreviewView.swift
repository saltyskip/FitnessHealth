//
//  RunPreviewView.swift
//  FitnessHealth
//
//  Created by Andrei Terentiev on 12.08.23.
//

import Foundation
import SwiftUI
import DesignSystem
import HealthKit
import MapKit

struct RunPreviewView: View {
    @StateObject var vm: RunPreviewViewModel
    var body: some View {
        NavigationLink(value: vm.workout) {
            VStack(spacing: 0) {
                VStack(spacing: Dimensions.spacer * 2) {
                    Map(interactionModes: []) {
                        MapPolyline(coordinates: vm.coordinates)
                            .stroke(.pink, lineWidth: 3)
                    }
                    .mapStyle(.standard(elevation: .flat,
                                        pointsOfInterest: .excludingAll,
                                        showsTraffic: false))
                    .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                    
                    
                    HStack(spacing: Dimensions.spacer * 1.5) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(HKQuantityTypeIdentifier.distanceWalkingRunning.displayName)
                                .font(Font.interCaption)
                            Text(vm.distance)
                                .font(Font.inter)
                                .bold()
                                .foregroundColor(.lightBlue600)
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Pace")
                                .font(Font.interCaption)
                            Text(vm.pace)
                                .font(Font.inter)
                                .bold()
                                .foregroundColor(.lightBlue600)
                            
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Time")
                                .font(Font.interCaption)
                            Text(vm.time)
                                .font(Font.inter)
                                .bold()
                                .foregroundColor(.lightBlue600)
                            
                        }
                        Spacer()
                    }
                    .padding(.horizontal, Dimensions.spacer)
                    .padding(.bottom, Dimensions.spacer * 2)
                }
            }
            .cornerRadius(12.0)
            .background(
                RoundedRectangle(cornerRadius: 12.0)
                    .foregroundColor(Color.backgroundCardColor)
                    .shadow(color: Color(red: 0.1, green: 0.1, blue: 0.1).opacity(0.2),
                            radius: 20, x: -1, y: 30)
            )
        }
            .padding(.horizontal, Dimensions.spacer * 2)
            .navigationDestination(for: HKWorkout.self) { workout in
                RunDetailView(vm: RunDetailViewModel(workout: workout))
            }
    }
}
