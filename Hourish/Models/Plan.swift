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
    
    @Relationship(deleteRule: .cascade)
    private(set) var tasks: [Task] = []
    
    init(name: String) {
        self.name = name
    }
}
