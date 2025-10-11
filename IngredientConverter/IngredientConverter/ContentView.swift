//
//  ContentView.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/5/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        IngredientListView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Ingredient.self, inMemory: true)
}
