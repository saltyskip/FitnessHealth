//
//  EnableHealthKitView.swift
//  FitnessHealth
//
//  Created by Andrei Terentiev on 11.08.23.
//

import Foundation
import SwiftUI
import DesignSystem

struct EnableHealthKitView: View {
    @EnvironmentObject var vm: HealthKitViewModel
    
    var body: some View {
        VStack {
            if vm.isAuthorized {
                VStack {
                    Text("Today's Step Count")
                        .font(.title3)
                    
                    Text("\(vm.userStepCount)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
            } else {
                VStack {
                    Text("Please Authorize Health!")
                        .font(.title3)
                    
                    Button {
                        vm.getAuthorizationStatus()
                    } label: {
                        Text("Authorize HealthKit")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(width: 320, height: 55)
                    .background(Color(.orange))
                    .cornerRadius(10)
                }
            }
            Text("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
                .font(Font.inter)
            Text("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
                .font(Font.custom("SF-Pro-Display-Regular", size: 18))
            
            PrimaryButton(text: "", clicked: {})
        }
        .padding()
        .onAppear {
            vm.readStepsTakenToday()
        }
    }
}
