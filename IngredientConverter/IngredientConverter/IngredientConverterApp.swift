//
//  IngredientConverterApp.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/5/25.
//

import SwiftUI
import SwiftData

@main
struct IngredientConverterApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Ingredient.self,
            UnitConversion.self
        ])

        // Enable CloudKit syncing for automatic iCloud sync across devices
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // Load/merge default ingredients with version tracking
            let context = ModelContext(container)
            DefaultIngredientDatabase.loadAndMergeIfNeeded(context: context)

            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
