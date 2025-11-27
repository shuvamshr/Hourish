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
    var isActive: Bool
    
    var isComplete: Bool {
        duration <= 0
    }
}
