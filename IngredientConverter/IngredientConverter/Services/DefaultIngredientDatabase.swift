//
//  DefaultIngredientDatabase.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/5/25.
//

import Foundation
import SwiftData

struct DefaultIngredientDatabase {
    private static let versionKey = "defaultIngredientsDatabaseVersion"
    private static let hasLoadedDefaultsKey = "hasLoadedDefaultIngredientsOnce"

    // Load and merge default ingredients with existing database
    static func loadAndMergeIfNeeded(context: ModelContext) {
        // Load the JSON data
        guard let ingredientsJSON = loadJSONData() else {
            DebugLogger.log("❌ Could not load default ingredients JSON", category: "Database")
            return
        }

        // Check if THIS DEVICE has ever loaded defaults before
        let hasLoadedBefore = UserDefaults.standard.bool(forKey: hasLoadedDefaultsKey)
        let currentVersion = UserDefaults.standard.integer(forKey: versionKey)
        let bundledVersion = ingredientsJSON.version

        DebugLogger.log("📊 Has loaded before: \(hasLoadedBefore), Current version: \(currentVersion), Bundled version: \(bundledVersion)", category: "Database")

        if !hasLoadedBefore {
            // First launch on this device - load defaults (but check for CloudKit synced duplicates first)
            DebugLogger.log("📦 First launch on this device - checking for existing defaults...", category: "Database")

            // Give CloudKit a moment to sync if this is a second device
            let fetchDescriptor = FetchDescriptor<Ingredient>(
                predicate: #Predicate<Ingredient> { ingredient in
                    ingredient.isCustom == false
                }
            )
            let existingDefaultsCount = (try? context.fetchCount(fetchDescriptor)) ?? 0

            if existingDefaultsCount > 0 {
                DebugLogger.log("☁️ Found \(existingDefaultsCount) default ingredients from CloudKit sync - skipping load", category: "Database")
                // Mark as loaded even though we didn't load them (they came from CloudKit)
                UserDefaults.standard.set(bundledVersion, forKey: versionKey)
                UserDefaults.standard.set(true, forKey: hasLoadedDefaultsKey)
            } else {
                DebugLogger.log("📦 No existing defaults - loading from bundle...", category: "Database")
                loadAllDefaults(from: ingredientsJSON, context: context)
                UserDefaults.standard.set(bundledVersion, forKey: versionKey)
                UserDefaults.standard.set(true, forKey: hasLoadedDefaultsKey)
            }
        } else if bundledVersion > currentVersion {
            // Newer version available - merge changes
            DebugLogger.log("🔄 Newer version available - merging changes...", category: "Database")
            mergeDefaultIngredients(from: ingredientsJSON, context: context)
            UserDefaults.standard.set(bundledVersion, forKey: versionKey)
        } else {
            DebugLogger.log("✓ Database is up to date (version \(currentVersion))", category: "Database")
        }

