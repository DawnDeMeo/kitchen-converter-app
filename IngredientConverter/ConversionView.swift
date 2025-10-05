//
//  ConversionView.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/5/25.
//

import SwiftUI
import SwiftData

struct ConversionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var ingredients: [Ingredient]
    
    @State private var selectedIngredient: Ingredient?
    @State private var inputAmount: String = ""
    @State private var selectedFromUnit: MeasurementUnit?
    @State private var selectedToUnit: MeasurementUnit?
    @State private var conversionResult: Double?
    @State private var showingIngredientPicker = false
    
    private let conversionEngine = ConversionEngine()
    
    var body: some View {
        NavigationStack {
            Form {
                // Ingredient Selection
                Section("Ingredient") {
                    Button {
                        showingIngredientPicker = true
                    } label: {
                        HStack {
                            Text(selectedIngredient?.name ?? "Select an ingredient")
                                .foregroundColor(selectedIngredient == nil ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                    
                    if let ingredient = selectedIngredient, let brand = ingredient.brand {
                        Text(brand)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Input Amount
                Section("Amount") {
                    TextField("Enter amount", text: $inputAmount)
                        .keyboardType(.decimalPad)
                        .onChange(of: inputAmount) { _, _ in
                            performConversion()
                        }
                }
                
                // From Unit
                Section("From") {
                    if let ingredient = selectedIngredient {
                        Picker("Unit", selection: $selectedFromUnit) {
                            Text("Select unit").tag(nil as MeasurementUnit?)
                            ForEach(availableUnits(for: ingredient), id: \.self) { unit in
                                Text(unitDisplayText(unit)).tag(unit as MeasurementUnit?)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: selectedFromUnit) { _, _ in
                            performConversion()
                        }
                    } else {
                        Text("Select an ingredient first")
                            .foregroundColor(.gray)
                    }
                }
                
                // Swap Button
                if selectedFromUnit != nil && selectedToUnit != nil {
                    Section {
                        Button {
                            swapUnits()
                        } label: {
                            HStack {
                                Spacer()
                                Image(systemName: "arrow.up.arrow.down")
                                Text("Swap Units")
                                Spacer()
                            }
                        }
                    }
                }
                
                // To Unit
                Section("To") {
                    if let ingredient = selectedIngredient {
                        Picker("Unit", selection: $selectedToUnit) {
                            Text("Select unit").tag(nil as MeasurementUnit?)
                            ForEach(availableUnits(for: ingredient), id: \.self) { unit in
                                Text(unitDisplayText(unit)).tag(unit as MeasurementUnit?)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: selectedToUnit) { _, _ in
                            performConversion()
                        }
                    } else {
                        Text("Select an ingredient first")
                            .foregroundColor(.gray)
                    }
                }
                
                // Result
                if let result = conversionResult,
                   let fromUnit = selectedFromUnit,
                   let toUnit = selectedToUnit,
                   let amount = Double(inputAmount) {
                    Section("Result") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(formatAmount(amount))
                                    .font(.title2)
                                Text(unitDisplayText(fromUnit, amount: amount))
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }
                            
                            Image(systemName: "equal")
                                .foregroundColor(.blue)
                                .font(.title3)
                            
                            HStack {
                                Text(formatAmount(result))
                                    .font(.title)
                                    .bold()
                                Text(unitDisplayText(toUnit, amount: result))
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                } else if selectedIngredient != nil && !inputAmount.isEmpty && selectedFromUnit != nil && selectedToUnit != nil {
                    Section("Result") {
                        Text("No conversion available")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Convert")
            .sheet(isPresented: $showingIngredientPicker) {
                IngredientPickerView(
                    ingredients: ingredients,
                    selectedIngredient: $selectedIngredient
                )
            }
            .onChange(of: selectedIngredient) { _, _ in
                // Reset units when ingredient changes
                selectedFromUnit = nil
                selectedToUnit = nil
                conversionResult = nil
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func availableUnits(for ingredient: Ingredient) -> [MeasurementUnit] {
        var units = Set<MeasurementUnit>()
        
        for conversion in ingredient.conversions {
            units.insert(conversion.fromUnit)
            units.insert(conversion.toUnit)
        }
        
        return Array(units).sorted { unitDisplayText($0) < unitDisplayText($1) }
    }
    
    private func unitDisplayText(_ unit: MeasurementUnit, amount: Double? = nil) -> String {
        if let amount = amount {
            return unit.displayName(for: amount)
        }
        return unit.displayName
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
    
    private func performConversion() {
        guard let ingredient = selectedIngredient,
              let fromUnit = selectedFromUnit,
              let toUnit = selectedToUnit,
              let amount = Double(inputAmount),
              amount > 0 else {
            conversionResult = nil
            return
        }
        
        conversionResult = conversionEngine.convert(
            amount: amount,
            from: fromUnit,
            to: toUnit,
            for: ingredient
        )
        
        // Update last used date
        if conversionResult != nil {
            ingredient.lastUsedDate = Date()
        }
    }
    
    private func swapUnits() {
        let temp = selectedFromUnit
        selectedFromUnit = selectedToUnit
        selectedToUnit = temp
        
        // If we have a result, swap the input amount with the result
        if let result = conversionResult {
            inputAmount = formatAmount(result)
        }
        
        performConversion()
    }
}

#Preview {
    ConversionView()
        .modelContainer(for: Ingredient.self, inMemory: true)
}
