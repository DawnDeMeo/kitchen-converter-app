//
//  ConversionEditorSheet.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/6/25.
//

import SwiftUI

struct ConversionEditorSheet: View {
    @Environment(\.appColorScheme) private var colorScheme
    @State private var fromKeyboardVisible: Bool = false
    @State private var toKeyboardVisible: Bool = false

    @Environment(\.dismiss) private var dismiss
    
    let onSave: (ConversionEditor) -> Void
    
    @State private var fromAmount: String = ""
    @State private var fromUnit: MeasurementUnit = .cup
    @State private var fromUnitType: UnitInputType = .volume
    @State private var countSingular: String = ""
    @State private var countPlural: String = ""

    @State private var toAmount: String = ""
    @State private var toUnit: MeasurementUnit = .gram
    @State private var toUnitType: UnitInputType = .weight
    @State private var toCountSingular: String = ""
    @State private var toCountPlural: String = ""
    
    @State private var showingError = false
    @State private var errorMessage = ""
    
    enum UnitInputType: String, CaseIterable {
        case volume = "Volume"
        case weight = "Weight"
        case count = "Count"
    }
    
    var volumeUnits: [MeasurementUnit] {
        [.teaspoon, .tablespoon, .cup, .pint, .quart, .gallon, .liter, .centiliter, .milliliter, .fluidOunce]
    }

