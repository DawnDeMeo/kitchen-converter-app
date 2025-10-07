//
//  MeasurementUnit.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/5/25.
//

import Foundation

enum UnitType: Codable {
    case volume
    case weight
    case count
    case other
}

enum MeasurementUnit: Codable, Hashable {
    // Volume
    case cup
    case tablespoon
    case teaspoon
    case milliliter
    case liter
    case fluidOunce
    
    // Weight
    case gram
    case kilogram
    case ounce
    case pound
    
    // Count - stores custom singular/plural names
    case count(singular: String, plural: String)
    
    // Other custom units
    case other(name: String)
    
    var type: UnitType {
        switch self {
        case .cup, .tablespoon, .teaspoon, .milliliter, .liter, .fluidOunce:
            return .volume
        case .gram, .kilogram, .ounce, .pound:
            return .weight
        case .count:
            return .count
        case .other:
            return .other
        }
    }
    
    var displayName: String {
        switch self {
        case .cup: return "cup"
        case .tablespoon: return "tbsp"
        case .teaspoon: return "tsp"
        case .milliliter: return "ml"
        case .liter: return "L"
        case .fluidOunce: return "fl oz"
        case .gram: return "g"
        case .kilogram: return "kg"
        case .ounce: return "oz"
        case .pound: return "lb"
        case .count(let singular, _): return singular
        case .other(let name): return name
        }
    }
    
    // Returns singular or plural form based on amount
    func displayName(for amount: Double) -> String {
        switch self {
        case .count(let singular, let plural):
            return amount == 1.0 ? singular : plural
        case .cup:
            return amount == 1.0 ? "cup" : "cups"
        case .tablespoon:
            return amount == 1.0 ? "tbsp" : "tbsp"
        case .teaspoon:
            return amount == 1.0 ? "tsp" : "tsp"
        default:
            return displayName
        }
    }
    
    var fullDisplayName: String {
        switch self {
        case .cup: return "cup"
        case .tablespoon: return "tablespoon"
        case .teaspoon: return "teaspoon"
        case .milliliter: return "milliliter"
        case .liter: return "liter"
        case .fluidOunce: return "fluid ounce"
        case .gram: return "gram"
        case .kilogram: return "kilogram"
        case .ounce: return "ounce"
        case .pound: return "pound"
        case .count(let singular, _): return singular
        case .other(let name): return name
        }
    }

    // Returns singular or plural form based on amount (for full names)
    func fullDisplayName(for amount: Double) -> String {
        switch self {
        case .count(let singular, let plural):
            return amount == 1.0 ? singular : plural
        case .cup:
            return amount == 1.0 ? "cup" : "cups"
        case .tablespoon:
            return amount == 1.0 ? "tablespoon" : "tablespoons"
        case .teaspoon:
            return amount == 1.0 ? "teaspoon" : "teaspoons"
        case .milliliter:
            return amount == 1.0 ? "milliliter" : "milliliters"
        case .liter:
            return amount == 1.0 ? "liter" : "liters"
        case .fluidOunce:
            return amount == 1.0 ? "fluid ounce" : "fluid ounces"
        case .gram:
            return amount == 1.0 ? "gram" : "grams"
        case .kilogram:
            return amount == 1.0 ? "kilogram" : "kilograms"
        case .ounce:
            return amount == 1.0 ? "ounce" : "ounces"
        case .pound:
            return amount == 1.0 ? "pound" : "pounds"
        case .other(let name):
            return name
        }
    }
}
