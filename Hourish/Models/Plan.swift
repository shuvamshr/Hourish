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
}
