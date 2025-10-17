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
    // CloudKit requires: no unique constraints, all properties optional or with defaults
    var id: UUID = UUID()
    var ingredient: Ingredient?

    var fromAmount: Double = 0.0
    var fromUnit: MeasurementUnit = .cup

    var toAmount: Double = 0.0
    var toUnit: MeasurementUnit = .gram

    init(fromAmount: Double, fromUnit: MeasurementUnit, toAmount: Double, toUnit: MeasurementUnit) {
        self.id = UUID()
        self.fromAmount = fromAmount
        self.fromUnit = fromUnit
        self.toAmount = toAmount
        self.toUnit = toUnit
    }
}
