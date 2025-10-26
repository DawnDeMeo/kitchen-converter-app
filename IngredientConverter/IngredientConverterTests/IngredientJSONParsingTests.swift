//
//  IngredientJSONParsingTests.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/26/25.
//

import Foundation
import Testing
@testable import IngredientConverter

@Suite("Ingredient JSON Parsing Tests")
struct IngredientJSONParsingTests {

    @Test("Parse ingredient with ID field")
    func parseIngredientWithId() throws {
        let jsonString = """
        {
            "id": "test-flour-id",
            "name": "Flour",
            "category": "Baking",
            "brand": null,
            "conversions": []
        }
        """

        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let ingredient = try decoder.decode(IngredientJSON.self, from: data)

        #expect(ingredient.id == "test-flour-id")
        #expect(ingredient.name == "Flour")
        #expect(ingredient.category == "Baking")
        #expect(ingredient.brand == nil)
    }

    @Test("Parse ingredient without ID field")
    func parseIngredientWithoutId() throws {
        let jsonString = """
        {
            "name": "Sugar",
            "category": "Sweetener",
            "brand": null,
            "conversions": []
        }
        """

        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let ingredient = try decoder.decode(IngredientJSON.self, from: data)

        #expect(ingredient.id == nil)
        #expect(ingredient.name == "Sugar")
        #expect(ingredient.category == "Sweetener")
    }

    @Test("Parse ingredient with null ID")
    func parseIngredientWithNullId() throws {
        let jsonString = """
        {
            "id": null,
            "name": "Salt",
            "category": "Spice",
            "brand": null,
            "conversions": []
        }
        """

        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let ingredient = try decoder.decode(IngredientJSON.self, from: data)

        #expect(ingredient.id == nil)
        #expect(ingredient.name == "Salt")
    }

    @Test("Parse ingredient with brand")
    func parseIngredientWithBrand() throws {
        let jsonString = """
        {
            "id": "test-id",
            "name": "Flour",
            "category": "Baking",
            "brand": "King Arthur",
            "conversions": []
        }
        """

        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let ingredient = try decoder.decode(IngredientJSON.self, from: data)

        #expect(ingredient.brand == "King Arthur")
    }

    @Test("Parse ingredient with simple unit conversions")
    func parseSimpleConversions() throws {
        let jsonString = """
        {
            "name": "Flour",
            "category": "Baking",
            "brand": null,
            "conversions": [
                {
                    "fromAmount": 1.0,
                    "fromUnit": "cup",
                    "toAmount": 120.0,
                    "toUnit": "gram"
                }
            ]
        }
        """

        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let ingredient = try decoder.decode(IngredientJSON.self, from: data)

        #expect(ingredient.conversions.count == 1)

        let conversion = ingredient.conversions[0]
        #expect(conversion.fromAmount == 1.0)
        #expect(conversion.toAmount == 120.0)

        if case .simple(let fromUnit) = conversion.fromUnit {
            #expect(fromUnit == "cup")
        } else {
            Issue.record("Expected simple unit for fromUnit")
        }

        if case .simple(let toUnit) = conversion.toUnit {
            #expect(toUnit == "gram")
        } else {
            Issue.record("Expected simple unit for toUnit")
        }
    }

    @Test("Parse ingredient with count unit conversions")
    func parseCountConversions() throws {
        let jsonString = """
        {
            "name": "Eggs",
            "category": "Egg",
            "brand": null,
            "conversions": [
                {
                    "fromAmount": 1.0,
                    "fromUnit": {
                        "count": {
                            "singular": "egg",
                            "plural": "eggs"
                        }
                    },
                    "toAmount": 50.0,
                    "toUnit": "gram"
                }
            ]
        }
        """

        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let ingredient = try decoder.decode(IngredientJSON.self, from: data)

        #expect(ingredient.conversions.count == 1)

        let conversion = ingredient.conversions[0]

        if case .count(let countUnit) = conversion.fromUnit {
            #expect(countUnit.singular == "egg")
            #expect(countUnit.plural == "eggs")
        } else {
            Issue.record("Expected count unit for fromUnit")
        }
    }

