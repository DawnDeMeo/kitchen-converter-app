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

    @State private var ingredients: [Ingredient] = []
    @State private var searchText = ""
    @State private var sortOption: IngredientSortOption = .alphabetical
    @State private var filterOption: IngredientFilterOption = .all
    @State private var showingAddIngredient = false
    @State private var ingredientToEdit: Ingredient?
    @State private var ingredientToDelete: Ingredient?
    @State private var showingDeleteConfirmation = false
    @State private var ingredientToConvert: Ingredient?

    // Fetch ingredients with predicates and sorting at the database level
    private func fetchIngredients() {
        var descriptor = FetchDescriptor<Ingredient>()

        // Build combined predicate based on filter and search
        let search = searchText

        switch (filterOption, searchText.isEmpty) {
        case (.all, true):
            // No predicate needed - fetch all
            descriptor.predicate = nil

        case (.all, false):
            // Only search predicate
            descriptor.predicate = #Predicate { ingredient in
                ingredient.name.localizedStandardContains(search) ||
                (ingredient.brand?.localizedStandardContains(search) ?? false)
            }

        case (.favorites, true):
            // Only favorites predicate
            descriptor.predicate = #Predicate { $0.isFavorite == true }

        case (.favorites, false):
            // Favorites AND search
            descriptor.predicate = #Predicate { ingredient in
                ingredient.isFavorite == true &&
                (ingredient.name.localizedStandardContains(search) ||
                 (ingredient.brand?.localizedStandardContains(search) ?? false))
            }

        case (.custom, true):
            // Only custom predicate
            descriptor.predicate = #Predicate { $0.isCustom == true }

        case (.custom, false):
            // Custom AND search
            descriptor.predicate = #Predicate { ingredient in
                ingredient.isCustom == true &&
                (ingredient.name.localizedStandardContains(search) ||
                 (ingredient.brand?.localizedStandardContains(search) ?? false))
            }

        case (.defaultOnly, true):
            // Only default predicate
            descriptor.predicate = #Predicate { $0.isCustom == false }

        case (.defaultOnly, false):
            // Default AND search
            descriptor.predicate = #Predicate { ingredient in
                ingredient.isCustom == false &&
                (ingredient.name.localizedStandardContains(search) ||
                 (ingredient.brand?.localizedStandardContains(search) ?? false))
            }
        }

        // Apply sort descriptors at database level
        switch sortOption {
        case .alphabetical:
            descriptor.sortBy = [SortDescriptor(\Ingredient.name, order: .forward)]
        case .lastUsed:
            descriptor.sortBy = [
                SortDescriptor(\Ingredient.lastUsedDate, order: .reverse),
                SortDescriptor(\Ingredient.name, order: .forward)
            ]
        }

        // Fetch from SwiftData
        do {
            ingredients = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch ingredients: \(error)")
            ingredients = []
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if ingredients.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No Ingredients" : "No Results",
                        systemImage: searchText.isEmpty ? "tray" : "magnifyingglass",
                        description: Text(searchText.isEmpty ? "Add ingredients to get started" : "Try adjusting your search or filters")
                    )
                } else {
                    List {
                        ForEach(ingredients) { ingredient in
                            Button {
                                ingredientToConvert = ingredient
                            } label: {
                                IngredientRow(ingredient: ingredient)
                            }
                            .buttonStyle(.plain)
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
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                if ingredient.isCustom {
                                    Button(role: .destructive) {
                                        ingredientToDelete = ingredient
                                        showingDeleteConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button {
                                        ingredientToEdit = ingredient
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                            }
                            .contextMenu {
                                Button {
                                    ingredientToConvert = ingredient
                                } label: {
                                    Label("Convert", systemImage: "arrow.left.arrow.right")
                                }
                                
                                Divider()
                                
                                Button {
                                    toggleFavorite(ingredient)
                                } label: {
                                    Label(
                                        ingredient.isFavorite ? "Unfavorite" : "Favorite",
                                        systemImage: ingredient.isFavorite ? "star.slash.fill" : "star.fill"
                                    )
                                }
                                
                                if ingredient.isCustom {
                                    Button {
                                        ingredientToEdit = ingredient
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    
                                    Divider()
                                    
                                    Button(role: .destructive) {
                                        ingredientToDelete = ingredient
                                        showingDeleteConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
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
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddIngredient = true
                    } label: {
                        Label("Add Ingredient", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddIngredient, onDismiss: {
                fetchIngredients()
            }) {
                IngredientEditorView()
            }
            .sheet(item: $ingredientToEdit, onDismiss: {
                fetchIngredients()
            }) { ingredient in
                IngredientEditorView(ingredient: ingredient)
            }
            .sheet(item: $ingredientToConvert) { ingredient in
                NavigationStack {
                    ConversionView(preselectedIngredient: ingredient)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") {
                                    ingredientToConvert = nil
                                }
                            }
                        }
                }
            }
            .confirmationDialog(
                "Delete \(ingredientToDelete?.name ?? "ingredient")?",
                isPresented: $showingDeleteConfirmation,
                presenting: ingredientToDelete
            ) { ingredient in
                Button("Delete", role: .destructive) {
                    deleteIngredient(ingredient)
                }
                Button("Cancel", role: .cancel) { }
            } message: { ingredient in
                Text("This action cannot be undone. This ingredient has \(ingredient.conversions.count) conversion\(ingredient.conversions.count == 1 ? "" : "s").")
            }
            .onAppear {
                fetchIngredients()
            }
            .onChange(of: searchText) { _, _ in
                fetchIngredients()
            }
            .onChange(of: filterOption) { _, _ in
                fetchIngredients()
            }
            .onChange(of: sortOption) { _, _ in
                fetchIngredients()
            }
        }
    }
    
    private func toggleFavorite(_ ingredient: Ingredient) {
        withAnimation {
            ingredient.isFavorite.toggle()
            // Refetch to reflect changes if filtering by favorites
            if filterOption == .favorites {
                fetchIngredients()
            }
        }
    }

    private func deleteIngredient(_ ingredient: Ingredient) {
        withAnimation {
            modelContext.delete(ingredient)
            fetchIngredients()
        }
    }
}

struct IngredientRow: View {
    @Bindable var ingredient: Ingredient
    
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
