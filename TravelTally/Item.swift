//
//  Item.swift
//  TravelTally
//
//  Created by Alex on 2/23/24.
//

import Foundation
import SwiftData

@Model
final class FundItem {
    var id: UUID
    var dateAdded: Date
    var name: String
    var amount: Float
    var note: String
    
    init(id: UUID, dateAdded: Date, name: String, amount: Float, note: String) {
        self.id = id
        self.dateAdded = dateAdded
        self.name = name
        self.amount = amount
        self.note = note
    }
}
