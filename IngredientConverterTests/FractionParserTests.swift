//
//  FractionParserTests.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/7/25.
//

import Testing
@testable import IngredientConverter

@Suite("Fraction Parser Tests")
struct FractionParserTests {
    
    @Test("Parse simple fraction")
    func parseSimpleFraction() {
        #expect(FractionParser.parse("3/4") == 0.75)
        #expect(FractionParser.parse("1/2") == 0.5)
        #expect(FractionParser.parse("1/4") == 0.25)
        #expect(FractionParser.parse("2/3")! - 0.6667 < 0.001)
    }
    
    @Test("Parse mixed number")
    func parseMixedNumber() {
        #expect(FractionParser.parse("1 1/2") == 1.5)
        #expect(FractionParser.parse("2 3/4") == 2.75)
        #expect(FractionParser.parse("5 3/8") == 5.375)
    }
    
    @Test("Parse whole number")
    func parseWholeNumber() {
        #expect(FractionParser.parse("5") == 5.0)
        #expect(FractionParser.parse("10") == 10.0)
    }
    
    @Test("Parse decimal")
    func parseDecimal() {
        #expect(FractionParser.parse("2.5") == 2.5)
        #expect(FractionParser.parse("0.75") == 0.75)
        #expect(FractionParser.parse("3.14") == 3.14)
    }
    
    @Test("Parse with whitespace")
    func parseWithWhitespace() {
        #expect(FractionParser.parse("  1/2  ") == 0.5)
        #expect(FractionParser.parse("  2 1/4  ") == 2.25)
    }
    
    @Test("Invalid input returns nil")
    func invalidInput() {
        #expect(FractionParser.parse("") == nil)
        #expect(FractionParser.parse("abc") == nil)
        #expect(FractionParser.parse("1/0") == nil)
        #expect(FractionParser.parse("1 2 3") == nil)
    }
    
    @Test("Format as fraction")
    func formatAsFraction() {
        #expect(FractionParser.formatAsFraction(0.5) == "1/2")
        #expect(FractionParser.formatAsFraction(0.75) == "3/4")
        #expect(FractionParser.formatAsFraction(1.5) == "1 1/2")
        #expect(FractionParser.formatAsFraction(2.0) == "2")
        #expect(FractionParser.formatAsFraction(2.25) == "2 1/4")
    }
}
