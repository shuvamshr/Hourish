//
//  Plan.swift
//  Hourish
//
//  Created by Shuvam Shrestha on 11/11/2025.
//

import Foundation
import SwiftData

@Model final class Plan {
    var name: String
    var tasks: [Task] = []
    
    init(name: String) {
        self.name = name
    }
    
    var formattedName: String {
        if self.name.isEmpty {
            "Untitled"
        } else {
            self.name
        }
    }
    
    var taskCount: Int {
        tasks.count
    }
    
    // Total duration in seconds
    var totalDuration: Int {
        tasks.reduce(0) { $0 + Int($1.duration) }
    }
    
    // Formatted total duration as "MM:SS"
    var formattedTaskTotalDuration: String {
        let minutes = totalDuration / 60
        let seconds = totalDuration % 60
        let secondsString = String(format: "%02d", seconds)
        return "\(minutes):\(secondsString)"
    }
}
