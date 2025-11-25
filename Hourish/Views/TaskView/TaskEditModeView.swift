//
//  TaskEditModeView.swift
//  Hourish
//
//  Created by Shuvam Shrestha on 25/11/2025.
//

import SwiftUI
import SwiftData

struct TaskEditModeView: View {
    
    let plan: Plan
    
    @State private var showNewTaskSheet: Bool = false
    @State private var selectedTask: Task?
    @State private var showEditPlanSheet: Bool = false
    @State private var showDeleteAlert: Bool = false
    
    @Environment(SessionViewModel.self) private var sessionViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Group {
            if plan.tasks.isEmpty {
                ContentUnavailableView("No Task Yet", image: "checklist", description: Text("Add task to “\(plan.formattedName)”"))
            } else {
                List {
                    Section {
                        ForEach(plan.tasks.sorted { $0.order < $1.order }) { task in
                            TaskCardView(task: task)
                                .buttonStyle(.plain)
                                .listRowSeparator(.visible, edges: [.top, .bottom])
                                .swipeActions(edge: .trailing) {
                                    Button("Edit", systemImage: "pencil") {
                                        selectedTask = task
                                    }
                                    Button("Delete", systemImage: "trash.fill", role: .destructive) {
                                        if let index = plan.tasks.firstIndex(of: task) {
                                            plan.tasks.remove(atOffsets: IndexSet(integer: index))
                                        }
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    if task.isLocked {
                                        Button("Unlock", systemImage: "lock.open.fill") {
                                            task.isLocked = false
                                        }
                                        .tint(Color.secondary)
                                    } else {
                                        Button("Lock", systemImage: "lock.fill") {
                                            task.isLocked = true
                                        }
                                        .tint(Color.accentColor)
                                    }
                                }
                                .onTapGesture {
                                    selectedTask = task
                                }
                        }
                        .onMove { source, destination in
                            for task in plan.tasks {
                                print("\(task.title): \(task.order)")
                            }
                            plan.tasks.move(fromOffsets: source, toOffset: destination)
                            
                            for (index, task) in plan.tasks.enumerated() {
                                task.order = index
                            }
                            for task in plan.tasks {
                                print("\(task.title): \(task.order)")
                            }
                        }
                        .onDelete { indexSet in
                            plan.tasks.remove(atOffsets: indexSet)
                        }
                        
                        
                    } header: {
                        Text(plan.formattedName)
                            .font(.title)
                            .foregroundStyle(.white)
                            .bold()
                        
                    }
                }
                .listStyle(.plain)
                
            }
        }
        .toolbar {
            if editMode?.wrappedValue == .inactive {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu("Edit", systemImage: "ellipsis") {
                        Section {
                            Button("Rename Plan", systemImage: "character.cursor.ibeam") {
                                showEditPlanSheet.toggle()
                            }
                            Button("Edit Tasks", systemImage: "pencil") {
                                withAnimation {
                                    editMode?.wrappedValue =
                                    editMode?.wrappedValue == .active ? .inactive : .active
                                }
                            }
                        }
                        Button("Delete Plan", systemImage: "trash.fill", role: .destructive) {
                            showDeleteAlert.toggle()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", systemImage: "plus") {
                        showNewTaskSheet.toggle()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Start Session (\(plan.formattedTaskTotalDuration))") {
                        withAnimation {
                            sessionViewModel.populateSessionTasks(plan.tasks)
                            sessionViewModel.startSession()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(plan.tasks.isEmpty)
                    .tint(Color.accent)
                }
            } else {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") {
                        withAnimation {
                            editMode?.wrappedValue = .inactive
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showNewTaskSheet) {
            NewTaskSheetView(plan: plan)
        }
        .sheet(isPresented: $showEditPlanSheet) {
            EditPlanSheetView(plan: plan)
        }
        .sheet(item: $selectedTask) { task in
            EditTaskSheetView(plan: plan, task: task)
        }
        .confirmationDialog(
            "Are you sure you want to delete?",
            isPresented: $showDeleteAlert,
            titleVisibility: .visible
        ) {
            Button("Delete Plan", role: .destructive) {
                modelContext.delete(plan)
                dismiss()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
}

struct NewTaskSheetView: View {
    
    let plan: Plan
    
    @State private var title: String = ""
    @State private var note: String = ""
    @State private var minute: Int = 1
    @State private var second: Int = 0
    @State private var duration: Int = 60
    @State private var isLocked: Bool = false
    
    @FocusState private var isTaskTitleFocused
    @FocusState private var isNoteFocused
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Task Title", text: $title)
                        .focused($isTaskTitleFocused)
                        .onSubmit {
                            isTaskTitleFocused.toggle()
                            isNoteFocused.toggle()
                        }
                    TextField("Notes", text: $note)
                        .focused($isNoteFocused)
                }
                Section {
                    HStack {
                        withAnimation {
                            Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                                .foregroundStyle(isLocked ? Color.accentColor : Color.secondary)
                        }
                        Toggle("Lock Time", isOn: $isLocked)
                    }
                    HStack(spacing: 2) {
                        Picker("Task Duration", selection: $minute) {
                            ForEach(0...60, id: \.self) { value in
                                Text("\(value)").tag(value)
                            }
                        }
                        .pickerStyle(.wheel)
                        .onChange(of: minute) {
                            self.duration = (minute * 60) + second
                            if self.duration == 0 {
                                second = 1
                            }
                        }
                        Text("min")
                            .bold()
                        Picker("Task Duration", selection: $second) {
                            ForEach(0...60, id: \.self) { value in
                                Text("\(value)").tag(value)
                            }
                        }
                        .pickerStyle(.wheel)
                        .onChange(of: second) {
                            self.duration = (minute * 60) + second
                            if self.duration == 0 {
                                second = 1
                            }
                        }
                        Text("sec")
                            .bold()
                    }
                    
                }
                
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") {
                        addNewTask()
                        dismiss()
                    }
                    .disabled(isInputInvalid)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                isTaskTitleFocused.toggle()
            }
        }
    }
    
    private var isInputInvalid: Bool {
        title.isEmpty
    }
    
    private func addNewTask() {
        // Clean title and note
        let cleanedTitle = title
            .trimmingCharacters(in: .whitespacesAndNewlines)           // remove leading/trailing spaces
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression) // collapse multiple spaces
        
        let cleanedNote = note
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        let newTask = Task(
            title: cleanedTitle,
            note: cleanedNote,
            duration: Double(duration),
            isLocked: isLocked,
            order: plan.tasks.count
        )
        
        plan.tasks.append(newTask)
    }
}

struct EditTaskSheetView: View {
    
