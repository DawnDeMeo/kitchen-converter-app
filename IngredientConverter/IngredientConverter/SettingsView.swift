//
//  SettingsView.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/12/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

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
    @AppStorage("defaultFromUnit") private var defaultFromUnitKey: String = "cup"
    @AppStorage("defaultToUnit") private var defaultToUnitKey: String = "gram"

    @State private var showingResetConfirmation = false
    @State private var showingShareSheet = false
    @State private var showingDocumentPicker = false
    @State private var exportURL: URL?
    @State private var showingImportAlert = false
    @State private var importMessage = ""

    private var defaultFromUnitBinding: Binding<MeasurementUnit> {
        Binding(
            get: { MeasurementUnit.fromStorageKey(self.defaultFromUnitKey) ?? .cup },
            set: { self.defaultFromUnitKey = $0.storageKey }
        )
    }

    private var defaultToUnitBinding: Binding<MeasurementUnit> {
        Binding(
            get: { MeasurementUnit.fromStorageKey(self.defaultToUnitKey) ?? .gram },
            set: { self.defaultToUnitKey = $0.storageKey }
        )
    }

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
                    Picker("From", selection: defaultFromUnitBinding) {
                        ForEach(MeasurementUnit.standardUnits, id: \.self) { unit in
                            Text(unit.fullDisplayName).tag(unit)
                        }
                    }

                    Picker("To", selection: defaultToUnitBinding) {
                        ForEach(MeasurementUnit.standardUnits, id: \.self) { unit in
                            Text(unit.fullDisplayName).tag(unit)
                        }
                    }
                } header: {
                    Text("Unit Preferences")
                } footer: {
                    Text("Set default units for conversions. These will be pre-selected when available for an ingredient.")
                }

                Section {
                    Button {
                        exportCustomIngredients()
                    } label: {
                        HStack {
                            Label("Export Custom Ingredients", systemImage: "square.and.arrow.up")
                            Spacer()
                        }
                    }

                    Button {
                        showingDocumentPicker = true
                    } label: {
                        HStack {
                            Label("Import Custom Ingredients", systemImage: "square.and.arrow.down")
                            Spacer()
                        }
                    }

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
                    Text("Export your custom ingredients to save a backup, or import ingredients from a JSON file.")
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

                        Text("Built with assistance from Claude Code")
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
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
            .sheet(isPresented: $showingDocumentPicker) {
                DocumentPicker { url in
                    importCustomIngredients(from: url)
                }
            }
            .alert("Import Result", isPresented: $showingImportAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(importMessage)
            }
        }
    }

    private func exportCustomIngredients() {
        let fetchDescriptor = FetchDescriptor<Ingredient>(
            predicate: #Predicate { $0.isCustom == true }
        )

        do {
            let customIngredients = try modelContext.fetch(fetchDescriptor)

            guard !customIngredients.isEmpty else {
                importMessage = "No custom ingredients to export."
                showingImportAlert = true
                return
            }

            // Convert to JSON format
            let ingredientsJSON = customIngredients.map { ingredient -> [String: Any] in
                var dict: [String: Any] = [
                    "name": ingredient.name,
                    "isCustom": true
                ]

                if let category = ingredient.category {
                    dict["category"] = category
                }

                if let brand = ingredient.brand {
                    dict["brand"] = brand
                }

                let conversions = ingredient.conversions.map { conversion -> [String: Any] in
                    var convDict: [String: Any] = [
                        "fromAmount": conversion.fromAmount,
                        "toAmount": conversion.toAmount
                    ]

                    // Convert fromUnit
                    convDict["fromUnit"] = unitToJSON(conversion.fromUnit)
                    convDict["toUnit"] = unitToJSON(conversion.toUnit)

                    return convDict
                }

                dict["conversions"] = conversions
                return dict
            }

            let exportData: [String: Any] = [
                "version": "1.0",
                "exportDate": ISO8601DateFormatter().string(from: Date()),
                "ingredients": ingredientsJSON
            ]

            let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)

            // Save to temp file
            let tempDir = FileManager.default.temporaryDirectory
            let fileName = "custom_ingredients_\(Date().timeIntervalSince1970).json"
            let fileURL = tempDir.appendingPathComponent(fileName)

            try jsonData.write(to: fileURL)

            exportURL = fileURL
            showingShareSheet = true

            print("✓ Exported \(customIngredients.count) custom ingredients")
        } catch {
            print("❌ Error exporting ingredients: \(error)")
            importMessage = "Failed to export ingredients: \(error.localizedDescription)"
            showingImportAlert = true
        }
    }

    private func importCustomIngredients(from url: URL) {
        // Request access to security-scoped resource
        guard url.startAccessingSecurityScopedResource() else {
            importMessage = "Failed to access the file. Please try again."
            showingImportAlert = true
            return
        }

        defer {
            url.stopAccessingSecurityScopedResource()
        }

        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

            guard let ingredientsArray = json?["ingredients"] as? [[String: Any]] else {
                throw NSError(domain: "Import", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format"])
            }

            var importedCount = 0

            for ingredientDict in ingredientsArray {
                guard let name = ingredientDict["name"] as? String else { continue }

                let category = ingredientDict["category"] as? String
                let brand = ingredientDict["brand"] as? String

                let newIngredient = Ingredient(
                    name: name,
                    category: category,
                    brand: brand,
                    isCustom: true
                )

                if let conversionsArray = ingredientDict["conversions"] as? [[String: Any]] {
                    for convDict in conversionsArray {
                        guard let fromAmount = convDict["fromAmount"] as? Double,
                              let toAmount = convDict["toAmount"] as? Double,
                              let fromUnit = jsonToUnit(convDict["fromUnit"]),
                              let toUnit = jsonToUnit(convDict["toUnit"]) else {
                            continue
                        }

                        let conversion = UnitConversion(
                            fromAmount: fromAmount,
                            fromUnit: fromUnit,
                            toAmount: toAmount,
                            toUnit: toUnit
                        )
                        newIngredient.conversions.append(conversion)
                    }
                }

                if !newIngredient.conversions.isEmpty {
                    modelContext.insert(newIngredient)
                    importedCount += 1
                }
            }

            try modelContext.save()

            importMessage = "Successfully imported \(importedCount) ingredient\(importedCount == 1 ? "" : "s")."
            showingImportAlert = true

            print("✓ Imported \(importedCount) custom ingredients")
        } catch {
            print("❌ Error importing ingredients: \(error)")
            importMessage = "Failed to import ingredients: \(error.localizedDescription)"
            showingImportAlert = true
        }
    }

    private func unitToJSON(_ unit: MeasurementUnit) -> Any {
        switch unit {
        case .count(let singular, let plural):
            return ["count": ["singular": singular, "plural": plural]]
        case .other(let name):
            return name
        case .teaspoon: return "teaspoon"
        case .tablespoon: return "tablespoon"
        case .cup: return "cup"
        case .pint: return "pint"
        case .quart: return "quart"
        case .gallon: return "gallon"
        case .liter: return "liter"
        case .centiliter: return "centiliter"
        case .milliliter: return "milliliter"
        case .fluidOunce: return "fluidounce"
        case .pound: return "pound"
        case .ounce: return "ounce"
        case .gram: return "gram"
        case .milligram: return "milligram"
        case .kilogram: return "kilogram"
        }
    }

    private func jsonToUnit(_ json: Any?) -> MeasurementUnit? {
        if let string = json as? String {
            switch string.lowercased() {
            case "teaspoon", "tsp": return .teaspoon
            case "tablespoon", "tbsp": return .tablespoon
            case "cup": return .cup
            case "pint", "pt": return .pint
            case "quart", "qt": return .quart
            case "gallon", "gal": return .gallon
            case "liter", "l": return .liter
            case "centiliter", "cl": return .centiliter
            case "milliliter", "ml": return .milliliter
            case "fluidounce", "fl oz", "floz": return .fluidOunce
            case "pound", "lb": return .pound
            case "ounce", "oz": return .ounce
            case "gram", "g": return .gram
            case "milligram", "mg": return .milligram
            case "kilogram", "kg": return .kilogram
            default: return .other(name: string)
            }
        } else if let dict = json as? [String: [String: String]],
                  let countDict = dict["count"],
                  let singular = countDict["singular"],
                  let plural = countDict["plural"] {
            return .count(singular: singular, plural: plural)
        }
        return nil
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

// MARK: - Helper Views

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct DocumentPicker: UIViewControllerRepresentable {
    let onPick: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void

        init(onPick: @escaping (URL) -> Void) {
            self.onPick = onPick
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onPick(url)
        }
    }
}

#Preview {
    SettingsView()
}
