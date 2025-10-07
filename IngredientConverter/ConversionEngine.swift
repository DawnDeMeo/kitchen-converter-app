//
//  ConversionEngine.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/5/25.
//

import Foundation

class ConversionEngine {
    
    /// Convert an amount from one unit to another for a specific ingredient
    func convert(amount: Double, from: MeasurementUnit, to: MeasurementUnit,
                 for ingredient: Ingredient) -> Double? {
        
        // If converting to the same unit, just return the amount
        if from == to {
            return amount
        }
        
        // If both units are the same type (both volume or both weight), use Foundation's conversion
        if from.type == to.type, from.type == .volume || from.type == .weight {
            return UnitConversionHelper.convert(amount: amount, from: from, to: to)
        }
        
        // Try direct conversion
        if let result = directConversion(amount: amount, from: from, to: to, for: ingredient) {
            return result
        }
        
        // Try reverse conversion
        if let result = reverseConversion(amount: amount, from: from, to: to, for: ingredient) {
            return result
        }
        
        // Try chained conversion
        if let result = chainedConversion(amount: amount, from: from, to: to, for: ingredient) {
            return result
        }
        
        // No conversion found
        return nil
    }
    
    /// Direct conversion: look for a conversion that matches from -> to
    private func directConversion(amount: Double, from: MeasurementUnit, to: MeasurementUnit,
                                   for ingredient: Ingredient) -> Double? {
        guard let conversion = ingredient.conversions.first(where: {
            $0.fromUnit == from && $0.toUnit == to
        }) else {
            return nil
        }
        
        // Calculate: (amount / fromAmount) * toAmount
        return (amount / conversion.fromAmount) * conversion.toAmount
    }
    
    /// Reverse conversion: look for a conversion that matches to -> from, then reverse it
    private func reverseConversion(amount: Double, from: MeasurementUnit, to: MeasurementUnit,
                                    for ingredient: Ingredient) -> Double? {
        guard let conversion = ingredient.conversions.first(where: {
            $0.fromUnit == to && $0.toUnit == from
        }) else {
            return nil
        }
        
        // Calculate in reverse: (amount / toAmount) * fromAmount
        return (amount / conversion.toAmount) * conversion.fromAmount
    }
    
    /// Chained conversion: try to find a path through intermediate units
    private func chainedConversion(amount: Double, from: MeasurementUnit, to: MeasurementUnit,
                                    for ingredient: Ingredient) -> Double? {
        
        // Build a graph of all possible conversions
        var visited = Set<MeasurementUnit>()
        
        // Use breadth-first search to find a conversion path
        return findConversionPath(
            currentAmount: amount,
            currentUnit: from,
            targetUnit: to,
            ingredient: ingredient,
            visited: &visited
        )
    }
    
    /// Recursive helper to find conversion path using BFS
    private func findConversionPath(currentAmount: Double, currentUnit: MeasurementUnit,
                                     targetUnit: MeasurementUnit, ingredient: Ingredient,
                                     visited: inout Set<MeasurementUnit>) -> Double? {
        
        // Mark current unit as visited
        visited.insert(currentUnit)
        
        // Check if we can convert using Foundation's standard conversions
        if currentUnit.type == targetUnit.type,
           let standardConversion = UnitConversionHelper.convert(amount: currentAmount, from: currentUnit, to: targetUnit) {
            return standardConversion
        }
        
        // Try all conversions from current unit
        for conversion in ingredient.conversions {
            var nextUnit: MeasurementUnit?
            var nextAmount: Double?
            
            // Check if we can use this conversion (forward direction)
            if conversion.fromUnit == currentUnit && !visited.contains(conversion.toUnit) {
                nextUnit = conversion.toUnit
                nextAmount = (currentAmount / conversion.fromAmount) * conversion.toAmount
            }
            // Check if we can use this conversion (reverse direction)
            else if conversion.toUnit == currentUnit && !visited.contains(conversion.fromUnit) {
                nextUnit = conversion.fromUnit
                nextAmount = (currentAmount / conversion.toAmount) * conversion.fromAmount
            }
            
            // If we found a valid next step
            if let unit = nextUnit, let amount = nextAmount {
                // Check if we reached the target
                if unit == targetUnit {
                    return amount
                }
                
                // Check if we can reach target via standard conversion
                if unit.type == targetUnit.type,
                   let finalAmount = UnitConversionHelper.convert(amount: amount, from: unit, to: targetUnit) {
                    return finalAmount
                }
                
                // Otherwise, continue searching recursively
                if let result = findConversionPath(
                    currentAmount: amount,
                    currentUnit: unit,
                    targetUnit: targetUnit,
                    ingredient: ingredient,
                    visited: &visited
                ) {
                    return result
                }
            }
        }
        
        return nil
    }
}
