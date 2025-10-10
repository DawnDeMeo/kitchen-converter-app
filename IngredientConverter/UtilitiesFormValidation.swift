
//  FormValidation.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/9/25.
//

import SwiftUI

@Observable
class FormValidationState {
    var isShowingError = false
    var errorMessage = ""
    
    func showError(_ message: String) {
        errorMessage = message
        isShowingError = true
    }
    
    func clearError() {
        isShowingError = false
        errorMessage = ""
    }
}

struct ValidationAlert: ViewModifier {
    @Bindable var validationState: FormValidationState
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: $validationState.isShowingError) {
                Button("OK", role: .cancel) {
                    validationState.clearError()
                }
            } message: {
                Text(validationState.errorMessage)
            }
    }
}

extension View {
    func validationAlert(_ validationState: FormValidationState) -> some View {
        modifier(ValidationAlert(validationState: validationState))
    }
}

enum ValidationError: Error, LocalizedError {
    case invalidAmount(String)
    case requiredFieldEmpty(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount(let fieldName):
            return "Please enter a valid \(fieldName)"
        case .requiredFieldEmpty(let fieldName):
            return "\(fieldName) is required"
        }
    }
}

struct AmountValidator {
    static func validate(_ amountString: String, fieldName: String = "amount") -> Result<Double, ValidationError> {
        guard let amount = FractionParser.parse(amountString), amount > 0 else {
            return .failure(.invalidAmount(fieldName))
        }
        return .success(amount)
    }
    
    static func validateRequired(_ text: String, fieldName: String) -> Result<String, ValidationError> {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            return .failure(.requiredFieldEmpty(fieldName))
        }
        return .success(trimmed)
    }
}
