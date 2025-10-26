//
//  Ingredient.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/5/25.
//

import Foundation
import SwiftData

@Model
class Ingredient {
    // CloudKit requires: no unique constraints, all properties optional or with defaults
    var id: UUID = UUID()
    var name: String = ""
    var category: String?
    var brand: String?
    var isFavorite: Bool = false
    var isCustom: Bool = false
    var lastUsedDate: Date?
    var defaultId: String?  // Stable ID from default database (for tracking across name changes)

    @Relationship(deleteRule: .cascade) var conversions: [UnitConversion]?

    init(name: String, category: String? = nil, brand: String? = nil, isFavorite: Bool = false, isCustom: Bool = false, defaultId: String? = nil) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.brand = brand
        self.isFavorite = isFavorite
        self.isCustom = isCustom
        self.lastUsedDate = nil
        self.defaultId = defaultId
        self.conversions = []
    }
}
