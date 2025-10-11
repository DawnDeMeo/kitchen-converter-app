//
//  DefaultIngredientDatabaseTests.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/5/25.
//

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
        
        #expect(names.contains("Flour, all-purpose, sifted"))
        #expect(names.contains("Sugar, granulated"))
        #expect(names.contains("Eggs, large"))
        #expect(names.contains("Graham crackers"))
    }
    
    @Test("Flour has multiple conversions")
    func flourHasMultipleConversions() {
        let ingredients = DefaultIngredientDatabase.loadFromJSON()
        let flour = ingredients.first { $0.name == "Flour, all-purpose, sifted" }
        
        #expect(flour != nil, "Flour should exist in database")
        #expect(flour?.conversions.count == 3, "Flour should have 3 conversions")
    }
    
    @Test("Flour has correct brand")
    func flourHasBrand() {
        let ingredients = DefaultIngredientDatabase.loadFromJSON()
        let flour = ingredients.first { $0.name == "Flour, all-purpose, sifted" }
        
        #expect(flour?.brand == "King Arthur")
    }
    
    @Test("Sugar has no brand")
    func sugarHasNoBrand() {
        let ingredients = DefaultIngredientDatabase.loadFromJSON()
        let sugar = ingredients.first { $0.name == "Sugar, granulated" }
        
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
        let eggs = ingredients.first { $0.name == "Eggs, large" }
        
        #expect(eggs != nil, "Eggs should exist in database")
        #expect(eggs?.conversions.count == 1, "Eggs should have 1 conversion")
        
        let conversion = eggs?.conversions.first
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
        
        let conversion = crackers?.conversions.first
        if case .count(let singular, let plural) = conversion?.fromUnit {
            #expect(singular == "cracker")
            #expect(plural == "crackers")
        } else {
            Issue.record("Cracker fromUnit should be a count unit")
        }
        
        #expect(conversion?.fromAmount == 8)
        #expect(conversion?.toAmount == 30)
    }
    
    @Test("Volume and weight units parse correctly")
    func volumeAndWeightUnitsCorrect() {
        let ingredients = DefaultIngredientDatabase.loadFromJSON()
        let flour = ingredients.first { $0.name == "Flour, all-purpose, sifted" }
        
        let cupConversion = flour?.conversions.first { $0.fromUnit == .cup }
        #expect(cupConversion != nil, "Should have cup conversion")
        #expect(cupConversion?.toUnit == .gram, "Cup should convert to grams")
        
        let tbspConversion = flour?.conversions.first { $0.fromUnit == .tablespoon }
        #expect(tbspConversion != nil, "Should have tablespoon conversion")
        #expect(tbspConversion?.toUnit == .gram, "Tablespoon should convert to grams")
    }
    
    @Test("Flour converts to both grams and ounces")
    func flourConvertsToMultipleUnits() {
        let ingredients = DefaultIngredientDatabase.loadFromJSON()
        let flour = ingredients.first { $0.name == "Flour, all-purpose, sifted" }
        
        let gramConversion = flour?.conversions.first { $0.toUnit == .gram }
        let ounceConversion = flour?.conversions.first { $0.toUnit == .ounce }
        
        #expect(gramConversion != nil, "Should have gram conversion")
        #expect(ounceConversion != nil, "Should have ounce conversion")
    }
}
