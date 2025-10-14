//
//  ConversionEngineTests.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/5/25.
//

import Testing
@testable import IngredientConverter

@Suite("Conversion Engine Tests")
struct ConversionEngineTests {
    
    @Test("Direct conversion - cup to gram")
    func directConversionCupToGram() {
        let engine = ConversionEngine()
        let ingredient = Ingredient(name: "Flour")
        
        // 1 cup = 120 grams
        let conversion = UnitConversion(
            fromAmount: 1,
            fromUnit: .cup,
            toAmount: 120,
            toUnit: .gram
        )
        ingredient.conversions.append(conversion)
        
        // Convert 2 cups to grams
        let result = engine.convert(amount: 2, from: .cup, to: .gram, for: ingredient)
        
        #expect(result == 240)
    }
    
    @Test("Reverse conversion - gram to cup")
    func reverseConversionGramToCup() {
        let engine = ConversionEngine()
        let ingredient = Ingredient(name: "Flour")
        
        // Only define cup -> gram conversion
        let conversion = UnitConversion(
            fromAmount: 1,
            fromUnit: .cup,
            toAmount: 120,
            toUnit: .gram
        )
        ingredient.conversions.append(conversion)
        
        // Should automatically work in reverse: 240 grams to cups
        let result = engine.convert(amount: 240, from: .gram, to: .cup, for: ingredient)
        
        #expect(result == 2)
    }
    
    @Test("Conversion with count units - graham crackers")
    func conversionWithCountUnits() {
        let engine = ConversionEngine()
        let ingredient = Ingredient(name: "Graham Crackers")
        
        // 8 crackers = 30 grams
        let conversion = UnitConversion(
            fromAmount: 8,
            fromUnit: .count(singular: "cracker", plural: "crackers"),
            toAmount: 30,
            toUnit: .gram
        )
        ingredient.conversions.append(conversion)
        
        // Convert 16 crackers to grams
        let result = engine.convert(
            amount: 16,
            from: .count(singular: "cracker", plural: "crackers"),
            to: .gram,
            for: ingredient
        )
        
        #expect(result == 60)
    }
    
    @Test("Chained conversion - tablespoon to gram via cup")
    func chainedConversion() {
        let engine = ConversionEngine()
        let ingredient = Ingredient(name: "Sugar")
        
        // Define: 1 cup = 200 grams
        let conversion1 = UnitConversion(
            fromAmount: 1,
            fromUnit: .cup,
            toAmount: 200,
            toUnit: .gram
        )
        
        // Define: 16 tablespoons = 1 cup
        let conversion2 = UnitConversion(
            fromAmount: 16,
            fromUnit: .tablespoon,
            toAmount: 1,
            toUnit: .cup
        )
        
        ingredient.conversions.append(conversion1)
        ingredient.conversions.append(conversion2)
        
        // Should chain: 8 tbsp -> 0.5 cup -> 100 grams
        let result = engine.convert(amount: 8, from: .tablespoon, to: .gram, for: ingredient)
        
        #expect(result == 100)
    }
    
    @Test("No conversion available returns nil")
    func noConversionAvailable() {
        let engine = ConversionEngine()
        let ingredient = Ingredient(name: "Mystery Ingredient")
        
        // No conversions defined
        let result = engine.convert(amount: 5, from: .cup, to: .gram, for: ingredient)
        
        #expect(result == nil)
    }
    
    @Test("Fractional amounts work correctly")
    func fractionalAmounts() {
        let engine = ConversionEngine()
        let ingredient = Ingredient(name: "Flour")

        // 1 cup = 120 grams
        let conversion = UnitConversion(
            fromAmount: 1,
            fromUnit: .cup,
            toAmount: 120,
            toUnit: .gram
        )
        ingredient.conversions.append(conversion)

        // Convert 0.5 cups (1/2 cup) to grams
        let result = engine.convert(amount: 0.5, from: .cup, to: .gram, for: ingredient)

        #expect(result == 60)
    }

    @Test("Foundation intermediate conversion - cup to gram via tablespoon")
    func foundationIntermediateConversionCupToGram() {
        let engine = ConversionEngine()
        let ingredient = Ingredient(name: "Active dry yeast")

        // Only define: 1 tablespoon = 9 grams
        let conversion = UnitConversion(
            fromAmount: 1,
            fromUnit: .tablespoon,
            toAmount: 9,
            toUnit: .gram
        )
        ingredient.conversions.append(conversion)

        // Should convert: 1 cup → tablespoons (Foundation) → grams (ingredient)
        let result = engine.convert(amount: 1, from: .cup, to: .gram, for: ingredient)

        // Use approximate equality due to Foundation's unit conversion precision
        #expect(result != nil, "Conversion should succeed")
        #expect(abs(result! - 144) < 3, "Result should be approximately 144 grams (within 3g)")
    }

    @Test("Foundation intermediate conversion - teaspoon to gram via tablespoon")
    func foundationIntermediateConversionTeaspoonToGram() {
        let engine = ConversionEngine()
        let ingredient = Ingredient(name: "Active dry yeast")

        // Only define: 1 tablespoon = 9 grams
        let conversion = UnitConversion(
            fromAmount: 1,
            fromUnit: .tablespoon,
            toAmount: 9,
            toUnit: .gram
        )
        ingredient.conversions.append(conversion)

        // Should convert: 1 tsp → 0.333... tbsp (Foundation) → ~3 grams (ingredient)
        let result = engine.convert(amount: 1, from: .teaspoon, to: .gram, for: ingredient)

        // 1 teaspoon = 1/3 tablespoon = 3 grams (approximately)
        #expect(result != nil, "Conversion should succeed")
        #expect(abs(result! - 3) < 0.01, "Result should be approximately 3 grams")
    }

    @Test("Foundation intermediate conversion - gram to cup via tablespoon")
    func foundationIntermediateConversionGramToCup() {
        let engine = ConversionEngine()
        let ingredient = Ingredient(name: "Active dry yeast")

        // Only define: 1 tablespoon = 9 grams
        let conversion = UnitConversion(
            fromAmount: 1,
            fromUnit: .tablespoon,
            toAmount: 9,
            toUnit: .gram
        )
        ingredient.conversions.append(conversion)

        // Should convert: 144 grams → 16 tbsp (ingredient reverse) → ~1 cup (Foundation)
        let result = engine.convert(amount: 144, from: .gram, to: .cup, for: ingredient)

        #expect(result != nil, "Conversion should succeed")
        #expect(abs(result! - 1.0) < 0.02, "Result should be approximately 1 cup")
    }

    @Test("Foundation intermediate conversion - gram to teaspoon via tablespoon")
    func foundationIntermediateConversionGramToTeaspoon() {
        let engine = ConversionEngine()
        let ingredient = Ingredient(name: "Active dry yeast")

        // Only define: 1 tablespoon = 9 grams
        let conversion = UnitConversion(
            fromAmount: 1,
            fromUnit: .tablespoon,
            toAmount: 9,
            toUnit: .gram
        )
        ingredient.conversions.append(conversion)

        // Should convert: 9 grams → 1 tbsp (ingredient reverse) → ~3 tsp (Foundation)
        let result = engine.convert(amount: 9, from: .gram, to: .teaspoon, for: ingredient)

        #expect(result != nil, "Conversion should succeed")
        #expect(abs(result! - 3.0) < 0.01, "Result should be approximately 3 teaspoons")
    }
}
