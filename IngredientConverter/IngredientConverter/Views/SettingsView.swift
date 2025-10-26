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
    @Environment(\.appColorScheme) private var colorScheme
    @Environment(ThemeManager.self) private var themeManager
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system
    @AppStorage("defaultFromUnit") private var defaultFromUnitKey: String = "cup"
    @AppStorage("defaultToUnit") private var defaultToUnitKey: String = "gram"

    @State private var showingResetConfirmation = false
    @State private var showingDeleteAllConfirmation = false
    @State private var showingShareSheet = false
    @State private var showingDocumentPicker = false
    @State private var exportURL: URL?
    @State private var showingImportAlert = false
    @State private var importMessage = ""
    @State private var cloudKitHelper = CloudKitHelper()

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
                            .foregroundColor(colorScheme.secondaryText)

                        Picker("Appearance", selection: $appearanceMode) {
                            ForEach(AppearanceMode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .background(
                            ThemedSegmentedPickerBackground(color: colorScheme.primary, textColor: colorScheme.buttonText)
                        )
                        .accessibilityLabel("Appearance mode")
                        .accessibilityValue(appearanceMode.rawValue)
                        .accessibilityHint("Choose between system, light, or dark mode")
                    }
                    .listRowBackground(colorScheme.cardBackground)
                } header: {
                    Text("Display")
                        .foregroundColor(colorScheme.secondary)
                } footer: {
                    Text("System will follow your device settings.")
                        .foregroundColor(colorScheme.secondaryText)
                }

                // MARK: - Color Scheme Selection
                Section {
                    Picker("Theme", selection: Binding(
                        get: { themeManager.currentScheme },
                        set: { themeManager.currentScheme = $0 }
                    )) {
                        ForEach(AppColorScheme.allSchemes) { scheme in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [scheme.primary, scheme.secondary],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Circle()
                                            .stroke(scheme.accent, lineWidth: 2)
                                    )
                                Text(scheme.name)
                                    .foregroundColor(colorScheme.primaryText)
                            }
                            .tag(scheme)
                        }
                    }
                    .listRowBackground(colorScheme.cardBackground)
                    .accessibilityLabel("Color scheme")
                    .accessibilityValue(themeManager.currentScheme.name)
                    .accessibilityHint("Choose a color theme for the app")
                } header: {
                    Text("Color Scheme")
                        .foregroundColor(colorScheme.secondary)
                } footer: {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(themeManager.currentScheme.primary)
                            .frame(width: 12, height: 12)
                        Text("Current theme: \(themeManager.currentScheme.name)")
                            .foregroundColor(colorScheme.secondaryText)
                    }
                }

                Section {
                    Picker("From", selection: defaultFromUnitBinding) {
                        ForEach(MeasurementUnit.standardUnits, id: \.self) { unit in
                            Text(unit.fullDisplayName).tag(unit)
                        }
                    }
                    .listRowBackground(colorScheme.cardBackground)

                    Picker("To", selection: defaultToUnitBinding) {
                        ForEach(MeasurementUnit.standardUnits, id: \.self) { unit in
                            Text(unit.fullDisplayName).tag(unit)
                        }
                    }
                    .listRowBackground(colorScheme.cardBackground)
                } header: {
                    Text("Unit Preferences")
                        .foregroundColor(colorScheme.secondary)
                } footer: {
                    Text("Set default units for conversions. These will be pre-selected when available for an ingredient.")
                        .foregroundColor(colorScheme.secondaryText)
                }

                Section {
                    Button {
                        exportCustomIngredients()
                    } label: {
                        HStack {
                            Label("Export Custom Ingredients", systemImage: "square.and.arrow.up")
                                .foregroundColor(colorScheme.primary)
                            Spacer()
                        }
                    }
                    .listRowBackground(colorScheme.cardBackground)

                    Button {
                        showingDocumentPicker = true
                    } label: {
                        HStack {
                            Label("Import Custom Ingredients", systemImage: "square.and.arrow.down")
                                .foregroundColor(colorScheme.primary)
                            Spacer()
                        }
                    }
                    .listRowBackground(colorScheme.cardBackground)

                    Button(role: .destructive) {
                        showingDeleteAllConfirmation = true
                    } label: {
                        HStack {
                            Label("Delete All Ingredients (Debug)", systemImage: "trash")
                                .foregroundColor(colorScheme.error)
                            Spacer()
                        }
                    }
                    .listRowBackground(colorScheme.error.opacity(0.05))

                    Button(role: .destructive) {
                        showingResetConfirmation = true
                    } label: {
                        HStack {
                            Label("Reset to Default Ingredients", systemImage: "arrow.counterclockwise")
                                .foregroundColor(colorScheme.error)
                            Spacer()
                        }
                    }
                    .listRowBackground(colorScheme.error.opacity(0.05))
                } header: {
                    Text("Data")
                        .foregroundColor(colorScheme.secondary)
                } footer: {
                    Text("Export your custom ingredients to save a backup, or import ingredients from a JSON file.")
                        .foregroundColor(colorScheme.secondaryText)
                }

                Section {
                    HStack {
                        Label("iCloud Sync", systemImage: cloudKitHelper.iCloudAvailable ? "icloud.fill" : "icloud.slash")
                            .foregroundColor(colorScheme.primaryText)
                        Spacer()
                        if cloudKitHelper.iCloudAvailable {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(colorScheme.accent)
                        } else {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(colorScheme.warning)
                        }
                    }
                    .listRowBackground(colorScheme.cardBackground)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("iCloud Sync: \(cloudKitHelper.iCloudAvailable ? "Available" : "Unavailable")")
                    .accessibilityValue(cloudKitHelper.statusMessage)
                } header: {
                    Text("iCloud")
                        .foregroundColor(colorScheme.secondary)
                } footer: {
                    Text(cloudKitHelper.statusMessage)
                        .foregroundColor(cloudKitHelper.iCloudAvailable ? colorScheme.secondaryText : colorScheme.warning)
                }

                Section {
                    NavigationLink {
                        HelpView()
                    } label: {
                        Label("Help & FAQ", systemImage: "questionmark.circle")
                            .foregroundColor(colorScheme.primary)
                    }
                    .listRowBackground(colorScheme.cardBackground)

                    Link(destination: URL(string: "mailto:dawndemeoapps@gmail.com?subject=Ingredient%20Converter%20Feedback")!) {
                        HStack {
                            Label("Send Feedback", systemImage: "envelope")
                                .foregroundColor(colorScheme.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(colorScheme.secondaryText)
                        }
                    }
                    .listRowBackground(colorScheme.cardBackground)
                } header: {
                    Text("Support")
                        .foregroundColor(colorScheme.secondary)
                } footer: {
                    Text("Get help using the app or send us feedback.")
                        .foregroundColor(colorScheme.secondaryText)
                }

                Section {
                    HStack {
                        Text("Version")
                            .foregroundColor(colorScheme.primaryText)
                        Spacer()
                        Text("\(appVersion) (\(buildNumber))")
                            .foregroundColor(colorScheme.secondaryText)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(colorScheme.secondary.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    .listRowBackground(colorScheme.cardBackground)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Version \(appVersion), build \(buildNumber)")
                } header: {
                    Text("About")
                        .foregroundColor(colorScheme.secondary)
                } footer: {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("© 2025 Dawn DeMeo. All rights reserved.")
                            .foregroundColor(colorScheme.primaryText)

                        Text("Default ingredient conversions have been verified against authoritative sources including USDA FoodData Central and King Arthur Baking Company's ingredient weight chart.")
                            .foregroundColor(colorScheme.secondaryText)

                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.caption2)
                            Text("Built with assistance from Claude Code")
                        }
                        .foregroundColor(colorScheme.accent)
                    }
                    .font(.caption)
                }
            }
            .scrollContentBackground(.hidden)
            .background(colorScheme.background)
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
            .alert(
                "Delete All Ingredients?",
                isPresented: $showingDeleteAllConfirmation
            ) {
                Button("Delete All", role: .destructive) {
                    deleteAllIngredients()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("⚠️ DEBUG TOOL: This will delete ALL ingredients (including defaults) from this device AND iCloud. Use this to clear duplicate data. The app will reload defaults on next launch. Cannot be undone!")
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

                let conversions = (ingredient.conversions ?? []).compactMap { conversion -> [String: Any]? in
                    // Skip conversions with missing units
                    guard let fromUnit = conversion.fromUnit,
                          let toUnit = conversion.toUnit else {
                        return nil
                    }

                    var convDict: [String: Any] = [
                        "fromAmount": conversion.fromAmount,
                        "toAmount": conversion.toAmount
                    ]

                    // Convert fromUnit
                    convDict["fromUnit"] = unitToJSON(fromUnit)
                    convDict["toUnit"] = unitToJSON(toUnit)

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

            // Fetch existing CUSTOM ingredients to check for duplicates
            // (Allow importing custom ingredients even if default versions exist)
            let fetchDescriptor = FetchDescriptor<Ingredient>(
                predicate: #Predicate<Ingredient> { ingredient in
                    ingredient.isCustom == true
                }
            )
            let existingCustomIngredients = try modelContext.fetch(fetchDescriptor)

            // Create a map of existing custom ingredient names (case-insensitive) for quick lookup
            var existingCustomNames = Set<String>()
            for ingredient in existingCustomIngredients {
                existingCustomNames.insert(ingredient.name.lowercased())
            }

            var importedCount = 0
            var skippedCount = 0

            for ingredientDict in ingredientsArray {
                guard let name = ingredientDict["name"] as? String else { continue }

                // Check if custom ingredient with this name already exists (case-insensitive)
                if existingCustomNames.contains(name.lowercased()) {
                    skippedCount += 1
                    print("⏭️ Skipping duplicate custom ingredient: \(name)")
                    continue
                }

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
                        // Initialize conversions array if nil
                        if newIngredient.conversions == nil {
                            newIngredient.conversions = []
                        }
                        newIngredient.conversions?.append(conversion)
                    }
                }

                if !(newIngredient.conversions ?? []).isEmpty {
                    modelContext.insert(newIngredient)
                    existingCustomNames.insert(name.lowercased()) // Add to set for subsequent checks
                    importedCount += 1
                }
            }

            try modelContext.save()

            // Build result message
            var message = "Successfully imported \(importedCount) ingredient\(importedCount == 1 ? "" : "s")."
            if skippedCount > 0 {
                message += " Skipped \(skippedCount) duplicate\(skippedCount == 1 ? "" : "s")."
            }

            importMessage = message
            showingImportAlert = true

            print("✓ Imported \(importedCount) custom ingredients, skipped \(skippedCount) duplicates")
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

    private func deleteAllIngredients() {
        let fetchDescriptor = FetchDescriptor<Ingredient>()

        do {
            let allIngredients = try modelContext.fetch(fetchDescriptor)
            print("🗑️ Deleting \(allIngredients.count) ingredients from local database and iCloud...")

            for ingredient in allIngredients {
                modelContext.delete(ingredient)
            }

            try modelContext.save()
            print("✅ Successfully deleted all ingredients. CloudKit will propagate deletions.")

            // Reset the flags so defaults reload on next launch
            UserDefaults.standard.set(0, forKey: "defaultIngredientsDatabaseVersion")
            UserDefaults.standard.set(false, forKey: "hasLoadedDefaultIngredientsOnce")
            print("🔄 Reset database flags. Defaults will reload on next launch.")
        } catch {
            print("❌ Error deleting all ingredients: \(error)")
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

// Helper view to theme segmented pickers
struct ThemedSegmentedPickerBackground: UIViewRepresentable {
    let color: Color
    let textColor: Color

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear

        // Configure segmented control appearance
        DispatchQueue.main.async {
            UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(self.color)
            UISegmentedControl.appearance().setTitleTextAttributes(
                [.foregroundColor: UIColor(self.textColor)],
                for: .selected
            )
            UISegmentedControl.appearance().setTitleTextAttributes(
                [.foregroundColor: UIColor(self.color)],
                for: .normal
            )
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update appearance when color changes
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(color)
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor(textColor)],
            for: .selected
        )
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor(color)],
            for: .normal
        )
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Ingredient.self, configurations: config)

    return SettingsView()
        .modelContainer(container)
        .environment(ThemeManager())
}
