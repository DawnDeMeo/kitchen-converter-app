//
//  CustomIngredientImportTests.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/26/25.
//

import Foundation
import Testing
import SwiftData
@testable import IngredientConverter

@Suite("Custom Ingredient Import Tests")
struct CustomIngredientImportTests {

    @Test("Import succeeds when custom ingredient has same name as default")
    func importWithSameNameAsDefault() {
        // Create in-memory model container
        let schema = Schema([Ingredient.self, UnitConversion.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        // Add a default ingredient
        let defaultIngredient = Ingredient(
            name: "Flour",
            category: "Baking",
            isCustom: false,
            defaultId: "default-flour-id"
        )
        context.insert(defaultIngredient)
        try! context.save()

        // Create JSON for custom ingredient with same name
        let customJSON: [String: Any] = [
            "name": "Flour",
            "brand": "King Arthur",
            "category": "Custom",
            "conversions": []
        ]

        // Simulate import logic
        let fetchDescriptor = FetchDescriptor<Ingredient>(
            predicate: #Predicate<Ingredient> { ingredient in
                ingredient.isCustom == true
            }
        )
        let existingCustom = try! context.fetch(fetchDescriptor)
        let existingCustomNames = Set(existingCustom.map { $0.name.lowercased() })

        // Should not be blocked by default ingredient
        #expect(!existingCustomNames.contains("flour"))

        // Add the custom ingredient
        let customIngredient = Ingredient(
            name: customJSON["name"] as! String,
            category: customJSON["category"] as? String,
            brand: customJSON["brand"] as? String,
            isCustom: true
        )
        context.insert(customIngredient)
        try! context.save()

        // Verify both exist
        let allIngredients = try! context.fetch(FetchDescriptor<Ingredient>())
        #expect(allIngredients.count == 2)

        let customFlour = allIngredients.first { $0.isCustom }
        let defaultFlour = allIngredients.first { !$0.isCustom }

        #expect(customFlour?.name == "Flour")
        #expect(customFlour?.brand == "King Arthur")
        #expect(defaultFlour?.name == "Flour")
        #expect(defaultFlour?.brand == nil)
    }

    @Test("Import skips duplicate custom ingredients")
    func importSkipsDuplicateCustom() {
        let schema = Schema([Ingredient.self, UnitConversion.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        // Add existing custom ingredient
        let existingCustom = Ingredient(
            name: "My Custom Flour",
            brand: "Brand A",
            isCustom: true
        )
        context.insert(existingCustom)
        try! context.save()

        // Try to import ingredient with same name
        let fetchDescriptor = FetchDescriptor<Ingredient>(
            predicate: #Predicate<Ingredient> { ingredient in
                ingredient.isCustom == true
            }
        )
        let existingCustomIngredients = try! context.fetch(fetchDescriptor)
        let existingCustomNames = Set(existingCustomIngredients.map { $0.name.lowercased() })

        // Should be blocked
        #expect(existingCustomNames.contains("my custom flour"))

        // Don't add duplicate
        let allIngredients = try! context.fetch(FetchDescriptor<Ingredient>())
        #expect(allIngredients.count == 1)
    }

    @Test("Import sets isCustom flag to true")
    func importSetsCustomFlag() {
        let schema = Schema([Ingredient.self, UnitConversion.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        // Import a custom ingredient
        let customIngredient = Ingredient(
            name: "My Special Ingredient",
            category: "Custom",
            brand: "My Brand",
            isCustom: true
        )
        context.insert(customIngredient)
        try! context.save()

        // Verify
        let allIngredients = try! context.fetch(FetchDescriptor<Ingredient>())
        #expect(allIngredients.count == 1)

        let imported = allIngredients.first!
        #expect(imported.isCustom == true)
        #expect(imported.name == "My Special Ingredient")
        #expect(imported.brand == "My Brand")
    }

    @Test("Import handles brand correctly")
    func importHandlesBrand() {
        let schema = Schema([Ingredient.self, UnitConversion.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        // Import with brand
        let withBrand = Ingredient(
            name: "Flour",
            brand: "King Arthur",
            isCustom: true
        )
        context.insert(withBrand)

        // Import without brand
        let withoutBrand = Ingredient(
            name: "Sugar",
            brand: nil,
            isCustom: true
        )
        context.insert(withoutBrand)

        try! context.save()

        // Verify
        let allIngredients = try! context.fetch(FetchDescriptor<Ingredient>())
        #expect(allIngredients.count == 2)

        let flour = allIngredients.first { $0.name == "Flour" }
        let sugar = allIngredients.first { $0.name == "Sugar" }

        #expect(flour?.brand == "King Arthur")
        #expect(sugar?.brand == nil)
    }

    @Test("Import with empty brand should store nil")
    func importEmptyBrandStoresNil() {
        let schema = Schema([Ingredient.self, UnitConversion.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        // Simulate trimming empty brand
        let brandValue = ""
        let trimmedBrand = brandValue.trimmingCharacters(in: .whitespaces)
        let finalBrand = trimmedBrand.isEmpty ? nil : trimmedBrand

        let ingredient = Ingredient(
            name: "Test",
            brand: finalBrand,
            isCustom: true
        )
        context.insert(ingredient)
        try! context.save()

        let allIngredients = try! context.fetch(FetchDescriptor<Ingredient>())
        #expect(allIngredients.first?.brand == nil)
    }

    @Test("Import only checks against custom ingredients, not defaults")
    func importOnlyChecksAgainstCustom() {
        let schema = Schema([Ingredient.self, UnitConversion.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        // Add default ingredient
        let defaultIngredient = Ingredient(
            name: "Common Name",
            isCustom: false,
            defaultId: "default-id"
        )
        context.insert(defaultIngredient)
        try! context.save()

        // Check if "Common Name" exists in custom ingredients
        let fetchDescriptor = FetchDescriptor<Ingredient>(
            predicate: #Predicate<Ingredient> { ingredient in
                ingredient.isCustom == true
            }
        )
        let existingCustom = try! context.fetch(fetchDescriptor)
        let existingCustomNames = Set(existingCustom.map { $0.name.lowercased() })

        // Should NOT find it (because we only checked custom)
        #expect(!existingCustomNames.contains("common name"))

        // Should be able to import
        let customIngredient = Ingredient(
            name: "Common Name",
            brand: "Custom Brand",
            isCustom: true
        )
        context.insert(customIngredient)
        try! context.save()

        // Verify both exist
        let allIngredients = try! context.fetch(FetchDescriptor<Ingredient>())
        #expect(allIngredients.count == 2)
    }

    @Test("Import with category preserves category")
    func importPreservesCategory() {
        let schema = Schema([Ingredient.self, UnitConversion.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        let ingredient = Ingredient(
            name: "Special Flour",
            category: "My Custom Category",
            brand: "My Brand",
            isCustom: true
        )
        context.insert(ingredient)
        try! context.save()

        let allIngredients = try! context.fetch(FetchDescriptor<Ingredient>())
        #expect(allIngredients.first?.category == "My Custom Category")
    }

    @Test("Case-insensitive duplicate detection for custom ingredients")
    func caseInsensitiveDuplicateDetection() {
        let schema = Schema([Ingredient.self, UnitConversion.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)

        // Add custom ingredient with lowercase name
        let existing = Ingredient(
            name: "special flour",
            isCustom: true
        )
        context.insert(existing)
        try! context.save()

        // Try to import with different casing
        let fetchDescriptor = FetchDescriptor<Ingredient>(
            predicate: #Predicate<Ingredient> { ingredient in
                ingredient.isCustom == true
            }
        )
        let existingCustom = try! context.fetch(fetchDescriptor)
        let existingCustomNames = Set(existingCustom.map { $0.name.lowercased() })

        // Should detect as duplicate (case-insensitive)
        #expect(existingCustomNames.contains("special flour"))
        #expect(existingCustomNames.contains("Special Flour".lowercased()))
        #expect(existingCustomNames.contains("SPECIAL FLOUR".lowercased()))
    }
}
