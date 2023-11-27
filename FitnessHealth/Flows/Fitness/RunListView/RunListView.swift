//
//  RunListView.swift
//  FitnessHealth
//
//  Created by Andrei Terentiev on 19.08.23.
//

import Foundation
import SwiftUI
import DesignSystem

struct RunListView: View {
    @StateObject var vm = RunListViewModel()
    private static var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate ("MMM, YYYY")
        return df
    }()
    
    init() {
        //remove line under navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    struct headerView: View {
        let dateString: String
    
        var body: some View {
            HStack(spacing: 0) {
                Text(dateString)
                    .font(Font.interTitle2)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundStyle(.accent)
                
            }
            .background(Color.backgroundColor)
            .padding(.horizontal, Dimensions.spacer * 2)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: Dimensions.spacer * 1.5, pinnedViews: [.sectionHeaders]) {
                        //todo refactor
                        ForEach(vm.workoutMonths, id: \.description.hashValue) { date in
                            Section(header: headerView(dateString: Self.dateFormatter.string(from: Calendar.current.date(from: date)!))) {
                                ForEach(vm.groupedWorkouts[date] ?? []) { workout in
                                    RunPreviewView(vm: RunPreviewViewModel(workout: workout))
                                }
                            }
                        }
                    }
                }
            }.coordinateSpace(name: "area")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.backgroundColor, for: .navigationBar)
        }
    }
}
