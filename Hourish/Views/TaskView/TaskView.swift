//
//  TaskView.swift
//  Hourish
//
//  Created by Shuvam Shrestha on 20/11/2025.
//

import SwiftUI
import SwiftData

struct TaskView: View {
    
    let plan: Plan
    
    @StateObject private var sessionViewModel = SessionViewModel()
    
    var body: some View {
        Group {
            if !sessionViewModel.sessionActive {
                TaskEditModeView(plan: plan)
            } else {
                TaskSessionModeView()
            }
        }
        .environmentObject(sessionViewModel)
    }
}
