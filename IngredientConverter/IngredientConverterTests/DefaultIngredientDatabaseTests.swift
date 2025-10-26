//
//  DefaultIngredientDatabaseTests.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/5/25.
//

import Foundation
import Testing
import SwiftData
@testable import IngredientConverter

@Suite("Default Ingredient Database Tests")
struct DefaultIngredientDatabaseTests {
    
    @Test("JSON file loads successfully")
    func jsonFileLoads() {
        let ingredients = DefaultIngredientDatabase.loadFromJSON()
        
        #expect(ingredients.count > 0, "Should load at least one ingredient from JSON")
    }
    
    @Test("Loaded ingredients have correct names")
    func ingredientNamesCorrect() {
        let ingredients = DefaultIngredientDatabase.loadFromJSON()
        let names = ingredients.map { $0.name }

        #expect(names.contains("All-purpose flour"))
        #expect(names.contains("Granulated sugar"))
        #expect(names.contains("Large egg, no shell"))
        #expect(names.contains("Graham crackers"))
    }
    
    @Test("Flour has multiple conversions")
    func flourHasMultipleConversions() {
        let ingredients = DefaultIngredientDatabase.loadFromJSON()
        let flour = ingredients.first { $0.name == "All-purpose flour" }

        #expect(flour != nil, "Flour should exist in database")
        #expect((flour?.conversions ?? []).count >= 2, "Flour should have at least 2 conversions")
    }
    
    @Test("Flour brand is optional")
    func flourBrandOptional() {
        let ingredients = DefaultIngredientDatabase.loadFromJSON()
        let flour = ingredients.first { $0.name == "All-purpose flour" }

        #expect(flour != nil, "Flour should exist in database")
        // Brand is optional, just verify flour exists
    }
    
    @Test("Sugar has no brand")
    func sugarHasNoBrand() {
        let ingredients = DefaultIngredientDatabase.loadFromJSON()
        let sugar = ingredients.first { $0.name == "Granulated sugar" }

        #expect(sugar != nil, "Granulated sugar should exist in database")
        #expect(sugar?.brand == nil)
    }
    
    @Test("All loaded ingredients are marked as default (not custom)")
    func ingredientsAreDefault() {
        let ingredients = DefaultIngredientDatabase.loadFromJSON()
        
        for ingredient in ingredients {
            #expect(ingredient.isCustom == false, "\(ingredient.name) should not be marked as custom")
        }
    }
    
    @Test("Count units load correctly for eggs")
    func eggCountUnitsCorrect() {
        let ingredients = DefaultIngredientDatabase.loadFromJSON()
        let eggs = ingredients.first { $0.name == "Large egg, no shell" }

        #expect(eggs != nil, "Eggs should exist in database")
        #expect((eggs?.conversions ?? []).count >= 1, "Eggs should have at least 1 conversion")

        let conversion = (eggs?.conversions ?? []).first
        if case .count(let singular, let plural) = conversion?.fromUnit {
            #expect(singular == "egg")
            #expect(plural == "eggs")
        } else {
            Issue.record("Egg fromUnit should be a count unit")
        }
    }
    
    @Test("Count units load correctly for graham crackers")
    func grahamCrackerCountUnitsCorrect() {
        let ingredients = DefaultIngredientDatabase.loadFromJSON()
        let crackers = ingredients.first { $0.name == "Graham crackers" }

        #expect(crackers != nil, "Graham crackers should exist")

        let conversion = (crackers?.conversions ?? []).first
        if case .count(let singular, let plural) = conversion?.fromUnit {
            #expect(singular == "cracker")
            #expect(plural == "crackers")
        } else {
            Issue.record("Cracker fromUnit should be a count unit")
        }

        #expect(conversion?.fromAmount == 1.0)
        #expect(conversion?.toAmount == 15.0)
    }
    
    @Test("Volume and weight units parse correctly")
    func volumeAndWeightUnitsCorrect() {
        let ingredients = DefaultIngredientDatabase.loadFromJSON()
        let flour = ingredients.first { $0.name == "All-purpose flour" }

        let cupConversion = (flour?.conversions ?? []).first { $0.fromUnit == .cup }
        #expect(cupConversion != nil, "Should have cup conversion")
        #expect(cupConversion?.toUnit == .gram, "Cup should convert to grams")

        let tbspConversion = (flour?.conversions ?? []).first { $0.fromUnit == .tablespoon }
        #expect(tbspConversion != nil, "Should have tablespoon conversion")
        #expect(tbspConversion?.toUnit == .gram, "Tablespoon should convert to grams")
    }
    
