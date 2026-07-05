import SwiftUI
import SwiftData

struct ExperimentEditView: View {
    @Bindable var experiment: Experiment
    var isNew: Bool = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    private var canSave: Bool {
        !experiment.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section("What did you try?") {
                TextField("Title (e.g. More garlic)", text: $experiment.title)
                TextField("Notes — what you changed", text: $experiment.notes, axis: .vertical)
                    .lineLimit(3...)
            }
            Section("How did it go?") {
                TextField("Outcome", text: $experiment.outcome, axis: .vertical)
                    .lineLimit(2...)
                Stepper(value: $experiment.rating, in: 0...5) {
                    HStack {
                        Text("Rating")
                        Spacer()
                        Text(experiment.rating == 0 ? "—" : String(repeating: "★", count: experiment.rating))
                            .foregroundStyle(.secondary)
                    }
                }
                Toggle("Keeper — fold into the recipe", isOn: $experiment.keep)
            }
            Section {
                DatePicker("Date", selection: $experiment.date, displayedComponents: .date)
            }
        }
        .navigationTitle(isNew ? "New Experiment" : "Edit Experiment")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel, action: cancel)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { dismiss() }.disabled(!canSave)
            }
        }
    }

    private func cancel() {
        if isNew {
            context.delete(experiment)
        }
        dismiss()
    }
}
