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
            .id(appearanceMode) // Force view recreation when appearance mode changes
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

        // Update the global appearance proxy - this handles future navigation bars
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance

        // Update existing navigation bars that are already on screen
        updateExistingNavigationBars(with: appearance)
    }

    /// Update navigation bars that are already instantiated
    private func updateExistingNavigationBars(with appearance: UINavigationBarAppearance) {
        // Find all windows in all scenes and update their navigation bars
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }

            for window in windowScene.windows where window.isKeyWindow {
                updateNavigationBars(in: window, with: appearance)
            }
        }
    }

    /// Recursively find and update navigation bars
    private func updateNavigationBars(in view: UIView, with appearance: UINavigationBarAppearance) {
        if let navigationBar = view as? UINavigationBar {
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
        }

        // Check subviews
        for subview in view.subviews {
            updateNavigationBars(in: subview, with: appearance)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Ingredient.self, inMemory: true)
}