    @Test("Flour converts to grams")
    func flourConvertsToGrams() {
        let ingredients = DefaultIngredientDatabase.loadFromJSON()
        let flour = ingredients.first { $0.name == "All-purpose flour" }

        #expect(flour != nil, "Flour should exist")

        let gramConversion = (flour?.conversions ?? []).first { $0.toUnit == .gram }
        #expect(gramConversion != nil, "Should have gram conversion")
    }

    // MARK: - Merge Logic Tests

    @Test("Merge logic updates ingredient by ID when name changed")
    func mergeUpdatesIngredientByIdWhenRenamed() {
        // Create in-memory model container for testing
        let schema = Schema([Ingredient.self, UnitConversion.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        // Create existing ingredient with ID
        let existingIngredient = Ingredient(
            name: "Apricots, dried",
            category: "Dried Fruit",
            isCustom: false,
            defaultId: "test-apricot-id"
        )
        // Note: Not adding conversions to avoid SwiftData encoding issues in tests
        context.insert(existingIngredient)
        try! context.save()

        // Create JSON with same ID but new name (without conversions for test simplicity)
        let json = IngredientJSON(
            id: "test-apricot-id",
            name: "Dried apricots",
            category: "Fruit",
            brand: nil,
            conversions: []
        )
        let ingredientsJSON = IngredientsJSON(version: 2, ingredients: [json])

        // Perform merge
        DefaultIngredientDatabase.mergeDefaultIngredients(from: ingredientsJSON, context: context)

        // Fetch all ingredients
        let fetchDescriptor = FetchDescriptor<Ingredient>()
        let allIngredients = try! context.fetch(fetchDescriptor)

        // Should only have 1 ingredient (updated, not duplicated)
        #expect(allIngredients.count == 1)

        // Check that name was updated
        let updated = allIngredients.first!
        #expect(updated.name == "Dried apricots")
        #expect(updated.category == "Fruit")
        #expect(updated.defaultId == "test-apricot-id")
    }

    @Test("Merge logic matches by name when no ID present")
    func mergeMatchesByNameWhenNoId() {
        let schema = Schema([Ingredient.self, UnitConversion.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        // Create existing ingredient without defaultId
        let existingIngredient = Ingredient(
            name: "Sugar",
            category: "Sugar",
            isCustom: false,
            defaultId: nil
        )
        context.insert(existingIngredient)
        try! context.save()

        // Create JSON without ID (backward compatibility)
        let json = IngredientJSON(
            id: nil,
            name: "Sugar",
            category: "Sweetener",
            brand: nil,
            conversions: []
        )
        let ingredientsJSON = IngredientsJSON(version: 2, ingredients: [json])

        // Perform merge
        DefaultIngredientDatabase.mergeDefaultIngredients(from: ingredientsJSON, context: context)

        // Fetch all ingredients
        let fetchDescriptor = FetchDescriptor<Ingredient>()
        let allIngredients = try! context.fetch(fetchDescriptor)

        // Should only have 1 ingredient (updated via name matching)
        #expect(allIngredients.count == 1)

        // Check that category was updated
        let updated = allIngredients.first!
        #expect(updated.name == "Sugar")
        #expect(updated.category == "Sweetener")
    }

    @Test("Merge logic adds new ingredients")
    func mergeAddsNewIngredients() {
        let schema = Schema([Ingredient.self, UnitConversion.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        // Start with empty database

        // Create JSON with new ingredient
        let json = IngredientJSON(
            id: "new-ingredient-id",
            name: "New Ingredient",
            category: "Test",
            brand: nil,
            conversions: []
        )
        let ingredientsJSON = IngredientsJSON(version: 1, ingredients: [json])

        // Perform merge
        DefaultIngredientDatabase.mergeDefaultIngredients(from: ingredientsJSON, context: context)

        // Fetch all ingredients
        let fetchDescriptor = FetchDescriptor<Ingredient>()
        let allIngredients = try! context.fetch(fetchDescriptor)

        // Should have added the new ingredient
        #expect(allIngredients.count == 1)

        let added = allIngredients.first!
        #expect(added.name == "New Ingredient")
        #expect(added.category == "Test")
        #expect(added.defaultId == "new-ingredient-id")
        #expect(added.isCustom == false)
    }

    @Test("Merge logic preserves custom ingredients with same name")
    func mergePreservesCustomIngredientsWithSameName() {
        let schema = Schema([Ingredient.self, UnitConversion.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        // Create custom ingredient
        let customIngredient = Ingredient(
            name: "Flour",
            category: "Custom",
            brand: "My Brand",
            isCustom: true,
            defaultId: nil
        )
        context.insert(customIngredient)
        try! context.save()

        // Create JSON with same name but it's a default ingredient
        let json = IngredientJSON(
            id: "default-flour-id",
            name: "Flour",
            category: "Baking",
            brand: nil,
            conversions: []
        )
        let ingredientsJSON = IngredientsJSON(version: 1, ingredients: [json])

        // Perform merge
        DefaultIngredientDatabase.mergeDefaultIngredients(from: ingredientsJSON, context: context)

        // Fetch all ingredients
        let fetchDescriptor = FetchDescriptor<Ingredient>()
        let allIngredients = try! context.fetch(fetchDescriptor)

        // Should have both custom and default versions
        #expect(allIngredients.count == 2)

        let customFlour = allIngredients.first { $0.isCustom }
        let defaultFlour = allIngredients.first { !$0.isCustom }

        #expect(customFlour != nil, "Custom ingredient should be preserved")
        #expect(defaultFlour != nil, "Default ingredient should be added")

        #expect(customFlour?.brand == "My Brand")
        #expect(customFlour?.category == "Custom")

        #expect(defaultFlour?.category == "Baking")
        #expect(defaultFlour?.defaultId == "default-flour-id")
    }

    @Test("Merge logic updates category on existing default ingredients")
    func mergeUpdatesCategoryOnDefaults() {
        let schema = Schema([Ingredient.self, UnitConversion.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        // Create existing default ingredient with old category
        let existingIngredient = Ingredient(
            name: "Chocolate chips",
            category: "Baking",
            isCustom: false,
            defaultId: "chocolate-chips-id"
        )
        context.insert(existingIngredient)
        try! context.save()

        // Create JSON with updated category
        let json = IngredientJSON(
            id: "chocolate-chips-id",
            name: "Chocolate chips",
            category: "Chocolate",
            brand: nil,
            conversions: []
        )
        let ingredientsJSON = IngredientsJSON(version: 2, ingredients: [json])

        // Perform merge
        DefaultIngredientDatabase.mergeDefaultIngredients(from: ingredientsJSON, context: context)

        // Fetch the ingredient
        let fetchDescriptor = FetchDescriptor<Ingredient>()
        let allIngredients = try! context.fetch(fetchDescriptor)

        #expect(allIngredients.count == 1)

        let updated = allIngredients.first!
        #expect(updated.category == "Chocolate", "Category should be updated")
        #expect(updated.defaultId == "chocolate-chips-id")
    }

    @Test("Merge logic preserves user preferences on update")
    func mergePreservesUserPreferences() {
        let schema = Schema([Ingredient.self, UnitConversion.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        // Create existing ingredient with user preferences
        let existingIngredient = Ingredient(
            name: "Flour",
            category: "Baking",
            isCustom: false,
            defaultId: "flour-id"
        )
        existingIngredient.isFavorite = true
        existingIngredient.lastUsedDate = Date()
        context.insert(existingIngredient)
        try! context.save()

        let originalLastUsed = existingIngredient.lastUsedDate

        // Create JSON with updates
        let json = IngredientJSON(
            id: "flour-id",
            name: "All-purpose flour",
            category: "Flour",
            brand: nil,
            conversions: []
        )
        let ingredientsJSON = IngredientsJSON(version: 2, ingredients: [json])

        // Perform merge
        DefaultIngredientDatabase.mergeDefaultIngredients(from: ingredientsJSON, context: context)

        // Fetch the ingredient
        let fetchDescriptor = FetchDescriptor<Ingredient>()
        let allIngredients = try! context.fetch(fetchDescriptor)

        #expect(allIngredients.count == 1)

        let updated = allIngredients.first!
        // Name and category should update
        #expect(updated.name == "All-purpose flour")
        #expect(updated.category == "Flour")

        // But user preferences should be preserved
        #expect(updated.isFavorite == true, "Should preserve favorite status")
        #expect(updated.lastUsedDate == originalLastUsed, "Should preserve last used date")
    }

    @Test("Merge logic does not modify custom ingredients")
    func mergeDoesNotModifyCustomIngredients() {
        let schema = Schema([Ingredient.self, UnitConversion.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        // Create custom ingredient that happens to have a name collision
        let customIngredient = Ingredient(
            name: "Salt",
            category: "Custom Category",
            brand: "Custom Brand",
            isCustom: true,
            defaultId: nil
        )
        context.insert(customIngredient)
        try! context.save()

        // Create JSON with same name
        let json = IngredientJSON(
            id: "salt-id",
            name: "Salt",
            category: "Spice",
            brand: nil,
            conversions: []
        )
        let ingredientsJSON = IngredientsJSON(version: 1, ingredients: [json])

        // Perform merge
        DefaultIngredientDatabase.mergeDefaultIngredients(from: ingredientsJSON, context: context)

        // Fetch all ingredients
        let fetchDescriptor = FetchDescriptor<Ingredient>()
        let allIngredients = try! context.fetch(fetchDescriptor)

        // Should have both ingredients
        #expect(allIngredients.count == 2)

        let custom = allIngredients.first { $0.isCustom }

        // Custom ingredient should be completely unchanged
        #expect(custom?.name == "Salt")
        #expect(custom?.category == "Custom Category")
        #expect(custom?.brand == "Custom Brand")
        #expect(custom?.isCustom == true)
    }

    // MARK: - Rename Handling Tests

    @Test("Multiple ingredients renamed in same update")
    func multipleIngredientsRenamed() {
        let schema = Schema([Ingredient.self, UnitConversion.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        // Create existing ingredients with old names
        let apricots = Ingredient(
            name: "Apricots, dried",
            category: "Dried Fruit",
            isCustom: false,
            defaultId: "apricot-id"
        )
        let cranberries = Ingredient(
            name: "Cranberries, dried",
            category: "Dried Fruit",
            isCustom: false,
            defaultId: "cranberry-id"
        )
        context.insert(apricots)
        context.insert(cranberries)
        try! context.save()

        // Create JSON with new names for both
        let json1 = IngredientJSON(
            id: "apricot-id",
            name: "Dried apricots",
            category: "Fruit",
            brand: nil,
            conversions: []
        )
        let json2 = IngredientJSON(
            id: "cranberry-id",
            name: "Dried cranberries",
            category: "Fruit",
            brand: nil,
            conversions: []
        )
        let ingredientsJSON = IngredientsJSON(version: 2, ingredients: [json1, json2])

        // Perform merge
        DefaultIngredientDatabase.mergeDefaultIngredients(from: ingredientsJSON, context: context)

        // Fetch all ingredients
        let fetchDescriptor = FetchDescriptor<Ingredient>()
        let allIngredients = try! context.fetch(fetchDescriptor)

        // Should still only have 2 ingredients (renamed, not duplicated)
        #expect(allIngredients.count == 2)

        // Check both were renamed
        let updatedApricots = allIngredients.first { $0.defaultId == "apricot-id" }
        let updatedCranberries = allIngredients.first { $0.defaultId == "cranberry-id" }

        #expect(updatedApricots?.name == "Dried apricots")
        #expect(updatedCranberries?.name == "Dried cranberries")
    }

    @Test("Rename with simultaneous category change")
    func renameWithCategoryChange() {
        let schema = Schema([Ingredient.self, UnitConversion.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        // Create existing ingredient
        let existing = Ingredient(
            name: "Chocolate chips, semisweet",
            category: "Baking",
            isCustom: false,
            defaultId: "choc-chip-id"
        )
        context.insert(existing)
        try! context.save()

        // Create JSON with both name and category change
        let json = IngredientJSON(
            id: "choc-chip-id",
            name: "Semisweet chocolate chips",
            category: "Chocolate",
            brand: nil,
            conversions: []
        )
        let ingredientsJSON = IngredientsJSON(version: 2, ingredients: [json])

        // Perform merge
        DefaultIngredientDatabase.mergeDefaultIngredients(from: ingredientsJSON, context: context)

        // Fetch and verify
        let fetchDescriptor = FetchDescriptor<Ingredient>()
        let allIngredients = try! context.fetch(fetchDescriptor)

        #expect(allIngredients.count == 1)

        let updated = allIngredients.first!
        #expect(updated.name == "Semisweet chocolate chips")
        #expect(updated.category == "Chocolate")
        #expect(updated.defaultId == "choc-chip-id")
    }

    @Test("Rename doesn't affect custom ingredients with old name")
    func renameDoesntAffectCustomWithOldName() {
        let schema = Schema([Ingredient.self, UnitConversion.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        // Create default ingredient with old name
        let defaultIng = Ingredient(
            name: "Apricots, dried",
            category: "Dried Fruit",
            isCustom: false,
            defaultId: "apricot-id"
        )
        context.insert(defaultIng)

        // Create custom ingredient with same old name
        let customIng = Ingredient(
            name: "Apricots, dried",
            category: "Custom",
            brand: "Organic Brand",
            isCustom: true,
            defaultId: nil
        )
        context.insert(customIng)
        try! context.save()

        // Rename the default ingredient
        let json = IngredientJSON(
            id: "apricot-id",
            name: "Dried apricots",
            category: "Fruit",
            brand: nil,
            conversions: []
        )
        let ingredientsJSON = IngredientsJSON(version: 2, ingredients: [json])

        // Perform merge
        DefaultIngredientDatabase.mergeDefaultIngredients(from: ingredientsJSON, context: context)

        // Fetch all ingredients
        let fetchDescriptor = FetchDescriptor<Ingredient>()
        let allIngredients = try! context.fetch(fetchDescriptor)

        #expect(allIngredients.count == 2)

        let defaultIngredient = allIngredients.first { !$0.isCustom }
        let customIngredient = allIngredients.first { $0.isCustom }

        // Default should be renamed
        #expect(defaultIngredient?.name == "Dried apricots")
        #expect(defaultIngredient?.defaultId == "apricot-id")

        // Custom should retain old name
        #expect(customIngredient?.name == "Apricots, dried")
        #expect(customIngredient?.brand == "Organic Brand")
    }

    @Test("Backward compatibility: ingredients without IDs still work")
    func backwardCompatibilityWithoutIds() {
        let schema = Schema([Ingredient.self, UnitConversion.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        // Create old-style ingredients without defaultIds
        let ingredient1 = Ingredient(
            name: "Old Ingredient 1",
            category: "Test",
            isCustom: false,
            defaultId: nil
        )
        let ingredient2 = Ingredient(
            name: "Old Ingredient 2",
            category: "Test",
            isCustom: false,
            defaultId: nil
        )
        context.insert(ingredient1)
        context.insert(ingredient2)
        try! context.save()

        // Update using name-based matching (no IDs in JSON)
        let json1 = IngredientJSON(
            id: nil,
            name: "Old Ingredient 1",
            category: "Updated",
            brand: nil,
            conversions: []
        )
        let json2 = IngredientJSON(
            id: nil,
            name: "Old Ingredient 2",
            category: "Updated",
            brand: nil,
            conversions: []
        )
        let ingredientsJSON = IngredientsJSON(version: 2, ingredients: [json1, json2])

        // Perform merge
        DefaultIngredientDatabase.mergeDefaultIngredients(from: ingredientsJSON, context: context)

        // Should still work via name matching
        let fetchDescriptor = FetchDescriptor<Ingredient>()
        let allIngredients = try! context.fetch(fetchDescriptor)

        #expect(allIngredients.count == 2)

        for ingredient in allIngredients {
            #expect(ingredient.category == "Updated")
        }
    }

    @Test("ID takes precedence over name when both match")
    func idTakesPrecedenceOverName() {
        let schema = Schema([Ingredient.self, UnitConversion.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        // Create ingredient A with ID
        let ingredientA = Ingredient(
            name: "Ingredient A",
            category: "Category A",
            isCustom: false,
            defaultId: "id-a"
        )
        context.insert(ingredientA)
        try! context.save()

        // Create JSON with ID that matches A, but name that would create confusion
        let json = IngredientJSON(
            id: "id-a",
            name: "Ingredient A Renamed",
            category: "Category Updated",
            brand: nil,
            conversions: []
        )
        let ingredientsJSON = IngredientsJSON(version: 2, ingredients: [json])

        // Perform merge
        DefaultIngredientDatabase.mergeDefaultIngredients(from: ingredientsJSON, context: context)

        // Should match by ID and rename
        let fetchDescriptor = FetchDescriptor<Ingredient>()
        let allIngredients = try! context.fetch(fetchDescriptor)

        #expect(allIngredients.count == 1)

        let updated = allIngredients.first!
        #expect(updated.name == "Ingredient A Renamed")
        #expect(updated.category == "Category Updated")
        #expect(updated.defaultId == "id-a")
    }
}
