//
//  Item.swift
//  Eventful
//
//  Created by ManCheukNam on 28/1/2025.
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
