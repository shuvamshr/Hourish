//
//  PlanView.swift
//  Hourish
//
//  Created by Shuvam Shrestha on 11/11/2025.
//

import SwiftUI
import SwiftData

struct PlanView: View {
    
    @Query private var plans: [Plan]
    
    @State private var showNewPlanSheet: Bool = false
    
    @State private var planKeyword: String = ""
    
    @FocusState private var searchFocus: Bool
    
    var body: some View {
        NavigationStack {
            Group {
                if !searchFocus && filteredPlans.isEmpty {
                    ContentUnavailableView("No Plan Yet", image: "questionmark.text.page.fill", description: Text("Create a plan to get started"))
                }
                else if searchFocus && filteredPlans.isEmpty {
                    ContentUnavailableView.search(text: planKeyword)
                } else {
                    List(filteredPlans) { plan in
                        Section {
                            NavigationLink {
                                TaskView(plan: plan)
                            } label: {
                                PlanCardView(plan: plan)
                            }
                        }
                    }
                    .listSectionSpacing(12)
                }
            }
            .searchable(text: $planKeyword)
            .searchFocused($searchFocus)
            .navigationTitle("My Plans")
            .navigationSubtitle("^[\(planCount) Plan](inflect: true)")
            .sheet(isPresented: $showNewPlanSheet) {
                NewPlanSheetView()
            }
            .toolbar {
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", systemImage: "plus") {
                        showNewPlanSheet.toggle()
                    }
                }
            }
        }
    }
    
    private var planCount: Int {
        plans.count
    }
    
    private var filteredPlans: [Plan] {
        if planKeyword.isEmpty {
            plans
        } else {
            plans.filter({ $0.name.hasPrefix(planKeyword) })
        }
    }
}

struct PlanCardView: View {
    
    let plan: Plan
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(plan.formattedName)
                .font(.headline)
            Text("^[\(plan.taskCount) Task](inflect: true)")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
        }
    }
}



struct NewPlanSheetView: View {
    
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
            .navigationTitle("New Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") {
                        addNewPlan()
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
    }
    
    private func addNewPlan() {
        
        let cleanedName = name
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)

        let newPlan = Plan(name: cleanedName)
        
        context.insert(newPlan)
    }
    
    private var isInputInvalid: Bool {
        name.isEmpty
    }
}


#Preview {
    PlanView()
}
