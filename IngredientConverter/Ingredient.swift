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
    @Attribute(.unique) var id: UUID
    var name: String
    var brand: String?
    var isFavorite: Bool
    var isCustom: Bool
    var lastUsedDate: Date?
    
    @Relationship(deleteRule: .cascade) var conversions: [UnitConversion]
    
    init(name: String, brand: String? = nil, isFavorite: Bool = false, isCustom: Bool = false) {
        self.id = UUID()
        self.name = name
        self.brand = brand
        self.isFavorite = isFavorite
        self.isCustom = isCustom
        self.lastUsedDate = nil
        self.conversions = []
    }
}
