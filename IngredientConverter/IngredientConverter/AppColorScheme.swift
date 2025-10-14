//
//  AppColorScheme.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/12/25.
//

import SwiftUI

struct AppColorScheme: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String

    // Equatable conformance - compare by name
    static func == (lhs: AppColorScheme, rhs: AppColorScheme) -> Bool {
        lhs.name == rhs.name
    }

    // Hashable conformance - hash by name
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    // Core colors (adaptive)
    var primary: Color
    var secondary: Color
    var accent: Color

    // Background colors (adaptive)
    var background: Color
    var secondaryBackground: Color
    var groupedBackground: Color

    // Text colors (adaptive)
    var primaryText: Color
    var secondaryText: Color
    var buttonText: Color

    // Semantic colors (adaptive)
    var success: Color
    var warning: Color
    var error: Color

    // UI Element colors (adaptive)
    var cardBackground: Color
    var divider: Color
    var shadow: Color

    // Helper to create adaptive colors
    static func adaptiveColor(light: Color, dark: Color) -> Color {
        Color(uiColor: UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}

// MARK: - Preset Color Schemes

extension AppColorScheme {

    // Ocean-inspired blues and teals
    static let blueCrab = AppColorScheme(
        name: "Blue Crab",
        primary: adaptiveColor(
            light: Color(red: 0.0, green: 0.48, blue: 0.73),
            dark: Color(red: 0.2, green: 0.6, blue: 0.85)
        ),
        secondary: adaptiveColor(
            light: Color(red: 0.0, green: 0.65, blue: 0.85),
            dark: Color(red: 0.3, green: 0.75, blue: 0.95)
        ),
        accent: adaptiveColor(
            light: Color(red: 0.0, green: 0.77, blue: 0.71),
            dark: Color(red: 0.2, green: 0.87, blue: 0.81)
        ),
        background: adaptiveColor(
            light: Color(red: 0.97, green: 0.99, blue: 1.0),
            dark: Color(red: 0.05, green: 0.08, blue: 0.12)
        ),
        secondaryBackground: adaptiveColor(
            light: Color(red: 0.93, green: 0.96, blue: 0.98),
            dark: Color(red: 0.08, green: 0.12, blue: 0.16)
        ),
        groupedBackground: adaptiveColor(
            light: Color(red: 0.95, green: 0.98, blue: 0.99),
            dark: Color(red: 0.06, green: 0.1, blue: 0.14)
        ),
        primaryText: adaptiveColor(
            light: Color(red: 0.1, green: 0.2, blue: 0.3),
            dark: Color(red: 0.9, green: 0.95, blue: 1.0)
        ),
        secondaryText: adaptiveColor(
            light: Color(red: 0.3, green: 0.4, blue: 0.5),
            dark: Color(red: 0.6, green: 0.7, blue: 0.8)
        ),
        buttonText: Color.white,
        success: adaptiveColor(
            light: Color(red: 0.0, green: 0.7, blue: 0.6),
            dark: Color(red: 0.2, green: 0.8, blue: 0.7)
        ),
        warning: adaptiveColor(
            light: Color(red: 1.0, green: 0.7, blue: 0.0),
            dark: Color(red: 1.0, green: 0.8, blue: 0.2)
        ),
        error: adaptiveColor(
            light: Color(red: 0.9, green: 0.2, blue: 0.3),
            dark: Color(red: 1.0, green: 0.4, blue: 0.4)
        ),
        cardBackground: adaptiveColor(
            light: Color.white,
            dark: Color(red: 0.1, green: 0.15, blue: 0.2)
        ),
        divider: adaptiveColor(
            light: Color(red: 0.8, green: 0.9, blue: 0.95),
            dark: Color(red: 0.15, green: 0.2, blue: 0.25)
        ),
        shadow: adaptiveColor(
            light: Color(red: 0.0, green: 0.48, blue: 0.73).opacity(0.15),
            dark: Color.black.opacity(0.4)
        )
    )

    // Warm sunset colors
    static let cayenne = AppColorScheme(
        name: "Cayenne",
        primary: adaptiveColor(
            light: Color(red: 0.95, green: 0.45, blue: 0.3),
            dark: Color(red: 1.0, green: 0.6, blue: 0.45)
        ),
        secondary: adaptiveColor(
            light: Color(red: 1.0, green: 0.6, blue: 0.4),
            dark: Color(red: 1.0, green: 0.7, blue: 0.5)
        ),
        accent: adaptiveColor(
            light: Color(red: 0.95, green: 0.7, blue: 0.2),
            dark: Color(red: 1.0, green: 0.8, blue: 0.3)
        ),
        background: adaptiveColor(
            light: Color(red: 1.0, green: 0.98, blue: 0.95),
            dark: Color(red: 0.12, green: 0.08, blue: 0.05)
        ),
        secondaryBackground: adaptiveColor(
            light: Color(red: 0.98, green: 0.95, blue: 0.92),
            dark: Color(red: 0.16, green: 0.12, blue: 0.08)
        ),
        groupedBackground: adaptiveColor(
            light: Color(red: 0.99, green: 0.97, blue: 0.94),
            dark: Color(red: 0.14, green: 0.1, blue: 0.06)
        ),
        primaryText: adaptiveColor(
            light: Color(red: 0.25, green: 0.15, blue: 0.1),
            dark: Color(red: 1.0, green: 0.95, blue: 0.9)
        ),
        secondaryText: adaptiveColor(
            light: Color(red: 0.5, green: 0.35, blue: 0.25),
            dark: Color(red: 0.8, green: 0.7, blue: 0.6)
        ),
        buttonText: Color.white,
        success: adaptiveColor(
            light: Color(red: 0.4, green: 0.75, blue: 0.4),
            dark: Color(red: 0.5, green: 0.85, blue: 0.5)
        ),
        warning: adaptiveColor(
            light: Color(red: 0.95, green: 0.7, blue: 0.2),
            dark: Color(red: 1.0, green: 0.8, blue: 0.3)
        ),
        error: adaptiveColor(
            light: Color(red: 0.9, green: 0.3, blue: 0.25),
            dark: Color(red: 1.0, green: 0.5, blue: 0.4)
        ),
        cardBackground: adaptiveColor(
            light: Color(red: 1.0, green: 0.99, blue: 0.97),
            dark: Color(red: 0.18, green: 0.14, blue: 0.1)
        ),
        divider: adaptiveColor(
            light: Color(red: 0.95, green: 0.85, blue: 0.75),
            dark: Color(red: 0.25, green: 0.18, blue: 0.12)
        ),
        shadow: adaptiveColor(
            light: Color(red: 0.95, green: 0.45, blue: 0.3).opacity(0.2),
            dark: Color.black.opacity(0.4)
        )
    )

    // Lavender and purple tones
    static let lavender = AppColorScheme(
        name: "Lavender",
        primary: adaptiveColor(
            light: Color(red: 0.55, green: 0.45, blue: 0.8),
            dark: Color(red: 0.7, green: 0.6, blue: 0.95)
        ),
        secondary: adaptiveColor(
            light: Color(red: 0.7, green: 0.6, blue: 0.9),
            dark: Color(red: 0.8, green: 0.7, blue: 1.0)
        ),
        accent: adaptiveColor(
            light: Color(red: 0.85, green: 0.55, blue: 0.75),
            dark: Color(red: 0.95, green: 0.65, blue: 0.85)
        ),
        background: adaptiveColor(
            light: Color(red: 0.98, green: 0.97, blue: 1.0),
            dark: Color(red: 0.08, green: 0.06, blue: 0.12)
        ),
        secondaryBackground: adaptiveColor(
            light: Color(red: 0.95, green: 0.94, blue: 0.98),
            dark: Color(red: 0.12, green: 0.1, blue: 0.16)
        ),
        groupedBackground: adaptiveColor(
            light: Color(red: 0.97, green: 0.96, blue: 0.99),
            dark: Color(red: 0.1, green: 0.08, blue: 0.14)
        ),
        primaryText: adaptiveColor(
            light: Color(red: 0.2, green: 0.15, blue: 0.3),
            dark: Color(red: 0.95, green: 0.9, blue: 1.0)
        ),
        secondaryText: adaptiveColor(
            light: Color(red: 0.4, green: 0.35, blue: 0.5),
            dark: Color(red: 0.7, green: 0.6, blue: 0.8)
        ),
        buttonText: Color.white,
        success: adaptiveColor(
            light: Color(red: 0.45, green: 0.7, blue: 0.55),
            dark: Color(red: 0.55, green: 0.8, blue: 0.65)
        ),
        warning: adaptiveColor(
            light: Color(red: 0.95, green: 0.65, blue: 0.3),
            dark: Color(red: 1.0, green: 0.75, blue: 0.4)
        ),
        error: adaptiveColor(
            light: Color(red: 0.85, green: 0.3, blue: 0.4),
            dark: Color(red: 0.95, green: 0.5, blue: 0.55)
        ),
        cardBackground: adaptiveColor(
            light: Color(red: 1.0, green: 0.99, blue: 1.0),
            dark: Color(red: 0.14, green: 0.12, blue: 0.18)
        ),
        divider: adaptiveColor(
            light: Color(red: 0.85, green: 0.8, blue: 0.9),
            dark: Color(red: 0.2, green: 0.16, blue: 0.25)
        ),
        shadow: adaptiveColor(
            light: Color(red: 0.55, green: 0.45, blue: 0.8).opacity(0.2),
            dark: Color.black.opacity(0.4)
        )
    )

    // Monochrome with subtle warmth
    static let saltandpepper = AppColorScheme(
        name: "Salt & Pepper",
        primary: adaptiveColor(
            light: Color(red: 0.2, green: 0.2, blue: 0.2),
            dark: Color(red: 0.85, green: 0.85, blue: 0.85) // Light gray with white text
        ),
        secondary: adaptiveColor(
            light: Color(red: 0.4, green: 0.4, blue: 0.4),
            dark: Color(red: 0.6, green: 0.6, blue: 0.6) // Medium gray
        ),
        accent: adaptiveColor(
            light: Color(red: 0.1, green: 0.1, blue: 0.1),
            dark: Color(red: 0.75, green: 0.75, blue: 0.75) // Medium-light gray
        ),
        background: adaptiveColor(
            light: Color(red: 1.0, green: 1.0, blue: 1.0),
            dark: Color(red: 0.05, green: 0.05, blue: 0.05) // Slightly lighter than pure black
        ),
        secondaryBackground: adaptiveColor(
            light: Color(red: 0.97, green: 0.97, blue: 0.97),
            dark: Color(red: 0.12, green: 0.12, blue: 0.12) // More contrast
        ),
        groupedBackground: adaptiveColor(
            light: Color(red: 0.98, green: 0.98, blue: 0.98),
            dark: Color(red: 0.08, green: 0.08, blue: 0.08)
        ),
        primaryText: adaptiveColor(
            light: Color(red: 0.1, green: 0.1, blue: 0.1),
            dark: Color(red: 1.0, green: 1.0, blue: 1.0) // Pure white text
        ),
        secondaryText: adaptiveColor(
            light: Color(red: 0.5, green: 0.5, blue: 0.5),
            dark: Color(red: 0.7, green: 0.7, blue: 0.7) // Lighter for readability
        ),
        buttonText: adaptiveColor(
            light: Color.white,
            dark: Color(red: 0.05, green: 0.05, blue: 0.05) // Almost black for high contrast on light buttons
        ),
        success: adaptiveColor(
            light: Color(red: 0.3, green: 0.3, blue: 0.3),
            dark: Color(red: 0.7, green: 0.7, blue: 0.7)
        ),
        warning: adaptiveColor(
            light: Color(red: 0.4, green: 0.4, blue: 0.4),
            dark: Color(red: 0.65, green: 0.65, blue: 0.65)
        ),
        error: adaptiveColor(
            light: Color(red: 0.2, green: 0.2, blue: 0.2),
            dark: Color(red: 0.55, green: 0.55, blue: 0.55) // Darker so white text is readable
        ),
        cardBackground: adaptiveColor(
            light: Color(red: 0.99, green: 0.99, blue: 0.99),
            dark: Color(red: 0.15, green: 0.15, blue: 0.15) // More contrast
        ),
        divider: adaptiveColor(
            light: Color(red: 0.9, green: 0.9, blue: 0.9),
            dark: Color(red: 0.25, green: 0.25, blue: 0.25) // More visible
        ),
        shadow: adaptiveColor(
            light: Color.black.opacity(0.05),
            dark: Color.black.opacity(0.6)
        )
    )

    // Sage - earthy greens with warm accents
    static let sage = AppColorScheme(
        name: "Sage",
        primary: adaptiveColor(
            light: Color(red: 0.439, green: 0.541, blue: 0.384), // #708A62
            dark: Color(red: 0.55, green: 0.65, blue: 0.50) // Brighter for dark mode
        ),
        secondary: adaptiveColor(
            light: Color(red: 0.502, green: 0.608, blue: 0.4), // #809B66
            dark: Color(red: 0.6, green: 0.7, blue: 0.5)
        ),
        accent: adaptiveColor(
            light: Color(red: 0.784, green: 0.569, blue: 0.392), // #C89164
            dark: Color(red: 0.85, green: 0.65, blue: 0.48)
        ),
        background: adaptiveColor(
            light: Color(red: 0.98, green: 0.98, blue: 0.96),
            dark: Color(red: 0.08, green: 0.09, blue: 0.08)
        ),
        secondaryBackground: adaptiveColor(
            light: Color(red: 0.95, green: 0.96, blue: 0.94),
            dark: Color(red: 0.12, green: 0.13, blue: 0.11)
        ),
        groupedBackground: adaptiveColor(
            light: Color(red: 0.97, green: 0.97, blue: 0.95),
            dark: Color(red: 0.1, green: 0.11, blue: 0.09)
        ),
        primaryText: adaptiveColor(
            light: Color(red: 0.2, green: 0.25, blue: 0.18),
            dark: Color(red: 0.92, green: 0.95, blue: 0.9)
        ),
        secondaryText: adaptiveColor(
            light: Color(red: 0.45, green: 0.5, blue: 0.4),
            dark: Color(red: 0.65, green: 0.7, blue: 0.6)
        ),
        buttonText: adaptiveColor(
            light: Color.white,
            dark: Color.white
        ),
        success: adaptiveColor(
            light: Color(red: 0.596, green: 0.678, blue: 0.529), // #98AD87
            dark: Color(red: 0.68, green: 0.75, blue: 0.62)
        ),
        warning: adaptiveColor(
            light: Color(red: 0.788, green: 0.675, blue: 0.608), // #C9AC9B
            dark: Color(red: 0.85, green: 0.75, blue: 0.68)
        ),
        error: adaptiveColor(
            light: Color(red: 0.737, green: 0.404, blue: 0.498), // #BC677F
            dark: Color(red: 0.85, green: 0.52, blue: 0.62)
        ),
        cardBackground: adaptiveColor(
            light: Color(red: 0.99, green: 1.0, blue: 0.98),
            dark: Color(red: 0.14, green: 0.15, blue: 0.13)
        ),
        divider: adaptiveColor(
            light: Color(red: 0.82, green: 0.86, blue: 0.8),
            dark: Color(red: 0.22, green: 0.24, blue: 0.2)
        ),
        shadow: adaptiveColor(
            light: Color(red: 0.439, green: 0.541, blue: 0.384).opacity(0.15),
            dark: Color.black.opacity(0.4)
        )
    )

    static let allSchemes: [AppColorScheme] = [
        .blueCrab, .cayenne, .lavender, .sage, .saltandpepper
    ]
}
