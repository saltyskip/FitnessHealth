//
//  RunDetailView.swift
//  FitnessHealth
//
//  Created by Andrei Terentiev on 20.08.23.
//

import Foundation
import SwiftUI
import DesignSystem
import HealthKit
import Charts
import MapKit
import Factory
//struct Split: Codable, Identifiable {
//    let id: String
//    let splitNumber: Int
//    let heartRate: Double
//    let pace: TimeInterval
//}

struct RunDetailView: View {
    @StateObject var vm: RunDetailViewModel
    @Injected(\.appSettingsRepo) private var appSettingsRepo

    @State var selectedHeartRate: HKDiscreteQuantitySample?

    //todo make this lazy
    var paceFormmater: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .dropLeading
        return formatter
    }
    
    func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> HKDiscreteQuantitySample? {
        return nil
//        let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
//        if let date = proxy.value(atX: relativeXPosition) as Date? {
//            // Find the closest date element.
//            var minDistance: TimeInterval = .infinity
//            var index: Int? = nil
//            for heartRateDataIndex in vm.heartRates.indices {
//                let nthSalesDataDistance = vm.heartRates[heartRateDataIndex].startDate.distance(to: date)
//                if abs(nthSalesDataDistance) < minDistance {
//                    minDistance = abs(nthSalesDataDistance)
//                    index = heartRateDataIndex
//                }
//            }
//            
//            if let index {
//                return vm.heartRates[index]
//            }
//        }
//        return nil
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: Dimensions.spacer * 2) {
                    //Workout Route
                    Map(interactionModes: [.all]) {
//                        MapPolyline(coordinates: vm.coordinates.map { $0.coordinate})
//                            .stroke(.pink, lineWidth: 3)
//                        if let selectedHeartRate = selectedHeartRate,
//                            let mapPoint = vm.coordinates.first (where: { $0.timeStamp >= selectedHeartRate.startDate && $0.timeStamp >= selectedHeartRate.endDate  }) {
//                            MapCircle(center: mapPoint.coordinate,
//                                      radius: CLLocationDistance(integerLiteral: 20))
//                                    .foregroundStyle(.green)
//                                    .mapOverlayLevel(level: .aboveLabels)
//                        }
                    }
                    .mapStyle(.standard(elevation: .realistic,
                                        pointsOfInterest: .excludingAll,
                                        showsTraffic: false))
                    .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                    
                    //Stat highlights
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
                    
                    //Pace Chart
                    Spacer()
                    ForEach(Array(vm.allDataSamples.keys), id: \.self) { key  in
                        Text(key.name)
                        Chart {
                            ForEach(vm.allDataSamples[key] ?? []) { dataSample in
                                
                                LineMark(
                                    x: .value("Time", dataSample.startDate),
                                    y: .value("Heart Rate", dataSample.averageQuantity.doubleValue(for: key.defaultUnit))
                                )
                                .foregroundStyle(Color.red)
                            }
                        }
//                        .chartOverlay { proxy in
//                            GeometryReader { geo in
//                                Rectangle()
//                                    .fill(.clear)
//                                    .contentShape(Rectangle())
//                                    .gesture(
//                                        SpatialTapGesture()
//                                            .onEnded { value in
//                                                debugPrint(value)
//                                                let element =   findElement(location: value.location,
//                                                                          proxy: proxy,
//                                                                          geometry: geo)
//                                                if selectedHeartRate != nil {
//                                                    selectedHeartRate = nil
//                                                } else {
//                                                    selectedHeartRate = element
//                                                }
//                                            }
//                                            .exclusively(before: DragGesture()
//                                                .onChanged { value in
//                                                    selectedHeartRate = findElement(location: value.location,
//                                                                                  proxy: proxy,
//                                                                                  geometry: geo)
//                                                }
//                                                .onEnded { value in
//                                                    selectedHeartRate = nil
//                                                })
//                                    )
//                            }
//                            .sensoryFeedback(.selection, trigger: selectedHeartRate)
//                        }
//                        .chartBackground { proxy in
//                            ZStack(alignment: .topLeading) {
//                                GeometryReader { geo in
//                                    if let selectedElement = selectedHeartRate {
//
//                                        let startPositionX1 = proxy.position(forX: selectedElement.startDate) ?? 0
//
//                                          let lineX = startPositionX1 + geo[proxy.plotAreaFrame].origin.x
//                                          let lineHeight = geo[proxy.plotAreaFrame].maxY
//                                          let boxWidth: CGFloat = 100
//                                          let boxOffset = max(0, min(geo.size.width - boxWidth, lineX - boxWidth / 2))
//
//                                          Rectangle()
//                                                .fill(.orange)
//                                              .frame(width: 2, height: lineHeight)
//                                              .position(x: lineX, y: lineHeight / 2)
//
//                                          VStack(alignment: .center) {
//                                              Text("\(selectedElement.startDate, format: .dateTime.year().month().day())")
//                                                  .font(.callout)
//                                                  .foregroundStyle(.secondary)
//                                              Text("\(Int(selectedElement.averageQuantity.doubleValue(for: HKUnit(from: "count/min"))))")
//                                                  .font(.title2.bold())
//                                                  .foregroundColor(.primary)
//                                          }
//                                          .accessibilityElement(children: .combine)
//                                          //.accessibilityHidden(isOverview)
//                                          .frame(width: boxWidth, alignment: .leading)
//                                          .background {
//                                              ZStack {
//                                                  RoundedRectangle(cornerRadius: 8)
//                                                      .fill(.background)
//                                                  RoundedRectangle(cornerRadius: 8)
//                                                      .fill(.quaternary.opacity(0.7))
//                                              }
//                                              .padding(.horizontal, -8)
//                                              .padding(.vertical, -4)
//                                          }
//                                          .offset(x: boxOffset)
//                                      }
//                                  }
//                            }
//                        }
                        .padding(.horizontal, Dimensions.spacer )
                    }
                    
                    
                    let strideBy = 10.0
                    
                    let paces = vm.splits.map { $0.pace }
                    let heartRates = vm.splits.map { $0.heartRate }
                    
                    //let pacesMax = Double(paces.max() ?? 0.0) * 1.1
                    //let heartRatesMax = Double(heartRates.max()!) * 1.1
                    
                    //let pacesMin = Double(paces.min() ?? 0.0) * 0.9
                    //let heartRatesMin = Double(heartRates.min()!) * 0.9
                     
                    if let pacesMax = paces.max(), pacesMax > 0,
                       let pacesMin = paces.min(), pacesMin > 0,
                       let heartRateMax = heartRates.max(), heartRateMax > 0,
                       let heartRateMin = heartRates.min(), heartRateMin > 0 {
                        let pacesMaxBuffered = pacesMax * 1.1
                        let pacesMinBuffered = pacesMin * 0.9
                        let heartRatesMaxBuffered = heartRateMax * 1.1
                        let heartRatesMinBuffered = heartRateMin * 0.9
                        Chart {
                            ForEach(vm.splits) { split in
                                BarMark(
                                    x: .value("Splits", String(split.splitNumber)),
                                    y: .value("Pace", (split.pace - pacesMinBuffered) / (pacesMaxBuffered - pacesMinBuffered))
                                )
                                .foregroundStyle(Color.lightBlue600)
                                .annotation() {
                                    Text(paceFormmater.string(from: TimeInterval(split.pace))!).font(.system(size: 8.0))
                                    
                                }
                            }
                            
                            ForEach(vm.splits) { split in
                                LineMark(
                                    x: .value("Split", String(split.splitNumber)),
                                    y: .value("Heart Rate", (split.heartRate - heartRateMin) / (heartRateMax - heartRateMin))
                                )
                                .foregroundStyle(Color.rose600)
                            }
                            
                            ForEach(vm.splits) { split in
                                PointMark(
                                    x: .value("Split", String(split.splitNumber)),
                                    y: .value("Heart Rate", (split.heartRate - heartRateMin) / (heartRateMax - heartRateMin))
                                )
                                .foregroundStyle(Color.rose600)
                                .annotation() {
                                    Text("\(Int(split.heartRate))").font(.system(size: 8.0))
                                    
                                }
                            }
                            
                            
                            
                            
                            
                        }
                        .chartYAxis {
                            let defaultStride = Array(stride(from: 0, to: 1.0, by: 1/strideBy))

                            let dataSetOneStride = Array(stride(from: pacesMinBuffered,
                                                                           through: pacesMaxBuffered,
                                                                by: (pacesMaxBuffered - pacesMinBuffered)/Double(strideBy)))
                            AxisMarks(position: .leading, values: defaultStride) { axis in
                                AxisValueLabel {
                                    let value = dataSetOneStride[axis.index]
                                    Text(paceFormmater.string(from: TimeInterval(value))!)
                                }
                            }

                            let dataSetTwoStride = Array(stride(from: Double(heartRateMin),
                                                                    through: Double(heartRateMax),
                                                                by: Double(heartRateMax - heartRateMin)/strideBy))
    
                            //data set two
                            AxisMarks(position: .trailing, values: defaultStride) { axis in
                                AxisValueLabel {
                                    let value = dataSetTwoStride[axis.index]
                                    Text("\(Int(value))")
                                }
                            }
                        }
                        .padding(.horizontal, Dimensions.spacer )
                        .frame(height: 250)
                        Picker("Split Type", selection: $vm.selectedSplit) {
                            ForEach(appSettingsRepo.distanceSetting.availableSplits) { splitType in
                                Text(splitType.name)
                            }
                        }
                        .padding(.horizontal, Dimensions.spacer)
                        .pickerStyle(.segmented)
                    }
                    
                    // heart rate zone section
                    HStack {
                        Gauge(value: 150, in: 100...200) {
                                Label("Temperature (°F)", systemImage: "thermometer.medium")
                                    } currentValueLabel: {
                                        Text(Int(150), format: .number)
                                            .foregroundColor(.green)

                                    } minimumValueLabel: {
                                        Text("32")
                                            .foregroundColor(.blue)

                                    } maximumValueLabel: {
                                        Text("570")
                                            .foregroundColor(.pink)

                                    }
                                    .gaugeStyle(SpeedometerGaugeStyle())
                                    .tint(Gradient(colors: [.blue, .green, .pink]))
                        Spacer()
                        VStack(spacing: Dimensions.spacer) {
                            HStack(spacing: 0) {
                                Text("Zone 1")
                                    .font(Font.interSubHeadlineSemiBold)
                                    .foregroundStyle(Color.heartRateZone1)
                                Spacer()
                                Text("<136BPM")
                                    .font(Font.interSubHeadlineSemiBold)
                                    .foregroundStyle(Color.heartRateZone1)
                            }
                            HStack(spacing: 0) {
                                Text("Zone 2")
                                    .font(Font.interSubHeadlineSemiBold)
                                    .foregroundStyle(Color.heartRateZone2)
                                Spacer()
                                Text("137-148BPM")
                                    .font(Font.interSubHeadlineSemiBold)
                                    .foregroundStyle(Color.heartRateZone2)
                            }
                            HStack(spacing: 0) {
                                Text("Zone 3")
                                    .font(Font.interSubHeadlineSemiBold)
                                    .foregroundStyle(Color.heartRateZone3)
                                Spacer()
                                Text("149-161BPM")
                                    .font(Font.interSubHeadlineSemiBold)
                                    .foregroundStyle(Color.heartRateZone3)
                            }
                            HStack(spacing: 0) {
                                Text("Zone 4")
                                    .font(Font.interSubHeadlineSemiBold)
                                    .foregroundStyle(Color.heartRateZone4)
                                Spacer()
                                Text("162-174BPM")
                                    .font(Font.interSubHeadlineSemiBold)
                                    .foregroundStyle(Color.heartRateZone4)
                            }
                            HStack(spacing: 0) {
                                Text("Zone 5")
                                    .font(Font.interSubHeadlineSemiBold)
                                    .foregroundStyle(Color.heartRateZone5)
                                Spacer()
                                Text("175+BPM")
                                    .font(Font.interSubHeadlineSemiBold)
                                    .foregroundStyle(Color.heartRateZone5)
                            }
                            
                        }
                    }
                    .padding([.top, .trailing], Dimensions.spacer)
                    
                                
                    
                    
                    
                }
            }
            .padding(.bottom, Dimensions.spacer)
        }
    }
}

