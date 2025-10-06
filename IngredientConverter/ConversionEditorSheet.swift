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
    @State private var fromUnitType: UnitInputType = .standard
    @State private var countSingular: String = ""
    @State private var countPlural: String = ""
    
    @State private var toAmount: String = "1"
    @State private var toUnit: MeasurementUnit = .gram
    @State private var toUnitType: UnitInputType = .standard
    @State private var toCountSingular: String = ""
    @State private var toCountPlural: String = ""
    
    @State private var showingError = false
    @State private var errorMessage = ""
    
    enum UnitInputType: String, CaseIterable {
        case standard = "Standard"
        case count = "Count"
        
        var description: String {
            switch self {
            case .standard: return "Volume or Weight"
            case .count: return "Pieces/Items"
            }
        }
    }
    
    var standardUnits: [MeasurementUnit] {
        [.cup, .tablespoon, .teaspoon, .milliliter, .liter, .fluidOunce,
         .gram, .kilogram, .ounce, .pound]
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("From") {
                    Picker("Unit Type", selection: $fromUnitType) {
                        ForEach(UnitInputType.allCases, id: \.self) { type in
                            Text(type.description).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    TextField("Amount", text: $fromAmount)
                        .keyboardType(.decimalPad)
                    
                    if fromUnitType == .standard {
                        Picker("Unit", selection: $fromUnit) {
                            ForEach(standardUnits, id: \.self) { unit in
                                Text(unit.displayName).tag(unit)
                            }
                        }
                    } else {
                        TextField("Singular (e.g., egg)", text: $countSingular)
                        TextField("Plural (e.g., eggs)", text: $countPlural)
                    }
                }
                
                Section("To") {
                    Picker("Unit Type", selection: $toUnitType) {
                        ForEach(UnitInputType.allCases, id: \.self) { type in
                            Text(type.description).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    TextField("Amount", text: $toAmount)
                        .keyboardType(.decimalPad)
                    
                    if toUnitType == .standard {
                        Picker("Unit", selection: $toUnit) {
                            ForEach(standardUnits, id: \.self) { unit in
                                Text(unit.displayName).tag(unit)
                            }
                        }
                    } else {
                        TextField("Singular (e.g., piece)", text: $toCountSingular)
                        TextField("Plural (e.g., pieces)", text: $toCountPlural)
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
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var previewText: String? {
        guard let from = Double(fromAmount),
              let to = Double(toAmount) else {
            return nil
        }
        
        let fromUnitText: String
        if fromUnitType == .standard {
            fromUnitText = fromUnit.displayName(for: from)
        } else if !countSingular.isEmpty && !countPlural.isEmpty {
            fromUnitText = from == 1 ? countSingular : countPlural
        } else {
            return nil
        }
        
        let toUnitText: String
        if toUnitType == .standard {
            toUnitText = toUnit.displayName(for: to)
        } else if !toCountSingular.isEmpty && !toCountPlural.isEmpty {
            toUnitText = to == 1 ? toCountSingular : toCountPlural
        } else {
            return nil
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
        if fromUnitType == .standard {
            finalFromUnit = fromUnit
        } else {
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
        if toUnitType == .standard {
            finalToUnit = toUnit
        } else {
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
