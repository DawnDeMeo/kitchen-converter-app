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
        TabView {
            ConversionView()
                .tabItem {
                    Label("Convert", systemImage: "arrow.left.arrow.right")
                }
            
            IngredientListView()
                .tabItem {
                    Label("Ingredients", systemImage: "list.bullet")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Ingredient.self, inMemory: true)
}
