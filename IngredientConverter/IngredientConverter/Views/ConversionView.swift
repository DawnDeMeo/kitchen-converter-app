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
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                Form {
                    // Result - Always visible when units are selected
                    if let fromUnit = selectedFromUnit,
                       let toUnit = selectedToUnit,
                       selectedIngredient != nil {
                        Section {
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
                                .accessibilityLabel(inputAmount.isEmpty ? "Tap to enter amount" : "\(amountToWords(displayAmount)) \(unitDisplayText(fromUnit, amount: effectiveAmount ?? 1))")
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
                .onAppear {
                    print("Custom keyboard appeared")
                }
            } else {
                Color.clear
                    .frame(height: 0)
                    .onAppear {
                        print("Custom keyboard hidden, isKeyboardVisible = \(isKeyboardVisible)")
                    }
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
        .onChange(of: selectedIngredient) { _, newIngredient in
            // Reset units when ingredient changes
            selectedFromUnit = nil
            selectedToUnit = nil
            conversionResult = nil

            // Compute and cache available units for new ingredient
            if let ingredient = newIngredient {
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
        .task(id: selectedIngredient?.id) {
            // Compute units on initial appearance if ingredient is preselected
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
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isKeyboardVisible)
        .onChange(of: isKeyboardVisible) { oldValue, newValue in
            print("isKeyboardVisible changed from \(oldValue) to \(newValue)")
        }
    }
    
    // MARK: - Helper Functions

    private func computeAvailableUnits(for ingredient: Ingredient) -> [MeasurementUnit] {
        var units = Set<MeasurementUnit>()

        // Add all units from conversions
        for conversion in ingredient.conversions ?? [] {
            // Skip conversions with missing units
            guard let fromUnit = conversion.fromUnit,
                  let toUnit = conversion.toUnit else {
                continue
            }

            units.insert(fromUnit)
            units.insert(toUnit)

            // Add all units of the same type
            let fromSameType = UnitConversionHelper.allUnitsOfSameType(as: fromUnit)
            units.formUnion(fromSameType)

            let toSameType = UnitConversionHelper.allUnitsOfSameType(as: toUnit)
            units.formUnion(toSameType)
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

    private func amountToWords(_ amount: String) -> String {
        let trimmed = amount.trimmingCharacters(in: .whitespaces)

        // Check if it's a mixed number (e.g., "1 1/2")
        if trimmed.contains(" ") && trimmed.contains("/") {
            let parts = trimmed.components(separatedBy: " ")
            if parts.count == 2 {
                let whole = parts[0]
                let fraction = parts[1]
                return "\(whole) and \(fractionToWords(fraction))"
            }
        }

        // Check if it's a simple fraction (e.g., "1/4")
        if trimmed.contains("/") && !trimmed.contains(" ") {
            return fractionToWords(trimmed)
        }

        // Check if it's a decimal - replace "." with " point " for VoiceOver
        if trimmed.contains(".") {
            return trimmed.replacingOccurrences(of: ".", with: " point ")
        }

        return trimmed
    }

    private func fractionToWords(_ fraction: String) -> String {
        switch fraction {
        case "1/8": return "one eighth"
        case "1/4": return "one quarter"
        case "1/3": return "one third"
        case "1/2": return "one half"
        case "2/3": return "two thirds"
        case "3/4": return "three quarters"
        default:
            // Try to parse other fractions like "5/8" → "five eighths"
            let components = fraction.components(separatedBy: "/")
            if components.count == 2,
               let numerator = Int(components[0]),
               let denominator = Int(components[1]) {
                let numWord = numberToWord(numerator)
                let denomWord = denominatorToWord(denominator, plural: numerator > 1)
                return "\(numWord) \(denomWord)"
            }
            return fraction
        }
    }

    private func numberToWord(_ num: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        return formatter.string(from: NSNumber(value: num)) ?? "\(num)"
    }

    private func denominatorToWord(_ denom: Int, plural: Bool) -> String {
        let base: String
        switch denom {
        case 2: base = "half"
        case 3: base = "third"
        case 4: base = "quarter"
        case 5: base = "fifth"
        case 6: base = "sixth"
        case 7: base = "seventh"
        case 8: base = "eighth"
        case 9: base = "ninth"
        case 10: base = "tenth"
        default: base = "\(denom)th"
        }
        return plural ? base + "s" : base
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
