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
    
    @FocusState private var isInputFocused: Bool
    
    private let conversionEngine = ConversionEngine()
    
    // Add initializer to support preselected ingredient
    init(preselectedIngredient: Ingredient? = nil) {
        _selectedIngredient = State(initialValue: preselectedIngredient)
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            Form {
                // Ingredient Display (not selectable)
                if let ingredient = selectedIngredient {
                    Section("Ingredient") {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ingredient.name)
                                .font(.headline)
                            
                            if let brand = ingredient.brand {
                                Text(brand)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Input Amount
                Section("Amount") {
                    TextField("Enter amount (e.g., 1 1/2)", text: $inputAmount)
                        .keyboardType(.numbersAndPunctuation)
                        .focused($isInputFocused)
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
                                Text(unit.fullDisplayName).tag(unit as MeasurementUnit?)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: selectedFromUnit) { _, _ in
                            performConversion()
                            withAnimation {
                                proxy.scrollTo("result", anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Swap Button
                if selectedFromUnit != nil && selectedToUnit != nil {
                    Section {
                        Button {
                            isInputFocused = false
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
                                Text(unit.fullDisplayName).tag(unit as MeasurementUnit?)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: selectedToUnit) { _, _ in
                            performConversion()
                            withAnimation {
                                proxy.scrollTo("result", anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Result
                if let result = conversionResult,
                   let fromUnit = selectedFromUnit,
                   let toUnit = selectedToUnit,
                   let amount = FractionParser.parse(inputAmount) {
                    Section("Result") {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(inputAmount)  // Show what they typed
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
                                    .font(.system(.title, design: .rounded))
                                    .bold()
                                    .foregroundColor(.blue)
                                Text(unitDisplayText(toUnit, amount: result))
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .id("result")
                } else if selectedIngredient != nil && !inputAmount.isEmpty && selectedFromUnit != nil && selectedToUnit != nil {
                    Section("Result") {
                        Label("No conversion available", systemImage: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                    }
                    .id("result")
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle("Convert")
        .onChange(of: selectedIngredient) { _, _ in
            // Reset units when ingredient changes
            selectedFromUnit = nil
            selectedToUnit = nil
            conversionResult = nil
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isInputFocused = false
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func availableUnits(for ingredient: Ingredient) -> [MeasurementUnit] {
        var units = Set<MeasurementUnit>()
        
        // Add all units from conversions
        for conversion in ingredient.conversions {
            units.insert(conversion.fromUnit)
            units.insert(conversion.toUnit)
            
            // Add all units of the same type
            let fromSameType = UnitConversionHelper.allUnitsOfSameType(as: conversion.fromUnit)
            units.formUnion(fromSameType)
            
            let toSameType = UnitConversionHelper.allUnitsOfSameType(as: conversion.toUnit)
            units.formUnion(toSameType)
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
              let amount = FractionParser.parse(inputAmount),
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
