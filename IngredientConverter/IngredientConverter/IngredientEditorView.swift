//
//  IngredientEditorView.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/6/25.
//

import SwiftUI
import SwiftData

struct IngredientEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appColorScheme) private var colorScheme

    let ingredientToEdit: Ingredient?
    let onDismiss: (() -> Void)?
    
    @State private var name: String = ""
    @State private var brand: String = ""
    @State private var category: String = "Other"
    @State private var conversions: [ConversionEditor] = []
    @State private var showingAddConversion = false

    // For validation
    @State private var showingError = false
    @State private var errorMessage = ""

    // Available categories matching the database
    private let availableCategories = [
        "Baking",
        "Chocolate",
        "Dairy",
        "Dried Fruit",
        "Egg",
        "Fat",
        "Flour",
        "Fruit",
        "Grain",
        "Nut",
        "Other",
        "Spice",
        "Sugar",
        "Vegetable"
    ]
    
    var isEditing: Bool {
        ingredientToEdit != nil
    }

    init(ingredient: Ingredient? = nil, onDismiss: (() -> Void)? = nil) {
        self.ingredientToEdit = ingredient
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        Form {
                Section {
                    TextField("Name", text: $name)
                        .foregroundColor(colorScheme.primaryText)
                        .listRowBackground(colorScheme.cardBackground)
                        .accessibilityLabel("Ingredient name")
                        .accessibilityHint("Enter the name of the ingredient")
                    TextField("Brand (optional)", text: $brand)
                        .foregroundColor(colorScheme.primaryText)
                        .listRowBackground(colorScheme.cardBackground)
                        .accessibilityLabel("Brand name")
                        .accessibilityHint("Enter the brand name, if applicable")

                    Picker("Category", selection: $category) {
                        ForEach(availableCategories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .listRowBackground(colorScheme.cardBackground)
                } header: {
                    Text("Basic Info")
                        .foregroundColor(colorScheme.secondary)
                }

                Section {
                    ForEach(conversions) { conversion in
                        ConversionEditorRow(conversion: conversion)
                            .listRowBackground(colorScheme.cardBackground)
                    }
                    .onDelete(perform: deleteConversion)
                    .onMove(perform: moveConversion)

                    Button {
                        showingAddConversion = true
                    } label: {
                        Label("Add Conversion", systemImage: "plus.circle.fill")
                            .foregroundColor(colorScheme.primary)
                    }
                    .listRowBackground(colorScheme.primary.opacity(0.1))
                } header: {
                    Text("Conversions")
                        .foregroundColor(colorScheme.secondary)
                } footer: {
                    if conversions.isEmpty {
                        Text("Add at least one conversion to save this ingredient")
                            .foregroundColor(colorScheme.warning)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(colorScheme.background)
            .navigationTitle(isEditing ? "Edit Ingredient" : "New Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveIngredient()
                    }
                    .disabled(!isValid)
                }

                if !conversions.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        EditButton()
                    }
                }
            }
            .navigationDestination(isPresented: $showingAddConversion) {
                ConversionEditorSheet { newConversion in
                    conversions.append(newConversion)
                    showingAddConversion = false
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                loadIngredient()
            }
    }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !conversions.isEmpty
    }
    
    private func loadIngredient() {
        guard let ingredient = ingredientToEdit else { return }

        name = ingredient.name
        brand = ingredient.brand ?? ""
        category = ingredient.category ?? "Other"
        conversions = (ingredient.conversions ?? []).compactMap { conversion in
            // Skip conversions with missing units
            guard let fromUnit = conversion.fromUnit,
                  let toUnit = conversion.toUnit else {
                return nil
            }

            return ConversionEditor(
                fromAmount: conversion.fromAmount,
                fromUnit: fromUnit,
                toAmount: conversion.toAmount,
                toUnit: toUnit
            )
        }
    }
    
    private func saveIngredient() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedBrand = brand.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedName.isEmpty else {
            errorMessage = "Please enter an ingredient name"
            showingError = true
            return
        }
        
        guard !conversions.isEmpty else {
            errorMessage = "Please add at least one conversion"
            showingError = true
            return
        }
        
        if let existing = ingredientToEdit {
            // Update existing ingredient
            existing.name = trimmedName
            existing.brand = trimmedBrand.isEmpty ? nil : trimmedBrand
            existing.category = category

            // Initialize conversions array if nil
            if existing.conversions == nil {
                existing.conversions = []
            }
            existing.conversions?.removeAll()

            for conversionEditor in conversions {
                let conversion = UnitConversion(
                    fromAmount: conversionEditor.fromAmount,
                    fromUnit: conversionEditor.fromUnit,
                    toAmount: conversionEditor.toAmount,
                    toUnit: conversionEditor.toUnit
                )
                conversion.ingredient = existing
                existing.conversions?.append(conversion)
            }
        } else {
            // Create new ingredient
            let newIngredient = Ingredient(
                name: trimmedName,
                category: category,
                brand: trimmedBrand.isEmpty ? nil : trimmedBrand,
                isCustom: true
            )

            // Initialize conversions array if nil
            if newIngredient.conversions == nil {
                newIngredient.conversions = []
            }

            for conversionEditor in conversions {
                let conversion = UnitConversion(
                    fromAmount: conversionEditor.fromAmount,
                    fromUnit: conversionEditor.fromUnit,
                    toAmount: conversionEditor.toAmount,
                    toUnit: conversionEditor.toUnit
                )
                newIngredient.conversions?.append(conversion)
            }

            modelContext.insert(newIngredient)
        }

        onDismiss?()
        dismiss()
    }
    
    private func deleteConversion(at offsets: IndexSet) {
        conversions.remove(atOffsets: offsets)
    }
    
    private func moveConversion(from source: IndexSet, to destination: Int) {
        conversions.move(fromOffsets: source, toOffset: destination)
    }
}

