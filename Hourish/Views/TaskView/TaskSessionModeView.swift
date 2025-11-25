//
//  TaskSessionModeView.swift
//  Hourish
//
//  Created by Shuvam Shrestha on 25/11/2025.
//

import SwiftUI

struct TaskSessionModeView: View {
    
    @Environment(SessionViewModel.self) private var sessionViewModel
    
    var body: some View {
        Group {
            List {
                ForEach(sessionViewModel.sessionTasks.sorted { $0.order < $1.order }, id: \.self) { task in
                    SessionTaskCardView(
                        task: task
                    )
                }
            }
            .listStyle(.plain)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Stop Session", systemImage: "xmark", role: .destructive) {
                    withAnimation {
                        sessionViewModel.stopSession()
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("\(formatTime(sessionViewModel.totalRemainingTime))")
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Add Task", systemImage: "forward.fill") {
                    
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let totalSeconds = max(seconds, 0)
        
        // Show milliseconds if below 60 seconds
        if totalSeconds < 60 {
            let sec = Int(totalSeconds)
            let milliseconds = Int((totalSeconds - Double(sec)) * 100)
            return String(format: "%02d.%02d", sec, milliseconds)
        } else {
            // Show minutes:seconds format for 60+ seconds
            let total = Int(ceil(totalSeconds))
            let min = total / 60
            let sec = total % 60
            return String(format: "%02d:%02d", min, sec)
        }
    }
}

struct SessionTaskCardView: View {
    let task: SessionTask
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // LEFT SIDE
            VStack(alignment: .leading, spacing: 4) {
                
                
                Text(task.title)
                    .fontWeight(task.isActive ? .semibold : .regular)
                    .foregroundStyle(task.isComplete ? Color.secondary : Color.primary)
                
                if !task.note.isEmpty {
                    
                    Text(task.note)
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                }
                
            }
            Spacer()
            // RIGHT SIDE DURATION
            if task.isActive {
                Text(formatTime(task.duration))
                    .font(.system(size: 48, weight: .thin))
                    .monospacedDigit()
                    .foregroundStyle(.accent)
            } else {
                Text(formatTime(task.duration))
                    .font(.system(size: 48, weight: .thin))
                    .monospacedDigit()
                    .foregroundStyle(task.isComplete ? Color.secondary : Color.primary)
            }
        }
        .contentShape(Rectangle())
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let totalSeconds = max(seconds, 0)
        
        // Show milliseconds if below 60 seconds
        if totalSeconds < 60 {
            let sec = Int(totalSeconds)
            let milliseconds = Int((totalSeconds - Double(sec)) * 100)
            return String(format: "%02d.%02d", sec, milliseconds)
        } else {
            // Show minutes:seconds format for 60+ seconds
            let total = Int(ceil(totalSeconds))
            let min = total / 60
            let sec = total % 60
            return String(format: "%02d:%02d", min, sec)
        }
    }
}
