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
        #expect(MeasurementUnit.milliliter.displayName == "mL")
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

    // MARK: - Storage Tests

    @Test("Storage key conversion for volume units")
    func storageKeyVolumeUnits() {
        #expect(MeasurementUnit.cup.storageKey == "cup")
        #expect(MeasurementUnit.tablespoon.storageKey == "tablespoon")
        #expect(MeasurementUnit.teaspoon.storageKey == "teaspoon")
        #expect(MeasurementUnit.milliliter.storageKey == "milliliter")
        #expect(MeasurementUnit.liter.storageKey == "liter")
    }

    @Test("Storage key conversion for weight units")
    func storageKeyWeightUnits() {
        #expect(MeasurementUnit.gram.storageKey == "gram")
        #expect(MeasurementUnit.kilogram.storageKey == "kilogram")
        #expect(MeasurementUnit.ounce.storageKey == "ounce")
        #expect(MeasurementUnit.pound.storageKey == "pound")
    }

    @Test("From storage key creates correct units")
    func fromStorageKeyCreatesUnits() {
        #expect(MeasurementUnit.fromStorageKey("cup") == .cup)
        #expect(MeasurementUnit.fromStorageKey("gram") == .gram)
        #expect(MeasurementUnit.fromStorageKey("tablespoon") == .tablespoon)
        #expect(MeasurementUnit.fromStorageKey("ounce") == .ounce)
        #expect(MeasurementUnit.fromStorageKey("liter") == .liter)
    }

    @Test("From storage key returns nil for invalid keys")
    func fromStorageKeyInvalidKeys() {
        #expect(MeasurementUnit.fromStorageKey("invalid") == nil)
        #expect(MeasurementUnit.fromStorageKey("") == nil)
        #expect(MeasurementUnit.fromStorageKey("CUPS") == nil) // Case sensitive
    }

    @Test("Round trip storage conversion")
    func roundTripStorageConversion() {
        let units: [MeasurementUnit] = [
            .cup, .tablespoon, .teaspoon, .gram, .ounce,
            .liter, .milliliter, .pound, .kilogram
        ]

        for unit in units {
            let key = unit.storageKey
            let restored = MeasurementUnit.fromStorageKey(key)
            #expect(restored == unit, "Failed round trip for \(unit)")
        }
    }

    @Test("Standard units contains expected volume units")
    func standardUnitsContainsVolumeUnits() {
        let standardUnits = MeasurementUnit.standardUnits

        #expect(standardUnits.contains(.cup))
        #expect(standardUnits.contains(.tablespoon))
        #expect(standardUnits.contains(.teaspoon))
        #expect(standardUnits.contains(.milliliter))
        #expect(standardUnits.contains(.liter))
        #expect(standardUnits.contains(.fluidOunce))
    }

    @Test("Standard units contains expected weight units")
    func standardUnitsContainsWeightUnits() {
        let standardUnits = MeasurementUnit.standardUnits

        #expect(standardUnits.contains(.gram))
        #expect(standardUnits.contains(.kilogram))
        #expect(standardUnits.contains(.ounce))
        #expect(standardUnits.contains(.pound))
        #expect(standardUnits.contains(.milligram))
    }

    @Test("Standard units does not contain count units")
    func standardUnitsExcludesCountUnits() {
        let standardUnits = MeasurementUnit.standardUnits

        // Count units have associated values, so we check there are no count type units
        for unit in standardUnits {
            #expect(unit.type != .count, "Standard units should not contain count units")
        }
    }

    @Test("Standard units count is reasonable")
    func standardUnitsCountReasonable() {
        let standardUnits = MeasurementUnit.standardUnits

        // We expect 15 standard units (10 volume + 5 weight)
        #expect(standardUnits.count == 15)
    }
}
