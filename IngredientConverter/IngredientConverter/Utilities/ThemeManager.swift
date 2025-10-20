//
//  ThemeManager.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/12/25.
//

import SwiftUI

// Environment key for the current color scheme
struct ColorSchemeKey: EnvironmentKey {
    static let defaultValue: AppColorScheme = .sage
}

extension EnvironmentValues {
    var appColorScheme: AppColorScheme {
        get { self[ColorSchemeKey.self] }
        set { self[ColorSchemeKey.self] = newValue }
    }
}

// Observable class to manage the current theme
@Observable
class ThemeManager {
    var currentScheme: AppColorScheme {
        didSet {
            // Save the scheme name to UserDefaults
            UserDefaults.standard.set(currentScheme.name, forKey: "selectedColorScheme")
        }
    }

    init() {
        // Load saved scheme or default to Lavender
        if let savedName = UserDefaults.standard.string(forKey: "selectedColorScheme"),
           let scheme = AppColorScheme.allSchemes.first(where: { $0.name == savedName }) {
            self.currentScheme = scheme
        } else {
            self.currentScheme = .lavender
        }
    }
}
