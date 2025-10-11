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
    
    let ingredientToEdit: Ingredient?
    
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
    
    init(ingredient: Ingredient? = nil) {
        self.ingredientToEdit = ingredient
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Name", text: $name)
                    TextField("Brand (optional)", text: $brand)

                    Picker("Category", selection: $category) {
                        ForEach(availableCategories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
                
                Section {
                    ForEach(conversions) { conversion in
                        ConversionEditorRow(conversion: conversion)
                    }
                    .onDelete(perform: deleteConversion)
                    .onMove(perform: moveConversion)
                    
                    Button {
                        showingAddConversion = true
                    } label: {
                        Label("Add Conversion", systemImage: "plus.circle.fill")
                    }
                } header: {
                    Text("Conversions")
                } footer: {
                    if conversions.isEmpty {
                        Text("Add at least one conversion to save this ingredient")
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Ingredient" : "New Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
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
            .sheet(isPresented: $showingAddConversion) {
                ConversionEditorSheet { newConversion in
                    conversions.append(newConversion)
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
    }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !conversions.isEmpty
    }
    
    private func loadIngredient() {
        guard let ingredient = ingredientToEdit else { return }

        name = ingredient.name
        brand = ingredient.brand ?? ""
        category = ingredient.category ?? "Other"
        conversions = ingredient.conversions.map { conversion in
            ConversionEditor(
                fromAmount: conversion.fromAmount,
                fromUnit: conversion.fromUnit,
                toAmount: conversion.toAmount,
                toUnit: conversion.toUnit
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
            existing.conversions.removeAll()

            for conversionEditor in conversions {
                let conversion = UnitConversion(
                    fromAmount: conversionEditor.fromAmount,
                    fromUnit: conversionEditor.fromUnit,
                    toAmount: conversionEditor.toAmount,
                    toUnit: conversionEditor.toUnit
                )
                conversion.ingredient = existing
                existing.conversions.append(conversion)
            }
        } else {
            // Create new ingredient
            let newIngredient = Ingredient(
                name: trimmedName,
                category: category,
                brand: trimmedBrand.isEmpty ? nil : trimmedBrand,
                isCustom: true
            )

            for conversionEditor in conversions {
                let conversion = UnitConversion(
                    fromAmount: conversionEditor.fromAmount,
                    fromUnit: conversionEditor.fromUnit,
                    toAmount: conversionEditor.toAmount,
                    toUnit: conversionEditor.toUnit
                )
                newIngredient.conversions.append(conversion)
            }

            modelContext.insert(newIngredient)
        }
        
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
    @Bindable var conversion: ConversionEditor
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("From:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack {
                TextField("Amount", value: $conversion.fromAmount, format: .number)
                    .keyboardType(.numbersAndPunctuation)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                
                Text(conversion.fromUnit.displayName)
                    .foregroundColor(.secondary)
            }
            
            Image(systemName: "arrow.down")
                .foregroundColor(.blue)
                .font(.caption)
            
            HStack {
                Text("To:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack {
                TextField("Amount", value: $conversion.toAmount, format: .number)
                    .keyboardType(.numbersAndPunctuation)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                
                Text(conversion.toUnit.displayName)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    IngredientEditorView()
        .modelContainer(for: Ingredient.self, inMemory: true)
}