    var weightUnits: [MeasurementUnit] {
        [.pound, .ounce, .gram, .milligram, .kilogram]
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                    Section {
                        Picker("Unit Type", selection: $fromUnitType) {
                            ForEach(UnitInputType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .background(
                            ThemedSegmentedPickerBackground(color: colorScheme.primary, textColor: colorScheme.buttonText)
                        )
                        .onChange(of: fromUnitType) { oldValue, newValue in
                            handleFromUnitTypeChange(from: oldValue, to: newValue)
                        }
                        .listRowBackground(colorScheme.cardBackground)

                        NoKeyboardTextField(
                            text: $fromAmount,
                            placeholder: "Enter from amount (e.g., 1 1/2)",
                            isFocused: $fromKeyboardVisible,
                            onChange: nil
                        )
                        .foregroundColor(colorScheme.primaryText)
                        .listRowBackground(colorScheme.cardBackground)

                        switch fromUnitType {
                        case .volume:
                            Picker("Unit", selection: $fromUnit) {
                                ForEach(volumeUnits, id: \.self) { unit in
                                    Text(unit.displayName).tag(unit)
                                }
                            }
                            .listRowBackground(colorScheme.cardBackground)
                        case .weight:
                            Picker("Unit", selection: $fromUnit) {
                                ForEach(weightUnits, id: \.self) { unit in
                                    Text(unit.displayName).tag(unit)
                                }
                            }
                            .listRowBackground(colorScheme.cardBackground)
                        case .count:
                            TextField("Singular (e.g., egg)", text: $countSingular)
                                .foregroundColor(colorScheme.primaryText)
                                .listRowBackground(colorScheme.cardBackground)
                            TextField("Plural (e.g., eggs)", text: $countPlural)
                                .foregroundColor(colorScheme.primaryText)
                                .listRowBackground(colorScheme.cardBackground)
                        }
                    } header: {
                        Text("From")
                            .foregroundColor(colorScheme.secondary)
                    }

                    Section {
                        Picker("Unit Type", selection: $toUnitType) {
                            ForEach(allowedToUnitTypes, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .background(
                            ThemedSegmentedPickerBackground(color: colorScheme.accent, textColor: colorScheme.buttonText)
                        )
                        .onChange(of: toUnitType) { oldValue, newValue in
                            handleToUnitTypeChange(from: oldValue, to: newValue)
                        }
                        .listRowBackground(colorScheme.cardBackground)

                        NoKeyboardTextField(
                            text: $toAmount,
                            placeholder: "Enter to amount (e.g., 1 1/2)",
                            isFocused: $toKeyboardVisible,
                            onChange: nil
                        )
                        .foregroundColor(colorScheme.primaryText)
                        .listRowBackground(colorScheme.cardBackground)

                        switch toUnitType {
                        case .volume:
                            Picker("Unit", selection: $toUnit) {
                                ForEach(volumeUnits, id: \.self) { unit in
                                    Text(unit.displayName).tag(unit)
                                }
                            }
                            .listRowBackground(colorScheme.cardBackground)
                        case .weight:
                            Picker("Unit", selection: $toUnit) {
                                ForEach(weightUnits, id: \.self) { unit in
                                    Text(unit.displayName).tag(unit)
                                }
                            }
                            .listRowBackground(colorScheme.cardBackground)
                        case .count:
                            TextField("Singular (e.g., piece)", text: $toCountSingular)
                                .foregroundColor(colorScheme.primaryText)
                                .listRowBackground(colorScheme.cardBackground)
                            TextField("Plural (e.g., pieces)", text: $toCountPlural)
                                .foregroundColor(colorScheme.primaryText)
                                .listRowBackground(colorScheme.cardBackground)
                        }
                    } header: {
                        Text("To")
                            .foregroundColor(colorScheme.secondary)
                    }

                    if fromUnitType == toUnitType {
                        Section {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(colorScheme.warning)
                                Text("Cannot convert between the same unit types")
                                    .font(.callout)
                                    .foregroundColor(colorScheme.primaryText)
                            }
                            .listRowBackground(colorScheme.warning.opacity(0.1))
                        }
                    }

                    Section {
                        if let preview = previewText {
                            HStack {
                                Image(systemName: "eye.fill")
                                    .foregroundColor(colorScheme.accent)
                                Text(preview)
                                    .font(.callout)
                                    .foregroundColor(colorScheme.primaryText)
                            }
                            .listRowBackground(colorScheme.accent.opacity(0.05))
                        }
                    } header: {
                        Text("Preview")
                            .foregroundColor(colorScheme.accent)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(colorScheme.background)

                // Custom keyboard
                if fromKeyboardVisible {
                    CustomNumericKeyboard(
                        text: $fromAmount,
                        onDone: {
                            fromKeyboardVisible = false
                        },
                        onChange: nil
                    )
                    .transition(.move(edge: .bottom))
                } else if toKeyboardVisible {
                    CustomNumericKeyboard(
                        text: $toAmount,
                        onDone: {
                            toKeyboardVisible = false
                        },
                        onChange: nil
                    )
                    .transition(.move(edge: .bottom))
                }
            }
            .background(colorScheme.background)
            .navigationTitle("Add Conversion")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveConversion()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .animation(.easeInOut(duration: 0.3), value: fromKeyboardVisible || toKeyboardVisible)
            .onChange(of: fromKeyboardVisible) { _, newValue in
                if newValue {
                    toKeyboardVisible = false
                }
            }
            .onChange(of: toKeyboardVisible) { _, newValue in
                if newValue {
                    fromKeyboardVisible = false
                }
            }
        }
    }

    // Available "To" unit types based on "From" selection
    private var allowedToUnitTypes: [UnitInputType] {
        UnitInputType.allCases.filter { $0 != fromUnitType }
    }
    
    private func handleFromUnitTypeChange(from oldType: UnitInputType, to newType: UnitInputType) {
        // Update default unit when type changes
        switch newType {
        case .volume:
            fromUnit = .cup
        case .weight:
            fromUnit = .gram
        case .count:
            break
        }
        
        // If "to" type is now the same as "from", switch it
        if toUnitType == newType {
            // Pick the first different type
            if let differentType = UnitInputType.allCases.first(where: { $0 != newType }) {
                toUnitType = differentType
            }
        }
    }

    private func handleToUnitTypeChange(from oldType: UnitInputType, to newType: UnitInputType) {
        // Update default unit when type changes
        switch newType {
        case .volume:
            toUnit = .milliliter
        case .weight:
            toUnit = .gram
        case .count:
            break
        }
    }
    
    private var previewText: String? {
        guard let from = FractionParser.parse(fromAmount),
              let to = FractionParser.parse(toAmount) else {
            return nil
        }
        
        let fromUnitText: String
        switch fromUnitType {
        case .volume, .weight:
            fromUnitText = fromUnit.displayName(for: from)
        case .count:
            if !countSingular.isEmpty && !countPlural.isEmpty {
                fromUnitText = from == 1 ? countSingular : countPlural
            } else {
                return nil
            }
        }
        
        let toUnitText: String
        switch toUnitType {
        case .volume, .weight:
            toUnitText = toUnit.displayName(for: to)
        case .count:
            if !toCountSingular.isEmpty && !toCountPlural.isEmpty {
                toUnitText = to == 1 ? toCountSingular : toCountPlural
            } else {
                return nil
            }
        }
        
        return "\(fromAmount) \(fromUnitText) = \(toAmount) \(toUnitText)"
    }
    
    private func saveConversion() {
        // Validate that unit types are different
        guard fromUnitType != toUnitType else {
            errorMessage = "Cannot convert between the same unit types. For example, volume-to-volume conversions (cup to ml) are universal and don't depend on the ingredient."
            showingError = true
            return
        }
        
        guard let fromAmt = FractionParser.parse(fromAmount), fromAmt > 0 else {
            errorMessage = "Please enter a valid 'from' amount"
            showingError = true
            return
        }
        
        guard let toAmt = FractionParser.parse(toAmount), toAmt > 0 else {
            errorMessage = "Please enter a valid 'to' amount"
            showingError = true
            return
        }
        
        let finalFromUnit: MeasurementUnit
        switch fromUnitType {
        case .volume, .weight:
            finalFromUnit = fromUnit
        case .count:
            let singular = countSingular.trimmingCharacters(in: .whitespaces)
            let plural = countPlural.trimmingCharacters(in: .whitespaces)
            
            guard !singular.isEmpty && !plural.isEmpty else {
                errorMessage = "Please enter both singular and plural forms for count units"
                showingError = true
                return
            }
            
            finalFromUnit = .count(singular: singular, plural: plural)
        }
        
        let finalToUnit: MeasurementUnit
        switch toUnitType {
        case .volume, .weight:
            finalToUnit = toUnit
        case .count:
            let singular = toCountSingular.trimmingCharacters(in: .whitespaces)
            let plural = toCountPlural.trimmingCharacters(in: .whitespaces)
            
            guard !singular.isEmpty && !plural.isEmpty else {
                errorMessage = "Please enter both singular and plural forms for count units"
                showingError = true
                return
            }
            
            finalToUnit = .count(singular: singular, plural: plural)
        }
        
        let conversion = ConversionEditor(
            fromAmount: fromAmt,
            fromUnit: finalFromUnit,
            toAmount: toAmt,
            toUnit: finalToUnit
        )
        
        onSave(conversion)
        dismiss()
    }
}

#Preview {
    ConversionEditorSheet { conversion in
        print("Saved: \(conversion)")
    }
}
