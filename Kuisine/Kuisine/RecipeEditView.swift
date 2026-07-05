import SwiftUI
import SwiftData

struct RecipeEditView: View {
    @Bindable var recipe: Recipe
    var isNew: Bool = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    private var canSave: Bool {
        !recipe.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section("Recipe") {
                TextField("Title", text: $recipe.title)
                TextField("Short description", text: $recipe.summary, axis: .vertical)
            }
            Section("Ingredients") {
                TextField("One per line…", text: $recipe.ingredients, axis: .vertical)
                    .lineLimit(3...)
            }
            Section("Steps") {
                TextField("How to make it…", text: $recipe.steps, axis: .vertical)
                    .lineLimit(3...)
            }
        }
        .navigationTitle(isNew ? "New Recipe" : "Edit Recipe")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel, action: cancel)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: save).disabled(!canSave)
            }
        }
    }

    private func save() {
        recipe.updatedAt = .now
        dismiss()
    }

    private func cancel() {
        // A brand-new recipe was inserted before editing; discard it if abandoned.
        if isNew {
            context.delete(recipe)
        }
        dismiss()
    }
}
