//
//  IngredientFilterTests.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/5/25.
//

import Testing
@testable import IngredientConverter

@Suite("Ingredient Filter Tests")
struct IngredientFilterTests {
    
    func createTestIngredients() -> [Ingredient] {
        let flour = Ingredient(name: "Flour, all-purpose", isCustom: false)
        let sugar = Ingredient(name: "Sugar, granulated", isCustom: false)
        let brownSugar = Ingredient(name: "Sugar, brown", isCustom: false)
        let customFlour = Ingredient(name: "Flour, custom blend", brand: "MyBrand", isCustom: true)
        
        flour.isFavorite = true
        sugar.isFavorite = false
        brownSugar.isFavorite = false
        customFlour.isFavorite = true
        
        return [flour, sugar, brownSugar, customFlour]
    }
    
    @Test("Filter by favorites")
    func filterByFavorites() {
        let ingredients = createTestIngredients()
        let favorites = ingredients.filter { $0.isFavorite }
        
        #expect(favorites.count == 2)
        #expect(favorites.contains { $0.name == "Flour, all-purpose" })
        #expect(favorites.contains { $0.name == "Flour, custom blend" })
    }
    
    @Test("Filter by custom ingredients")
    func filterByCustom() {
        let ingredients = createTestIngredients()
        let custom = ingredients.filter { $0.isCustom }
        
        #expect(custom.count == 1)
        #expect(custom.first?.name == "Flour, custom blend")
    }
    
    @Test("Filter by default ingredients")
    func filterByDefault() {
        let ingredients = createTestIngredients()
        let defaults = ingredients.filter { !$0.isCustom }
        
        #expect(defaults.count == 3)
    }
    
    @Test("Search by name - case insensitive")
    func searchByName() {
        let ingredients = createTestIngredients()
        let searchTerm = "flour"
        let results = ingredients.filter {
            $0.name.lowercased().contains(searchTerm.lowercased())
        }
        
        #expect(results.count == 2)
        #expect(results.contains { $0.name == "Flour, all-purpose" })
        #expect(results.contains { $0.name == "Flour, custom blend" })
    }
    
    @Test("Search for sugar finds both types")
    func searchForSugar() {
        let ingredients = createTestIngredients()
        let results = ingredients.filter {
            $0.name.lowercased().contains("sugar")
        }
        
        #expect(results.count == 2)
    }
    
    @Test("Filter by brand")
    func filterByBrand() {
        let ingredients = createTestIngredients()
        let withBrand = ingredients.filter { $0.brand != nil }
        
        #expect(withBrand.count == 1)
        #expect(withBrand.first?.brand == "MyBrand")
    }
}