struct SpeedometerGaugeStyle: GaugeStyle {
    private var heartRateGradient =
    AngularGradient(gradient: Gradient(colors: [
        Color.heartRateZone1,
        Color.heartRateZone2,
        Color.heartRateZone3,
        Color.heartRateZone4,
        Color.heartRateZone5,
    ]), center: .center, startAngle: Angle(degrees: 0.0), endAngle: Angle(degrees: 270.0) )

    func degreeToXY(radius: Double, angle: Double) -> (x: Double, y: Double) {
        let x = radius * sin(Double.pi * 2 * angle / 360.0)
        let y = radius * cos(Double.pi * 2 * angle / 360.0)
        return (x: x, y: y)
    }
    
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(heartRateGradient, lineWidth: 20)
                    .rotationEffect(.degrees(135))
                
                //Circle
                
                Circle()
                    .fill(.pink)
                    .offset(y: geometry.size.height / -2)
                    .frame(width: 20, height: 20)
                
                Circle()
                    .fill(Color.heartRateZone5)
                    .offset(x: degreeToXY(radius: geometry.size.height / 2, angle: 45).x,
                            y: degreeToXY(radius: geometry.size.height / 2, angle: 45).y)
                    .frame(width: 20, height: 20)
                Circle()
                    .fill(Color.heartRateZone1)
                    .offset(x: degreeToXY(radius: geometry.size.height / 2, angle: 315).x,
                            y: degreeToXY(radius: geometry.size.height / 2, angle: 315).y)
                    .frame(width: 20, height: 20)
                
                
                
                
                VStack {
                    configuration.currentValueLabel
                        .scaledToFill()
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .foregroundColor(.gray)
                    Text("BPM")
                        .font(.system(.body, design: .rounded))
                        .bold()
                        .foregroundColor(.gray)
                }
                
            }
            .frame(idealWidth: 150, maxWidth: 200, idealHeight: 150, maxHeight: 200)

        }
 
    }
 
}
