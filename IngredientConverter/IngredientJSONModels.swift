//
//  IngredientJSONModels.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/5/25.
//

import Foundation

// JSON parsing structures
struct IngredientsJSON: Codable {
    let ingredients: [IngredientJSON]
}

struct IngredientJSON: Codable {
    let name: String
    let brand: String?
    let conversions: [ConversionJSON]
}

struct ConversionJSON: Codable {
    let fromAmount: Double
    let fromUnit: UnitJSON
    let toAmount: Double
    let toUnit: UnitJSON
}

enum UnitJSON: Codable {
    case simple(String)
    case count(CountUnit)
    case other(String)
    
    struct CountUnit: Codable {
        let singular: String
        let plural: String
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // Try to decode as a dictionary (for count units)
        if let dict = try? container.decode([String: CountUnit].self),
           let countUnit = dict["count"] {
            self = .count(countUnit)
            return
        }
        
        // Try to decode as a simple string
        if let string = try? container.decode(String.self) {
            self = .simple(string)
            return
        }
        
        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Cannot decode unit"
        )
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .simple(let string):
            try container.encode(string)
        case .count(let countUnit):
            try container.encode(["count": countUnit])
        case .other(let string):
            try container.encode(string)
        }
    }
    
    // Convert JSON unit to MeasurementUnit
    func toMeasurementUnit() -> MeasurementUnit? {
        switch self {
        case .simple(let string):
            switch string.lowercased() {
            case "cup": return .cup
            case "tablespoon", "tbsp": return .tablespoon
            case "teaspoon", "tsp": return .teaspoon
            case "milliliter", "ml": return .milliliter
            case "liter", "l": return .liter
            case "fluidounce", "fl oz", "floz": return .fluidOunce
            case "gram", "g": return .gram
            case "kilogram", "kg": return .kilogram
            case "ounce", "oz": return .ounce
            case "pound", "lb": return .pound
            default: return .other(name: string)
            }
        case .count(let countUnit):
            return .count(singular: countUnit.singular, plural: countUnit.plural)
        case .other(let name):
            return .other(name: name)
        }
    }
}
