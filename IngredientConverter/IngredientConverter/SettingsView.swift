//
//  SettingsView.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/12/25.
//

import SwiftUI
import SwiftData

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system

    @State private var showingResetConfirmation = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Appearance")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Picker("Appearance", selection: $appearanceMode) {
                            ForEach(AppearanceMode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                } header: {
                    Text("Display")
                } footer: {
                    Text("System will follow your device settings.")
                }

                Section {
                    Button(role: .destructive) {
                        showingResetConfirmation = true
                    } label: {
                        HStack {
                            Label("Reset to Default Ingredients", systemImage: "arrow.counterclockwise")
                            Spacer()
                        }
                    }
                } header: {
                    Text("Data")
                } footer: {
                    Text("Remove all custom ingredients and reset the database to its default state. This action cannot be undone.")
                }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("\(appVersion) (\(buildNumber))")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                } footer: {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("© 2025 Dawn DeMeo. All rights reserved.")

                        Text("Default ingredient conversions have been verified against authoritative sources including USDA FoodData Central and King Arthur Baking Company's ingredient weight chart.")

                        Text("Built with Claude Code")
                            .foregroundColor(.secondary)
                    }
                    .font(.caption)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert(
                "Reset to Default Ingredients?",
                isPresented: $showingResetConfirmation
            ) {
                Button("Reset Database", role: .destructive) {
                    resetDatabase()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will permanently delete all custom ingredients. Default ingredients will remain. This action cannot be undone.")
            }
        }
    }

    private func resetDatabase() {
        let fetchDescriptor = FetchDescriptor<Ingredient>(
            predicate: #Predicate { $0.isCustom == true }
        )

        do {
            let customIngredients = try modelContext.fetch(fetchDescriptor)
            for ingredient in customIngredients {
                modelContext.delete(ingredient)
            }
            try modelContext.save()
            print("✓ Deleted \(customIngredients.count) custom ingredients")
        } catch {
            print("❌ Error resetting database: \(error)")
        }
    }
}

#Preview {
    SettingsView()
}
