//
//  ContentView.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/5/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system
    @State private var themeManager = ThemeManager()

    var body: some View {
        IngredientListView()
            .environment(themeManager)
            .environment(\.appColorScheme, themeManager.currentScheme)
            .preferredColorScheme(appearanceMode.colorScheme)
            .tint(themeManager.currentScheme.primary) // Set app-wide accent color
            .onAppear {
                configureNavigationBarAppearance()
            }
            .onChange(of: themeManager.currentScheme) { _, _ in
                configureNavigationBarAppearance()
            }
    }

    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()

        // Set title colors to theme primary color
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(themeManager.currentScheme.primary)]
        appearance.titleTextAttributes = [.foregroundColor: UIColor(themeManager.currentScheme.primary)]

        // Update the global appearance proxy (for future navigation bars)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance

        // Force update all existing navigation bars immediately
        for scene in UIApplication.shared.connectedScenes {
            if let windowScene = scene as? UIWindowScene {
                for window in windowScene.windows {
                    for view in window.subviews {
                        view.removeFromSuperview()
                        window.addSubview(view)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Ingredient.self, inMemory: true)
}
