//
//  IngredientRowView.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/13/25.
//

import SwiftUI
import SwiftData

struct IngredientRowView: View {
    @Environment(\.appColorScheme) private var colorScheme
    @Bindable var ingredient: Ingredient

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(ingredient.name)
                    .font(.body)
                    .foregroundColor(colorScheme.primaryText)
                
                HStack(spacing: 8) {
                    if let brand = ingredient.brand {
                        Text(brand)
                            .font(.caption)
                            .foregroundColor(colorScheme.secondaryText)
                    }
                    
                    if let category = ingredient.category {
                        HStack(spacing: 4) {
                            Image(systemName: "tag.fill")
                                .font(.caption2)
                            Text(category)
                                .font(.caption2)
                        }
                        .foregroundColor(colorScheme.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(colorScheme.secondary.opacity(0.1))
                        .clipShape(Capsule())
                    }
                    
                    if ingredient.isCustom {
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                            Text("Custom")
                        }
                        .font(.caption2)
                        .foregroundColor(colorScheme.primary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(colorScheme.primary.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Ingredient.self, configurations: config)
        
        return container
    }()
    
    IngredientRowView(ingredient: Ingredient(name: "All-purpose flour", category: "Flour", brand: "King Arthur", isFavorite: true, isCustom: true))
        .modelContainer(container)
}
