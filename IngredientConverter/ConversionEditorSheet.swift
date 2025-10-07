//
//  ConversionEditorSheet.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/6/25.
//

import SwiftUI

struct ConversionEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let onSave: (ConversionEditor) -> Void
    
    @State private var fromAmount: String = "1"
    @State private var fromUnit: MeasurementUnit = .cup
    @State private var fromUnitType: UnitInputType = .volume
    @State private var countSingular: String = ""
    @State private var countPlural: String = ""
    
    @State private var toAmount: String = "1"
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
        
        var description: String {
            switch self {
            case .volume: return "Volume (cups, tbsp, ml)"
            case .weight: return "Weight (grams, oz, lb)"
            case .count: return "Pieces/Items"
            }
        }
    }
    
    var volumeUnits: [MeasurementUnit] {
        [.teaspoon, .tablespoon, .cup, .pint, .quart, .gallon, .liter, .centiliter, .milliliter, .fluidOunce]
    }

    var weightUnits: [MeasurementUnit] {
        [.pound, .ounce, .gram, .milligram, .kilogram]
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("From") {
                    Picker("Unit Type", selection: $fromUnitType) {
                        ForEach(UnitInputType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: fromUnitType) { oldValue, newValue in
                        handleFromUnitTypeChange(from: oldValue, to: newValue)
                    }
                    
                    TextField("Amount", text: $fromAmount)
                        .keyboardType(.decimalPad)
                    
                    switch fromUnitType {
                    case .volume:
                        Picker("Unit", selection: $fromUnit) {
                            ForEach(volumeUnits, id: \.self) { unit in
                                Text(unit.displayName).tag(unit)
                            }
                        }
                    case .weight:
                        Picker("Unit", selection: $fromUnit) {
                            ForEach(weightUnits, id: \.self) { unit in
                                Text(unit.displayName).tag(unit)
                            }
                        }
                    case .count:
                        TextField("Singular (e.g., egg)", text: $countSingular)
                        TextField("Plural (e.g., eggs)", text: $countPlural)
                    }
                }
                
                Section("To") {
                    Picker("Unit Type", selection: $toUnitType) {
                        ForEach(allowedToUnitTypes, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: toUnitType) { oldValue, newValue in
                        handleToUnitTypeChange(from: oldValue, to: newValue)
                    }
                    
                    TextField("Amount", text: $toAmount)
                        .keyboardType(.decimalPad)
                    
                    switch toUnitType {
                    case .volume:
                        Picker("Unit", selection: $toUnit) {
                            ForEach(volumeUnits, id: \.self) { unit in
                                Text(unit.displayName).tag(unit)
                            }
                        }
                    case .weight:
                        Picker("Unit", selection: $toUnit) {
                            ForEach(weightUnits, id: \.self) { unit in
                                Text(unit.displayName).tag(unit)
                            }
                        }
                    case .count:
                        TextField("Singular (e.g., piece)", text: $toCountSingular)
                        TextField("Plural (e.g., pieces)", text: $toCountPlural)
                    }
                }
                
                if fromUnitType == toUnitType {
                    Section {
                        Label("Cannot convert between the same unit types", systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.callout)
                    }
                }
                
                Section {
                    if let preview = previewText {
                        Text(preview)
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Preview")
                }
            }
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
                    .disabled(fromUnitType == toUnitType)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
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
        guard let from = Double(fromAmount),
              let to = Double(toAmount) else {
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
        
        return "\(formatAmount(from)) \(fromUnitText) = \(formatAmount(to)) \(toUnitText)"
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
    
    private func saveConversion() {
        // Validate that unit types are different
        guard fromUnitType != toUnitType else {
            errorMessage = "Cannot convert between the same unit types. For example, volume-to-volume conversions (cup to ml) are universal and don't depend on the ingredient."
            showingError = true
            return
        }
        
        guard let fromAmt = Double(fromAmount), fromAmt > 0 else {
            errorMessage = "Please enter a valid 'from' amount"
            showingError = true
            return
        }
        
        guard let toAmt = Double(toAmount), toAmt > 0 else {
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
