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
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Load default ingredients on first launch
            loadDefaultIngredientsIfNeeded(container: container)
            
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
    
    static func loadDefaultIngredientsIfNeeded(container: ModelContainer) {
        let context = ModelContext(container)
        
        // Check if we already have ingredients
        let fetchDescriptor = FetchDescriptor<Ingredient>()
        let existingCount = (try? context.fetchCount(fetchDescriptor)) ?? 0
        
        // Only load defaults if database is empty
        if existingCount == 0 {
            print("📦 Loading default ingredients from JSON...")
            let defaultIngredients = DefaultIngredientDatabase.loadFromJSON()
            
            for ingredient in defaultIngredients {
                context.insert(ingredient)
            }
            
            do {
                try context.save()
                print("✅ Loaded \(defaultIngredients.count) default ingredients")
            } catch {
                print("❌ Error saving ingredients: \(error)")
            }
        } else {
            print("✓ Database already has \(existingCount) ingredients")
        }
    }
}
