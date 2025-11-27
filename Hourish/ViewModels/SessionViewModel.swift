//
//  SessionViewModel.swift
//  Hourish
//
//  Created by Shuvam Shrestha on 24/11/2025.
//
import SwiftUI
import Playgrounds
import Combine

final class SessionViewModel: ObservableObject {
    @Published var sessionTasks: [SessionTask] = []
    @Published var sessionActive: Bool = false
    @Published var totalRemainingTime: Double = 0
    
    private var timer: DispatchSourceTimer?
    private var taskStartTime: Date?
    private var initialTaskDuration: Double = 0

    // MARK: - Populate Tasks
    
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

    // MARK: - Session Control
    
    func startSession() {
        guard !sessionTasks.isEmpty else { return }
        sessionActive = true
        
        // Activate first task
        let sortedTasks = sessionTasks.sorted { $0.order < $1.order }
        guard let firstTask = sortedTasks.first else { return }
        for i in 0..<sessionTasks.count {
            sessionTasks[i].isActive = (sessionTasks[i].order == firstTask.order)
        }
        
        if let activeIndex = sessionTasks.firstIndex(where: { $0.isActive }) {
            initialTaskDuration = sessionTasks[activeIndex].duration
            taskStartTime = Date()
        }
        
        calculateTotalRemainingTime()
        startTimer()
    }
    
    func stopSession() {
        sessionActive = false
        timer?.cancel()
        timer = nil
        taskStartTime = nil
        initialTaskDuration = 0
        totalRemainingTime = 0
        
        for i in 0..<sessionTasks.count {
            sessionTasks[i].isActive = false
        }
    }

    // MARK: - Timer
    
    private func startTimer() {
        timer?.cancel()  // ensure no duplicate timers
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer?.schedule(deadline: .now(), repeating: 0.01)
        timer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.updateTimer()
            }
        }
        timer?.resume()
    }
    
    private func updateTimer() {
        guard let activeIndex = sessionTasks.firstIndex(where: { $0.isActive }),
              let taskStart = taskStartTime else {
            stopSession()
            return
        }
        
        let elapsed = Date().timeIntervalSince(taskStart)
        let remaining = max(0, initialTaskDuration - elapsed)
        sessionTasks[activeIndex].duration = remaining
        calculateTotalRemainingTime()
        
        if remaining <= 0 {
            sessionTasks[activeIndex].duration = 0
            sessionTasks[activeIndex].isActive = false
            
            let sortedTasks = sessionTasks.sorted { $0.order < $1.order }
            if let nextTask = sortedTasks.first(where: { $0.order > sessionTasks[activeIndex].order }),
               let nextIndex = sessionTasks.firstIndex(where: { $0.order == nextTask.order }) {
                sessionTasks[nextIndex].isActive = true
                initialTaskDuration = sessionTasks[nextIndex].duration
                taskStartTime = Date()
            } else {
                timer?.cancel()
                timer = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.stopSession()
                }
            }
        }
    }
    
    private func calculateTotalRemainingTime() {
        totalRemainingTime = sessionTasks.reduce(0) { $0 + $1.duration }
    }
    
    deinit {
        timer?.cancel()
    }
}
