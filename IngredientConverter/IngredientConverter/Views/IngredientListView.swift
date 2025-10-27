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

        // Build combined predicate compositionally based on active filters
        let search = searchText
        let category = selectedCategory
        let hasSearch = !searchText.isEmpty
        let hasCategory = selectedCategory != nil

        // Build predicate based on combination of active filters
        descriptor.predicate = buildPredicate(
            filterOption: filterOption,
            search: hasSearch ? search : nil,
            category: hasCategory ? category : nil
        )

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
            DebugLogger.log("Failed to fetch ingredients: \(error)", category: "IngredientList")
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
            DebugLogger.log("Failed to fetch categories: \(error)", category: "IngredientList")
            availableCategories = []
        }
    }

    /// Build a predicate compositionally based on active filters
    /// - Parameters:
    ///   - filterOption: The type filter (all, favorites, custom, or default)
    ///   - search: Optional search string for name/brand
    ///   - category: Optional category filter
    /// - Returns: Combined predicate, or nil if no filters are active
    private func buildPredicate(
        filterOption: IngredientFilterOption,
        search: String?,
        category: String?
    ) -> Predicate<Ingredient>? {
        // If no filters at all, return nil (fetch all)
        if filterOption == .all && search == nil && category == nil {
            return nil
        }

        // Build predicate based on combination of filters
        switch (filterOption, search, category) {
        // Filter only
        case (.favorites, nil, nil):
            return #Predicate { $0.isFavorite == true }
        case (.custom, nil, nil):
            return #Predicate { $0.isCustom == true }
        case (.defaultOnly, nil, nil):
            return #Predicate { $0.isCustom == false }

        // Category only
        case (.all, nil, let cat?):
            return #Predicate { $0.category == cat }

        // Search only
        case (.all, let s?, nil):
            return #Predicate { ingredient in
                ingredient.name.localizedStandardContains(s) ||
                (ingredient.brand?.localizedStandardContains(s) ?? false)
            }

        // Filter + Category
        case (.favorites, nil, let cat?):
            return #Predicate { $0.isFavorite == true && $0.category == cat }
        case (.custom, nil, let cat?):
            return #Predicate { $0.isCustom == true && $0.category == cat }
        case (.defaultOnly, nil, let cat?):
            return #Predicate { $0.isCustom == false && $0.category == cat }

        // Filter + Search
        case (.favorites, let s?, nil):
            return #Predicate { ingredient in
                ingredient.isFavorite == true &&
                (ingredient.name.localizedStandardContains(s) ||
                 (ingredient.brand?.localizedStandardContains(s) ?? false))
            }
        case (.custom, let s?, nil):
            return #Predicate { ingredient in
                ingredient.isCustom == true &&
                (ingredient.name.localizedStandardContains(s) ||
                 (ingredient.brand?.localizedStandardContains(s) ?? false))
            }
        case (.defaultOnly, let s?, nil):
            return #Predicate { ingredient in
                ingredient.isCustom == false &&
                (ingredient.name.localizedStandardContains(s) ||
                 (ingredient.brand?.localizedStandardContains(s) ?? false))
            }

        // Category + Search
        case (.all, let s?, let cat?):
            return #Predicate { ingredient in
                ingredient.category == cat &&
                (ingredient.name.localizedStandardContains(s) ||
                 (ingredient.brand?.localizedStandardContains(s) ?? false))
            }

        // Filter + Category + Search
        case (.favorites, let s?, let cat?):
            return #Predicate { ingredient in
                ingredient.isFavorite == true &&
                ingredient.category == cat &&
                (ingredient.name.localizedStandardContains(s) ||
                 (ingredient.brand?.localizedStandardContains(s) ?? false))
            }
        case (.custom, let s?, let cat?):
            return #Predicate { ingredient in
                ingredient.isCustom == true &&
                ingredient.category == cat &&
                (ingredient.name.localizedStandardContains(s) ||
                 (ingredient.brand?.localizedStandardContains(s) ?? false))
            }
        case (.defaultOnly, let s?, let cat?):
            return #Predicate { ingredient in
                ingredient.isCustom == false &&
                ingredient.category == cat &&
                (ingredient.name.localizedStandardContains(s) ||
                 (ingredient.brand?.localizedStandardContains(s) ?? false))
            }

        default:
            return nil
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
                            .accessibilityLabel(ingredientAccessibilityLabel(ingredient))
                            .accessibilityHint("Double tap to convert this ingredient")
                            .accessibilityAction(named: Text(ingredient.isFavorite ? "Remove from favorites" : "Add to favorites")) {
                                toggleFavorite(ingredient)
                            }
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
                    .accessibilityLabel("Sort by \(sortOption == .alphabetical ? "last used" : "alphabetical")")
                    .accessibilityHint("Changes the sort order of ingredients")
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
                    .accessibilityLabel("Filter ingredients")
                    .accessibilityValue(filterOption.rawValue)
                    .accessibilityHint("Filter ingredients by all, favorites, custom, or default")
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
                    .accessibilityLabel("Filter by category")
                    .accessibilityValue(selectedCategory ?? "All Categories")
                    .accessibilityHint("Filter ingredients by category")
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
            .navigationDestination(isPresented: $showingAddIngredient) {
                IngredientEditorView(onDismiss: fetchIngredients)
            }
            .navigationDestination(item: $ingredientToEdit) { ingredient in
                IngredientEditorView(ingredient: ingredient, onDismiss: fetchIngredients)
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
                Text("This action cannot be undone. This ingredient has \((ingredient.conversions ?? []).count) conversion\((ingredient.conversions ?? []).count == 1 ? "" : "s").")
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

    private func ingredientAccessibilityLabel(_ ingredient: Ingredient) -> String {
        var parts: [String] = [ingredient.name]

        if let brand = ingredient.brand {
            parts.append("Brand: \(brand)")
        }

        if let category = ingredient.category {
            parts.append("Category: \(category)")
        }

        if ingredient.isCustom {
            parts.append("Custom ingredient")
        }

        if ingredient.isFavorite {
            parts.append("Favorite")
        }

        return parts.joined(separator: ", ")
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
            .accessibilityLabel(ingredient.isFavorite ? "Remove from favorites" : "Add to favorites")
            .accessibilityHint("Toggles favorite status for this ingredient")
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
