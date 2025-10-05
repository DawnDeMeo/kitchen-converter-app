//
//  UnitConversion.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/5/25.
//

import Foundation
import SwiftData

@Model
class UnitConversion {
    @Attribute(.unique) var id: UUID
    var ingredient: Ingredient?
    
    var fromAmount: Double
    var fromUnit: MeasurementUnit
    
    var toAmount: Double
    var toUnit: MeasurementUnit
    
    init(fromAmount: Double, fromUnit: MeasurementUnit, toAmount: Double, toUnit: MeasurementUnit) {
        self.id = UUID()
        self.fromAmount = fromAmount
        self.fromUnit = fromUnit
        self.toAmount = toAmount
        self.toUnit = toUnit
    }
}
