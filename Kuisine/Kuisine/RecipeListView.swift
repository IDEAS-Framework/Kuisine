import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Recipe.updatedAt, order: .reverse) private var recipes: [Recipe]

    @State private var newRecipe: Recipe?

    var body: some View {
        NavigationStack {
            Group {
                if recipes.isEmpty {
                    ContentUnavailableView {
                        Label("No Recipes Yet", systemImage: "fork.knife")
                    } description: {
                        Text("Add your first recipe, then log the tweaks and experiments you try.")
                    }
                } else {
                    List {
                        ForEach(recipes) { recipe in
                            NavigationLink(value: recipe) {
                                RecipeRow(recipe: recipe)
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("Kuisine")
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: addRecipe) {
                        Label("Add Recipe", systemImage: "plus")
                    }
                }
            }
            .sheet(item: $newRecipe) { recipe in
                NavigationStack {
                    RecipeEditView(recipe: recipe, isNew: true)
                }
            }
        }
    }

    private func addRecipe() {
        let recipe = Recipe()
        context.insert(recipe)
        newRecipe = recipe
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            context.delete(recipes[index])
        }
    }
}

private struct RecipeRow: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(recipe.title.isEmpty ? "Untitled Recipe" : recipe.title)
                .font(.headline)
            if !recipe.summary.isEmpty {
                Text(recipe.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            let count = recipe.experiments?.count ?? 0
            if count > 0 {
                Text(count == 1 ? "1 experiment" : "\(count) experiments")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
