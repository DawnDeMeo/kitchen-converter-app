//
//  ConversionEditorSheet.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/6/25.
//

import SwiftUI

struct ConversionEditorSheet: View {
    @Environment(\.appColorScheme) private var colorScheme

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

    @State private var focusedField: AmountField?
    @State private var showingFromUnitPicker = false
    @State private var showingToUnitPicker = false

    enum AmountField {
        case fromAmount
        case toAmount
    }
    
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

    private var activeTextBinding: Binding<String> {
        switch focusedField {
        case .fromAmount:
            return $fromAmount
        case .toAmount:
            return $toAmount
        case .none:
            return .constant("")
        }
    }

    private var fromAvailableUnits: [MeasurementUnit] {
        switch fromUnitType {
        case .volume:
            return volumeUnits
        case .weight:
            return weightUnits
        case .count:
            return []
        }
    }

    private var toAvailableUnits: [MeasurementUnit] {
        switch toUnitType {
        case .volume:
            return volumeUnits
        case .weight:
            return weightUnits
        case .count:
            return []
        }
    }

    var body: some View {
        VStack(spacing: 0) {
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

                        ZStack(alignment: .leading) {
                            if fromAmount.isEmpty {
                                Text("Enter from amount (e.g., 1 1/2)")
                                    .foregroundColor(colorScheme.secondary.opacity(0.6))
                                    .padding(.horizontal, 4)
                            }
                            Text(fromAmount.isEmpty ? " " : fromAmount)
                                .foregroundColor(colorScheme.primaryText)
                                .padding(.horizontal, 4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(height: 44)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            focusedField = .fromAmount
                        }
                        .listRowBackground(colorScheme.cardBackground)

                        switch fromUnitType {
                        case .volume, .weight:
                            Button {
                                focusedField = nil
                                showingFromUnitPicker = true
                            } label: {
                                HStack {
                                    Text("Unit")
                                        .foregroundColor(colorScheme.secondaryText)
                                    Spacer()
                                    Text(fromUnit.displayName)
                                        .foregroundColor(colorScheme.primaryText)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(colorScheme.secondary)
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
                            ForEach(UnitInputType.allCases, id: \.self) { type in
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

                        ZStack(alignment: .leading) {
                            if toAmount.isEmpty {
                                Text("Enter to amount (e.g., 1 1/2)")
                                    .foregroundColor(colorScheme.secondary.opacity(0.6))
                                    .padding(.horizontal, 4)
                            }
                            Text(toAmount.isEmpty ? " " : toAmount)
                                .foregroundColor(colorScheme.primaryText)
                                .padding(.horizontal, 4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(height: 44)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            focusedField = .toAmount
                        }
                        .listRowBackground(colorScheme.cardBackground)

                        switch toUnitType {
                        case .volume, .weight:
                            Button {
                                focusedField = nil
                                showingToUnitPicker = true
                            } label: {
                                HStack {
                                    Text("Unit")
                                        .foregroundColor(colorScheme.secondaryText)
                                    Spacer()
                                    Text(toUnit.displayName)
                                        .foregroundColor(colorScheme.primaryText)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(colorScheme.secondary)
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
            }
            .background(colorScheme.background)
            .navigationTitle("Add Conversion")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveConversion()
                    }
                    .disabled(fromUnitType == toUnitType)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showingFromUnitPicker) {
                UnitPickerSheet(
                    availableUnits: fromAvailableUnits,
                    selectedUnit: $fromUnit,
                    title: "From Unit"
                )
            }
            .sheet(isPresented: $showingToUnitPicker) {
                UnitPickerSheet(
                    availableUnits: toAvailableUnits,
                    selectedUnit: $toUnit,
                    title: "To Unit"
                )
            }

            // Custom keyboard
            if focusedField != nil {
                CustomNumericKeyboard(
                    text: activeTextBinding,
                    onDone: {
                        focusedField = nil
                    }
                )
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: focusedField)
    }

    private func handleFromUnitTypeChange(from oldType: UnitInputType, to newType: UnitInputType) {
        // Dismiss keyboard when changing unit type
        focusedField = nil

        // Update default unit when type changes
        switch newType {
        case .volume:
            fromUnit = .cup
        case .weight:
            fromUnit = .gram
        case .count:
            break
        }
    }

    private func handleToUnitTypeChange(from oldType: UnitInputType, to newType: UnitInputType) {
        // Dismiss keyboard when changing unit type
        focusedField = nil

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
    }
}

#Preview {
    ConversionEditorSheet { conversion in
        print("Saved: \(conversion)")
    }
}
