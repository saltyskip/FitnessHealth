//
//  File.swift
//  
//
//  Created by Andrei Terentiev on 17.08.23.
//

import Foundation
import SwiftUI
import UIKit

public extension Color {
    //fixed regardless of appearance
    static let primaryColor = Color(UIColor(named: "AccentColor", in: .module, compatibleWith: nil)!)
    static let rose600 = Color(UIColor(named: "Rose600", in: .module, compatibleWith: nil)!)
    static let lightBlue600 = Color(UIColor(named: "LightBlue600", in: .module, compatibleWith: nil)!)
    
    //heart rate zones
    static let heartRateZone1 = Color(UIColor(named: "BlueGray400", in: .module, compatibleWith: nil)!)
    static let heartRateZone2 = Color(UIColor(named: "LightBlue400", in: .module, compatibleWith: nil)!)
    static let heartRateZone3 = Color(UIColor(named: "Success400", in: .module, compatibleWith: nil)!)
    static let heartRateZone4 = Color(UIColor(named: "Warning400", in: .module, compatibleWith: nil)!)
    static let heartRateZone5 = Color(UIColor(named: "Rose600", in: .module, compatibleWith: nil)!)
    
    //change on appearance
    static let backgroundColor = Color(UIColor(named: "background", in: .module, compatibleWith: nil)!)
    static let backgroundCardColor = Color(UIColor(named: "backgroundCard", in: .module, compatibleWith: nil)!)
}
