//
//  UnitConversionHelper.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/6/25.
//

import Foundation

struct UnitConversionHelper {

    // MARK: - Exact Volume Conversion Table (US Cooking Measurements)
    // Foundation's Measurement API has precision issues, so we use exact ratios

    private static let volumeConversionsToTeaspoons: [MeasurementUnit: Double] = [
        .teaspoon: 1.0,
        .tablespoon: 3.0,        // Exactly 3 teaspoons
        .fluidOunce: 6.0,        // Exactly 6 teaspoons
        .cup: 48.0,              // Exactly 48 teaspoons (16 tbsp × 3)
        .pint: 96.0,             // Exactly 2 cups
        .quart: 192.0,           // Exactly 4 cups
        .gallon: 768.0,          // Exactly 16 cups
        // Metric (use standard conversions)
        .milliliter: 1.0 / 4.92892159375,  // 1 tsp = 4.92892159375 mL (US)
        .centiliter: 10.0 / 4.92892159375,
        .liter: 1000.0 / 4.92892159375
    ]

    // MARK: - Exact Weight Conversion Table
    // Using exact conversion factors for precision

    private static let weightConversionsToGrams: [MeasurementUnit: Double] = [
        .milligram: 0.001,
        .gram: 1.0,
        .kilogram: 1000.0,
        .ounce: 28.349523125,      // Exact international avoirdupois ounce
        .pound: 453.59237           // Exact international avoirdupois pound
    ]

    /// Convert between units of the same type using exact conversion tables
    static func convert(amount: Double, from fromUnit: MeasurementUnit, to toUnit: MeasurementUnit) -> Double? {
        print("   📐 UnitConversionHelper: \(amount) \(fromUnit.displayName) → \(toUnit.displayName)")
        // Only convert if both units are the same type
        guard fromUnit.type == toUnit.type else {
            print("   ❌ Types don't match: \(fromUnit.type) vs \(toUnit.type)")
            return nil
        }

        let result: Double?
        switch fromUnit.type {
        case .volume:
            result = convertVolume(amount: amount, from: fromUnit, to: toUnit)
        case .weight:
            result = convertWeight(amount: amount, from: fromUnit, to: toUnit)
        case .count, .other:
            // Can't auto-convert count or other types
            result = nil
        }

        if let result = result {
            print("   ✅ UnitConversionHelper result: \(result)")
        } else {
            print("   ❌ UnitConversionHelper returned nil")
        }

        return result
    }
    
    private static func convertVolume(amount: Double, from fromUnit: MeasurementUnit, to toUnit: MeasurementUnit) -> Double? {
        // Use exact conversion table for precision
        guard let fromTeaspoons = volumeConversionsToTeaspoons[fromUnit],
              let toTeaspoons = volumeConversionsToTeaspoons[toUnit] else {
            return nil
        }

        // Convert: amount in fromUnit → teaspoons → toUnit
        let amountInTeaspoons = amount * fromTeaspoons
        let result = amountInTeaspoons / toTeaspoons

        print("      🧮 Exact calculation: \(amount) × \(fromTeaspoons) ÷ \(toTeaspoons) = \(result)")

        return result
    }
    
    private static func convertWeight(amount: Double, from fromUnit: MeasurementUnit, to toUnit: MeasurementUnit) -> Double? {
        // Use exact conversion table for precision
        guard let fromGrams = weightConversionsToGrams[fromUnit],
              let toGrams = weightConversionsToGrams[toUnit] else {
            return nil
        }

        // Convert: amount in fromUnit → grams → toUnit
        let amountInGrams = amount * fromGrams
        let result = amountInGrams / toGrams

        print("      🧮 Exact calculation: \(amount) × \(fromGrams) ÷ \(toGrams) = \(result)")

        return result
    }
    
    /// Get all available units of the same type as the given unit
    static func allUnitsOfSameType(as unit: MeasurementUnit) -> [MeasurementUnit] {
        switch unit.type {
        case .volume:
            return [.teaspoon, .tablespoon, .cup, .pint, .quart, .gallon, .liter, .centiliter, .milliliter, .fluidOunce]
        case .weight:
            return [.pound, .ounce, .gram, .milligram, .kilogram]
        case .count, .other:
            return [unit]
        }
    }
}
