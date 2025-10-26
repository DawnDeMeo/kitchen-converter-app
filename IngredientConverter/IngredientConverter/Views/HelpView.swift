//
//  HelpView.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/26/25.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.appColorScheme) private var colorScheme
    @State private var expandedSections: Set<String> = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Help & FAQ")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme.primaryText)

                    Text("Everything you need to know about using Ingredient Converter")
                        .font(.subheadline)
                        .foregroundColor(colorScheme.secondaryText)
                }
                .padding(.horizontal)
                .padding(.top)

                // Getting Started
                HelpSection(
                    title: "Getting Started",
                    icon: "star.fill",
                    iconColor: colorScheme.accent,
                    isExpanded: expandedSections.contains("getting-started")
                ) {
                    expandedSections.toggle("getting-started")
                } content: {
                    VStack(alignment: .leading, spacing: 12) {
                        HelpItem(
                            question: "What does this app do?",
                            answer: "Ingredient Converter helps you convert cooking ingredient measurements between volume (cups, tablespoons), weight (grams, ounces), and count (eggs, crackers). Unlike standard converters, it accounts for the fact that different ingredients have different densities."
                        )

                        HelpItem(
                            question: "How do I convert an ingredient?",
                            answer: "1. Tap the Conversions tab\n2. Search for or select an ingredient\n3. Enter an amount using the keypad\n4. Tap a 'From' unit (e.g., cups)\n5. Tap a 'To' unit (e.g., grams)\n6. The result appears instantly!"
                        )
                    }
                }

                // Ingredients
                HelpSection(
                    title: "Working with Ingredients",
                    icon: "list.bullet",
                    iconColor: colorScheme.primary,
                    isExpanded: expandedSections.contains("ingredients")
                ) {
                    expandedSections.toggle("ingredients")
                } content: {
                    VStack(alignment: .leading, spacing: 12) {
                        HelpItem(
                            question: "What's the difference between default and custom ingredients?",
                            answer: "Default ingredients come pre-loaded with the app and include verified conversions from trusted sources. Custom ingredients are ones you add yourself. Both appear in your ingredient list, and you can have custom versions of default ingredients."
                        )

                        HelpItem(
                            question: "How do I add a custom ingredient?",
                            answer: "1. Go to the Ingredients tab\n2. Tap the + button\n3. Enter the ingredient name and optional brand\n4. Add at least one conversion (e.g., 1 cup = 120 grams)\n5. Tap Save"
                        )

                        HelpItem(
                            question: "Can I favorite ingredients?",
                            answer: "Yes! Tap the star icon next to any ingredient to favorite it. Filter by favorites using the filter button at the top of the ingredient list."
                        )

                        HelpItem(
                            question: "What are categories?",
                            answer: "Categories help organize ingredients (e.g., Flour, Sugar, Dairy). Default ingredients come with categories. When adding custom ingredients, you can choose from existing categories or the category will default to 'Other'."
                        )
                    }
                }

                // Conversions
                HelpSection(
                    title: "Understanding Conversions",
                    icon: "arrow.left.arrow.right",
                    iconColor: colorScheme.accent,
                    isExpanded: expandedSections.contains("conversions")
                ) {
                    expandedSections.toggle("conversions")
                } content: {
                    VStack(alignment: .leading, spacing: 12) {
                        HelpItem(
                            question: "Can I convert between the same unit types?",
                            answer: "Yes! Volume-to-volume (cups ↔ tablespoons) and weight-to-weight (grams ↔ ounces) conversions use standard measurements that are the same for all ingredients. For example, 1 cup always equals 16 tablespoons, regardless of the ingredient."
                        )

                        HelpItem(
                            question: "What are count units?",
                            answer: "Count units represent whole items like 'eggs', 'crackers', or 'cloves'. These are ingredient-specific. For example, you can convert 2 eggs to grams, or 8 crackers to cups."
                        )

                        HelpItem(
                            question: "Can conversions work in reverse?",
                            answer: "Yes! If an ingredient has '1 cup = 120 grams', you can also convert from grams to cups. The app automatically reverses conversions."
                        )

                        HelpItem(
                            question: "What are chained conversions?",
                            answer: "If you have '1 cup = 200g' and '16 tbsp = 1 cup', the app can automatically convert tablespoons to grams by chaining through cups. This works for complex conversion paths!"
                        )
                    }
                }

                // Import & Export
                HelpSection(
                    title: "Import & Export",
                    icon: "arrow.up.arrow.down.circle.fill",
                    iconColor: colorScheme.primary,
                    isExpanded: expandedSections.contains("import-export")
                ) {
                    expandedSections.toggle("import-export")
                } content: {
                    VStack(alignment: .leading, spacing: 12) {
                        HelpItem(
                            question: "How do I back up my custom ingredients?",
                            answer: "Go to Settings → Data Management → Export Custom Ingredients. This creates a JSON file you can save to Files, email, or share."
                        )

                        HelpItem(
                            question: "How do I import ingredients?",
                            answer: "Go to Settings → Data Management → Import Custom Ingredients. Select a previously exported JSON file. Only custom ingredients will be imported, and duplicates are skipped."
                        )

                        HelpItem(
                            question: "Will importing overwrite my existing ingredients?",
                            answer: "No! Import only adds new custom ingredients. If you already have a custom ingredient with the same name, it will be skipped to protect your data."
                        )
                    }
                }

                // iCloud Sync
                HelpSection(
                    title: "iCloud Sync",
                    icon: "icloud.fill",
                    iconColor: .blue,
                    isExpanded: expandedSections.contains("icloud")
                ) {
                    expandedSections.toggle("icloud")
                } content: {
                    VStack(alignment: .leading, spacing: 12) {
                        HelpItem(
                            question: "Does my data sync across devices?",
                            answer: "Yes! If you're signed into iCloud, your custom ingredients, favorites, and preferences automatically sync across all your devices using the same Apple ID."
                        )

                        HelpItem(
                            question: "What if iCloud sync is unavailable?",
                            answer: "Check Settings to see your iCloud status. Make sure you're signed into iCloud and have granted the app permission. Data is still saved locally even without iCloud."
                        )

                        HelpItem(
                            question: "Can I use the app without iCloud?",
                            answer: "Absolutely! The app works perfectly without iCloud. Your data is saved locally on your device. You can use import/export to transfer data between devices manually."
                        )
                    }
                }

                // Fractions & Input
                HelpSection(
                    title: "Entering Amounts",
                    icon: "textformat.123",
                    iconColor: colorScheme.accent,
                    isExpanded: expandedSections.contains("input")
                ) {
                    expandedSections.toggle("input")
                } content: {
                    VStack(alignment: .leading, spacing: 12) {
                        HelpItem(
                            question: "How do I enter fractions?",
                            answer: "Use the custom keypad! It includes common fractions (½, ⅓, ¼, etc.) and a fraction button to create any fraction. For example: tap '1', tap '½' to get 1½ cups."
                        )

                        HelpItem(
                            question: "Can I use decimals?",
                            answer: "Yes! Tap the decimal point button to enter amounts like 2.5 or 0.75. Both fractions and decimals work."
                        )

                        HelpItem(
                            question: "What's the maximum amount I can enter?",
                            answer: "The app supports very large amounts for batch cooking or commercial use. There's no practical limit."
                        )
                    }
                }

                // Settings
                HelpSection(
                    title: "Settings & Preferences",
                    icon: "gear",
                    iconColor: colorScheme.primary,
                    isExpanded: expandedSections.contains("settings")
                ) {
                    expandedSections.toggle("settings")
                } content: {
                    VStack(alignment: .leading, spacing: 12) {
                        HelpItem(
                            question: "Can I change default units?",
                            answer: "Yes! Go to Settings → Default Conversion Units to set your preferred 'From' and 'To' units. These will be pre-selected when you open the Conversions tab."
                        )

                        HelpItem(
                            question: "How do I change the app theme?",
                            answer: "Go to Settings → Appearance → Color Scheme. Choose from Sage (green), Lavender (purple), or one of the other available color schemes."
                        )

                        HelpItem(
                            question: "Is there a dark mode?",
                            answer: "Yes! Each color scheme has both light and dark variants. Set Color Scheme to 'System' to follow your device settings, or choose a specific scheme."
                        )
                    }
                }

                // Troubleshooting
                HelpSection(
                    title: "Troubleshooting",
                    icon: "wrench.and.screwdriver.fill",
                    iconColor: .orange,
                    isExpanded: expandedSections.contains("troubleshooting")
                ) {
                    expandedSections.toggle("troubleshooting")
                } content: {
                    VStack(alignment: .leading, spacing: 12) {
                        HelpItem(
                            question: "A conversion returns nil or doesn't work. Why?",
                            answer: "If a conversion returns no result, the ingredient may not have the necessary conversion data. For example, to convert cups to grams, the ingredient needs a volume-to-weight conversion defined. Volume-to-volume and weight-to-weight conversions always work using standard measurements."
                        )

                        HelpItem(
                            question: "I see duplicate ingredients. What happened?",
                            answer: "This can happen if multiple devices loaded the default database before syncing. Don't worry - duplicates are automatically removed. If you still see them, try force-quitting and reopening the app."
                        )

                        HelpItem(
                            question: "Can I delete default ingredients?",
                            answer: "No, default ingredients can't be deleted. They're maintained and updated by the app. However, you can hide them by filtering for 'Custom Only' in the ingredient list."
                        )

                        HelpItem(
                            question: "How do I delete a custom ingredient?",
                            answer: "Go to Ingredients tab, swipe left on the custom ingredient, and tap Delete. Or tap Edit, select ingredients, and tap the Delete button."
                        )
                    }
                }

                // About
                HelpSection(
                    title: "About",
                    icon: "info.circle.fill",
                    iconColor: .blue,
                    isExpanded: expandedSections.contains("about")
                ) {
                    expandedSections.toggle("about")
                } content: {
                    VStack(alignment: .leading, spacing: 12) {
                        HelpItem(
                            question: "Where do the conversions come from?",
                            answer: "Default ingredient conversions are sourced from King Arthur Baking's ingredient weight chart and USDA FoodData Central. These are professional, verified measurements used by bakers and food scientists."
                        )

                        HelpItem(
                            question: "How often is the ingredient database updated?",
                            answer: "The default database is updated periodically with new ingredients and improved conversions. Updates happen automatically when you update the app."
                        )

                        HelpItem(
                            question: "Is my data private?",
                            answer: "Yes! All your data (custom ingredients, favorites, etc.) stays on your devices. If you enable iCloud sync, data is stored in your personal iCloud account. We don't collect or have access to your data."
                        )
                    }
                }

                // Footer
                VStack(spacing: 8) {
                    Text("Still have questions?")
                        .font(.subheadline)
                        .foregroundColor(colorScheme.secondaryText)

                    Link(destination: URL(string: "mailto:dawndemeoapps@gmail.com?subject=Ingredient%20Converter%20Support")!) {
                        HStack(spacing: 4) {
                            Image(systemName: "envelope.fill")
                                .font(.caption)
                            Text("Contact Support")
                                .font(.caption)
                        }
                        .foregroundColor(colorScheme.accent)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .background(colorScheme.background)
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Help Section Component

struct HelpSection<Content: View>: View {
    @Environment(\.appColorScheme) private var colorScheme

    let title: String
    let icon: String
    let iconColor: Color
    let isExpanded: Bool
    let onToggle: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onToggle) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .frame(width: 24)

                    Text(title)
                        .font(.headline)
                        .foregroundColor(colorScheme.primaryText)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(colorScheme.secondaryText)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding()
                .background(colorScheme.cardBackground)
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())

            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    content
                }
                .padding()
                .background(colorScheme.cardBackground.opacity(0.5))
                .cornerRadius(12)
                .padding(.top, 4)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Help Item Component

struct HelpItem: View {
    @Environment(\.appColorScheme) private var colorScheme

    let question: String
    let answer: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(question)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(colorScheme.primaryText)

            Text(answer)
                .font(.subheadline)
                .foregroundColor(colorScheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Set Extension for Toggle

extension Set {
    mutating func toggle(_ element: Element) {
        if contains(element) {
            remove(element)
        } else {
            insert(element)
        }
    }
}

#Preview {
    NavigationStack {
        HelpView()
    }
}
