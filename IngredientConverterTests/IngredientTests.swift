//
//  IngredientTests.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/5/25.
//

import Testing
import SwiftData
@testable import IngredientConverter

@Suite("Ingredient Tests")
struct IngredientTests {
    
    @Test("Create ingredient with default values")
    func createIngredientWithDefaults() {
        let ingredient = Ingredient(name: "Flour")
        
        #expect(ingredient.name == "Flour")
        #expect(ingredient.brand == nil)
        #expect(ingredient.isFavorite == false)
        #expect(ingredient.isCustom == false)
        #expect(ingredient.conversions.isEmpty)
    }
    
    @Test("Create ingredient with custom values")
    func createIngredientWithCustomValues() {
        let ingredient = Ingredient(
            name: "Flour",
            brand: "King Arthur",
            isFavorite: true,
            isCustom: true
        )
        
        #expect(ingredient.name == "Flour")
        #expect(ingredient.brand == "King Arthur")
        #expect(ingredient.isFavorite == true)
        #expect(ingredient.isCustom == true)
    }
    
    @Test("Add conversion to ingredient")
    func addConversionToIngredient() {
        let ingredient = Ingredient(name: "Sugar")
        let conversion = UnitConversion(
            fromAmount: 1,
            fromUnit: .cup,
            toAmount: 200,
            toUnit: .gram
        )
        
        ingredient.conversions.append(conversion)
        
        #expect(ingredient.conversions.count == 1)
        #expect(ingredient.conversions.first?.fromAmount == 1)
        #expect(ingredient.conversions.first?.fromUnit == .cup)
        #expect(ingredient.conversions.first?.toAmount == 200)
        #expect(ingredient.conversions.first?.toUnit == .gram)
    }
}
