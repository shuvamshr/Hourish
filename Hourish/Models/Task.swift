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
    
    @Relationship(inverse: \Plan.tasks)
    var task: Task?
    
    init(title: String, note: String, duration: Double) {
        self.title = title
        self.note = note
        self.duration = duration
    }
}
