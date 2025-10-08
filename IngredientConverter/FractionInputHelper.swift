//
//  FractionInputHelper.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/8/25.
//

import SwiftUI

struct FractionInputHelper {
    /// Common cooking fractions
    static let commonFractions = ["1/8", "1/4", "1/3", "1/2", "2/3", "3/4"]
    
    /// Handle tapping a fraction button - updates the input text intelligently
    static func appendFraction(_ fraction: String, to currentInput: String) -> String {
        // If empty, just set the fraction
        if currentInput.isEmpty || currentInput == "0" {
            return fraction
        } else {
            // If there's already a number, append as mixed number
            let trimmed = currentInput.trimmingCharacters(in: .whitespaces)
            // Check if it already has a fraction (contains "/")
            if trimmed.contains("/") {
                // Replace with just the new fraction
                return fraction
            } else {
                // Append as mixed number
                return trimmed + " " + fraction
            }
        }
    }
}

/// Reusable toolbar for fraction input
struct FractionToolbarContent: ToolbarContent {
    @Binding var inputText: String
    @FocusState.Binding var isFocused: Bool
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(FractionInputHelper.commonFractions, id: \.self) { fraction in
                        Button(fraction) {
                            inputText = FractionInputHelper.appendFraction(fraction, to: inputText)
                        }
                        .buttonStyle(.bordered)
                        .font(.subheadline)
                    }
                }
            }
            
            Spacer()
            
            Button("Done") {
                isFocused = false
            }
        }
    }
}
