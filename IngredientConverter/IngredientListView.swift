//
//  IngredientListView.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/5/25.
//

import SwiftUI
import SwiftData

struct IngredientListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var ingredients: [Ingredient]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(ingredients.sorted { $0.name < $1.name }) { ingredient in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ingredient.name)
                        
                        if let brand = ingredient.brand {
                            Text(brand)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("\(ingredient.conversions.count) conversions")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Ingredients")
        }
    }
}

#Preview {
    IngredientListView()
        .modelContainer(for: Ingredient.self, inMemory: true)
}
