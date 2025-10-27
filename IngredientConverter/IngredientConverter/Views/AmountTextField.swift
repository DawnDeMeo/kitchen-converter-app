//
//  AmountTextField.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/9/25.
//

import SwiftUI
import UIKit

struct AmountTextField: View {
    @Binding var text: String
    let placeholder: String
    @FocusState.Binding var isFocused: Bool
    let onChange: (() -> Void)?
    var useCustomKeyboard: Bool = false

    init(
        text: Binding<String>,
        placeholder: String = "Enter amount (e.g., 1 1/2)",
        isFocused: FocusState<Bool>.Binding,
        onChange: (() -> Void)? = nil,
        useCustomKeyboard: Bool = false
    ) {
        self._text = text
        self.placeholder = placeholder
        self._isFocused = isFocused
        self.onChange = onChange
        self.useCustomKeyboard = useCustomKeyboard
    }

    var body: some View {
        if useCustomKeyboard {
            NoKeyboardTextField(
                text: $text,
                placeholder: placeholder,
                isFocused: Binding(
                    get: { isFocused },
                    set: { isFocused = $0 }
                ),
                onChange: onChange
            )
        } else {
            TextField(placeholder, text: $text)
                .keyboardType(.numbersAndPunctuation)
                .focused($isFocused)
                .onChange(of: text) { _, _ in
                    onChange?()
                }
        }
    }
}

// UITextField with custom keyboard
struct NoKeyboardTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    @Binding var isFocused: Bool
    let onChange: (() -> Void)?

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        textField.font = .systemFont(ofSize: 17)
        textField.tintColor = .systemBlue

        // This is the key - use a non-zero sized view to avoid layout issues
        let dummyView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        textField.inputView = dummyView

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }

        if isFocused && !uiView.isFirstResponder {
            DispatchQueue.main.async {
                uiView.becomeFirstResponder()
            }
        } else if !isFocused && uiView.isFirstResponder {
            DispatchQueue.main.async {
                uiView.resignFirstResponder()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: NoKeyboardTextField

        init(_ parent: NoKeyboardTextField) {
            self.parent = parent
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            return false // Block system input since we're using custom keyboard
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.parent.isFocused = true
            }
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.parent.isFocused = false
            }
        }
    }
}

// Simple blinking cursor
struct BlinkingCursor: View {
    @State private var isVisible = true
    @State private var timer: Timer?

    var body: some View {
        Rectangle()
            .fill(Color.blue)
            .frame(width: 2, height: 20)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                    isVisible.toggle()
                }
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
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