//
//  AmountTextField.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/9/25.
//

import SwiftUI

struct AmountTextField: View {
    @Binding var text: String
    let placeholder: String
    @FocusState.Binding var isFocused: Bool
    let onChange: (() -> Void)?
    
    init(
        text: Binding<String>,
        placeholder: String = "Enter amount (e.g., 1 1/2)",
        isFocused: FocusState<Bool>.Binding,
        onChange: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self._isFocused = isFocused
        self.onChange = onChange
    }
    
    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(.numbersAndPunctuation)
            .focused($isFocused)
            .onChange(of: text) { _, _ in
                onChange?()
            }
    }
}

#Preview {
    @Previewable @State var text = ""
    @Previewable @FocusState var isFocused: Bool
    
    NavigationStack {
        Form {
            Section("Amount") {
                AmountTextField(
                    text: $text,
                    placeholder: "Enter amount",
                    isFocused: $isFocused
                )
            }
        }
        .toolbar {
            FractionToolbarContent(inputText: $text, isFocused: $isFocused)
        }
    }
}