    let plan: Plan
    let task: Task
    
    @State private var title: String = ""
    @State private var note: String = ""
    @State private var minute: Int = 1
    @State private var second: Int = 0
    @State private var duration: Int = 60
    @State private var isLocked: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Task Title", text: $title)
                    TextField("Notes", text: $note)
                    
                }
                Section {
                    HStack {
                        withAnimation {
                            Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                                .foregroundStyle(isLocked ? Color.accentColor : Color.secondary)
                        }
                        Toggle("Lock Time", isOn: $isLocked)
                    }
                    HStack(spacing: 2) {
                        Picker("Task Duration", selection: $minute) {
                            ForEach(0...60, id: \.self) { value in
                                Text("\(value)").tag(value)
                            }
                        }
                        .pickerStyle(.wheel)
                        .onChange(of: minute) {
                            self.duration = (minute * 60) + second
                            if self.duration == 0 {
                                second = 1
                            }
                        }
                        Text("min")
                            .bold()
                        Picker("Task Duration", selection: $second) {
                            ForEach(0...60, id: \.self) { value in
                                Text("\(value)").tag(value)
                            }
                        }
                        .pickerStyle(.wheel)
                        .onChange(of: second) {
                            self.duration = (minute * 60) + second
                            if self.duration == 0 {
                                second = 1
                            }
                        }
                        Text("sec")
                            .bold()
                    }
                }
            }
            .navigationTitle("Update Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") {
                        updateTask()
                        dismiss()
                    }
                    .disabled(isInputInvalid)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            self.title = task.title
            self.note = task.note
            let totalSeconds = Int(task.duration)
            self.minute = totalSeconds / 60
            self.second = totalSeconds % 60
            self.isLocked = task.isLocked
        }
    }
    
    private func clean(_ text: String) -> String {
        text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
    
    private func updateTask() {
        task.title = clean(title)
        task.note = clean(note)
        task.duration = Double(minute) * 60 + Double(second)
        task.isLocked = isLocked
    }
    
    private var isInputInvalid: Bool {
        title.isEmpty
    }
}

struct EditPlanSheetView: View {
    
    let plan: Plan
    
    @State private var name: String = ""
    
    @Environment(\.modelContext) private var context
    
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var isPlanNameFocused
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Enter Plan Name", text: $name)
                    .focused($isPlanNameFocused)
            }
            .navigationTitle("Rename Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") {
                        updatePlan()
                        dismiss()
                    }
                    .disabled(isInputInvalid)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                isPlanNameFocused.toggle()
            }
        }
        .onAppear {
            name = plan.name
        }
    }
    
    private func updatePlan() {
        
        let cleanedName = name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        plan.name = cleanedName
    }
    
    private var isInputInvalid: Bool {
        name.isEmpty || name == plan.name
    }
}

struct TaskCardView: View {
    let task: Task
    
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            if editMode?.wrappedValue == .inactive {
                Image(systemName: task.isLocked ? "lock.fill" : "lock.open.fill")
                    .foregroundStyle(task.isLocked ? Color.accentColor : Color.secondary.opacity(0.3))
                    .frame(width: 20)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            task.isLocked.toggle()
                        }
                    }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                if !task.note.isEmpty {
                    Text(task.note)
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                }
            }
            if editMode?.wrappedValue == .inactive {
                Spacer()
                Text(task.formattedDuration)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
    }
}
