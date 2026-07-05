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
                        Label("Aucune recette", systemImage: "fork.knife")
                    } description: {
                        Text("Ajoutez votre première recette, puis notez les ajustements et expériences que vous tentez.")
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
                        Label("Ajouter une recette", systemImage: "plus")
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
            HStack(spacing: 6) {
                Text(recipe.title.isEmpty ? "Recette sans titre" : recipe.title)
                    .font(.headline)
                if recipe.isVariant {
                    Image(systemName: "arrow.triangle.branch")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            if !recipe.summary.isEmpty {
                Text(recipe.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            let ingredients = recipe.recipeIngredients?.count ?? 0
            let experiments = recipe.experiments?.count ?? 0
            if ingredients > 0 || experiments > 0 {
                Text(subtitle(ingredients: ingredients, experiments: experiments))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private func subtitle(ingredients: Int, experiments: Int) -> String {
        var parts: [String] = []
        if ingredients > 0 {
            parts.append(ingredients == 1 ? "1 ingrédient" : "\(ingredients) ingrédients")
        }
        if experiments > 0 {
            parts.append(experiments == 1 ? "1 expérience" : "\(experiments) expériences")
        }
        return parts.joined(separator: " · ")
    }
}