    @Test("Parse full ingredients JSON with version")
    func parseFullIngredientsJSON() throws {
        let jsonString = """
        {
            "version": 2,
            "ingredients": [
                {
                    "id": "flour-id",
                    "name": "Flour",
                    "category": "Baking",
                    "brand": null,
                    "conversions": []
                },
                {
                    "id": "sugar-id",
                    "name": "Sugar",
                    "category": "Sweetener",
                    "brand": null,
                    "conversions": []
                }
            ]
        }
        """

        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let ingredientsJSON = try decoder.decode(IngredientsJSON.self, from: data)

        #expect(ingredientsJSON.version == 2)
        #expect(ingredientsJSON.ingredients.count == 2)

        #expect(ingredientsJSON.ingredients[0].id == "flour-id")
        #expect(ingredientsJSON.ingredients[0].name == "Flour")

        #expect(ingredientsJSON.ingredients[1].id == "sugar-id")
        #expect(ingredientsJSON.ingredients[1].name == "Sugar")
    }

    @Test("Encode ingredient with ID to JSON")
    func encodeIngredientWithId() throws {
        let conversion = ConversionJSON(
            fromAmount: 1.0,
            fromUnit: .simple("cup"),
            toAmount: 120.0,
            toUnit: .simple("gram")
        )

        let ingredient = IngredientJSON(
            id: "test-id",
            name: "Flour",
            category: "Baking",
            brand: nil,
            conversions: [conversion]
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(ingredient)
        let jsonString = String(data: data, encoding: .utf8)!

        #expect(jsonString.contains("\"id\":\"test-id\""))
        #expect(jsonString.contains("\"name\":\"Flour\""))
    }

    @Test("Encode ingredient without ID to JSON")
    func encodeIngredientWithoutId() throws {
        let ingredient = IngredientJSON(
            id: nil,
            name: "Sugar",
            category: "Sweetener",
            brand: nil,
            conversions: []
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(ingredient)
        let jsonString = String(data: data, encoding: .utf8)!

        // When ID is nil, it should still encode (as null)
        // JSON encoding behavior: optional nil values are encoded as null
        #expect(jsonString.contains("\"name\":\"Sugar\""))
    }

    @Test("Round trip: encode then decode ingredient")
    func roundTripIngredient() throws {
        let originalConversion = ConversionJSON(
            fromAmount: 1.0,
            fromUnit: .simple("cup"),
            toAmount: 200.0,
            toUnit: .simple("gram")
        )

        let original = IngredientJSON(
            id: "unique-id",
            name: "Test Ingredient",
            category: "Test Category",
            brand: "Test Brand",
            conversions: [originalConversion]
        )

        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        // Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(IngredientJSON.self, from: data)

        // Verify
        #expect(decoded.id == "unique-id")
        #expect(decoded.name == "Test Ingredient")
        #expect(decoded.category == "Test Category")
        #expect(decoded.brand == "Test Brand")
        #expect(decoded.conversions.count == 1)
        #expect(decoded.conversions[0].fromAmount == 1.0)
        #expect(decoded.conversions[0].toAmount == 200.0)
    }

    @Test("Parse ingredient with multiple conversions")
    func parseMultipleConversions() throws {
        let jsonString = """
        {
            "name": "Flour",
            "category": "Baking",
            "brand": null,
            "conversions": [
                {
                    "fromAmount": 1.0,
                    "fromUnit": "cup",
                    "toAmount": 120.0,
                    "toUnit": "gram"
                },
                {
                    "fromAmount": 1.0,
                    "fromUnit": "tablespoon",
                    "toAmount": 7.5,
                    "toUnit": "gram"
                }
            ]
        }
        """

        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let ingredient = try decoder.decode(IngredientJSON.self, from: data)

        #expect(ingredient.conversions.count == 2)
        #expect(ingredient.conversions[0].fromAmount == 1.0)
        #expect(ingredient.conversions[1].fromAmount == 1.0)
    }

    @Test("Parse empty conversions array")
    func parseEmptyConversions() throws {
        let jsonString = """
        {
            "id": "test-id",
            "name": "Test",
            "category": "Test",
            "brand": null,
            "conversions": []
        }
        """

        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let ingredient = try decoder.decode(IngredientJSON.self, from: data)

        #expect(ingredient.conversions.isEmpty)
    }
}