// Helper model for editing conversions
@Observable
class ConversionEditor: Identifiable {
    let id = UUID()
    var fromAmount: Double
    var fromUnit: MeasurementUnit
    var toAmount: Double
    var toUnit: MeasurementUnit
    
    init(fromAmount: Double = 1, fromUnit: MeasurementUnit = .cup, toAmount: Double = 1, toUnit: MeasurementUnit = .gram) {
        self.fromAmount = fromAmount
        self.fromUnit = fromUnit
        self.toAmount = toAmount
        self.toUnit = toUnit
    }
}

struct ConversionEditorRow: View {
    @Environment(\.appColorScheme) private var colorScheme
    @Bindable var conversion: ConversionEditor

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("From:")
                    .font(.caption.weight(.medium))
                    .foregroundColor(colorScheme.secondary)
                Spacer()
            }

            HStack(spacing: 12) {
                TextField("Amount", value: $conversion.fromAmount, format: .number)
                    .keyboardType(.numbersAndPunctuation)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                    .foregroundColor(colorScheme.primaryText)
                    .accessibilityLabel("From amount")
                    .accessibilityValue("\(conversion.fromAmount)")

                Text(conversion.fromUnit.displayName)
                    .foregroundColor(colorScheme.secondaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(colorScheme.primary.opacity(0.1))
                    .clipShape(Capsule())
                    .accessibilityLabel("From unit: \(conversion.fromUnit.displayName)")
            }

            HStack {
                Spacer()
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundColor(colorScheme.primary)
                    .font(.title3)
                Spacer()
            }

            HStack {
                Text("To:")
                    .font(.caption.weight(.medium))
                    .foregroundColor(colorScheme.secondary)
                Spacer()
            }

            HStack(spacing: 12) {
                TextField("Amount", value: $conversion.toAmount, format: .number)
                    .keyboardType(.numbersAndPunctuation)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                    .foregroundColor(colorScheme.primaryText)
                    .accessibilityLabel("To amount")
                    .accessibilityValue("\(conversion.toAmount)")

                Text(conversion.toUnit.displayName)
                    .foregroundColor(colorScheme.secondaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(colorScheme.accent.opacity(0.1))
                    .clipShape(Capsule())
                    .accessibilityLabel("To unit: \(conversion.toUnit.displayName)")
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        IngredientEditorView()
            .modelContainer(for: Ingredient.self, inMemory: true)
    }
}
