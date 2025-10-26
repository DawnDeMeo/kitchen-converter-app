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
            print("❌ Could not load default ingredients JSON")
            return
        }

        // Check if THIS DEVICE has ever loaded defaults before
        let hasLoadedBefore = UserDefaults.standard.bool(forKey: hasLoadedDefaultsKey)
        let currentVersion = UserDefaults.standard.integer(forKey: versionKey)
        let bundledVersion = ingredientsJSON.version

        print("📊 Has loaded before: \(hasLoadedBefore), Current version: \(currentVersion), Bundled version: \(bundledVersion)")

        if !hasLoadedBefore {
            // First launch on this device - load defaults (but check for CloudKit synced duplicates first)
            print("📦 First launch on this device - checking for existing defaults...")

            // Give CloudKit a moment to sync if this is a second device
            let fetchDescriptor = FetchDescriptor<Ingredient>(
                predicate: #Predicate<Ingredient> { ingredient in
                    ingredient.isCustom == false
                }
            )
            let existingDefaultsCount = (try? context.fetchCount(fetchDescriptor)) ?? 0

            if existingDefaultsCount > 0 {
                print("☁️ Found \(existingDefaultsCount) default ingredients from CloudKit sync - skipping load")
                // Mark as loaded even though we didn't load them (they came from CloudKit)
                UserDefaults.standard.set(bundledVersion, forKey: versionKey)
                UserDefaults.standard.set(true, forKey: hasLoadedDefaultsKey)
            } else {
                print("📦 No existing defaults - loading from bundle...")
                loadAllDefaults(from: ingredientsJSON, context: context)
                UserDefaults.standard.set(bundledVersion, forKey: versionKey)
                UserDefaults.standard.set(true, forKey: hasLoadedDefaultsKey)
            }
        } else if bundledVersion > currentVersion {
            // Newer version available - merge changes
            print("🔄 Newer version available - merging changes...")
            mergeDefaultIngredients(from: ingredientsJSON, context: context)
            UserDefaults.standard.set(bundledVersion, forKey: versionKey)
        } else {
            print("✓ Database is up to date (version \(currentVersion))")
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
    private static func deduplicateDefaultIngredients(context: ModelContext) {
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

            print("🔍 Found \(ingredients.count) copies of '\(name)' - keeping best version (favorite: \(toKeep.isFavorite)), deleting \(toDelete.count)")

            // Delete the others
            for ingredient in toDelete {
                context.delete(ingredient)
                deletedCount += 1
            }
        }

        if deletedCount > 0 {
            do {
                try context.save()
                print("✅ Deduplicated \(deletedCount) duplicate default ingredients")
            } catch {
                print("❌ Error saving after deduplication: \(error)")
            }
        } else {
            print("✓ No duplicate default ingredients found")
        }
    }

    // Load JSON data from bundle
    private static func loadJSONData() -> IngredientsJSON? {
        guard let url = Bundle.main.url(forResource: "default_ingredients", withExtension: "json") else {
            print("❌ Could not find default_ingredients.json")
            return nil
        }

        guard let data = try? Data(contentsOf: url) else {
            print("❌ Could not load data from default_ingredients.json")
            return nil
        }

        let decoder = JSONDecoder()
        guard let ingredientsJSON = try? decoder.decode(IngredientsJSON.self, from: data) else {
            print("❌ Could not decode default_ingredients.json")
            return nil
        }

        print("✓ Successfully parsed JSON version \(ingredientsJSON.version) with \(ingredientsJSON.ingredients.count) ingredients")
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
            print("✅ Loaded \(ingredients.count) default ingredients")
        } catch {
            print("❌ Error saving ingredients: \(error)")
        }
    }

    // Merge new/updated defaults with existing database
    private static func mergeDefaultIngredients(from ingredientsJSON: IngredientsJSON, context: ModelContext) {
        // Fetch all existing ingredients
        let fetchDescriptor = FetchDescriptor<Ingredient>()
        guard let existingIngredients = try? context.fetch(fetchDescriptor) else {
            print("❌ Could not fetch existing ingredients")
            return
        }

        // Group existing ingredients by name, preserving both custom and default versions
        var ingredientsByName: [String: [Ingredient]] = [:]
        for ingredient in existingIngredients {
            let key = ingredient.name.lowercased()
            ingredientsByName[key, default: []].append(ingredient)
        }

        var addedCount = 0
        var updatedCount = 0
        var skippedCustomCount = 0

        for ingredientJSON in ingredientsJSON.ingredients {
            let key = ingredientJSON.name.lowercased()

            if let existingGroup = ingredientsByName[key] {
                // Find the default version (if any) and update it
                if let defaultIngredient = existingGroup.first(where: { !$0.isCustom }) {
                    // Update existing default ingredient
                    updateIngredient(defaultIngredient, from: ingredientJSON, context: context)
                    updatedCount += 1
                    print("🔄 Updated default ingredient: \(defaultIngredient.name)")
                } else {
                    // Only custom versions exist - add the default version
                    if let newIngredient = convertJSONToIngredient(ingredientJSON) {
                        context.insert(newIngredient)
                        addedCount += 1
                        print("➕ Added default ingredient (custom version exists): \(newIngredient.name)")
                    }
                }

                // Count custom ingredients we're preserving
                let customCount = existingGroup.filter { $0.isCustom }.count
                if customCount > 0 {
                    skippedCustomCount += customCount
                    for customIng in existingGroup.filter({ $0.isCustom }) {
                        print("✓ Preserving custom ingredient: \(customIng.name) (brand: \(customIng.brand ?? "none"))")
                    }
                }
            } else {
                // New ingredient - add it
                if let newIngredient = convertJSONToIngredient(ingredientJSON) {
                    context.insert(newIngredient)
                    addedCount += 1
                    print("➕ Added new ingredient: \(newIngredient.name)")
                }
            }
        }

        do {
            try context.save()
            print("✅ Merge complete: \(addedCount) added, \(updatedCount) updated, \(skippedCustomCount) custom ingredients preserved")
        } catch {
            print("❌ Error saving merged ingredients: \(error)")
        }
    }

    // Update an existing ingredient with new data
    private static func updateIngredient(_ ingredient: Ingredient, from json: IngredientJSON, context: ModelContext) {
        // Update basic properties (but preserve user preferences like isFavorite)
        ingredient.category = json.category
        ingredient.brand = json.brand

        // Clear old conversions and add new ones
        if ingredient.conversions == nil {
            ingredient.conversions = []
        }
        ingredient.conversions?.removeAll()

        for conversionJSON in json.conversions {
            guard let fromUnit = conversionJSON.fromUnit.toMeasurementUnit(),
                  let toUnit = conversionJSON.toUnit.toMeasurementUnit() else {
                print("⚠️ Could not convert units for \(json.name)")
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
        let ingredient = Ingredient(name: json.name, category: json.category, brand: json.brand, isCustom: false)

        // Ensure conversions array is initialized
        if ingredient.conversions == nil {
            ingredient.conversions = []
        }

        for conversionJSON in json.conversions {
            guard let fromUnit = conversionJSON.fromUnit.toMeasurementUnit(),
                  let toUnit = conversionJSON.toUnit.toMeasurementUnit() else {
                print("⚠️ Could not convert units for \(json.name)")
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
