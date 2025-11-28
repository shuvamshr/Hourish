//
//  TaskSessionModeView.swift
//  Hourish
//
//  Created by Shuvam Shrestha on 25/11/2025.
//

import SwiftUI

struct TaskSessionModeView: View {
    
    @Environment(SessionViewModel.self) private var sessionViewModel
    
    @State private var showStopSessionAlert: Bool = false
    
    var body: some View {
        Group {
            List {
                ForEach(sessionViewModel.sessionTasks.sorted { $0.order < $1.order }, id: \.self) { task in
                    SessionTaskCardView(
                        task: task
                    )
                    .swipeActions(edge: .leading) {
                        Button("Delay", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90") {
                            
                        }
                        .tint(Color.accentColor)
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Complete", systemImage: "checkmark.arrow.trianglehead.clockwise") {
                            
                        }
                        .tint(Color.green)
                    }
                }
            }
            .listStyle(.plain)
          
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Stop Session", systemImage: "xmark", role: .destructive) {
                    showStopSessionAlert.toggle()
                }
            }
        }
        .confirmationDialog("Would you like to stop this session?", isPresented: $showStopSessionAlert, titleVisibility: .visible) {
            Button("Stop Session", role: .destructive) {
                withAnimation {
                    sessionViewModel.stopSession()
                }
            }
        }
        
        .navigationBarBackButtonHidden()
    }
    
}

struct SessionTaskCardView: View {
    let task: SessionTask
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // LEFT SIDE
            VStack(alignment: .leading, spacing: 12) {
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .fontWeight(task.isActive ? .semibold : .regular)
                        .foregroundStyle(task.isComplete ? Color.secondary : Color.primary)
                        .lineLimit(task.isComplete ? 1 : 999)
                        .truncationMode(.tail)
                    
                    if !task.note.isEmpty {
                        
                        Text(task.note)
                            .font(.footnote)
                            .foregroundStyle(Color.secondary)
                            .lineLimit(task.isComplete ? 1 : 999)
                            .truncationMode(.tail)
                    }
                }
                
                if task.isLocked {
                    HStack {
                        Image(systemName: "lock.fill")
                        Text("Locked")
                    }
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(task.isComplete ? Color.secondary : Color.accent)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.gray.quaternary)
                    .clipShape(RoundedRectangle(cornerRadius: .infinity))
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
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .opacity(task.isComplete ? 0.5 : 1)
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let total = Int(max(seconds, 0))       // keep time ≥ 0
        let min = total / 60                   // convert to minutes
        let sec = total % 60                   // remainder seconds
        return String(format: "%02d:%02d", min, sec)
    }
}

