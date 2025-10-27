
//
//  FractionParser.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/7/25.
//

import Foundation

struct FractionParser {
    
    /// Parse a string that may contain fractions, mixed numbers, or decimals
    /// Examples: "3/4", "1 1/2", "5 3/8", "2.5", "3"
    static func parse(_ input: String) -> Double? {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        
        if trimmed.isEmpty {
            return nil
        }
        
        // Check if it contains a fraction (has a "/" character)
        if trimmed.contains("/") {
            return parseFraction(trimmed)
        } else {
            // Try parsing as a regular decimal number
            return Double(trimmed)
        }
    }
    
    private static func parseFraction(_ input: String) -> Double? {
        // Split by space to check for mixed numbers (e.g., "1 1/2")
        let parts = input.split(separator: " ", omittingEmptySubsequences: true)
        
        if parts.count == 1 {
            // Simple fraction (e.g., "3/4")
            return parseSimpleFraction(String(parts[0]))
        } else if parts.count == 2 {
            // Mixed number (e.g., "1 1/2")
            guard let wholePart = Double(parts[0]),
                  let fractionPart = parseSimpleFraction(String(parts[1])) else {
                return nil
            }
            return wholePart + fractionPart
        } else {
            return nil
        }
    }
    
    private static func parseSimpleFraction(_ input: String) -> Double? {
        let components = input.split(separator: "/")
        
        guard components.count == 2,
              let numerator = Double(components[0]),
              let denominator = Double(components[1]),
              denominator != 0 else {
            return nil
        }
        
        return numerator / denominator
    }
    
    /// Format a decimal number as a mixed fraction string for display
    /// Examples: 1.5 → "1 1/2", 0.75 → "3/4", 2.0 → "2"
    static func formatAsFraction(_ value: Double, maxDenominator: Int = 16) -> String {
        // If it's a whole number, just return it
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        }
        
        let wholePart = Int(value)
        let fractionalPart = value - Double(wholePart)
        
        // Find the best fraction approximation
        if let (numerator, denominator) = bestFraction(for: fractionalPart, maxDenominator: maxDenominator) {
            if wholePart > 0 {
                return "\(wholePart) \(numerator)/\(denominator)"
            } else {
                return "\(numerator)/\(denominator)"
            }
        } else {
            // Fall back to decimal if we can't find a good fraction
            return String(format: "%.2f", value)
        }
    }
    
    /// Find the best fraction representation for a decimal value
    private static func bestFraction(for value: Double, maxDenominator: Int) -> (numerator: Int, denominator: Int)? {
        var bestNumerator = 0
        var bestDenominator = 1
        var bestError = abs(value)
        
        for denominator in 1...maxDenominator {
            let numerator = Int(round(value * Double(denominator)))
            let error = abs(value - Double(numerator) / Double(denominator))
            
            if error < bestError {
                bestError = error
                bestNumerator = numerator
                bestDenominator = denominator
            }
            
            // If we found an exact match, stop searching
            if error < 0.0001 {
                break
            }
        }
        
        // Simplify the fraction
        let gcd = greatestCommonDivisor(bestNumerator, bestDenominator)
        let simplifiedNumerator = bestNumerator / gcd
        let simplifiedDenominator = bestDenominator / gcd
        
        // Don't return if the simplified numerator is 0
        if simplifiedNumerator == 0 {
            return nil
        }
        
        return (simplifiedNumerator, simplifiedDenominator)
    }
    
    /// Calculate greatest common divisor
    private static func greatestCommonDivisor(_ a: Int, _ b: Int) -> Int {
        var a = abs(a)
        var b = abs(b)

        while b != 0 {
            let temp = b
            b = a % b
            a = temp
        }

        return a
    }

    // MARK: - Accessibility Helpers

    /// Convert an amount string to words for accessibility (VoiceOver)
    /// Handles mixed numbers, fractions, and decimals
    /// Examples: "1 1/2" → "1 and one half", "3/4" → "three quarters", "2.5" → "2 point 5"
    static func amountToWords(_ amount: String) -> String {
        let trimmed = amount.trimmingCharacters(in: .whitespaces)

        // Check if it's a mixed number (e.g., "1 1/2")
        if trimmed.contains(" ") && trimmed.contains("/") {
            let parts = trimmed.components(separatedBy: " ")
            if parts.count == 2 {
                let whole = parts[0]
                let fraction = parts[1]
                return "\(whole) and \(fractionToWords(fraction))"
            }
        }

        // Check if it's a simple fraction (e.g., "1/4")
        if trimmed.contains("/") && !trimmed.contains(" ") {
            return fractionToWords(trimmed)
        }

        // Check if it's a decimal - replace "." with " point " for VoiceOver
        if trimmed.contains(".") {
            return trimmed.replacingOccurrences(of: ".", with: " point ")
        }

        return trimmed
    }

    /// Convert a fraction string to words for accessibility
    /// Examples: "1/2" → "one half", "3/4" → "three quarters"
    static func fractionToWords(_ fraction: String) -> String {
        // Handle common cooking fractions with natural language
        switch fraction {
        case "1/8": return "one eighth"
        case "1/4": return "one quarter"
        case "1/3": return "one third"
        case "1/2": return "one half"
        case "2/3": return "two thirds"
        case "3/4": return "three quarters"
        default:
            // Try to parse other fractions like "5/8" → "five eighths"
            let components = fraction.components(separatedBy: "/")
            if components.count == 2,
               let numerator = Int(components[0]),
               let denominator = Int(components[1]) {
                let numWord = numberToWord(numerator)
                let denomWord = denominatorToWord(denominator, plural: numerator > 1)
                return "\(numWord) \(denomWord)"
            }
            return fraction
        }
    }

    /// Convert a number to its word representation
    /// Example: 5 → "five"
    private static func numberToWord(_ num: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        return formatter.string(from: NSNumber(value: num)) ?? "\(num)"
    }

    /// Convert a denominator to its ordinal word form
    /// Examples: 2 → "half"/"halves", 3 → "third"/"thirds", 4 → "quarter"/"quarters"
    private static func denominatorToWord(_ denom: Int, plural: Bool) -> String {
        let base: String
        switch denom {
        case 2: base = "half"
        case 3: base = "third"
        case 4: base = "quarter"
        case 5: base = "fifth"
        case 6: base = "sixth"
        case 7: base = "seventh"
        case 8: base = "eighth"
        case 9: base = "ninth"
        case 10: base = "tenth"
        default: base = "\(denom)th"
        }
        return plural ? base + "s" : base
    }
}
