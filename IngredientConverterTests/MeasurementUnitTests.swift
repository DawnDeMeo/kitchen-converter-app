//
//  MeasurementUnitTests.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/5/25.
//

import Testing
@testable import IngredientConverter

@Suite("Measurement Unit Tests")
struct MeasurementUnitTests {
    
    @Test("Unit types are correct")
    func unitTypesCorrect() {
        #expect(MeasurementUnit.cup.type == .volume)
        #expect(MeasurementUnit.tablespoon.type == .volume)
        #expect(MeasurementUnit.gram.type == .weight)
        #expect(MeasurementUnit.ounce.type == .weight)
        #expect(MeasurementUnit.count(singular: "egg", plural: "eggs").type == .count)
    }
    
    @Test("Display names are correct")
    func displayNamesCorrect() {
        #expect(MeasurementUnit.cup.displayName == "cup")
        #expect(MeasurementUnit.tablespoon.displayName == "tbsp")
        #expect(MeasurementUnit.teaspoon.displayName == "tsp")
        #expect(MeasurementUnit.gram.displayName == "g")
        #expect(MeasurementUnit.ounce.displayName == "oz")
        #expect(MeasurementUnit.milliliter.displayName == "ml")
    }
    
    @Test("Count unit singular display")
    func countUnitSingularDisplay() {
        let unit = MeasurementUnit.count(singular: "egg", plural: "eggs")
        #expect(unit.displayName == "egg")
        #expect(unit.displayName(for: 1.0) == "egg")
    }
    
    @Test("Count unit plural display")
    func countUnitPluralDisplay() {
        let unit = MeasurementUnit.count(singular: "egg", plural: "eggs")
        #expect(unit.displayName(for: 2.0) == "eggs")
        #expect(unit.displayName(for: 0.0) == "eggs")
        #expect(unit.displayName(for: 0.5) == "eggs")
    }
    
    @Test("Cup pluralization")
    func cupPluralization() {
        #expect(MeasurementUnit.cup.displayName(for: 1.0) == "cup")
        #expect(MeasurementUnit.cup.displayName(for: 2.0) == "cups")
        #expect(MeasurementUnit.cup.displayName(for: 0.5) == "cups")
    }
    
    @Test("Unit equality works correctly")
    func unitEquality() {
        #expect(MeasurementUnit.cup == MeasurementUnit.cup)
        #expect(MeasurementUnit.gram == MeasurementUnit.gram)
        #expect(MeasurementUnit.cup != MeasurementUnit.tablespoon)
        
        let egg1 = MeasurementUnit.count(singular: "egg", plural: "eggs")
        let egg2 = MeasurementUnit.count(singular: "egg", plural: "eggs")
        #expect(egg1 == egg2)
        
        let cracker = MeasurementUnit.count(singular: "cracker", plural: "crackers")
        #expect(egg1 != cracker)
    }
}
