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
    @Environment(\.appColorScheme) private var colorScheme

    @State private var ingredients: [Ingredient] = []
    @State private var searchText = ""

    // Persisted preferences
    @AppStorage("sortOption") private var sortOption: IngredientSortOption = .alphabetical
    @AppStorage("filterOption") private var filterOption: IngredientFilterOption = .all
    @AppStorage("selectedCategory") private var selectedCategory: String?

    @State private var availableCategories: [String] = []
    @State private var showingAddIngredient = false
    @State private var showingSettings = false
    @State private var ingredientToEdit: Ingredient?
    @State private var ingredientToDelete: Ingredient?
    @State private var showingDeleteConfirmation = false
    @State private var ingredientToConvert: Ingredient?

    // Fetch ingredients with predicates and sorting at the database level
    private func fetchIngredients() {
        var descriptor = FetchDescriptor<Ingredient>()

        // Build combined predicate based on filter, search, and category
        let search = searchText
        let category = selectedCategory

        switch (filterOption, searchText.isEmpty, selectedCategory == nil) {
        // No filters at all
        case (.all, true, true):
            descriptor.predicate = nil

        // Only category filter
        case (.all, true, false):
            descriptor.predicate = #Predicate { ingredient in
                ingredient.category == category
            }

        // Only search filter
        case (.all, false, true):
            descriptor.predicate = #Predicate { ingredient in
                ingredient.name.localizedStandardContains(search) ||
                (ingredient.brand?.localizedStandardContains(search) ?? false)
            }

        // Category AND search
        case (.all, false, false):
            descriptor.predicate = #Predicate { ingredient in
                ingredient.category == category &&
                (ingredient.name.localizedStandardContains(search) ||
                 (ingredient.brand?.localizedStandardContains(search) ?? false))
            }

        // Favorites only
        case (.favorites, true, true):
            descriptor.predicate = #Predicate { $0.isFavorite == true }

        // Favorites AND category
        case (.favorites, true, false):
            descriptor.predicate = #Predicate { ingredient in
                ingredient.isFavorite == true &&
                ingredient.category == category
            }

        // Favorites AND search
        case (.favorites, false, true):
            descriptor.predicate = #Predicate { ingredient in
                ingredient.isFavorite == true &&
                (ingredient.name.localizedStandardContains(search) ||
                 (ingredient.brand?.localizedStandardContains(search) ?? false))
            }

        // Favorites AND category AND search
        case (.favorites, false, false):
            descriptor.predicate = #Predicate { ingredient in
                ingredient.isFavorite == true &&
                ingredient.category == category &&
                (ingredient.name.localizedStandardContains(search) ||
                 (ingredient.brand?.localizedStandardContains(search) ?? false))
            }

        // Custom only
        case (.custom, true, true):
            descriptor.predicate = #Predicate { $0.isCustom == true }

        // Custom AND category
        case (.custom, true, false):
            descriptor.predicate = #Predicate { ingredient in
                ingredient.isCustom == true &&
                ingredient.category == category
            }

        // Custom AND search
        case (.custom, false, true):
            descriptor.predicate = #Predicate { ingredient in
                ingredient.isCustom == true &&
                (ingredient.name.localizedStandardContains(search) ||
                 (ingredient.brand?.localizedStandardContains(search) ?? false))
            }

        // Custom AND category AND search
        case (.custom, false, false):
            descriptor.predicate = #Predicate { ingredient in
                ingredient.isCustom == true &&
                ingredient.category == category &&
                (ingredient.name.localizedStandardContains(search) ||
                 (ingredient.brand?.localizedStandardContains(search) ?? false))
            }

        // Default only
        case (.defaultOnly, true, true):
            descriptor.predicate = #Predicate { $0.isCustom == false }

        // Default AND category
        case (.defaultOnly, true, false):
            descriptor.predicate = #Predicate { ingredient in
                ingredient.isCustom == false &&
                ingredient.category == category
            }

        // Default AND search
        case (.defaultOnly, false, true):
            descriptor.predicate = #Predicate { ingredient in
                ingredient.isCustom == false &&
                (ingredient.name.localizedStandardContains(search) ||
                 (ingredient.brand?.localizedStandardContains(search) ?? false))
            }

        // Default AND category AND search
        case (.defaultOnly, false, false):
            descriptor.predicate = #Predicate { ingredient in
                ingredient.isCustom == false &&
                ingredient.category == category &&
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

    private func fetchAvailableCategories() {
        let descriptor = FetchDescriptor<Ingredient>()
        do {
            let allIngredients = try modelContext.fetch(descriptor)
            let categories = Set(allIngredients.compactMap { $0.category })
            availableCategories = categories.sorted()
        } catch {
            print("Failed to fetch categories: \(error)")
            availableCategories = []
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
                    .foregroundStyle(colorScheme.primaryText, colorScheme.secondaryText)
                } else {
                    List {
                        ForEach(ingredients) { ingredient in
                            Button {
                                ingredientToConvert = ingredient
                            } label: {
                                IngredientRow(ingredient: ingredient)
                            }
                            .listRowBackground(colorScheme.cardBackground)
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
                                .tint(ingredient.isFavorite ? colorScheme.secondary.opacity(0.6) : colorScheme.accent)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                if ingredient.isCustom {
                                    Button(role: .destructive) {
                                        ingredientToDelete = ingredient
                                        showingDeleteConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    .tint(colorScheme.error)

                                    Button {
                                        ingredientToEdit = ingredient
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(colorScheme.primary)
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
                    .scrollContentBackground(.hidden)
                    .background(colorScheme.background)
                }
            }
            .background(colorScheme.background)
            .navigationTitle("Ingredients")
            .searchable(text: $searchText, prompt: "Search ingredients")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        sortOption = sortOption == .alphabetical ? .lastUsed : .alphabetical
                    } label: {
                        Image(systemName: sortOption.systemImage)
                            .frame(width: 20, alignment: .center)
                            .padding(.horizontal, 4)
                    }
                }

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

                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button {
                            selectedCategory = nil
                        } label: {
                            HStack {
                                Label("All Categories", systemImage: "square.stack.3d.up")
                                if selectedCategory == nil {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }

                        Divider()

                        ForEach(availableCategories, id: \.self) { category in
                            Button {
                                selectedCategory = category
                            } label: {
                                HStack {
                                    Text(category)
                                    if selectedCategory == category {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Label(
                            selectedCategory ?? "Category",
                            systemImage: "tag"
                        )
                        .symbolVariant(selectedCategory == nil ? .none : .fill)
                    }
                }

                if filterOption != .all || selectedCategory != nil {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            filterOption = .all
                            selectedCategory = nil
                        } label: {
                            Label("Clear Filters", systemImage: "xmark.circle.fill")
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Label("Settings", systemImage: "gearshape")
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
            .navigationDestination(item: $ingredientToConvert) { ingredient in
                ConversionView(preselectedIngredient: ingredient)
            }
            .sheet(isPresented: $showingSettings, onDismiss: {
                fetchAvailableCategories()
                fetchIngredients()
            }) {
                SettingsView()
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
                fetchAvailableCategories()
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
            .onChange(of: selectedCategory) { _, _ in
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
    @Environment(\.appColorScheme) private var colorScheme
    @Bindable var ingredient: Ingredient

    var body: some View {
        HStack(spacing: 12) {
            IngredientRowView(ingredient: ingredient)

            Spacer()

            Button {
                ingredient.isFavorite.toggle()
            } label: {
                Image(systemName: ingredient.isFavorite ? "star.fill" : "star")
                    .foregroundColor(ingredient.isFavorite ? colorScheme.accent : colorScheme.secondaryText.opacity(0.4))
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

#Preview {
    @Previewable @State var container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Ingredient.self, configurations: config)
        
        let flour = Ingredient(name: "All-purpose flour", category: "Flour", brand: "King Arthur", isFavorite: true, isCustom: true)
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
