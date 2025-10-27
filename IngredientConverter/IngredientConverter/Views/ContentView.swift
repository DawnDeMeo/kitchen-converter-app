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

        // Update existing navigation bars with a more targeted approach
        updateExistingNavigationBars(with: appearance)
    }

    /// Update existing navigation bars without disrupting the entire view hierarchy
    private func updateExistingNavigationBars(with appearance: UINavigationBarAppearance) {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }

            for window in windowScene.windows {
                // Find and update navigation bars directly instead of recreating entire view hierarchy
                updateNavigationBarsInView(window, with: appearance)
            }
        }
    }

    /// Recursively find and update navigation bars in view hierarchy
    private func updateNavigationBarsInView(_ view: UIView, with appearance: UINavigationBarAppearance) {
        for subview in view.subviews {
            if let navigationBar = subview as? UINavigationBar {
                navigationBar.standardAppearance = appearance
                navigationBar.scrollEdgeAppearance = appearance
                navigationBar.compactAppearance = appearance
                navigationBar.setNeedsLayout()
            }
            // Continue recursively to find nested navigation bars
            updateNavigationBarsInView(subview, with: appearance)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Ingredient.self, inMemory: true)
}
