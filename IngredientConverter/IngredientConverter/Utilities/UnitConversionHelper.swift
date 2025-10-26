//
//  UnitConversionHelper.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/6/25.
//

import Foundation

struct UnitConversionHelper {
    
    /// Convert between units of the same type using Foundation's Measurement API
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
        guard let fromVolumeUnit = foundationVolumeUnit(for: fromUnit),
              let toVolumeUnit = foundationVolumeUnit(for: toUnit) else {
            return nil
        }
        
        let measurement = Measurement(value: amount, unit: fromVolumeUnit)
        let converted = measurement.converted(to: toVolumeUnit)
        return converted.value
    }
    
    private static func convertWeight(amount: Double, from fromUnit: MeasurementUnit, to toUnit: MeasurementUnit) -> Double? {
        guard let fromWeightUnit = foundationWeightUnit(for: fromUnit),
              let toWeightUnit = foundationWeightUnit(for: toUnit) else {
            return nil
        }
        
        let measurement = Measurement(value: amount, unit: fromWeightUnit)
        let converted = measurement.converted(to: toWeightUnit)
        return converted.value
    }
    
    private static func foundationVolumeUnit(for unit: MeasurementUnit) -> UnitVolume? {
        switch unit {
        case .teaspoon:
            return .teaspoons
        case .tablespoon:
            return .tablespoons
        case .cup:
            return .cups
        case .pint:
            return .pints
        case .quart:
            return .quarts
        case .gallon:
            return .gallons
        case .liter:
            return .liters
        case .centiliter:
            return .centiliters
        case .milliliter:
            return .milliliters
        case .fluidOunce:
            return .fluidOunces
        default:
            return nil
        }
    }
    
    private static func foundationWeightUnit(for unit: MeasurementUnit) -> UnitMass? {
        switch unit {
        case .pound:
            return .pounds
        case .ounce:
            return .ounces
        case .gram:
            return .grams
        case .milligram:
            return .milligrams
        case .kilogram:
            return .kilograms
        default:
            return nil
        }
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
