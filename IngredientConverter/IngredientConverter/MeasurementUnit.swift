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
    case teaspoon
    case tablespoon
    case cup
    case pint
    case quart
    case gallon
    case liter
    case centiliter
    case milliliter
    case fluidOunce
    
    // Weight
    case pound
    case ounce
    case gram
    case milligram
    case kilogram
    
    // Count - stores custom singular/plural names
    case count(singular: String, plural: String)
    
    // Could add more as needed
    case other(name: String)
    
    var type: UnitType {
        switch self {
        case .teaspoon, .tablespoon, .cup, .pint, .quart, .gallon, .liter, .centiliter, .milliliter, .fluidOunce:
            return .volume
        case .pound, .ounce, .gram, .milligram, .kilogram:
            return .weight
        case .count:
            return .count
        case .other:
            return .other
        }
    }
    
    var displayName: String {
        switch self {
        case .teaspoon: return "tsp"
        case .tablespoon: return "tbsp"
        case .cup: return "cup"
        case .pint: return "pt"
        case .quart: return "qt"
        case .gallon: return "gal"
        case .liter: return "L"
        case .centiliter: return "cL"
        case .milliliter: return "mL"
        case .fluidOunce: return "fl oz"
        case .pound: return "lb"
        case .ounce: return "oz"
        case .gram: return "g"
        case .milligram: return "mg"
        case .kilogram: return "kg"
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
        case .tablespoon, .teaspoon, .pint, .quart, .gallon, .liter, .centiliter, .milliliter, .fluidOunce,
             .pound, .ounce, .gram, .milligram, .kilogram:
            return displayName
        case .other(let name):
            return name
        }
    }
    
    var fullDisplayName: String {
        switch self {
        case .teaspoon: return "teaspoon"
        case .tablespoon: return "tablespoon"
        case .cup: return "cup"
        case .pint: return "pint"
        case .quart: return "quart"
        case .gallon: return "gallon"
        case .liter: return "liter"
        case .centiliter: return "centiliter"
        case .milliliter: return "milliliter"
        case .fluidOunce: return "fluid ounce"
        case .pound: return "pound"
        case .ounce: return "ounce"
        case .gram: return "gram"
        case .milligram: return "milligram"
        case .kilogram: return "kilogram"
        case .count(let singular, _): return singular
        case .other(let name): return name
        }
    }
    
    // Returns singular or plural form based on amount (for full names)
    func fullDisplayName(for amount: Double) -> String {
        switch self {
        case .count(let singular, let plural):
            return amount == 1.0 ? singular : plural
        case .teaspoon:
            return amount == 1.0 ? "teaspoon" : "teaspoons"
        case .tablespoon:
            return amount == 1.0 ? "tablespoon" : "tablespoons"
        case .cup:
            return amount == 1.0 ? "cup" : "cups"
        case .pint:
            return amount == 1.0 ? "pint" : "pints"
        case .quart:
            return amount == 1.0 ? "quart" : "quarts"
        case .gallon:
            return amount == 1.0 ? "gallon" : "gallons"
        case .liter:
            return amount == 1.0 ? "liter" : "liters"
        case .centiliter:
            return amount == 1.0 ? "centiliter" : "centiliters"
        case .milliliter:
            return amount == 1.0 ? "milliliter" : "milliliters"
        case .fluidOunce:
            return amount == 1.0 ? "fluid ounce" : "fluid ounces"
        case .pound:
            return amount == 1.0 ? "pound" : "pounds"
        case .ounce:
            return amount == 1.0 ? "ounce" : "ounces"
        case .gram:
            return amount == 1.0 ? "gram" : "grams"
        case .milligram:
            return amount == 1.0 ? "milligram" : "milligrams"
        case .kilogram:
            return amount == 1.0 ? "kilogram" : "kilograms"
        case .other(let name):
            return name
        }
    }
}