        // Always deduplicate default ingredients after load (handles CloudKit sync duplicates)
        deduplicateDefaultIngredients(context: context)
    }

    // Choose the best duplicate to keep - prioritizes user preferences
    private static func chooseBestDuplicate(from ingredients: [Ingredient]) -> Ingredient {
        // Priority 1: Keep favorited ingredient
        if let favorited = ingredients.first(where: { $0.isFavorite }) {
            return favorited
        }

        // Priority 2: Keep ingredient with most recent lastUsedDate
        let withUsageDate = ingredients.filter { $0.lastUsedDate != nil }
        if let mostRecentlyUsed = withUsageDate.max(by: { ($0.lastUsedDate ?? .distantPast) < ($1.lastUsedDate ?? .distantPast) }) {
            return mostRecentlyUsed
        }

        // Priority 3: Keep the first one
        return ingredients[0]
    }

    // Remove duplicate default ingredients (happens when multiple devices load defaults before CloudKit syncs)
    // Internal for testing
    internal static func deduplicateDefaultIngredients(context: ModelContext) {
        let fetchDescriptor = FetchDescriptor<Ingredient>(
            predicate: #Predicate<Ingredient> { ingredient in
                ingredient.isCustom == false
            },
            sortBy: [SortDescriptor(\.name)]
        )

        guard let allDefaults = try? context.fetch(fetchDescriptor) else {
            return
        }

        // Group by name (case-insensitive)
        var nameGroups: [String: [Ingredient]] = [:]
        for ingredient in allDefaults {
            let key = ingredient.name.lowercased()
            nameGroups[key, default: []].append(ingredient)
        }

        // Find and remove duplicates
        var deletedCount = 0
        for (name, ingredients) in nameGroups where ingredients.count > 1 {
            // Choose which duplicate to keep based on user preferences
            let toKeep = chooseBestDuplicate(from: ingredients)
            let toDelete = ingredients.filter { $0.id != toKeep.id }

            DebugLogger.log("🔍 Found \(ingredients.count) copies of '\(name)' - keeping best version (favorite: \(toKeep.isFavorite)), deleting \(toDelete.count)", category: "Database")

            // Delete the others
            for ingredient in toDelete {
                context.delete(ingredient)
                deletedCount += 1
            }
        }

        if deletedCount > 0 {
            do {
                try context.save()
                DebugLogger.log("✅ Deduplicated \(deletedCount) duplicate default ingredients", category: "Database")
            } catch {
                DebugLogger.log("❌ Error saving after deduplication: \(error)", category: "Database")
            }
        } else {
            DebugLogger.log("✓ No duplicate default ingredients found", category: "Database")
        }
    }

    // Load JSON data from bundle
    private static func loadJSONData() -> IngredientsJSON? {
        guard let url = Bundle.main.url(forResource: "default_ingredients", withExtension: "json") else {
            DebugLogger.log("❌ Could not find default_ingredients.json", category: "Database")
            return nil
        }

        guard let data = try? Data(contentsOf: url) else {
            DebugLogger.log("❌ Could not load data from default_ingredients.json", category: "Database")
            return nil
        }

        let decoder = JSONDecoder()
        guard let ingredientsJSON = try? decoder.decode(IngredientsJSON.self, from: data) else {
            DebugLogger.log("❌ Could not decode default_ingredients.json", category: "Database")
            return nil
        }

        DebugLogger.log("✓ Successfully parsed JSON version \(ingredientsJSON.version) with \(ingredientsJSON.ingredients.count) ingredients", category: "Database")
        return ingredientsJSON
    }

    // Load all defaults (first launch)
    private static func loadAllDefaults(from ingredientsJSON: IngredientsJSON, context: ModelContext) {
        let ingredients = ingredientsJSON.ingredients.compactMap { ingredientJSON in
            convertJSONToIngredient(ingredientJSON)
        }

        for ingredient in ingredients {
            context.insert(ingredient)
        }

        do {
            try context.save()
            DebugLogger.log("✅ Loaded \(ingredients.count) default ingredients", category: "Database")
        } catch {
            DebugLogger.log("❌ Error saving ingredients: \(error)", category: "Database")
        }
    }

    // Merge new/updated defaults with existing database
    // Internal for testing
    internal static func mergeDefaultIngredients(from ingredientsJSON: IngredientsJSON, context: ModelContext) {
        // Fetch all existing ingredients
        let fetchDescriptor = FetchDescriptor<Ingredient>()
        guard let existingIngredients = try? context.fetch(fetchDescriptor) else {
            DebugLogger.log("❌ Could not fetch existing ingredients", category: "Database")
            return
        }

        // Create indexes for both ID-based and name-based lookups
        var ingredientsByDefaultId: [String: Ingredient] = [:]
        var ingredientsByName: [String: [Ingredient]] = [:]

        for ingredient in existingIngredients {
            // Index by defaultId (only for default ingredients with IDs)
            if !ingredient.isCustom, let defaultId = ingredient.defaultId {
                ingredientsByDefaultId[defaultId] = ingredient
            }

            // Index by name for fallback matching
            let key = ingredient.name.lowercased()
            ingredientsByName[key, default: []].append(ingredient)
        }

        var addedCount = 0
        var updatedCount = 0
        var renamedCount = 0
        var skippedCustomCount = 0

        for ingredientJSON in ingredientsJSON.ingredients {
            var matchedIngredient: Ingredient?
            var matchType: String = ""

            // Strategy 1: Match by defaultId (most reliable, handles renames)
            if let jsonId = ingredientJSON.id, let existing = ingredientsByDefaultId[jsonId] {
                matchedIngredient = existing
                matchType = "ID"

                // Check if name changed
                if existing.name != ingredientJSON.name {
                    renamedCount += 1
                    DebugLogger.log("🏷️  Detected rename: '\(existing.name)' → '\(ingredientJSON.name)'", category: "Database")
                }
            }
            // Strategy 2: Fall back to name matching (for backward compatibility)
            else if let existingGroup = ingredientsByName[ingredientJSON.name.lowercased()] {
                // Find the default version (if any)
                matchedIngredient = existingGroup.first(where: { !$0.isCustom })
                matchType = "name"

                // Count custom ingredients we're preserving
                let customCount = existingGroup.filter { $0.isCustom }.count
                if customCount > 0 {
                    skippedCustomCount += customCount
                    for customIng in existingGroup.filter({ $0.isCustom }) {
                        DebugLogger.log("✓ Preserving custom ingredient: \(customIng.name) (brand: \(customIng.brand ?? "none"))", category: "Database")
                    }
                }
            }

            // Update or add ingredient
            if let existing = matchedIngredient {
                // Update existing default ingredient
                updateIngredient(existing, from: ingredientJSON, context: context)
                updatedCount += 1
                DebugLogger.log("🔄 Updated ingredient (matched by \(matchType)): \(ingredientJSON.name)", category: "Database")
            } else {
                // New ingredient - add it
                if let newIngredient = convertJSONToIngredient(ingredientJSON) {
                    context.insert(newIngredient)
                    addedCount += 1
                    DebugLogger.log("➕ Added new ingredient: \(newIngredient.name)", category: "Database")
                }
            }
        }

        do {
            try context.save()
            DebugLogger.log("✅ Merge complete: \(addedCount) added, \(updatedCount) updated, \(renamedCount) renamed, \(skippedCustomCount) custom ingredients preserved", category: "Database")
        } catch {
            DebugLogger.log("❌ Error saving merged ingredients: \(error)", category: "Database")
        }
    }

    // Update an existing ingredient with new data
    private static func updateIngredient(_ ingredient: Ingredient, from json: IngredientJSON, context: ModelContext) {
        // Update basic properties (but preserve user preferences like isFavorite)
        ingredient.name = json.name  // Update name in case it changed
        ingredient.category = json.category
        ingredient.brand = json.brand
        ingredient.defaultId = json.id  // Update/set the defaultId

        // Clear old conversions and add new ones
        if ingredient.conversions == nil {
            ingredient.conversions = []
        }
        ingredient.conversions?.removeAll()

        for conversionJSON in json.conversions {
            guard let fromUnit = conversionJSON.fromUnit.toMeasurementUnit(),
                  let toUnit = conversionJSON.toUnit.toMeasurementUnit() else {
                DebugLogger.log("⚠️ Could not convert units for \(json.name)", category: "Database")
                continue
            }

            let conversion = UnitConversion(
                fromAmount: conversionJSON.fromAmount,
                fromUnit: fromUnit,
                toAmount: conversionJSON.toAmount,
                toUnit: toUnit
            )
            ingredient.conversions?.append(conversion)
        }
    }

    // Convert JSON to Ingredient model
    private static func convertJSONToIngredient(_ json: IngredientJSON) -> Ingredient? {
        let ingredient = Ingredient(name: json.name, category: json.category, brand: json.brand, isCustom: false, defaultId: json.id)

        // Ensure conversions array is initialized
        if ingredient.conversions == nil {
            ingredient.conversions = []
        }

        for conversionJSON in json.conversions {
            guard let fromUnit = conversionJSON.fromUnit.toMeasurementUnit(),
                  let toUnit = conversionJSON.toUnit.toMeasurementUnit() else {
                DebugLogger.log("⚠️ Could not convert units for \(json.name)", category: "Database")
                continue
            }

            let conversion = UnitConversion(
                fromAmount: conversionJSON.fromAmount,
                fromUnit: fromUnit,
                toAmount: conversionJSON.toAmount,
                toUnit: toUnit
            )
            ingredient.conversions?.append(conversion)
        }

        return ingredient
    }

    // Legacy method for backward compatibility
    static func loadFromJSON() -> [Ingredient] {
        guard let ingredientsJSON = loadJSONData() else {
            return []
        }

        return ingredientsJSON.ingredients.compactMap { ingredientJSON in
            convertJSONToIngredient(ingredientJSON)
        }
    }
}
