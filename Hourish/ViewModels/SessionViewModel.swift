//
//  SessionViewModel.swift
//  Hourish
//
//  Created by Shuvam Shrestha on 24/11/2025.
//

import SwiftUI

@Observable
final class SessionViewModel {
    var sessionTasks: [SessionTask] = []
    var sessionActive: Bool = false
    
    func populateSessionTasks(_ tasks: [Task]) {
            self.sessionTasks = tasks.map { task in
                return SessionTask(
                    title: task.title,
                    note: task.note,
                    duration: task.duration,
                    isLocked: task.isLocked,
                    order: task.order,
                    isActive: false
                )
            }
        }
    
    func startSession() {
        self.sessionActive = true
    }
    
    func stopSession() {
        self.sessionActive = false
    }
}
