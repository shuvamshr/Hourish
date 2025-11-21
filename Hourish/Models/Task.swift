//
//  Task.swift
//  Hourish
//
//  Created by Shuvam Shrestha on 11/11/2025.
//

import Foundation
import SwiftData

@Model final class Task {
    var title: String
    var note: String
    var duration: Double
    var isLocked: Bool
    var order: Int
    
    init(title: String, note: String, duration: Double, isLocked: Bool, order: Int) {
        self.title = title
        self.note = note
        self.duration = duration
        self.isLocked = isLocked
        self.order = order
    }

    
    var formattedDuration: String {
        let totalSeconds = Int(duration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        let secondsString = String(format: "%02d", seconds)
        
        return "\(minutes):\(secondsString)"
    }
}
