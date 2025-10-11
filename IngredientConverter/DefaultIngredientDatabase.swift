//
//  DefaultIngredientDatabase.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/5/25.
//

import Foundation
import SwiftData

struct DefaultIngredientDatabase {
    
    static func loadFromJSON() -> [Ingredient] {
        guard let url = Bundle.main.url(forResource: "default_ingredients", withExtension: "json") else {
            print("❌ Could not find default_ingredients.json")
            return []
        }
        
        guard let data = try? Data(contentsOf: url) else {
            print("❌ Could not load data from default_ingredients.json")
            return []
        }
        
        let decoder = JSONDecoder()
        guard let ingredientsJSON = try? decoder.decode(IngredientsJSON.self, from: data) else {
            print("❌ Could not decode default_ingredients.json")
            return []
        }
        
        print("✓ Successfully parsed JSON with \(ingredientsJSON.ingredients.count) ingredients")
        
        return ingredientsJSON.ingredients.compactMap { ingredientJSON in
            convertJSONToIngredient(ingredientJSON)
        }
    }
    
    private static func convertJSONToIngredient(_ json: IngredientJSON) -> Ingredient? {
        let ingredient = Ingredient(name: json.name, category: json.category, brand: json.brand, isCustom: false)
        
        for conversionJSON in json.conversions {
            guard let fromUnit = conversionJSON.fromUnit.toMeasurementUnit(),
                  let toUnit = conversionJSON.toUnit.toMeasurementUnit() else {
                print("⚠️ Could not convert units for \(json.name)")
                continue
            }
            
            let conversion = UnitConversion(
                fromAmount: conversionJSON.fromAmount,
                fromUnit: fromUnit,
                toAmount: conversionJSON.toAmount,
                toUnit: toUnit
            )
            ingredient.conversions.append(conversion)
        }
        
        print("✓ Loaded ingredient: \(ingredient.name) with \(ingredient.conversions.count) conversions")
        return ingredient
    }
}
