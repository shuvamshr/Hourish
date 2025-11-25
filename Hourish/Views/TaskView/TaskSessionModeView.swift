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
        .navigationBarBackButtonHidden()
    }
}

struct SessionTaskCardView: View {
    let task: SessionTask
    @State private var isActive: Bool = false
    @State private var remainingSeconds: Double?
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {

            // LEFT SIDE
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .fontWeight(isActive ? .bold : .regular)

                if !task.note.isEmpty {
                    Text(task.note)
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                }
            }

            Spacer()

            // RIGHT SIDE DURATION
            if isActive, let remainingSeconds {
                Text(formatTime(remainingSeconds))
                    .font(.system(size: 54, weight: .thin))
                    .monospacedDigit()
                    .foregroundStyle(.accent)
                    .contentTransition(.numericText())
            } else {
                Text(task.formattedDuration)
                    .font(.system(size: 54, weight: .thin))
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
    }

    private func formatTime(_ seconds: Double) -> String {
        let total = max(Int(seconds), 0)
        let min = total / 60
        let sec = total % 60
        return String(format: "%02d:%02d", min, sec)
    }
}
