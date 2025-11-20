//
//  HourishApp.swift
//  Hourish
//
//  Created by Shuvam Shrestha on 11/11/2025.
//

import SwiftUI
import SwiftData

@main
struct HourishApp: App {
    var body: some Scene {
        WindowGroup {
            PlanView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: Plan.self)
    }
}
