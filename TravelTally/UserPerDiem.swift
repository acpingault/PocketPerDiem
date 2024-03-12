//
//  UserPerDiem.swift
//  PocketPer Diem
//
//  Created by Alex on 3/2/24.
//

import Foundation

final class UserPerDiem{
    var id: UUID
    var totalDays: Int
    var perDayTotal: Int
    var dateRangeTotal: Int
    
    
    init(id: UUID, totalDays: Int, perDayTotal: Int) {
        self.id = id
        self.totalDays = totalDays
        self.perDayTotal = perDayTotal
        self.dateRangeTotal = totalDays * perDayTotal
    }
    
    init(){
        self.id = UUID()
        self.totalDays = 0
        self.perDayTotal = 0
        self.dateRangeTotal = 0
    }
    
}
