//
//  AppColorScheme.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/12/25.
//

import SwiftUI

struct AppColorScheme: Identifiable {
    let id = UUID()
    let name: String

    // Core colors
    let primary: Color
    let secondary: Color
    let accent: Color

    // Background colors
    let background: Color
    let secondaryBackground: Color
    let groupedBackground: Color

    // Text colors
    let primaryText: Color
    let secondaryText: Color

    // Semantic colors
    let success: Color
    let warning: Color
    let error: Color

    // UI Element colors
    let cardBackground: Color
    let divider: Color
    let shadow: Color
}

// MARK: - Preset Color Schemes

extension AppColorScheme {

    // System default with slight customization
    static let classic = AppColorScheme(
        name: "Classic",
        primary: Color.blue,
        secondary: Color(red: 0.4, green: 0.6, blue: 0.9),
        accent: Color.orange,
        background: Color(uiColor: .systemBackground),
        secondaryBackground: Color(uiColor: .secondarySystemBackground),
        groupedBackground: Color(uiColor: .systemGroupedBackground),
        primaryText: Color(uiColor: .label),
        secondaryText: Color(uiColor: .secondaryLabel),
        success: Color.green,
        warning: Color.orange,
        error: Color.red,
        cardBackground: Color(uiColor: .secondarySystemGroupedBackground),
        divider: Color(uiColor: .separator),
        shadow: Color.black.opacity(0.1)
    )

    // Ocean-inspired blues and teals
    static let ocean = AppColorScheme(
        name: "Ocean",
        primary: Color(red: 0.0, green: 0.48, blue: 0.73), // Ocean blue
        secondary: Color(red: 0.0, green: 0.65, blue: 0.85), // Lighter blue
        accent: Color(red: 0.0, green: 0.77, blue: 0.71), // Teal
        background: Color(red: 0.97, green: 0.99, blue: 1.0),
        secondaryBackground: Color(red: 0.93, green: 0.96, blue: 0.98),
        groupedBackground: Color(red: 0.95, green: 0.98, blue: 0.99),
        primaryText: Color(red: 0.1, green: 0.2, blue: 0.3),
        secondaryText: Color(red: 0.3, green: 0.4, blue: 0.5),
        success: Color(red: 0.0, green: 0.7, blue: 0.6),
        warning: Color(red: 1.0, green: 0.7, blue: 0.0),
        error: Color(red: 0.9, green: 0.2, blue: 0.3),
        cardBackground: Color.white,
        divider: Color(red: 0.8, green: 0.9, blue: 0.95),
        shadow: Color(red: 0.0, green: 0.48, blue: 0.73).opacity(0.15)
    )

    // Warm sunset colors
    static let sunset = AppColorScheme(
        name: "Sunset",
        primary: Color(red: 0.95, green: 0.45, blue: 0.3), // Coral
        secondary: Color(red: 1.0, green: 0.6, blue: 0.4), // Peach
        accent: Color(red: 0.95, green: 0.7, blue: 0.2), // Golden
        background: Color(red: 1.0, green: 0.98, blue: 0.95),
        secondaryBackground: Color(red: 0.98, green: 0.95, blue: 0.92),
        groupedBackground: Color(red: 0.99, green: 0.97, blue: 0.94),
        primaryText: Color(red: 0.25, green: 0.15, blue: 0.1),
        secondaryText: Color(red: 0.5, green: 0.35, blue: 0.25),
        success: Color(red: 0.4, green: 0.75, blue: 0.4),
        warning: Color(red: 0.95, green: 0.7, blue: 0.2),
        error: Color(red: 0.9, green: 0.3, blue: 0.25),
        cardBackground: Color(red: 1.0, green: 0.99, blue: 0.97),
        divider: Color(red: 0.95, green: 0.85, blue: 0.75),
        shadow: Color(red: 0.95, green: 0.45, blue: 0.3).opacity(0.2)
    )

