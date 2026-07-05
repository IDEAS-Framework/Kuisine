import SwiftUI
import SwiftData

@main
struct Kuisine: App {
    let container: ModelContainer

    init() {
        let schema = Schema([
            Recipe.self, RecipeIngredient.self, Ingredient.self,
            MeasureUnit.self, Step.self, Experiment.self,
        ])
        // Sync each user's own recipes across their devices via the CloudKit
        // private database. Family sharing (shared DB) is a later phase — see backlog.
        let configuration = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .private("iCloud.com.ideasframework.kuisine")
        )
        do {
            container = try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("Failed to create the SwiftData/CloudKit container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RecipeListView()
        }
        .modelContainer(container)
    }
}
