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

    // Load and merge default ingredients with existing database
    static func loadAndMergeIfNeeded(context: ModelContext) {
        // Load the JSON data
        guard let ingredientsJSON = loadJSONData() else {
            print("❌ Could not load default ingredients JSON")
            return
        }

        // Check if we need to update
        let currentVersion = UserDefaults.standard.integer(forKey: versionKey)
        let bundledVersion = ingredientsJSON.version

        print("📊 Current database version: \(currentVersion), Bundled version: \(bundledVersion)")

        // Check if database is empty (first launch)
        let fetchDescriptor = FetchDescriptor<Ingredient>()
        let existingCount = (try? context.fetchCount(fetchDescriptor)) ?? 0

        if existingCount == 0 {
            // First launch - load all defaults
            print("📦 First launch - loading all default ingredients...")
            loadAllDefaults(from: ingredientsJSON, context: context)
            UserDefaults.standard.set(bundledVersion, forKey: versionKey)
        } else if bundledVersion > currentVersion {
            // Newer version available - merge changes
            print("🔄 Newer version available - merging changes...")
            mergeDefaultIngredients(from: ingredientsJSON, context: context)
            UserDefaults.standard.set(bundledVersion, forKey: versionKey)
        } else {
            print("✓ Database is up to date (version \(currentVersion))")
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

        // Create a map of existing ingredients by name (case-insensitive)
        var existingMap: [String: Ingredient] = [:]
        for ingredient in existingIngredients {
            existingMap[ingredient.name.lowercased()] = ingredient
        }

        var addedCount = 0
        var updatedCount = 0
        var skippedCount = 0

        for ingredientJSON in ingredientsJSON.ingredients {
            let key = ingredientJSON.name.lowercased()

            if let existing = existingMap[key] {
                // Ingredient exists
                if existing.isCustom {
                    // Skip custom ingredients - never modify them
                    skippedCount += 1
                    print("⏭️ Skipping custom ingredient: \(existing.name)")
                } else {
                    // Update default ingredient
                    updateIngredient(existing, from: ingredientJSON, context: context)
                    updatedCount += 1
                    print("🔄 Updated ingredient: \(existing.name)")
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
            print("✅ Merge complete: \(addedCount) added, \(updatedCount) updated, \(skippedCount) custom ingredients preserved")
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
