//
//  IngredientListView.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/5/25.
//

import SwiftUI
import SwiftData

enum IngredientSortOption: String, CaseIterable {
    case alphabetical = "Alphabetical"
    case lastUsed = "Last Used"
    
    var systemImage: String {
        switch self {
        case .alphabetical: return "textformat.abc"
        case .lastUsed: return "clock"
        }
    }
}

enum IngredientFilterOption: String, CaseIterable {
    case all = "All"
    case favorites = "Favorites"
    case custom = "Custom"
    case defaultOnly = "Default"
    
    var systemImage: String {
        switch self {
        case .all: return "square.stack.3d.up"
        case .favorites: return "star.fill"
        case .custom: return "person.fill"
        case .defaultOnly: return "shippingbox.fill"
        }
    }
}

struct IngredientListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allIngredients: [Ingredient]
    
    @State private var searchText = ""
    @State private var sortOption: IngredientSortOption = .alphabetical
    @State private var filterOption: IngredientFilterOption = .all
    @State private var showingSortOptions = false
    @State private var showingFilterOptions = false
    
    var filteredAndSortedIngredients: [Ingredient] {
        var ingredients = allIngredients
        
        // Apply filter
        switch filterOption {
        case .all:
            break // Show all
        case .favorites:
            ingredients = ingredients.filter { $0.isFavorite }
        case .custom:
            ingredients = ingredients.filter { $0.isCustom }
        case .defaultOnly:
            ingredients = ingredients.filter { !$0.isCustom }
        }
        
        // Apply search
        if !searchText.isEmpty {
            ingredients = ingredients.filter { ingredient in
                ingredient.name.localizedCaseInsensitiveContains(searchText) ||
                (ingredient.brand?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Apply sort
        switch sortOption {
        case .alphabetical:
            ingredients.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .lastUsed:
            ingredients.sort { (lhs, rhs) in
                // Items with lastUsedDate come first, sorted by most recent
                // Items without lastUsedDate come last, sorted alphabetically
                switch (lhs.lastUsedDate, rhs.lastUsedDate) {
                case (.some(let lDate), .some(let rDate)):
                    return lDate > rDate
                case (.some, .none):
                    return true
                case (.none, .some):
                    return false
                case (.none, .none):
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                }
            }
        }
        
        return ingredients
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if filteredAndSortedIngredients.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No Ingredients" : "No Results",
                        systemImage: searchText.isEmpty ? "tray" : "magnifyingglass",
                        description: Text(searchText.isEmpty ? "Add ingredients to get started" : "Try adjusting your search or filters")
                    )
                } else {
                    List {
                        ForEach(filteredAndSortedIngredients) { ingredient in
                            IngredientRow(ingredient: ingredient)
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button {
                                        toggleFavorite(ingredient)
                                    } label: {
                                        Label(
                                            ingredient.isFavorite ? "Unfavorite" : "Favorite",
                                            systemImage: ingredient.isFavorite ? "star.slash" : "star.fill"
                                        )
                                    }
                                    .tint(ingredient.isFavorite ? .gray : .yellow)
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Ingredients")
            .searchable(text: $searchText, prompt: "Search ingredients")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Filter", selection: $filterOption) {
                            ForEach(IngredientFilterOption.allCases, id: \.self) { option in
                                Label(option.rawValue, systemImage: option.systemImage)
                                    .tag(option)
                            }
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                            .symbolVariant(filterOption == .all ? .none : .fill)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Sort", selection: $sortOption) {
                            ForEach(IngredientSortOption.allCases, id: \.self) { option in
                                Label(option.rawValue, systemImage: option.systemImage)
                                    .tag(option)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
        }
    }
    
    private func toggleFavorite(_ ingredient: Ingredient) {
        withAnimation {
            ingredient.isFavorite.toggle()
        }
    }
}

struct IngredientRow: View {
    @Bindable var ingredient: Ingredient
    
    private var lastUsedText: String {
        guard let lastUsed = ingredient.lastUsedDate else {
            return "Never used"
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(lastUsed) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Used today at \(formatter.string(from: lastUsed))"
        } else if calendar.isDateInYesterday(lastUsed) {
            return "Used yesterday"
        } else if let days = calendar.dateComponents([.day], from: lastUsed, to: now).day, days < 7 {
            return "Used \(days) day\(days == 1 ? "" : "s") ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return "Used \(formatter.string(from: lastUsed))"
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(ingredient.name)
                        .font(.body)
                    
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
                
                HStack(spacing: 12) {
                    Label("\(ingredient.conversions.count)", systemImage: "arrow.left.arrow.right")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(lastUsedText)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button {
                ingredient.isFavorite.toggle()
            } label: {
                Image(systemName: ingredient.isFavorite ? "star.fill" : "star")
                    .foregroundColor(ingredient.isFavorite ? .yellow : .gray)
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    @Previewable @State var container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Ingredient.self, configurations: config)
        
        // Add sample data
        let flour = Ingredient(name: "Flour, all-purpose", brand: "King Arthur", isFavorite: true)
        flour.lastUsedDate = Date()
        
        let sugar = Ingredient(name: "Sugar, granulated", isFavorite: false)
        sugar.lastUsedDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        
        let butter = Ingredient(name: "Butter", brand: "Kerry Gold", isFavorite: true, isCustom: true)
        
        let eggs = Ingredient(name: "Eggs, large")
        
        container.mainContext.insert(flour)
        container.mainContext.insert(sugar)
        container.mainContext.insert(butter)
        container.mainContext.insert(eggs)
        
        return container
    }()
    
    IngredientListView()
        .modelContainer(container)
}
