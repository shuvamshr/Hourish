//
//  SessionViewModel.swift
//  Hourish
//
//  Created by Shuvam Shrestha on 24/11/2025.
//
import SwiftUI
import Playgrounds
import Combine

@Observable
final class SessionViewModel {
    var sessionTasks: [SessionTask] = []
    var sessionActive: Bool = false
    var totalRemainingTime: Double = 0  // Stores the total remaining time across all tasks
    
    private var timer: Timer?
    private var sessionStartTime: Date?
    private var taskStartTime: Date?
    private var initialTaskDuration: Double = 0
    
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
    
    func populateSampleSessionTask() {
        sessionTasks = [
            .init(title: "First", note: "", duration: 10, isLocked: true, order: 0, isActive: true),
            .init(title: "Second", note: "", duration: 10, isLocked: true, order: 1, isActive: false),
            .init(title: "Third", note: "", duration: 10, isLocked: true, order: 2, isActive: false),
            .init(title: "Fourth", note: "", duration: 10, isLocked: true, order: 3, isActive: false),
        ]
    }
    
    func startSession() {
        guard !sessionTasks.isEmpty else { return }
        
        self.sessionActive = true
        self.sessionStartTime = Date()
        
        // Find and activate the first task (lowest order)
        let sortedTasks = sessionTasks.sorted { $0.order < $1.order }
        guard let firstTask = sortedTasks.first else { return }
        
        for i in 0..<sessionTasks.count {
            sessionTasks[i].isActive = (sessionTasks[i].order == firstTask.order)
        }
        
        // Store the initial duration of the active task
        if let activeIndex = sessionTasks.firstIndex(where: { $0.isActive }) {
            initialTaskDuration = sessionTasks[activeIndex].duration
            taskStartTime = Date()
        }
        
        // Calculate initial total remaining time
        calculateTotalRemainingTime()
        
        // Start the timer immediately
        startTimer()
    }
    
    func stopSession() {
        self.sessionActive = false
        timer?.invalidate()
        timer = nil
        sessionStartTime = nil
        taskStartTime = nil
        initialTaskDuration = 0
        totalRemainingTime = 0
        
        // Reset all tasks to inactive
        for i in 0..<sessionTasks.count {
            sessionTasks[i].isActive = false
        }
    }
    
    private func startTimer() {
        // Use a timer that fires every 10 milliseconds for smooth countdown
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func updateTimer() {
        // Find the currently active task
        guard let activeTaskIndex = sessionTasks.firstIndex(where: { $0.isActive }),
              let taskStart = taskStartTime else {
            stopSession()
            return
        }
        
        let activeTask = sessionTasks[activeTaskIndex]
        
        // Calculate elapsed time since task started
        let elapsed = Date().timeIntervalSince(taskStart)
        let remainingDuration = max(0, initialTaskDuration - elapsed)
        
        // Update the display with real-time calculation
        sessionTasks[activeTaskIndex].duration = remainingDuration
        
        // Calculate and update total remaining time across all tasks
        calculateTotalRemainingTime()
        
        // Check if current task is completed
        if remainingDuration <= 0 {
            // Mark current task as inactive and reset to 0
            sessionTasks[activeTaskIndex].duration = 0
            sessionTasks[activeTaskIndex].isActive = false
            
            // Find the next task by order
            let sortedTasks = sessionTasks.sorted { $0.order < $1.order }
            if let nextTask = sortedTasks.first(where: { $0.order > activeTask.order }),
               let nextTaskIndex = sessionTasks.firstIndex(where: { $0.order == nextTask.order }) {
                // Activate next task and continue immediately
                sessionTasks[nextTaskIndex].isActive = true
                
                // Reset timing for the new task
                initialTaskDuration = sessionTasks[nextTaskIndex].duration
                taskStartTime = Date()
            } else {
                // All tasks completed - stop timer first to prevent multiple calls
                timer?.invalidate()
                timer = nil
                
                // Wait 2 seconds before stopping session
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.stopSession()
                }
            }
        }
    }
    
    private func calculateTotalRemainingTime() {
        // Sum up all remaining durations across all tasks
        totalRemainingTime = sessionTasks.reduce(0) { $0 + $1.duration }
    }
    
    deinit {
        timer?.invalidate()
    }
}
