//
//  ConversionEdgeCaseTests.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/5/25.
//

import Testing
@testable import IngredientConverter

@Suite("Conversion Edge Case Tests")
struct ConversionEdgeCaseTests {
    
    @Test("Zero amount conversion")
    func zeroAmountConversion() {
        let engine = ConversionEngine()
        let ingredient = Ingredient(name: "Flour")
        
        let conversion = UnitConversion(
            fromAmount: 1,
            fromUnit: .cup,
            toAmount: 120,
            toUnit: .gram
        )
        ingredient.conversions.append(conversion)
        
        let result = engine.convert(amount: 0, from: .cup, to: .gram, for: ingredient)
        #expect(result == 0)
    }
    
    @Test("Very large amount conversion")
    func largeAmountConversion() {
        let engine = ConversionEngine()
        let ingredient = Ingredient(name: "Flour")
        
        let conversion = UnitConversion(
            fromAmount: 1,
            fromUnit: .cup,
            toAmount: 120,
            toUnit: .gram
        )
        ingredient.conversions.append(conversion)
        
        let result = engine.convert(amount: 1000, from: .cup, to: .gram, for: ingredient)
        #expect(result == 120000)
    }
    
    @Test("Very small fractional amount")
    func smallFractionalAmount() {
        let engine = ConversionEngine()
        let ingredient = Ingredient(name: "Salt")
        
        let conversion = UnitConversion(
            fromAmount: 1,
            fromUnit: .teaspoon,
            toAmount: 6,
            toUnit: .gram
        )
        ingredient.conversions.append(conversion)
        
        let result = engine.convert(amount: 0.125, from: .teaspoon, to: .gram, for: ingredient)
        #expect(result == 0.75)
    }
    
    @Test("Converting to same unit returns original amount")
    func sameUnitConversion() {
        let engine = ConversionEngine()
        let ingredient = Ingredient(name: "Sugar")
        
        let result = engine.convert(amount: 5, from: .cup, to: .cup, for: ingredient)
        #expect(result == 5)
    }
    
    @Test("Negative amount conversion")
    func negativeAmountConversion() {
        let engine = ConversionEngine()
        let ingredient = Ingredient(name: "Flour")
        
        let conversion = UnitConversion(
            fromAmount: 1,
            fromUnit: .cup,
            toAmount: 120,
            toUnit: .gram
        )
        ingredient.conversions.append(conversion)
        
        // Negative amounts don't make physical sense, but mathematically should work
        let result = engine.convert(amount: -2, from: .cup, to: .gram, for: ingredient)
        #expect(result == -240)
    }
    
    @Test("Long conversion chain")
    func longConversionChain() {
        let engine = ConversionEngine()
        let ingredient = Ingredient(name: "Liquid")
        
        // Create a chain: tsp -> tbsp -> cup -> ml
        ingredient.conversions = [
            UnitConversion(fromAmount: 3, fromUnit: .teaspoon, toAmount: 1, toUnit: .tablespoon),
            UnitConversion(fromAmount: 16, fromUnit: .tablespoon, toAmount: 1, toUnit: .cup),
            UnitConversion(fromAmount: 1, fromUnit: .cup, toAmount: 237, toUnit: .milliliter)
        ]
        
        // 6 tsp -> 2 tbsp -> 0.125 cup -> ~29.625 ml
        let result = engine.convert(amount: 6, from: .teaspoon, to: .milliliter, for: ingredient)
        
        #expect(result != nil, "Conversion should succeed")
        
        if let result = result {
            // Allow for small floating-point precision differences
            let expected = 29.625
            let tolerance = 0.5
            let difference = abs(result - expected)
            #expect(difference < tolerance, "Expected ~\(expected), got \(result)")
        }
    }
    
    @Test("Ingredient with no conversions returns nil")
    func noConversionsReturnsNil() {
        let engine = ConversionEngine()
        let ingredient = Ingredient(name: "Mystery Ingredient")
        // No conversions added
        
        let result = engine.convert(amount: 5, from: .cup, to: .gram, for: ingredient)
        #expect(result == nil)
    }
    
    @Test("Conversion with incompatible units returns nil")
    func incompatibleUnitsReturnsNil() {
        let engine = ConversionEngine()
        let ingredient = Ingredient(name: "Flour")
        
        // Only has cup to gram conversion
        let conversion = UnitConversion(
            fromAmount: 1,
            fromUnit: .cup,
            toAmount: 120,
            toUnit: .gram
        )
        ingredient.conversions.append(conversion)
        
        // Try to convert between count units (truly incompatible - no path available)
        let result = engine.convert(
            amount: 1,
            from: .count(singular: "egg", plural: "eggs"),
            to: .count(singular: "cracker", plural: "crackers"),
            for: ingredient
        )
        #expect(result == nil)
    }
}
