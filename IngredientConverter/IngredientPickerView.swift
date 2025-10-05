//
//  IngredientPickerView.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/5/25.
//

import SwiftUI

struct IngredientPickerView: View {
    let ingredients: [Ingredient]
    @Binding var selectedIngredient: Ingredient?
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var showFavoritesOnly = false
    
    var filteredIngredients: [Ingredient] {
        var filtered = ingredients
        
        // Filter by favorites
        if showFavoritesOnly {
            filtered = filtered.filter { $0.isFavorite }
        }
        
        // Filter by search
        if !searchText.isEmpty {
            filtered = filtered.filter { ingredient in
                ingredient.name.localizedCaseInsensitiveContains(searchText) ||
                (ingredient.brand?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return filtered.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if !filteredIngredients.isEmpty {
                    ForEach(filteredIngredients) { ingredient in
                        Button {
                            selectedIngredient = ingredient
                            dismiss()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(ingredient.name)
                                            .foregroundColor(.primary)
                                        
                                        if ingredient.isFavorite {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                                .font(.caption)
                                        }
                                        
                                        if ingredient.isCustom {
                                            Image(systemName: "person.fill")
                                                .foregroundColor(.blue)
                                                .font(.caption)
                                        }
                                    }
                                    
                                    if let brand = ingredient.brand {
                                        Text(brand)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text("\(ingredient.conversions.count) conversion\(ingredient.conversions.count == 1 ? "" : "s")")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if selectedIngredient?.id == ingredient.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                ingredient.isFavorite.toggle()
                            } label: {
                                Label(
                                    ingredient.isFavorite ? "Unfavorite" : "Favorite",
                                    systemImage: ingredient.isFavorite ? "star.slash" : "star.fill"
                                )
                            }
                            .tint(ingredient.isFavorite ? .gray : .yellow)
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "No Ingredients Found",
                        systemImage: "magnifyingglass",
                        description: Text("Try adjusting your search or filters")
                    )
                }
            }
            .navigationTitle("Select Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search ingredients")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showFavoritesOnly.toggle()
                    } label: {
                        Image(systemName: showFavoritesOnly ? "star.fill" : "star")
                            .foregroundColor(showFavoritesOnly ? .yellow : .blue)
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedIngredient: Ingredient?
    
    let flour = Ingredient(name: "Flour, all-purpose", isFavorite: true)
    let sugar = Ingredient(name: "Sugar, granulated")
    let butter = Ingredient(name: "Butter", brand: "Kerry Gold", isFavorite: true, isCustom: true)
    
    let sampleIngredients = [flour, sugar, butter]
    
    IngredientPickerView(
        ingredients: sampleIngredients,
        selectedIngredient: $selectedIngredient
    )
}