    // Forest greens and earthy tones
    static let forest = AppColorScheme(
        name: "Forest",
        primary: Color(red: 0.2, green: 0.55, blue: 0.35), // Forest green
        secondary: Color(red: 0.35, green: 0.65, blue: 0.45), // Lighter green
        accent: Color(red: 0.7, green: 0.55, blue: 0.3), // Brown/amber
        background: Color(red: 0.97, green: 0.98, blue: 0.96),
        secondaryBackground: Color(red: 0.94, green: 0.96, blue: 0.93),
        groupedBackground: Color(red: 0.96, green: 0.97, blue: 0.95),
        primaryText: Color(red: 0.15, green: 0.2, blue: 0.15),
        secondaryText: Color(red: 0.35, green: 0.4, blue: 0.35),
        success: Color(red: 0.3, green: 0.7, blue: 0.4),
        warning: Color(red: 0.85, green: 0.65, blue: 0.2),
        error: Color(red: 0.8, green: 0.3, blue: 0.25),
        cardBackground: Color(red: 0.99, green: 1.0, blue: 0.98),
        divider: Color(red: 0.8, green: 0.85, blue: 0.78),
        shadow: Color(red: 0.2, green: 0.55, blue: 0.35).opacity(0.15)
    )

    // Lavender and purple tones
    static let lavender = AppColorScheme(
        name: "Lavender",
        primary: Color(red: 0.55, green: 0.45, blue: 0.8), // Purple
        secondary: Color(red: 0.7, green: 0.6, blue: 0.9), // Light purple
        accent: Color(red: 0.85, green: 0.55, blue: 0.75), // Pink-purple
        background: Color(red: 0.98, green: 0.97, blue: 1.0),
        secondaryBackground: Color(red: 0.95, green: 0.94, blue: 0.98),
        groupedBackground: Color(red: 0.97, green: 0.96, blue: 0.99),
        primaryText: Color(red: 0.2, green: 0.15, blue: 0.3),
        secondaryText: Color(red: 0.4, green: 0.35, blue: 0.5),
        success: Color(red: 0.45, green: 0.7, blue: 0.55),
        warning: Color(red: 0.95, green: 0.65, blue: 0.3),
        error: Color(red: 0.85, green: 0.3, blue: 0.4),
        cardBackground: Color(red: 1.0, green: 0.99, blue: 1.0),
        divider: Color(red: 0.85, green: 0.8, blue: 0.9),
        shadow: Color(red: 0.55, green: 0.45, blue: 0.8).opacity(0.2)
    )

    // Monochrome with subtle warmth
    static let minimal = AppColorScheme(
        name: "Minimal",
        primary: Color(red: 0.2, green: 0.2, blue: 0.2), // Dark gray
        secondary: Color(red: 0.4, green: 0.4, blue: 0.4), // Medium gray
        accent: Color(red: 0.1, green: 0.1, blue: 0.1), // Almost black
        background: Color(red: 1.0, green: 1.0, blue: 1.0),
        secondaryBackground: Color(red: 0.97, green: 0.97, blue: 0.97),
        groupedBackground: Color(red: 0.98, green: 0.98, blue: 0.98),
        primaryText: Color(red: 0.1, green: 0.1, blue: 0.1),
        secondaryText: Color(red: 0.5, green: 0.5, blue: 0.5),
        success: Color(red: 0.3, green: 0.3, blue: 0.3),
        warning: Color(red: 0.4, green: 0.4, blue: 0.4),
        error: Color(red: 0.2, green: 0.2, blue: 0.2),
        cardBackground: Color(red: 0.99, green: 0.99, blue: 0.99),
        divider: Color(red: 0.9, green: 0.9, blue: 0.9),
        shadow: Color.black.opacity(0.05)
    )

    static let allSchemes: [AppColorScheme] = [
        .classic, .ocean, .sunset, .forest, .lavender, .minimal
    ]
}
