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
    @State private var isKeyboardVisible: Bool = false
    @State private var showingFromUnitPicker: Bool = false
    @State private var showingToUnitPicker: Bool = false

    private let conversionEngine = ConversionEngine()

    private var defaultFromUnit: MeasurementUnit? {
        MeasurementUnit.fromStorageKey(defaultFromUnitKey)
    }

    private var defaultToUnit: MeasurementUnit? {
        MeasurementUnit.fromStorageKey(defaultToUnitKey)
    }

    // Computed property for effective amount (parsed input or default to 1 if empty)
    private var effectiveAmount: Double? {
        if inputAmount.isEmpty {
            return 1.0
        }
        return FractionParser.parse(inputAmount)
    }

    // Computed property for display amount
    private var displayAmount: String {
        inputAmount.isEmpty ? "1" : inputAmount
    }

    // Check if input is invalid (not empty but can't be parsed)
    private var isInputInvalid: Bool {
        !inputAmount.isEmpty && FractionParser.parse(inputAmount) == nil
    }

    // Add initializer to support preselected ingredient
    init(preselectedIngredient: Ingredient? = nil) {
        _selectedIngredient = State(initialValue: preselectedIngredient)
    }

    // MARK: - Result Card View

    @ViewBuilder
    private func resultCardContent(fromUnit: MeasurementUnit, toUnit: MeasurementUnit) -> some View {
        VStack(alignment: .center, spacing: 16) {
            // First row - Tappable input area
            Button {
                isKeyboardVisible = true
            } label: {
                HStack {
                    if inputAmount.isEmpty {
                        Text("Tap to enter amount")
                            .font(.title3)
                            .foregroundColor(colorScheme.secondary)
                    } else {
                        Text(displayAmount)
                            .font(.title2)
                            .foregroundColor(colorScheme.primaryText)
                        Text(unitDisplayText(fromUnit, amount: effectiveAmount ?? 1))
                            .font(.title3)
                            .foregroundColor(colorScheme.secondaryText)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(inputAmount.isEmpty ? "Tap to enter amount" : "\(FractionParser.amountToWords(displayAmount)) \(unitDisplayText(fromUnit, amount: effectiveAmount ?? 1))")
            .accessibilityHint(inputAmount.isEmpty ? "Double tap to enter the quantity you want to convert" : "Double tap to edit amount")

            Divider()
                .background(colorScheme.divider)

            HStack {
                Image(systemName: "equal")
                    .foregroundColor(colorScheme.primary)
                    .font(.title2)
            }

            Divider()
                .background(colorScheme.divider)

            // Second row - Result
            resultRow(toUnit: toUnit)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .center)
        .listRowBackground(
            colorScheme.accent.opacity(0.05)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(colorScheme.accent.opacity(0.2), lineWidth: 2)
                )
        )
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private func resultRow(toUnit: MeasurementUnit) -> some View {
        if isInputInvalid {
            // Invalid input - show question mark
            HStack {
                Text("?")
                    .font(.system(.largeTitle, design: .rounded))
                    .bold()
                    .foregroundColor(colorScheme.secondaryText)
                Text(toUnit.fullDisplayName)
                    .font(.title2)
                    .foregroundColor(colorScheme.secondaryText)
            }
        } else if let result = conversionResult, let amount = effectiveAmount {
            // Valid result (shown even when inputAmount is empty, using default 1.0)
            HStack {
                Text(formatAmount(result))
                    .font(.system(.largeTitle, design: .rounded))
                    .bold()
                    .foregroundColor(colorScheme.accent)
                Text(unitDisplayText(toUnit, amount: result))
                    .font(.title2)
                    .foregroundColor(colorScheme.secondaryText)
            }
        } else {
            // No conversion available
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(colorScheme.warning)
                Text("No conversion")
                    .font(.title3)
                    .foregroundColor(colorScheme.warning)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                Form {
                    // Result - Always visible when units are selected
                    if let fromUnit = selectedFromUnit,
                       let toUnit = selectedToUnit,
                       selectedIngredient != nil {
                        Section {
                            resultCardContent(fromUnit: fromUnit, toUnit: toUnit)
                        }
                        .id("result")
                    }

                    // Conversion Controls
                    Section {

                        // From, Swap, To in horizontal layout
                        if selectedIngredient != nil {
                            HStack(alignment: .bottom, spacing: 8) {
                                // From Unit
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("From")
                                        .font(.caption)
                                        .foregroundColor(colorScheme.secondary)
                                        .textCase(.uppercase)

                                    Button {
                                        isKeyboardVisible = false
                                        showingFromUnitPicker = true
                                    } label: {
                                        HStack {
                                            Text(selectedFromUnit?.fullDisplayName ?? "Select")
                                                .foregroundColor(selectedFromUnit != nil ? colorScheme.primaryText : colorScheme.secondary)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .font(.caption)
                                                .foregroundColor(colorScheme.secondary)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(colorScheme.cardBackground)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(colorScheme.divider, lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("From unit")
                                }
                                .frame(maxWidth: .infinity)

                                // Swap Button
                                if selectedFromUnit != nil && selectedToUnit != nil {
                                    Button {
                                        isKeyboardVisible = false
                                        swapUnits()
                                    } label: {
                                        Image(systemName: "arrow.left.arrow.right")
                                            .foregroundColor(colorScheme.primary)
                                            .font(.title3)
                                            .padding(8)
                                            .background(colorScheme.primary.opacity(0.1))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Swap units")
                                    .accessibilityHint("Swaps the from and to units")
                                }

                                // To Unit
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("To")
                                        .font(.caption)
                                        .foregroundColor(colorScheme.secondary)
                                        .textCase(.uppercase)

                                    Button {
                                        isKeyboardVisible = false
                                        showingToUnitPicker = true
                                    } label: {
                                        HStack {
                                            Text(selectedToUnit?.fullDisplayName ?? "Select")
                                                .foregroundColor(selectedToUnit != nil ? colorScheme.primaryText : colorScheme.secondary)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .font(.caption)
                                                .foregroundColor(colorScheme.secondary)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(colorScheme.cardBackground)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(colorScheme.divider, lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("To unit")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .listRowBackground(colorScheme.cardBackground)
                        }
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .scrollContentBackground(.hidden)
                .background(colorScheme.background)
            }

            // Custom keyboard
            if isKeyboardVisible {
                CustomNumericKeyboard(
                    text: $inputAmount,
                    onDone: {
                        isKeyboardVisible = false
                    },
                    onChange: performConversion
                )
                .transition(.move(edge: .bottom))
            }
        }
        .background(colorScheme.background)
        .navigationTitle(selectedIngredient?.name ?? "No Ingredient Selected")
        .sheet(isPresented: $showingFromUnitPicker) {
            UnitPickerSheet(
                availableUnits: cachedAvailableUnits,
                selectedUnit: $selectedFromUnit,
                title: "From Unit"
            )
        }
        .sheet(isPresented: $showingToUnitPicker) {
            UnitPickerSheet(
                availableUnits: cachedAvailableUnits,
                selectedUnit: $selectedToUnit,
                title: "To Unit"
            )
        }
        .onChange(of: selectedFromUnit) { _, _ in
            performConversion()
        }
        .onChange(of: selectedToUnit) { _, _ in
            performConversion()
        }
        .task(id: selectedIngredient?.id) {
            // This runs on initial appearance AND whenever selectedIngredient changes
            // Reset units when ingredient changes
            selectedFromUnit = nil
            selectedToUnit = nil
            conversionResult = nil

            // Compute and cache available units for new ingredient
            if let ingredient = selectedIngredient {
                cachedAvailableUnits = computeAvailableUnits(for: ingredient)

                // For count-based ingredients, prefer count as fromUnit
                let countUnit = cachedAvailableUnits.first { unit in
                    if case .count = unit { return true }
                    return false
                }

                if let countUnit = countUnit {
                    // This is a count-based ingredient
                    selectedFromUnit = countUnit

                    // For toUnit, prefer defaultToUnit if available, otherwise first non-count unit
                    if let defaultTo = defaultToUnit,
                       cachedAvailableUnits.contains(defaultTo) {
                        selectedToUnit = defaultTo
                    } else {
                        selectedToUnit = cachedAvailableUnits.first { unit in
                            if case .count = unit { return false }
                            return true
                        }
                    }
                } else {
                    // Apply default unit preferences for measurement-based ingredients
                    if let defaultFrom = defaultFromUnit,
                       cachedAvailableUnits.contains(defaultFrom) {
                        selectedFromUnit = defaultFrom
                    }

                    if let defaultTo = defaultToUnit,
                       cachedAvailableUnits.contains(defaultTo) {
                        selectedToUnit = defaultTo
                    }
                }

                // Trigger conversion with default amount
                performConversion()
            } else {
                cachedAvailableUnits = []
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isKeyboardVisible)
    }
    
    // MARK: - Helper Functions

    private func computeAvailableUnits(for ingredient: Ingredient) -> [MeasurementUnit] {
        var units = Set<MeasurementUnit>()

        // Collect all direct units from conversions
        for conversion in ingredient.conversions ?? [] {
            // Skip conversions with missing units
            guard let fromUnit = conversion.fromUnit,
                  let toUnit = conversion.toUnit else {
                continue
            }

            units.insert(fromUnit)
            units.insert(toUnit)
        }

        // Now add all units of the same type for each unique unit we found
        // This way we only call allUnitsOfSameType() once per unique unit instead of per conversion
        let baseUnits = units
        for unit in baseUnits {
            let sameTypeUnits = UnitConversionHelper.allUnitsOfSameType(as: unit)
            units.formUnion(sameTypeUnits)
        }

        return Array(units).sorted { $0.sortOrder < $1.sortOrder }
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
              let amount = effectiveAmount,
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Ingredient.self, configurations: config)

    // Create flour with conversions
    let flour = Ingredient(name: "All-purpose flour", category: "Flour", brand: "King Arthur", isFavorite: true, isCustom: false)

    // Add conversions
    let cupToGram = UnitConversion(
        fromAmount: 1,
        fromUnit: .cup,
        toAmount: 120,
        toUnit: .gram
    )
    let tbspToGram = UnitConversion(
        fromAmount: 1,
        fromUnit: .tablespoon,
        toAmount: 7.5,
        toUnit: .gram
    )

    flour.conversions?.append(cupToGram)
    flour.conversions?.append(tbspToGram)

    container.mainContext.insert(flour)

    return NavigationStack {
        ConversionView(preselectedIngredient: flour)
            .modelContainer(container)
            .environment(\.appColorScheme, .sage)
    }
}

#Preview("Count-based Ingredient") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Ingredient.self, configurations: config)

    // Create apple with count-based conversions
    let apple = Ingredient(name: "Apple", category: "Fruit", brand: nil, isFavorite: false, isCustom: false)

    // Add conversions with count units
    let countToGram = UnitConversion(
        fromAmount: 1,
        fromUnit: .count(singular: "apple", plural: "apples"),
        toAmount: 182,
        toUnit: .gram
    )
    let countToCup = UnitConversion(
        fromAmount: 1,
        fromUnit: .count(singular: "apple", plural: "apples"),
        toAmount: 1.25,
        toUnit: .cup
    )

    apple.conversions?.append(countToGram)
    apple.conversions?.append(countToCup)

    container.mainContext.insert(apple)

    return NavigationStack {
        ConversionView(preselectedIngredient: apple)
            .modelContainer(container)
            .environment(\.appColorScheme, .sage)
    }
}
