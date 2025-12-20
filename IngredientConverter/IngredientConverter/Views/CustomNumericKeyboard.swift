//
//  CustomNumericKeyboard.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/14/25.
//

import SwiftUI

struct CustomNumericKeyboard: View {
    @Binding var text: String
    @Environment(\.appColorScheme) private var colorScheme
    var onDone: () -> Void
    var onChange: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            // Divider
            Divider()
                .background(colorScheme.divider)

            VStack(spacing: 8) {
                // Fraction grid (2 rows x 3 columns)
                VStack(spacing: 8) {
                    // Row 1: 1/8 1/4 1/3
                    HStack(spacing: 8) {
                        fractionButton("1/8")
                        fractionButton("1/4")
                        fractionButton("1/3")
                    }

                    // Row 2: 1/2 2/3 3/4
                    HStack(spacing: 8) {
                        fractionButton("1/2")
                        fractionButton("2/3")
                        fractionButton("3/4")
                    }
                }
                .padding(.horizontal)

                // Number pad
                VStack(spacing: 8) {
                    // Row 1: 1 2 3
                    HStack(spacing: 8) {
                        keyButton("1")
                        keyButton("2")
                        keyButton("3")
                    }

                    // Row 2: 4 5 6
                    HStack(spacing: 8) {
                        keyButton("4")
                        keyButton("5")
                        keyButton("6")
                    }

                    // Row 3: 7 8 9
                    HStack(spacing: 8) {
                        keyButton("7")
                        keyButton("8")
                        keyButton("9")
                    }

                    // Row 4: . / 0 space delete
                    HStack(spacing: 8) {
                        keyButton(".")
                        keyButton("/")
                        keyButton("0")
                        spaceButton()
                        deleteButton()
                    }
                }
                .padding(.horizontal)

                // Done button
                Button {
                    onDone()
                } label: {
                    Text("Done")
                        .font(.body.weight(.semibold))
                        .foregroundColor(colorScheme.buttonText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(colorScheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .accessibilityLabel("Done")
                .accessibilityHint("Closes the keyboard")
                .padding(.horizontal)
            }
            .padding(.vertical, 12)
            .background(colorScheme.secondaryBackground)
        }
    }

    private func keyButton(_ value: String) -> some View {
        Button {
            text.append(value)
            onChange?()
        } label: {
            Text(value)
                .font(.title2)
                .foregroundColor(colorScheme.primaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(colorScheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(colorScheme.divider.opacity(0.3), lineWidth: 1)
                )
        }
        .accessibilityLabel(accessibilityLabelForKey(value))
        .accessibilityHint("Adds \(value) to the input")
    }

    private func accessibilityLabelForKey(_ value: String) -> String {
        switch value {
        case ".": return "Decimal point"
        case "/": return "Fraction slash"
        default: return value
        }
    }

    private func deleteButton() -> some View {
        Button {
            if !text.isEmpty {
                text.removeLast()
                onChange?()
            }
        } label: {
            Image(systemName: "delete.left")
                .font(.title2)
                .foregroundColor(colorScheme.primaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(colorScheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(colorScheme.divider.opacity(0.3), lineWidth: 1)
                )
        }
        .accessibilityLabel("Delete")
        .accessibilityHint("Removes the last character from the input")
    }

    private func spaceButton() -> some View {
        Button {
            text.append(" ")
            onChange?()
        } label: {
            Image(systemName: "space")
                .font(.title2)
                .foregroundColor(colorScheme.primaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(colorScheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(colorScheme.divider.opacity(0.3), lineWidth: 1)
                )
        }
        .accessibilityLabel("Space")
        .accessibilityHint("Adds a space to the input")
    }

    private func fractionButton(_ fraction: String) -> some View {
        Button {
            appendFraction(fraction)
        } label: {
            Text(fraction)
                .font(.subheadline.weight(.medium))
                .foregroundColor(colorScheme.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(colorScheme.primary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(colorScheme.primary.opacity(0.3), lineWidth: 1)
                )
        }
        .accessibilityLabel(FractionParser.fractionToWords(fraction))
        .accessibilityHint("Adds \(FractionParser.fractionToWords(fraction)) to the input")
    }

    private func appendFraction(_ fraction: String) {
        // If empty, just set the fraction
        if text.isEmpty || text == "0" {
            text = fraction
        } else {
            // If there's already a number, append as mixed number
            let trimmed = text.trimmingCharacters(in: .whitespaces)
            // Check if it already has a fraction (contains "/")
            if trimmed.contains("/") {
                // Replace with just the new fraction
                text = fraction
            } else {
                // Append as mixed number
                text = trimmed + " " + fraction
            }
        }
        onChange?()
    }
}

#Preview {
    @Previewable @State var text = ""

    VStack {
        Spacer()

        Text("Input: \(text)")
            .font(.title)
            .padding()

        Spacer()

        CustomNumericKeyboard(text: $text, onDone: {
            print("Done tapped")
        })
    }
}
