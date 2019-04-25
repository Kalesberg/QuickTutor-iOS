//
//  TimeHelper.swift
//  QuickTutor
//
//  Created by Will Saults on 4/24/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import Foundation

struct TimeHelper {
    let oneMinuteInSeconds = 60.0
    let oneHourInSeconds = 3600.0
    let oneDayInSeconds = 86400.0
    
    func mulitplyDaysInSeconds(by: Int) -> Double {
        return self.oneDayInSeconds * Double(by)
    }
    
    func minutesFrom(seconds: Double) -> Int {
        return Int(seconds / 60)
    }
    
    func hoursFrom(seconds: Double) -> Int {
        return Int(seconds / 60 / 60)
    }
    
    func daysFrom(seconds: Double) -> Int {
        return Int(seconds / 60 / 60 / 24)
    }
}
