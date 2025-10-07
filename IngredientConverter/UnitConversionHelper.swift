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
        // Only convert if both units are the same type
        guard fromUnit.type == toUnit.type else {
            return nil
        }
        
        switch fromUnit.type {
        case .volume:
            return convertVolume(amount: amount, from: fromUnit, to: toUnit)
        case .weight:
            return convertWeight(amount: amount, from: fromUnit, to: toUnit)
        case .count, .other:
            // Can't auto-convert count or other types
            return nil
        }
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
        case .cup:
            return .cups
        case .tablespoon:
            return .tablespoons
        case .teaspoon:
            return .teaspoons
        case .milliliter:
            return .milliliters
        case .liter:
            return .liters
        case .fluidOunce:
            return .fluidOunces
        default:
            return nil
        }
    }
    
    private static func foundationWeightUnit(for unit: MeasurementUnit) -> UnitMass? {
        switch unit {
        case .gram:
            return .grams
        case .kilogram:
            return .kilograms
        case .ounce:
            return .ounces
        case .pound:
            return .pounds
        default:
            return nil
        }
    }
    
    /// Get all available units of the same type as the given unit
    static func allUnitsOfSameType(as unit: MeasurementUnit) -> [MeasurementUnit] {
        switch unit.type {
        case .volume:
            return [.cup, .tablespoon, .teaspoon, .milliliter, .liter, .fluidOunce]
        case .weight:
            return [.gram, .kilogram, .ounce, .pound]
        case .count, .other:
            return [unit]
        }
    }
}
