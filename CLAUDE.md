# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Kitchen Unit Converter (internal name: IngredientConverter) is an iOS app (SwiftUI + SwiftData) that converts cooking ingredient measurements between volume, weight, and count units. The app includes a default database of ~100 common ingredients with verified conversions, plus support for user-added custom ingredients.

## Building & Testing

### Running Tests
```bash
cd IngredientConverter
xcodebuild test -scheme IngredientConverter -destination 'platform=iOS Simulator,name=iPhone 15'
```

Or run specific test files in Xcode:
- `IngredientConverterTests/ConversionEngineTests.swift` - Core conversion logic
- `IngredientConverterTests/DefaultIngredientDatabaseTests.swift` - Database loading
- `IngredientConverterTests/FractionParserTests.swift` - Fraction parsing
- `IngredientConverterTests/MeasurementUnitTests.swift` - Unit definitions
- `IngredientConverterTests/ConversionEdgeCaseTests.swift` - Edge cases

### Building the App
Open `IngredientConverter/IngredientConverter.xcodeproj` in Xcode and build normally (⌘B).

## Architecture

### Core Data Models (SwiftData)

**Ingredient** (`Ingredient.swift:12-31`)
- Properties: `id`, `name`, `brand`, `isFavorite`, `isCustom`, `lastUsedDate`
- Has many `UnitConversion` relationships (cascade delete)
- `isCustom` flag distinguishes user-added ingredients from defaults (critical for data updates)

**UnitConversion** (`UnitConversion.swift:12-29`)
- Stores conversion ratios: `fromAmount/fromUnit` → `toAmount/toUnit`
- Bidirectional: engine can apply conversions in forward or reverse
- Example: 1 cup flour → 120 grams

**MeasurementUnit** (`MeasurementUnit.swift:17-154`)
- Enum with volume (.cup, .tablespoon, etc.), weight (.gram, .ounce, etc.), count, and other
- Supports custom count units with singular/plural forms: `.count(singular: "clove", plural: "cloves")`
- Provides display names and handles pluralization

### Conversion Engine

**ConversionEngine** (`ConversionEngine.swift:10-146`)
- Strategy: Attempts conversions in order of complexity:
  1. Same unit → return as-is
  2. Same unit type (volume-to-volume or weight-to-weight) → use Foundation's `Measurement` API via `UnitConversionHelper`
  3. Direct conversion → finds matching `fromUnit → toUnit` in ingredient's conversions
  4. Reverse conversion → finds `toUnit → fromUnit` and reverses the math
  5. Chained conversion → uses BFS graph search to find multi-hop conversion paths (e.g., cup → gram → ounce)

**UnitConversionHelper** (`UnitConversionHelper.swift`)
- Wraps Foundation's `Measurement` API for standard volume/weight conversions
- Handles teaspoons ↔ tablespoons ↔ cups, grams ↔ ounces, etc.

### Default Ingredient Database

**Loading Process** (`IngredientConverterApp.swift:39-64`)
- On app launch, checks if database is empty
- If empty, loads from bundled `default_ingredients.json`
- JSON parsed via `DefaultIngredientDatabase.loadFromJSON()` → creates `Ingredient` objects with `isCustom = false`

**Important**: Default ingredients are ONLY loaded on first launch. To update defaults without overwriting user data, implement merge logic that:
- Only inserts new ingredients not present
- Only updates existing ingredients where `isCustom = false`
- Never touches ingredients where `isCustom = true`

See `updating_default_list.md` for detailed strategy.

### Data Generation Pipeline (Python)

**`IngredientConverterHelpers/generate_ingredient_database.py`**
- Creates curated list of ~100 cooking ingredients with conversions
- Outputs to `ingredient_database.xlsx`
- Sources: King Arthur Baking weight chart, USDA FoodData Central

**`IngredientConverterHelpers/convert_ingredients.py`**
- Converts Excel → JSON format for app bundle
- Run: `python convert_ingredients.py ingredient_database.xlsx default_ingredients.json`
- Output must be copied to `IngredientConverter/IngredientConverter/default_ingredients.json`

### UI Views

**IngredientListView** (`IngredientListView.swift`)
- Main screen showing all ingredients (searchable, filterable)
- Supports favorites and recently used sorting

**ConversionView** (`ConversionView.swift`)
- Ingredient conversion interface
- Uses `ConversionEngine` to perform conversions

**IngredientEditorView** (`IngredientEditorView.swift`)
- Add/edit ingredients and their conversions
- Sets `isCustom = true` for user-added ingredients

### Input Handling

**FractionParser** (`FractionParser.swift`)
- Parses strings like "1 1/2", "2/3", "0.5" → Double
- Handles mixed numbers, improper fractions, decimals

**AmountTextField** (`AmountTextField.swift`)
- Custom text field for ingredient amounts
- Integrates fraction parsing with keyboard accessory view

## Key Constraints

- `Ingredient.id` and `UnitConversion.id` are unique (UUIDs)
- SwiftData schema defined in `IngredientConverterApp.swift:14-17`
- Default ingredients must never be deleted during app updates (rely on `isCustom` flag)
