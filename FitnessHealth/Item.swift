//
//  Item.swift
//  FitnessHealth
//
//  Created by Andrei Terentiev on 11.08.23.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
