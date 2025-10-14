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
    @Environment(\.appColorScheme) private var colorScheme
    @Query private var ingredients: [Ingredient]
    @AppStorage("defaultFromUnit") private var defaultFromUnitKey: String = "cup"
    @AppStorage("defaultToUnit") private var defaultToUnitKey: String = "gram"

    @State private var selectedIngredient: Ingredient?
    @State private var inputAmount: String = ""
    @State private var selectedFromUnit: MeasurementUnit?
    @State private var selectedToUnit: MeasurementUnit?
    @State private var conversionResult: Double?
    @State private var cachedAvailableUnits: [MeasurementUnit] = []

    @FocusState private var isInputFocused: Bool

    private let conversionEngine = ConversionEngine()

    private var defaultFromUnit: MeasurementUnit? {
        MeasurementUnit.fromStorageKey(defaultFromUnitKey)
    }

    private var defaultToUnit: MeasurementUnit? {
        MeasurementUnit.fromStorageKey(defaultToUnitKey)
    }
    
    // Add initializer to support preselected ingredient
    init(preselectedIngredient: Ingredient? = nil) {
        _selectedIngredient = State(initialValue: preselectedIngredient)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                Form {
                    // Ingredient Display (not selectable)
                    if let ingredient = selectedIngredient {
                        Section {
//                            VStack(alignment: .leading, spacing: 6) {
//                                Text(ingredient.name)
//                                    .font(.body)
//                                    .foregroundColor(colorScheme.primaryText)
//
//                                HStack(spacing: 8) {
//                                    if let brand = ingredient.brand {
//                                        Text(brand)
//                                            .font(.caption)
//                                            .foregroundColor(colorScheme.secondaryText)
//                                    }
//
//                                    if let category = ingredient.category {
//                                        HStack(spacing: 4) {
//                                            Image(systemName: "tag.fill")
//                                                .font(.caption2)
//                                            Text(category)
//                                                .font(.caption2)
//                                        }
//                                        .foregroundColor(colorScheme.secondary)
//                                        .padding(.horizontal, 6)
//                                        .padding(.vertical, 2)
//                                        .background(colorScheme.secondary.opacity(0.1))
//                                        .clipShape(Capsule())
//                                    }
//                                    
//                                    if ingredient.isCustom {
//                                        HStack(spacing: 4) {
//                                            Image(systemName: "person.fill")
//                                            Text("Custom")
//                                        }
//                                        .font(.caption2)
//                                        .foregroundColor(colorScheme.primary)
//                                        .padding(.horizontal, 6)
//                                        .padding(.vertical, 2)
//                                        .background(colorScheme.primary.opacity(0.1))
//                                        .clipShape(Capsule())
//                                    }
//                                }
//                            }
                            IngredientRowView(ingredient: ingredient)
                            .padding(.vertical, 4)
                            .listRowBackground(colorScheme.cardBackground)
                        } header: {
                            Text("Ingredient")
                                .foregroundColor(colorScheme.secondary)
                        }
                    }

                    // Input Amount
                    Section {
                        AmountTextField(
                            text: $inputAmount,
                            isFocused: $isInputFocused,
                            onChange: performConversion
                        )
                        .foregroundColor(colorScheme.primaryText)
                        .listRowBackground(colorScheme.cardBackground)
                    } header: {
                        Text("Amount")
                            .foregroundColor(colorScheme.secondary)
                    }

                    // From Unit
                    Section {
                        if selectedIngredient != nil {
                            Picker("Unit", selection: $selectedFromUnit) {
                                Text("Select unit").tag(nil as MeasurementUnit?)
                                ForEach(cachedAvailableUnits, id: \.self) { unit in
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
                            .listRowBackground(colorScheme.cardBackground)
                        }
                    } header: {
                        Text("From")
                            .foregroundColor(colorScheme.secondary)
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
                                        .foregroundColor(colorScheme.primary)
                                    Text("Swap Units")
                                        .foregroundColor(colorScheme.primary)
                                    Spacer()
                                }
                            }
                            .listRowBackground(colorScheme.primary.opacity(0.1))
                        }
                    }

                    // To Unit
                    Section {
                        if selectedIngredient != nil {
                            Picker("Unit", selection: $selectedToUnit) {
                                Text("Select unit").tag(nil as MeasurementUnit?)
                                ForEach(cachedAvailableUnits, id: \.self) { unit in
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
                            .listRowBackground(colorScheme.cardBackground)
                        }
                    } header: {
                        Text("To")
                            .foregroundColor(colorScheme.secondary)
                    }

                    // Result
                    if let result = conversionResult,
                       let fromUnit = selectedFromUnit,
                       let toUnit = selectedToUnit,
                       let amount = FractionParser.parse(inputAmount) {
                        Section {
                            VStack(alignment: .center, spacing: 16) {
                                HStack {
                                    Text(inputAmount)
                                        .font(.title2)
                                        .foregroundColor(colorScheme.primaryText)
                                    Text(unitDisplayText(fromUnit, amount: amount))
                                        .font(.title3)
                                        .foregroundColor(colorScheme.secondaryText)
                                }

                                Divider()
                                    .background(colorScheme.divider)

                                HStack {
                                    Image(systemName: "equal")
                                        .foregroundColor(colorScheme.primary)
                                        .font(.title2)
                                }

                                Divider()
                                    .background(colorScheme.divider)

                                HStack {
                                    Text(formatAmount(result))
                                        .font(.system(.largeTitle, design: .rounded))
                                        .bold()
                                        .foregroundColor(colorScheme.accent)
                                    Text(unitDisplayText(toUnit, amount: result))
                                        .font(.title2)
                                        .foregroundColor(colorScheme.secondaryText)
                                }
                            }
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .listRowBackground(
                                colorScheme.accent.opacity(0.05)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(colorScheme.accent.opacity(0.2), lineWidth: 2)
                                    )
                            )
                        } header: {
                            Text("Result")
                                .foregroundColor(colorScheme.accent)
                        }
                        .id("result")
                    } else if selectedIngredient != nil && !inputAmount.isEmpty && selectedFromUnit != nil && selectedToUnit != nil {
                        Section {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(colorScheme.warning)
                                Text("No conversion available")
                                    .foregroundColor(colorScheme.primaryText)
                            }
                            .listRowBackground(colorScheme.warning.opacity(0.1))
                        } header: {
                            Text("Result")
                                .foregroundColor(colorScheme.warning)
                        }
                        .id("result")
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .scrollContentBackground(.hidden)
                .background(colorScheme.background)
            }

            // Custom keyboard accessory view - reliable and consistent
            if isInputFocused {
                VStack(spacing: 0) {
                    Divider()
                        .background(colorScheme.divider)

                    HStack(spacing: 12) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(FractionInputHelper.commonFractions, id: \.self) { fraction in
                                    Button(fraction) {
                                        inputAmount = FractionInputHelper.appendFraction(fraction, to: inputAmount)
                                        performConversion()
                                    }
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(colorScheme.primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(colorScheme.primary.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(colorScheme.primary.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }

                        Button("Done") {
                            isInputFocused = false
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(colorScheme.buttonText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(colorScheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.trailing)
                    }
                    .padding(.vertical, 8)
                    .background(colorScheme.secondaryBackground)
                }
                .transition(.move(edge: .bottom))
            }
        }
        .background(colorScheme.background)
        .navigationTitle("Convert")
        .onChange(of: selectedIngredient) { _, newIngredient in
            // Reset units when ingredient changes
            selectedFromUnit = nil
            selectedToUnit = nil
            conversionResult = nil

            // Compute and cache available units for new ingredient
            if let ingredient = newIngredient {
                cachedAvailableUnits = computeAvailableUnits(for: ingredient)

                // Apply default unit preferences if available
                if let defaultFrom = defaultFromUnit,
                   cachedAvailableUnits.contains(defaultFrom) {
                    selectedFromUnit = defaultFrom
                }

                if let defaultTo = defaultToUnit,
                   cachedAvailableUnits.contains(defaultTo) {
                    selectedToUnit = defaultTo
                }
            } else {
                cachedAvailableUnits = []
            }
        }
        .onAppear {
            // Compute units on initial appearance if ingredient is preselected
            if let ingredient = selectedIngredient {
                cachedAvailableUnits = computeAvailableUnits(for: ingredient)

                // Apply default unit preferences if available
                if let defaultFrom = defaultFromUnit,
                   cachedAvailableUnits.contains(defaultFrom) {
                    selectedFromUnit = defaultFrom
                }

                if let defaultTo = defaultToUnit,
                   cachedAvailableUnits.contains(defaultTo) {
                    selectedToUnit = defaultTo
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isInputFocused)
    }
    
    // MARK: - Helper Functions

    private func computeAvailableUnits(for ingredient: Ingredient) -> [MeasurementUnit] {
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
