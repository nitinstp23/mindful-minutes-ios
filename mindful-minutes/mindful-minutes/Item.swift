//
//  Item.swift
//  mindful-minutes
//
//  Created by Nitin Misra on 12/7/2568 BE.
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
