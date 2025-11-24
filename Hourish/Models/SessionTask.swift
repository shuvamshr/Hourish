//
//  SessionTask.swift
//  Hourish
//
//  Created by Shuvam Shrestha on 21/11/2025.
//

import SwiftUI

struct SessionTask: Hashable {
    var title: String
    var note: String
    var duration: Double
    var isLocked: Bool
    var order: Int
    
    var formattedDuration: String {
        let totalSeconds = Int(duration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        let secondsString = String(format: "%02d", seconds)
        
        return "\(minutes):\(secondsString)"
    }
}
