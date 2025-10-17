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
                            IngredientRowView(ingredient: ingredient)
                            .padding(.vertical, 4)
                            .listRowBackground(colorScheme.cardBackground)
                        } header: {
                            Text("Ingredient")
                                .foregroundColor(colorScheme.secondary)
                        }
                    }

                    // Conversion Controls
                    Section {
                        // Amount Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Amount")
                                .font(.caption)
                                .foregroundColor(colorScheme.secondary)
                                .textCase(.uppercase)

                            NoKeyboardTextField(
                                text: $inputAmount,
                                placeholder: "Enter amount (e.g., 1 1/2)",
                                isFocused: $isKeyboardVisible,
                                onChange: performConversion
                            )
                            .foregroundColor(colorScheme.primaryText)
                            .accessibilityLabel("Amount to convert")
                            .accessibilityValue(inputAmount.isEmpty ? "Empty" : amountToWords(inputAmount))
                            .accessibilityHint("Enter the quantity you want to convert")
                        }
                        .listRowBackground(colorScheme.cardBackground)

                        // From, Swap, To in horizontal layout
                        if selectedIngredient != nil {
                            HStack(alignment: .bottom, spacing: 8) {
                                // From Unit
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("From")
                                        .font(.caption)
                                        .foregroundColor(colorScheme.secondary)
                                        .textCase(.uppercase)

                                    Picker("", selection: $selectedFromUnit) {
                                        Text("Select").tag(nil as MeasurementUnit?)
                                        ForEach(cachedAvailableUnits, id: \.self) { unit in
                                            Text(unit.fullDisplayName).tag(unit as MeasurementUnit?)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .accessibilityLabel("From unit")
                                    .onChange(of: selectedFromUnit) { _, _ in
                                        performConversion()
                                        withAnimation {
                                            proxy.scrollTo("result", anchor: .bottom)
                                        }
                                    }
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
                                    }
                                    .padding(8)
                                    .background(colorScheme.primary.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .accessibilityLabel("Swap units")
                                    .accessibilityHint("Swaps the from and to units")
                                }

                                // To Unit
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("To")
                                        .font(.caption)
                                        .foregroundColor(colorScheme.secondary)
                                        .textCase(.uppercase)

                                    Picker("", selection: $selectedToUnit) {
                                        Text("Select").tag(nil as MeasurementUnit?)
                                        ForEach(cachedAvailableUnits, id: \.self) { unit in
                                            Text(unit.fullDisplayName).tag(unit as MeasurementUnit?)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .accessibilityLabel("To unit")
                                    .onChange(of: selectedToUnit) { _, _ in
                                        performConversion()
                                        withAnimation {
                                            proxy.scrollTo("result", anchor: .bottom)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .listRowBackground(colorScheme.cardBackground)
                        }
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
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("\(amountToWords(inputAmount)) \(unitDisplayText(fromUnit, amount: amount)) equals \(amountToWords(formatAmount(result))) \(unitDisplayText(toUnit, amount: result))")
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
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Warning: No conversion available")
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
        .task(id: selectedIngredient?.id) {
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

        // Check if it's a decimal - replace any "dot" mentions with "point"
        // VoiceOver should naturally say "point" for decimals, but we'll ensure it
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
    }
}
